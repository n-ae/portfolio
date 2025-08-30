// Rate limiting middleware
//
// This middleware provides per-client rate limiting using
// token bucket algorithm for API endpoints.

const std = @import("std");
const Context = @import("../router.zig").Context;
const Handler = @import("../router.zig").Handler;
const RateLimiter = @import("../../yahoo_fantasy/rate_limiter.zig").RateLimiter;
const logging = @import("../../yahoo_fantasy/logging.zig");

const ClientLimiter = struct {
    limiter: RateLimiter,
    last_used: i64,
};

pub const RateLimitConfig = struct {
    requests_per_minute: f64 = 60.0,
    burst_size: f64 = 10.0,
    cleanup_interval: i64 = 300, // 5 minutes
    
    pub fn createLimiter(self: RateLimitConfig) RateLimiter {
        const refill_rate = self.requests_per_minute / 60.0; // per second
        return RateLimiter.init(self.burst_size, refill_rate);
    }
};

pub const RateLimitMiddleware = struct {
    config: RateLimitConfig,
    client_limiters: std.StringHashMap(ClientLimiter),
    mutex: std.Thread.Mutex,
    last_cleanup: i64,
    allocator: std.mem.Allocator,
    
    const Self = @This();
    
    pub fn init(allocator: std.mem.Allocator, config: RateLimitConfig) Self {
        return Self{
            .config = config,
            .client_limiters = std.StringHashMap(ClientLimiter).init(allocator),
            .mutex = std.Thread.Mutex{},
            .last_cleanup = std.time.timestamp(),
            .allocator = allocator,
        };
    }
    
    pub fn deinit(self: *Self) void {
        self.client_limiters.deinit();
    }
    
    pub fn middleware(self: *Self, ctx: *Context, next: Handler) !void {
        const client_id = self.getClientId(ctx);
        defer self.allocator.free(client_id);
        
        // Periodic cleanup
        self.cleanupOldClients();
        
        self.mutex.lock();
        defer self.mutex.unlock();
        
        const now = std.time.timestamp();
        
        // Get or create client limiter
        const entry = self.client_limiters.getPtr(client_id);
        var client_limiter: *ClientLimiter = undefined;
        
        if (entry) |existing| {
            existing.last_used = now;
            client_limiter = existing;
        } else {
            const new_limiter = ClientLimiter{
                .limiter = self.config.createLimiter(),
                .last_used = now,
            };
            try self.client_limiters.put(try self.allocator.dupe(u8, client_id), new_limiter);
            client_limiter = self.client_limiters.getPtr(client_id).?;
        }
        
        // Check rate limit
        if (!client_limiter.limiter.canMakeRequest()) {
            const wait_time = client_limiter.limiter.getWaitTime();
            const remaining_tokens = client_limiter.limiter.getRemainingTokens();
            
            const request_context = logging.LogContext{}
                .with("endpoint", ctx.request.target)
                .with("client_id", client_id);
            
            logging.warnCtx(request_context, "Rate limit exceeded, wait_time={d}ms", .{wait_time});
            
            ctx.status(429);
            
            // Add rate limit headers
            const wait_time_str = try std.fmt.allocPrint(ctx.allocator, "{d}", .{wait_time / 1000}); // seconds
            defer ctx.allocator.free(wait_time_str);
            
            const remaining_str = try std.fmt.allocPrint(ctx.allocator, "{d}", .{@as(u32, @intFromFloat(remaining_tokens))});
            defer ctx.allocator.free(remaining_str);
            
            const limit_str = try std.fmt.allocPrint(ctx.allocator, "{d}", .{@as(u32, @intFromFloat(self.config.burst_size))});
            defer ctx.allocator.free(limit_str);
            
            try ctx.response.headers.append("X-RateLimit-Limit", limit_str);
            try ctx.response.headers.append("X-RateLimit-Remaining", remaining_str);
            try ctx.response.headers.append("Retry-After", wait_time_str);
            
            try ctx.json(.{
                .error = "Too Many Requests",
                .message = "Rate limit exceeded. Please try again later.",
                .retry_after_seconds = wait_time / 1000,
            });
            return;
        }
        
        // Add rate limit headers for successful requests
        const remaining_tokens = client_limiter.limiter.getRemainingTokens();
        const remaining_str = try std.fmt.allocPrint(ctx.allocator, "{d}", .{@as(u32, @intFromFloat(remaining_tokens))});
        defer ctx.allocator.free(remaining_str);
        
        const limit_str = try std.fmt.allocPrint(ctx.allocator, "{d}", .{@as(u32, @intFromFloat(self.config.burst_size))});
        defer ctx.allocator.free(limit_str);
        
        try ctx.response.headers.append("X-RateLimit-Limit", limit_str);
        try ctx.response.headers.append("X-RateLimit-Remaining", remaining_str);
        
        // Continue to next middleware/handler
        try next(ctx);
    }
    
    fn getClientId(self: *Self, ctx: *Context) ![]u8 {
        // Try to use API key as client ID
        if (ctx.request.headers.getFirstValue("X-API-Key")) |api_key| {
            return self.allocator.dupe(u8, api_key);
        }
        
        // Try to use Authorization header
        if (ctx.request.headers.getFirstValue("Authorization")) |auth| {
            return self.allocator.dupe(u8, auth);
        }
        
        // Fall back to a generic client ID (this could be IP address in a real implementation)
        return self.allocator.dupe(u8, "anonymous");
    }
    
    fn cleanupOldClients(self: *Self) void {
        const now = std.time.timestamp();
        
        if (now - self.last_cleanup < self.config.cleanup_interval) {
            return;
        }
        
        self.mutex.lock();
        defer self.mutex.unlock();
        
        var keys_to_remove = std.ArrayList([]const u8).init(self.allocator);
        defer {
            for (keys_to_remove.items) |key| {
                self.allocator.free(key);
            }
            keys_to_remove.deinit();
        }
        
        var iterator = self.client_limiters.iterator();
        while (iterator.next()) |entry| {
            if (now - entry.value_ptr.last_used > self.config.cleanup_interval) {
                keys_to_remove.append(try self.allocator.dupe(u8, entry.key_ptr.*)) catch continue;
            }
        }
        
        for (keys_to_remove.items) |key| {
            if (self.client_limiters.fetchRemove(key)) |removed| {
                self.allocator.free(removed.key);
            }
        }
        
        self.last_cleanup = now;
        
        if (keys_to_remove.items.len > 0) {
            logging.debug("Cleaned up {d} inactive rate limit clients", .{keys_to_remove.items.len});
        }
    }
};

// Create rate limit middleware instance
pub fn rateLimitMiddleware(allocator: std.mem.Allocator, config: RateLimitConfig) !*RateLimitMiddleware {
    const middleware = try allocator.create(RateLimitMiddleware);
    middleware.* = RateLimitMiddleware.init(allocator, config);
    return middleware;
}

// Default rate limiting (60 requests per minute)
pub fn defaultRateLimit(allocator: std.mem.Allocator) !*RateLimitMiddleware {
    const config = RateLimitConfig{};
    return rateLimitMiddleware(allocator, config);
}

// Strict rate limiting (30 requests per minute)
pub fn strictRateLimit(allocator: std.mem.Allocator) !*RateLimitMiddleware {
    const config = RateLimitConfig{
        .requests_per_minute = 30.0,
        .burst_size = 5.0,
    };
    return rateLimitMiddleware(allocator, config);
}

test "rate limit config creates limiter" {
    const config = RateLimitConfig{
        .requests_per_minute = 60.0,
        .burst_size = 10.0,
    };
    
    var limiter = config.createLimiter();
    
    // Should allow initial requests up to burst size
    try std.testing.expect(limiter.canMakeRequest());
    try std.testing.expect(limiter.getRemainingTokens() < 10.0);
}