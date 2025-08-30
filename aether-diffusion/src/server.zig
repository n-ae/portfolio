const std = @import("std");
const aether_diffusion = @import("aether_diffusion");
const dotenv = @import("dotenv.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Load environment variables from .env file
    var env = dotenv.DotEnv.init(allocator);
    defer env.deinit();

    try env.load();

    std.log.info("Yahoo Fantasy API Server Starting...", .{});

    // Get credentials from environment variables (via dotenv)
    const consumer_key = env.get("YAHOO_CONSUMER_KEY") orelse {
        std.log.err("YAHOO_CONSUMER_KEY environment variable is required", .{});
        return;
    };
    
    const consumer_secret = env.get("YAHOO_CONSUMER_SECRET") orelse {
        std.log.err("YAHOO_CONSUMER_SECRET environment variable is required", .{});
        return;
    };

    if (std.mem.eql(u8, consumer_key, "") or std.mem.eql(u8, consumer_secret, "")) {
        std.log.err("YAHOO_CONSUMER_KEY and YAHOO_CONSUMER_SECRET must be set", .{});
        std.log.info("Copy .env.example to .env and set your API credentials", .{});
        return;
    }

    const access_token = env.get("YAHOO_ACCESS_TOKEN");
    const access_token_secret = env.get("YAHOO_ACCESS_TOKEN_SECRET");

    const credentials = aether_diffusion.OAuth.Credentials{
        .consumer_key = consumer_key,
        .consumer_secret = consumer_secret,
        .access_token = if (access_token != null and access_token.?.len > 0) access_token else null,
        .access_token_secret = if (access_token_secret != null and access_token_secret.?.len > 0) access_token_secret else null,
    };

    // Get port from environment or default to 8080
    const port_str = env.get("PORT") orelse "8080";
    const port = std.fmt.parseInt(u16, port_str, 10) catch 8080;

    std.log.info("Credentials loaded successfully", .{});
    if (credentials.access_token == null or credentials.access_token_secret == null) {
        std.log.warn("Access tokens not provided. Some endpoints may require user authentication.", .{});
        std.log.info("Set YAHOO_ACCESS_TOKEN and YAHOO_ACCESS_TOKEN_SECRET for full functionality.", .{});
    }

    // Initialize Yahoo Fantasy API client
    var client = aether_diffusion.Client.init(allocator, credentials) catch |err| {
        std.log.err("Failed to initialize Yahoo Fantasy API client: {}", .{err});
        return;
    };
    defer client.deinit();

    // Start simple HTTP server
    try startSimpleServer(allocator, &client, port);
}

fn startSimpleServer(allocator: std.mem.Allocator, client: *aether_diffusion.Client, port: u16) !void {
    const address = std.net.Address.initIp4([4]u8{ 0, 0, 0, 0 }, port);
    var listener = try address.listen(.{ .reuse_address = true });
    defer listener.deinit();

    std.log.info("Yahoo Fantasy API server listening on http://0.0.0.0:{d}", .{port});
    std.log.info("Available endpoints:", .{});
    std.log.info("  GET /health - Health check", .{});
    std.log.info("  GET /status - API status and configuration", .{});
    std.log.info("  GET /demo - Demo game data parsing", .{});
    
    while (true) {
        const connection = try listener.accept();
        defer connection.stream.close();

        handleConnection(allocator, client, connection) catch |err| {
            std.log.err("Error handling connection: {}", .{err});
        };
    }
}

fn handleConnection(allocator: std.mem.Allocator, client: *aether_diffusion.Client, connection: std.net.Server.Connection) !void {
    _ = client; // For future use
    
    var buffer: [4096]u8 = undefined;
    const bytes_read = try connection.stream.read(buffer[0..]);
    
    if (bytes_read == 0) return;
    
    const request = buffer[0..bytes_read];
    
    // Parse HTTP request line
    var lines = std.mem.splitSequence(u8, request, "\r\n");
    const request_line = lines.next() orelse return;
    
    var parts = std.mem.splitSequence(u8, request_line, " ");
    const method = parts.next() orelse return;
    const uri = parts.next() orelse return;
    
    std.log.info("{s} {s}", .{ method, uri });
    
    if (std.mem.eql(u8, method, "GET")) {
        if (std.mem.eql(u8, uri, "/health")) {
            try sendHealthResponse(connection);
        } else if (std.mem.eql(u8, uri, "/status")) {
            try sendStatusResponse(allocator, connection);
        } else if (std.mem.eql(u8, uri, "/demo")) {
            try sendDemoResponse(allocator, connection);
        } else {
            try sendNotFoundResponse(connection);
        }
    } else if (std.mem.eql(u8, method, "OPTIONS")) {
        try sendOptionsResponse(connection);
    } else {
        try sendMethodNotAllowedResponse(connection);
    }
}

fn sendHealthResponse(connection: std.net.Server.Connection) !void {
    const response = 
        \\HTTP/1.1 200 OK
        \\Content-Type: application/json
        \\Access-Control-Allow-Origin: *
        \\Content-Length: 72
        \\
        \\{"status": "healthy", "service": "yahoo-fantasy-api", "uptime": "ok"}
    ;
    
    try connection.stream.writeAll(response);
}

fn sendStatusResponse(allocator: std.mem.Allocator, connection: std.net.Server.Connection) !void {
    const timestamp = std.time.timestamp();
    const body = try std.fmt.allocPrint(allocator,
        \\{{"status": "running", "service": "yahoo-fantasy-api", "timestamp": {d}, "endpoints": ["/health", "/status", "/demo"]}}
    , .{timestamp});
    defer allocator.free(body);

    const response = try std.fmt.allocPrint(allocator,
        \\HTTP/1.1 200 OK
        \\Content-Type: application/json
        \\Access-Control-Allow-Origin: *
        \\Content-Length: {d}
        \\
        \\{s}
    , .{ body.len, body });
    defer allocator.free(response);

    try connection.stream.writeAll(response);
}

fn sendDemoResponse(allocator: std.mem.Allocator, connection: std.net.Server.Connection) !void {
    const sample_game_json = 
        \\{
        \\  "game": {
        \\    "game_key": "nfl",
        \\    "game_id": 449,
        \\    "name": "Football",
        \\    "code": "nfl",
        \\    "type": "full",
        \\    "url": "https://football.fantasysports.yahoo.com/f1",
        \\    "season": 2024,
        \\    "is_registration_over": 0,
        \\    "is_game_over": 0,
        \\    "is_offseason": 1
        \\  }
        \\}
    ;

    var game = aether_diffusion.Game.Game.fromJson(allocator, sample_game_json) catch |err| {
        std.log.err("Failed to parse game JSON: {}", .{err});
        try sendErrorResponse(connection, 500, "Internal Server Error");
        return;
    };
    defer game.deinit(allocator);

    const body = try std.fmt.allocPrint(allocator,
        \\{{"demo": true, "parsed_game": {{"name": "{s}", "code": "{s}", "season": {d}, "is_offseason": {}}}}}
    , .{ game.name, @tagName(game.code), game.season, game.is_offseason });
    defer allocator.free(body);

    const response = try std.fmt.allocPrint(allocator,
        \\HTTP/1.1 200 OK
        \\Content-Type: application/json
        \\Access-Control-Allow-Origin: *
        \\Content-Length: {d}
        \\
        \\{s}
    , .{ body.len, body });
    defer allocator.free(response);

    try connection.stream.writeAll(response);
}

fn sendOptionsResponse(connection: std.net.Server.Connection) !void {
    const response = 
        \\HTTP/1.1 200 OK
        \\Access-Control-Allow-Origin: *
        \\Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
        \\Access-Control-Allow-Headers: Content-Type, Authorization
        \\Content-Length: 0
        \\
        \\
    ;
    
    try connection.stream.writeAll(response);
}

fn sendNotFoundResponse(connection: std.net.Server.Connection) !void {
    const response = 
        \\HTTP/1.1 404 Not Found
        \\Content-Type: application/json
        \\Access-Control-Allow-Origin: *
        \\Content-Length: 34
        \\
        \\{"error": "Endpoint not found"}
    ;
    
    try connection.stream.writeAll(response);
}

fn sendMethodNotAllowedResponse(connection: std.net.Server.Connection) !void {
    const response = 
        \\HTTP/1.1 405 Method Not Allowed
        \\Content-Type: application/json
        \\Access-Control-Allow-Origin: *
        \\Content-Length: 36
        \\
        \\{"error": "Method not allowed"}
    ;
    
    try connection.stream.writeAll(response);
}

fn sendErrorResponse(connection: std.net.Server.Connection, status_code: u16, message: []const u8) !void {
    const status_text = switch (status_code) {
        400 => "Bad Request",
        500 => "Internal Server Error",
        else => "Error",
    };

    const body = try std.fmt.allocPrint(std.heap.page_allocator, 
        \\{{"error": "{s}"}}
    , .{message});
    defer std.heap.page_allocator.free(body);

    const response = try std.fmt.allocPrint(std.heap.page_allocator,
        \\HTTP/1.1 {d} {s}
        \\Content-Type: application/json
        \\Access-Control-Allow-Origin: *
        \\Content-Length: {d}
        \\
        \\{s}
    , .{ status_code, status_text, body.len, body });
    defer std.heap.page_allocator.free(response);

    try connection.stream.writeAll(response);
}