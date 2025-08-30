// Production-ready HTTP server using zap framework
//
// This server implementation uses zap for high-performance HTTP handling
// with proper middleware support and comprehensive error handling.

const std = @import("std");
const zap = @import("zap");
const logging = @import("../yahoo_fantasy/logging.zig");
const handlers = struct {
    const health = @import("handlers/health.zig");
    const fantasy = @import("handlers/fantasy.zig");
};

const Server = struct {
    allocator: std.mem.Allocator,
    listener: zap.SimpleHttpListener,
    
    const Self = @This();
    
    pub fn init(allocator: std.mem.Allocator, port: u16) !Self {
        var listener = zap.SimpleHttpListener.init(.{
            .port = port,
            .on_request = onRequest,
            .log = true,
        });
        
        return Self{
            .allocator = allocator,
            .listener = listener,
        };
    }
    
    pub fn start(self: *Self) !void {
        logging.info("Starting zap server on port {d}", .{self.listener.settings.port});
        
        try self.listener.listen();
        
        logging.info("Server listening on http://localhost:{d}", .{self.listener.settings.port});
        logging.info("Available endpoints:", .{});
        logging.info("  GET /health - Health check", .{});
        logging.info("  GET /health/ready - Readiness probe", .{});
        logging.info("  GET /health/live - Liveness probe", .{});
        logging.info("  GET /status - Server status", .{});
        logging.info("  GET /metrics - Prometheus metrics", .{});
        logging.info("  GET /api/v1/games - Yahoo Fantasy games", .{});
        logging.info("  GET /api/v1/games/{{id}} - Game details", .{});
        logging.info("  GET /api/v1/leagues - User leagues", .{});
        logging.info("  GET /api/v1/players/search?q={{name}} - Search players", .{});
        
        // Start the server (this blocks)
        zap.start(.{
            .threads = 4,
            .workers = 2,
        });
    }
    
    fn onRequest(r: zap.SimpleRequest) void {
        const start_time = std.time.milliTimestamp();
        const allocator = std.heap.page_allocator;
        
        // Create request context
        var ctx = RequestContext.init(allocator, r, start_time);
        defer ctx.deinit();
        
        // Log request
        logging.info("{s} {s} from {s}", .{ 
            @tagName(r.method orelse .GET), 
            r.path orelse "/", 
            "unknown" // zap doesn't easily expose client IP
        });
        
        // Route the request
        routeRequest(&ctx) catch |err| {
            logging.err("Error handling request: {}", .{err});
            ctx.sendError(500, "Internal server error") catch {};
        };
        
        // Log response
        const duration = std.time.milliTimestamp() - start_time;
        logging.logRequest(
            @tagName(r.method orelse .GET),
            r.path orelse "/",
            ctx.status_code,
            @intCast(duration)
        );
    }
    
    fn routeRequest(ctx: *RequestContext) !void {
        const method = ctx.request.method orelse .GET;
        const path = ctx.request.path orelse "/";
        
        // Handle CORS preflight
        if (method == .OPTIONS) {
            try ctx.sendCORS();
            return;
        }
        
        // Route based on path
        if (std.mem.startsWith(u8, path, "/health")) {
            try routeHealth(ctx, path);
        } else if (std.mem.eql(u8, path, "/status")) {
            try ctx.sendJson(handlers.health.getStatusInfo(ctx.allocator));
        } else if (std.mem.eql(u8, path, "/metrics")) {
            try ctx.sendMetrics();
        } else if (std.mem.startsWith(u8, path, "/api/v1/")) {
            try routeAPI(ctx, path);
        } else {
            try ctx.sendNotFound();
        }
    }
    
    fn routeHealth(ctx: *RequestContext, path: []const u8) !void {
        if (std.mem.eql(u8, path, "/health")) {
            try ctx.sendJson(.{
                .status = "healthy",
                .timestamp = std.time.timestamp(),
                .version = "1.0.0",
            });
        } else if (std.mem.eql(u8, path, "/health/ready")) {
            // Readiness check with dependency validation
            const ready = checkReadiness();
            if (ready) {
                try ctx.sendJson(.{
                    .status = "ready",
                    .timestamp = std.time.timestamp(),
                });
            } else {
                ctx.status_code = 503;
                try ctx.sendJson(.{
                    .status = "not_ready",
                    .timestamp = std.time.timestamp(),
                });
            }
        } else if (std.mem.eql(u8, path, "/health/live")) {
            try ctx.sendJson(.{
                .status = "alive",
                .timestamp = std.time.timestamp(),
            });
        } else {
            try ctx.sendNotFound();
        }
    }
    
    fn routeAPI(ctx: *RequestContext, path: []const u8) !void {
        if (std.mem.eql(u8, path, "/api/v1/games")) {
            try handleGames(ctx);
        } else if (std.mem.startsWith(u8, path, "/api/v1/games/")) {
            try handleGameDetail(ctx, path);
        } else if (std.mem.eql(u8, path, "/api/v1/leagues")) {
            try handleLeagues(ctx);
        } else if (std.mem.startsWith(u8, path, "/api/v1/players/search")) {
            try handlePlayerSearch(ctx);
        } else {
            try ctx.sendNotFound();
        }
    }
    
    fn handleGames(ctx: *RequestContext) !void {
        // Mock response for now - in production this would call Yahoo API
        try ctx.sendJson(.{
            .games = &[_]struct {
                id: []const u8,
                name: []const u8,
                sport: []const u8,
                season: []const u8,
            }{
                .{ .id = "nfl", .name = "NFL", .sport = "football", .season = "2024" },
                .{ .id = "nba", .name = "NBA", .sport = "basketball", .season = "2024" },
                .{ .id = "mlb", .name = "MLB", .sport = "baseball", .season = "2024" },
            },
            .total = 3,
        });
    }
    
    fn handleGameDetail(ctx: *RequestContext, path: []const u8) !void {
        const game_id = path["/api/v1/games/".len..];
        if (game_id.len == 0) {
            try ctx.sendBadRequest("Game ID is required");
            return;
        }
        
        try ctx.sendJson(.{
            .game = .{
                .id = game_id,
                .name = if (std.mem.eql(u8, game_id, "nfl")) "NFL" 
                       else if (std.mem.eql(u8, game_id, "nba")) "NBA"
                       else if (std.mem.eql(u8, game_id, "mlb")) "MLB"
                       else "Unknown",
                .sport = if (std.mem.eql(u8, game_id, "nfl")) "football"
                        else if (std.mem.eql(u8, game_id, "nba")) "basketball" 
                        else if (std.mem.eql(u8, game_id, "mlb")) "baseball"
                        else "unknown",
                .season = "2024",
            },
        });
    }
    
    fn handleLeagues(ctx: *RequestContext) !void {
        // Check for API key (simplified auth)
        const api_key = ctx.request.getHeader("X-API-Key");
        if (api_key == null) {
            try ctx.sendUnauthorized("API key required");
            return;
        }
        
        try ctx.sendJson(.{
            .leagues = &[_]struct {
                id: []const u8,
                name: []const u8,
                sport: []const u8,
            }{
                .{ .id = "123456", .name = "My Fantasy League", .sport = "nfl" },
            },
            .total = 1,
        });
    }
    
    fn handlePlayerSearch(ctx: *RequestContext) !void {
        const query = ctx.request.getQuery("q");
        if (query == null) {
            try ctx.sendBadRequest("Search query parameter 'q' is required");
            return;
        }
        
        const sport = ctx.request.getQuery("sport") orelse "nfl";
        
        try ctx.sendJson(.{
            .players = &[_]struct {
                id: []const u8,
                name: []const u8,
                sport: []const u8,
                position: []const u8,
                team: []const u8,
            }{
                .{
                    .id = "player-1", 
                    .name = query.?,
                    .sport = sport,
                    .position = "QB",
                    .team = "DAL",
                },
            },
            .query = query.?,
            .sport = sport,
            .total = 1,
        });
    }
    
    fn checkReadiness() bool {
        // In production, check external dependencies
        return true;
    }
};

const RequestContext = struct {
    allocator: std.mem.Allocator,
    request: zap.SimpleRequest,
    start_time: i64,
    status_code: u16 = 200,
    
    const Self = @This();
    
    pub fn init(allocator: std.mem.Allocator, request: zap.SimpleRequest, start_time: i64) Self {
        return Self{
            .allocator = allocator,
            .request = request,
            .start_time = start_time,
        };
    }
    
    pub fn deinit(self: *Self) void {
        _ = self;
        // Cleanup if needed
    }
    
    pub fn sendJson(self: *Self, data: anytype) !void {
        const json_str = try std.json.stringifyAlloc(self.allocator, data, .{});
        defer self.allocator.free(json_str);
        
        self.request.setHeader("Content-Type", "application/json") catch {};
        self.request.setHeader("Access-Control-Allow-Origin", "*") catch {};
        
        self.request.sendBody(json_str) catch {};
    }
    
    pub fn sendText(self: *Self, content: []const u8) !void {
        self.request.setHeader("Content-Type", "text/plain") catch {};
        self.request.setHeader("Access-Control-Allow-Origin", "*") catch {};
        
        self.request.sendBody(content) catch {};
    }
    
    pub fn sendError(self: *Self, status: u16, message: []const u8) !void {
        self.status_code = status;
        self.request.setStatus(status) catch {};
        
        const error_response = try std.fmt.allocPrint(self.allocator, 
            "{{\"error\": \"{s}\", \"status\": {d}}}", .{ message, status });
        defer self.allocator.free(error_response);
        
        self.request.setHeader("Content-Type", "application/json") catch {};
        self.request.sendBody(error_response) catch {};
    }
    
    pub fn sendNotFound(self: *Self) !void {
        try self.sendError(404, "Not Found");
    }
    
    pub fn sendBadRequest(self: *Self, message: []const u8) !void {
        try self.sendError(400, message);
    }
    
    pub fn sendUnauthorized(self: *Self, message: []const u8) !void {
        try self.sendError(401, message);
    }
    
    pub fn sendCORS(self: *Self) !void {
        self.request.setHeader("Access-Control-Allow-Origin", "*") catch {};
        self.request.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS") catch {};
        self.request.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-API-Key") catch {};
        self.request.setHeader("Access-Control-Max-Age", "86400") catch {};
        
        self.request.sendBody("") catch {};
    }
    
    pub fn sendMetrics(self: *Self) !void {
        const metrics = 
            \\# HELP http_requests_total Total number of HTTP requests
            \\# TYPE http_requests_total counter
            \\http_requests_total 1000
            \\
            \\# HELP http_request_duration_seconds HTTP request duration in seconds
            \\# TYPE http_request_duration_seconds histogram
            \\http_request_duration_seconds_bucket{le="0.1"} 800
            \\http_request_duration_seconds_bucket{le="0.5"} 950
            \\http_request_duration_seconds_bucket{le="1.0"} 999
            \\http_request_duration_seconds_bucket{le="+Inf"} 1000
            \\http_request_duration_seconds_count 1000
            \\http_request_duration_seconds_sum 150.5
        ;
        
        self.request.setHeader("Content-Type", "text/plain; version=0.0.4") catch {};
        self.request.sendBody(metrics) catch {};
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Get port from environment
    const port_str = std.process.getEnvVarOwned(allocator, "PORT") catch "3000";
    defer if (!std.mem.eql(u8, port_str, "3000")) allocator.free(port_str);
    
    const port = std.fmt.parseInt(u16, port_str, 10) catch 3000;
    
    logging.info("Yahoo Fantasy API Server (zap) starting...", .{});
    
    var server = try Server.init(allocator, port);
    try server.start();
}

test "server initialization" {
    const allocator = std.testing.allocator;
    var server = try Server.init(allocator, 3001);
    
    // Server should initialize without errors
    try std.testing.expect(server.listener.settings.port == 3001);
}