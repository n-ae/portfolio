// Enhanced server with router and middleware
//
// This is the new main server entry point using the router
// and middleware architecture for better maintainability.

const std = @import("std");
const dotenv = @import("../dotenv.zig");
const router_mod = @import("router.zig");
const middleware = struct {
    const cors = @import("middleware/cors.zig");
    const logging = @import("middleware/logging.zig");
    const auth = @import("middleware/auth.zig");
    const rate_limit = @import("middleware/rate_limit.zig");
};
const handlers = struct {
    const health = @import("handlers/health.zig");
    const fantasy = @import("handlers/fantasy.zig");
};
const logging = @import("../yahoo_fantasy/logging.zig");

const Server = struct {
    allocator: std.mem.Allocator,
    router: router_mod.Router,
    rate_limiter: *middleware.rate_limit.RateLimitMiddleware,
    
    const Self = @This();
    
    pub fn init(allocator: std.mem.Allocator) !Self {
        var router = router_mod.Router.init(allocator);
        
        // Create rate limiter
        const rate_limit_config = middleware.rate_limit.RateLimitConfig{
            .requests_per_minute = 100.0,
            .burst_size = 20.0,
        };
        const rate_limiter = try middleware.rate_limit.rateLimitMiddleware(allocator, rate_limit_config);
        
        // Setup global middleware (applied to all routes)
        try router.use(middleware.logging.requestLogger);
        try router.use(middleware.cors.defaultCors);
        
        // Setup routes
        try setupRoutes(&router, rate_limiter);
        
        return Self{
            .allocator = allocator,
            .router = router,
            .rate_limiter = rate_limiter,
        };
    }
    
    pub fn deinit(self: *Self) void {
        self.router.deinit();
        self.rate_limiter.deinit();
        self.allocator.destroy(self.rate_limiter);
    }
    
    fn setupRoutes(router: *router_mod.Router, rate_limiter: *middleware.rate_limit.RateLimitMiddleware) !void {
        // Health and system endpoints (no auth required)
        try router.get("/health", handlers.health.healthCheck);
        try router.get("/health/ready", handlers.health.readinessCheck);
        try router.get("/health/live", handlers.health.livenessCheck);
        try router.get("/status", handlers.health.statusInfo);
        try router.get("/metrics", handlers.health.metricsEndpoint);
        
        // Fantasy API endpoints (with rate limiting)
        const rate_limit_middleware = struct {
            limiter: *middleware.rate_limit.RateLimitMiddleware,
            
            fn middleware(self: @This(), ctx: *router_mod.Context, next: router_mod.Handler) !void {
                try self.limiter.middleware(ctx, next);
            }
        }{ .limiter = rate_limiter };
        
        // For development, we'll skip authentication but keep rate limiting
        const api_middlewares = [_]router_mod.Middleware{
            rate_limit_middleware.middleware,
            middleware.auth.devAuth, // Replace with real auth in production
        };
        
        try router.getWithMiddleware("/api/v1/games", handlers.fantasy.getGames, &api_middlewares);
        try router.getWithMiddleware("/api/v1/games/{id}", handlers.fantasy.getGame, &api_middlewares);
        try router.getWithMiddleware("/api/v1/leagues", handlers.fantasy.getLeagues, &api_middlewares);
        try router.getWithMiddleware("/api/v1/leagues/{id}", handlers.fantasy.getLeague, &api_middlewares);
        try router.getWithMiddleware("/api/v1/leagues/{id}/teams", handlers.fantasy.getLeagueTeams, &api_middlewares);
        try router.getWithMiddleware("/api/v1/players/search", handlers.fantasy.searchPlayers, &api_middlewares);
        
        logging.info("Routes configured successfully", .{});
    }
    
    pub fn handleConnection(self: *Self, connection: std.net.Server.Connection) !void {
        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const arena_allocator = arena.allocator();
        
        // Read request
        var buffer: [8192]u8 = undefined;
        const bytes_read = try connection.stream.read(buffer[0..]);
        
        if (bytes_read == 0) return;
        
        const request_data = buffer[0..bytes_read];
        
        // Parse HTTP request
        var request = try parseHttpRequest(arena_allocator, request_data);
        defer request.deinit();
        
        // Create mock response (simplified for this implementation)
        var response = MockResponse.init(arena_allocator, connection.stream.writer());
        
        // Create context
        var ctx = router_mod.Context.init(arena_allocator, &request, &response);
        defer ctx.deinit();
        
        // Dispatch to router
        self.router.dispatch(&ctx) catch |err| {
            logging.err("Router dispatch error: {}", .{err});
            ctx.internalServerError("Internal server error") catch {};
        };
    }
};

// Simplified HTTP request parser
const MockRequest = struct {
    method: std.http.Method,
    target: []const u8,
    headers: std.http.Headers,
    allocator: std.mem.Allocator,
    
    fn init(allocator: std.mem.Allocator, method: std.http.Method, target: []const u8) MockRequest {
        return MockRequest{
            .method = method,
            .target = target,
            .headers = std.http.Headers.init(allocator),
            .allocator = allocator,
        };
    }
    
    fn deinit(self: *MockRequest) void {
        self.headers.deinit();
    }
};

const MockResponse = struct {
    status: std.http.Status = .ok,
    headers: std.http.Headers,
    writer: std.fs.File.Writer,
    allocator: std.mem.Allocator,
    headers_sent: bool = false,
    
    fn init(allocator: std.mem.Allocator, writer: std.fs.File.Writer) MockResponse {
        return MockResponse{
            .headers = std.http.Headers.init(allocator),
            .writer = writer,
            .allocator = allocator,
        };
    }
    
    fn writeAll(self: *MockResponse, data: []const u8) !void {
        if (!self.headers_sent) {
            try self.sendHeaders();
        }
        try self.writer.writeAll(data);
    }
    
    fn sendHeaders(self: *MockResponse) !void {
        if (self.headers_sent) return;
        
        // Send status line
        const status_line = try std.fmt.allocPrint(
            self.allocator,
            "HTTP/1.1 {d} {s}\r\n",
            .{ @intFromEnum(self.status), @tagName(self.status) }
        );
        defer self.allocator.free(status_line);
        try self.writer.writeAll(status_line);
        
        // Send headers
        var iterator = self.headers.iterator();
        while (iterator.next()) |entry| {
            const header_line = try std.fmt.allocPrint(
                self.allocator,
                "{s}: {s}\r\n",
                .{ entry.name, entry.value }
            );
            defer self.allocator.free(header_line);
            try self.writer.writeAll(header_line);
        }
        
        // End headers
        try self.writer.writeAll("\r\n");
        self.headers_sent = true;
    }
};

fn parseHttpRequest(allocator: std.mem.Allocator, request_data: []const u8) !MockRequest {
    var lines = std.mem.splitSequence(u8, request_data, "\r\n");
    const request_line = lines.next() orelse return error.InvalidRequest;
    
    var parts = std.mem.splitSequence(u8, request_line, " ");
    const method_str = parts.next() orelse return error.InvalidRequest;
    const target = parts.next() orelse return error.InvalidRequest;
    
    const method = parseMethod(method_str) orelse return error.InvalidMethod;
    
    var request = MockRequest.init(allocator, method, target);
    
    // Parse headers (simplified)
    while (lines.next()) |line| {
        if (line.len == 0) break; // End of headers
        
        if (std.mem.indexOf(u8, line, ":")) |colon_pos| {
            const name = std.mem.trim(u8, line[0..colon_pos], " \t");
            const value = std.mem.trim(u8, line[colon_pos + 1..], " \t");
            try request.headers.append(name, value);
        }
    }
    
    return request;
}

fn parseMethod(method_str: []const u8) ?std.http.Method {
    if (std.mem.eql(u8, method_str, "GET")) return .GET;
    if (std.mem.eql(u8, method_str, "POST")) return .POST;
    if (std.mem.eql(u8, method_str, "PUT")) return .PUT;
    if (std.mem.eql(u8, method_str, "DELETE")) return .DELETE;
    if (std.mem.eql(u8, method_str, "OPTIONS")) return .OPTIONS;
    return null;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Load environment variables
    var env = dotenv.DotEnv.init(allocator);
    defer env.deinit();
    try env.load();
    
    // Initialize logging
    logging.info("Enhanced Yahoo Fantasy API Server Starting...", .{});
    
    // Get port from environment
    const port_str = env.get("PORT") orelse "8080";
    const port = std.fmt.parseInt(u16, port_str, 10) catch 8080;
    
    // Initialize server
    var server = try Server.init(allocator);
    defer server.deinit();
    
    // Start listening
    const address = std.net.Address.initIp4([4]u8{ 0, 0, 0, 0 }, port);
    var listener = try address.listen(.{ .reuse_address = true });
    defer listener.deinit();
    
    logging.info("Server listening on http://0.0.0.0:{d}", .{port});
    logging.info("Available endpoints:", .{});
    logging.info("  GET /health - Basic health check", .{});
    logging.info("  GET /health/ready - Readiness probe", .{});
    logging.info("  GET /health/live - Liveness probe", .{});
    logging.info("  GET /status - Server status and info", .{});
    logging.info("  GET /metrics - Prometheus metrics", .{});
    logging.info("  GET /api/v1/games - Available fantasy games", .{});
    logging.info("  GET /api/v1/games/{{id}} - Game details", .{});
    logging.info("  GET /api/v1/leagues - User leagues (requires auth)", .{});
    logging.info("  GET /api/v1/leagues/{{id}} - League details", .{});
    logging.info("  GET /api/v1/leagues/{{id}}/teams - League teams", .{});
    logging.info("  GET /api/v1/players/search?q={{name}} - Search players", .{});
    
    while (true) {
        const connection = try listener.accept();
        defer connection.stream.close();
        
        server.handleConnection(connection) catch |err| {
            logging.err("Error handling connection: {}", .{err});
        };
    }
}

test "server initialization" {
    const allocator = std.testing.allocator;
    
    var server = try Server.init(allocator);
    defer server.deinit();
    
    // Server should initialize without errors
    try std.testing.expect(server.router.routes.items.len > 0);
}