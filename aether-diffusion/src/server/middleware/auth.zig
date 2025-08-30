// Authentication middleware
//
// This middleware handles API key authentication and rate limiting
// for protected endpoints.

const std = @import("std");
const Context = @import("../router.zig").Context;
const Handler = @import("../router.zig").Handler;
const logging = @import("../../yahoo_fantasy/logging.zig");

const API_KEY_HEADER = "X-API-Key";
const AUTH_HEADER = "Authorization";

pub const AuthConfig = struct {
    api_keys: []const []const u8,
    require_auth: bool = true,
    
    pub fn isValidApiKey(self: AuthConfig, key: []const u8) bool {
        for (self.api_keys) |valid_key| {
            if (std.mem.eql(u8, valid_key, key)) {
                return true;
            }
        }
        return false;
    }
};

pub fn apiKeyAuth(config: AuthConfig) fn(*Context, Handler) anyerror!void {
    return struct {
        fn middleware(ctx: *Context, next: Handler) !void {
            if (!config.require_auth) {
                return next(ctx);
            }
            
            // Try to get API key from header
            const api_key = ctx.request.headers.getFirstValue(API_KEY_HEADER);
            
            if (api_key == null) {
                const request_context = logging.LogContext{}
                    .with("endpoint", ctx.request.target);
                
                logging.warnCtx(request_context, "Missing API key in request", .{});
                
                ctx.status(401);
                try ctx.json(.{
                    .error = "Unauthorized",
                    .message = "API key required. Include X-API-Key header.",
                });
                return;
            }
            
            if (!config.isValidApiKey(api_key.?)) {
                const request_context = logging.LogContext{}
                    .with("endpoint", ctx.request.target);
                
                logging.warnCtx(request_context, "Invalid API key in request", .{});
                
                ctx.status(401);
                try ctx.json(.{
                    .error = "Unauthorized", 
                    .message = "Invalid API key",
                });
                return;
            }
            
            // API key is valid, continue to next middleware/handler
            try next(ctx);
        }
    }.middleware;
}

pub fn bearerAuth(valid_tokens: []const []const u8) fn(*Context, Handler) anyerror!void {
    return struct {
        fn middleware(ctx: *Context, next: Handler) !void {
            const auth_header = ctx.request.headers.getFirstValue(AUTH_HEADER);
            
            if (auth_header == null) {
                ctx.status(401);
                try ctx.json(.{
                    .error = "Unauthorized",
                    .message = "Authorization header required",
                });
                return;
            }
            
            const auth_value = auth_header.?;
            
            if (!std.mem.startsWith(u8, auth_value, "Bearer ")) {
                ctx.status(401);
                try ctx.json(.{
                    .error = "Unauthorized",
                    .message = "Bearer token required",
                });
                return;
            }
            
            const token = auth_value[7..]; // Skip "Bearer "
            
            var token_valid = false;
            for (valid_tokens) |valid_token| {
                if (std.mem.eql(u8, valid_token, token)) {
                    token_valid = true;
                    break;
                }
            }
            
            if (!token_valid) {
                const request_context = logging.LogContext{}
                    .with("endpoint", ctx.request.target);
                
                logging.warnCtx(request_context, "Invalid bearer token in request", .{});
                
                ctx.status(401);
                try ctx.json(.{
                    .error = "Unauthorized",
                    .message = "Invalid bearer token",
                });
                return;
            }
            
            try next(ctx);
        }
    }.middleware;
}

// Optional auth middleware - allows requests with or without auth
pub fn optionalAuth(config: AuthConfig) fn(*Context, Handler) anyerror!void {
    return struct {
        fn middleware(ctx: *Context, next: Handler) !void {
            const api_key = ctx.request.headers.getFirstValue(API_KEY_HEADER);
            
            if (api_key) |key| {
                if (!config.isValidApiKey(key)) {
                    ctx.status(401);
                    try ctx.json(.{
                        .error = "Unauthorized",
                        .message = "Invalid API key",
                    });
                    return;
                }
                // Valid API key provided - mark context as authenticated
                // You could store user info in ctx.user_data here
            }
            
            // Continue regardless of auth status
            try next(ctx);
        }
    }.middleware;
}

// Development-only middleware that bypasses auth
pub fn devAuth(ctx: *Context, next: Handler) !void {
    const request_context = logging.LogContext{}
        .with("endpoint", ctx.request.target);
    
    logging.debugCtx(request_context, "Development mode - skipping authentication", .{});
    
    try next(ctx);
}

test "auth config API key validation" {
    const config = AuthConfig{
        .api_keys = &[_][]const u8{ "test-key-1", "test-key-2" },
    };
    
    try std.testing.expect(config.isValidApiKey("test-key-1"));
    try std.testing.expect(config.isValidApiKey("test-key-2"));
    try std.testing.expect(!config.isValidApiKey("invalid-key"));
    try std.testing.expect(!config.isValidApiKey(""));
}