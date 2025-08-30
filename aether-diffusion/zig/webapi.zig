//! Yahoo Fantasy Web API Server (Zig)
//!
//! RESTful HTTP API server that exposes Yahoo Fantasy Sports functionality
//! through clean JSON endpoints, using the underlying SDK for data access.

const std = @import("std");
const print = std.debug.print;
const json = std.json;

// Import our SDK
const sdk = @import("sdk.zig");

// ============================================================================
// Core Web API Server
// ============================================================================

pub const WebApiServer = struct {
    allocator: std.mem.Allocator,
    port: u16,
    yahoo_client: *sdk.YahooFantasyClient,
    
    const Self = @This();
    
    pub fn init(
        allocator: std.mem.Allocator,
        port: u16,
        consumer_key: []const u8,
        consumer_secret: []const u8,
    ) !*Self {
        var server = try allocator.create(Self);
        server.* = Self{
            .allocator = allocator,
            .port = port,
            .yahoo_client = try sdk.YahooFantasyClient.init(allocator, consumer_key, consumer_secret),
        };
        return server;
    }
    
    pub fn deinit(self: *Self) void {
        self.yahoo_client.deinit();
        self.allocator.destroy(self);
    }
    
    /// Set OAuth tokens for the underlying SDK client
    pub fn setTokens(self: *Self, access_token: []const u8, access_token_secret: []const u8) !void {
        try self.yahoo_client.setTokens(access_token, access_token_secret);
    }
    
    /// Start the HTTP server
    pub fn start(self: *Self) !void {
        print("Starting Yahoo Fantasy Web API Server on port {d}\n", .{self.port});
        print("Available endpoints:\n");
        print("  GET  /health             - Health check\n");
        print("  GET  /api/games          - Get all games\n");
        print("  GET  /api/leagues/:game  - Get leagues for game\n");
        print("  GET  /api/teams/:league  - Get teams in league\n");
        print("  GET  /api/players/search?game=:game&q=:query - Search players\n");
        print("  GET  /api/roster/:team   - Get team roster\n");
        print("  POST /api/auth/tokens    - Set OAuth tokens\n");
        print("\nServer ready at http://localhost:{d}\n", .{self.port});
        
        // Simple HTTP server implementation
        var server = std.http.Server.init(self.allocator, .{ .reuse_address = true });
        defer server.deinit();
        
        const address = std.net.Address.parseIp("127.0.0.1", self.port) catch unreachable;
        try server.listen(address);
        
        while (true) {
            var response = try server.accept(.{
                .allocator = self.allocator,
            });
            defer response.deinit();
            
            while (response.reset() != .closing) {
                response.wait() catch |err| switch (err) {
                    error.HttpHeadersInvalid => continue,
                    error.EndOfStream => continue,
                    else => return err,
                };
                
                try self.handleRequest(&response);
            }
        }
    }
    
    /// Handle incoming HTTP requests
    fn handleRequest(self: *Self, response: *std.http.Server.Response) !void {
        const method = response.request.method;
        const target = response.request.target;
        
        print("[{s}] {s}\n", .{ @tagName(method), target });
        
        // Route requests
        if (std.mem.eql(u8, target, "/health")) {
            try self.handleHealth(response);
        } else if (std.mem.startsWith(u8, target, "/api/games")) {
            try self.handleGames(response);
        } else if (std.mem.startsWith(u8, target, "/api/leagues/")) {
            try self.handleLeagues(response, target);
        } else if (std.mem.startsWith(u8, target, "/api/teams/")) {
            try self.handleTeams(response, target);
        } else if (std.mem.startsWith(u8, target, "/api/players/search")) {
            try self.handlePlayerSearch(response, target);
        } else if (std.mem.startsWith(u8, target, "/api/roster/")) {
            try self.handleRoster(response, target);
        } else if (std.mem.eql(u8, target, "/api/auth/tokens") and method == .POST) {
            try self.handleSetTokens(response);
        } else {
            try self.sendNotFound(response);
        }
    }
    
    // ========================================================================
    // Route Handlers
    // ========================================================================
    
    fn handleHealth(self: *Self, response: *std.http.Server.Response) !void {
        _ = self;
        
        const health_data = HealthResponse{
            .status = "healthy",
            .timestamp = std.time.timestamp(),
            .version = "1.0.0",
            .service = "yahoo-fantasy-webapi-zig",
        };
        
        try self.sendJson(response, health_data, 200);
    }
    
    fn handleGames(self: *Self, response: *std.http.Server.Response) !void {
        if (!self.yahoo_client.isAuthenticated()) {
            try self.sendError(response, 401, "Not authenticated. Please set OAuth tokens.");
            return;
        }
        
        const games = self.yahoo_client.getGames() catch |err| {
            try self.sendError(response, 500, switch (err) {
                sdk.SdkError.RateLimited => "Rate limit exceeded. Please try again later.",
                sdk.SdkError.NetworkError => "Network error occurred. Please try again.",
                else => "Internal server error occurred.",
            });
            return;
        };
        defer {
            for (games) |*game| {
                game.deinit(self.allocator);
            }
            self.allocator.free(games);
        }
        
        const response_data = GamesResponse{
            .games = games,
            .count = games.len,
        };
        
        try self.sendJson(response, response_data, 200);
    }
    
    fn handleLeagues(self: *Self, response: *std.http.Server.Response, target: []const u8) !void {
        if (!self.yahoo_client.isAuthenticated()) {
            try self.sendError(response, 401, "Not authenticated. Please set OAuth tokens.");
            return;
        }
        
        // Extract game key from path: /api/leagues/{game_key}
        const game_key = target["/api/leagues/".len..];
        if (game_key.len == 0) {
            try self.sendError(response, 400, "Game key is required");
            return;
        }
        
        const leagues = self.yahoo_client.getLeagues(game_key) catch |err| {
            try self.sendError(response, 500, switch (err) {
                sdk.SdkError.RateLimited => "Rate limit exceeded. Please try again later.",
                sdk.SdkError.NetworkError => "Network error occurred. Please try again.",
                else => "Internal server error occurred.",
            });
            return;
        };
        defer {
            for (leagues) |*league| {
                league.deinit(self.allocator);
            }
            self.allocator.free(leagues);
        }
        
        const response_data = LeaguesResponse{
            .leagues = leagues,
            .game_key = game_key,
            .count = leagues.len,
        };
        
        try self.sendJson(response, response_data, 200);
    }
    
    fn handleTeams(self: *Self, response: *std.http.Server.Response, target: []const u8) !void {
        if (!self.yahoo_client.isAuthenticated()) {
            try self.sendError(response, 401, "Not authenticated. Please set OAuth tokens.");
            return;
        }
        
        // Extract league key from path: /api/teams/{league_key}
        const league_key = target["/api/teams/".len..];
        if (league_key.len == 0) {
            try self.sendError(response, 400, "League key is required");
            return;
        }
        
        const teams = self.yahoo_client.getTeams(league_key) catch |err| {
            try self.sendError(response, 500, switch (err) {
                sdk.SdkError.RateLimited => "Rate limit exceeded. Please try again later.",
                sdk.SdkError.NetworkError => "Network error occurred. Please try again.",
                else => "Internal server error occurred.",
            });
            return;
        };
        defer {
            for (teams) |*team| {
                team.deinit(self.allocator);
            }
            self.allocator.free(teams);
        }
        
        const response_data = TeamsResponse{
            .teams = teams,
            .league_key = league_key,
            .count = teams.len,
        };
        
        try self.sendJson(response, response_data, 200);
    }
    
    fn handlePlayerSearch(self: *Self, response: *std.http.Server.Response, target: []const u8) !void {
        if (!self.yahoo_client.isAuthenticated()) {
            try self.sendError(response, 401, "Not authenticated. Please set OAuth tokens.");
            return;
        }
        
        // Parse query parameters
        const query_start = std.mem.indexOf(u8, target, "?") orelse {
            try self.sendError(response, 400, "Query parameters required: game and q");
            return;
        };
        
        const query_string = target[query_start + 1 ..];
        var game_key: ?[]const u8 = null;
        var search_query: ?[]const u8 = null;
        
        var params = std.mem.split(u8, query_string, "&");
        while (params.next()) |param| {
            var kv = std.mem.split(u8, param, "=");
            const key = kv.next() orelse continue;
            const value = kv.next() orelse continue;
            
            if (std.mem.eql(u8, key, "game")) {
                game_key = value;
            } else if (std.mem.eql(u8, key, "q")) {
                search_query = value;
            }
        }
        
        if (game_key == null or search_query == null) {
            try self.sendError(response, 400, "Both 'game' and 'q' parameters are required");
            return;
        }
        
        const players = self.yahoo_client.searchPlayers(game_key.?, search_query.?) catch |err| {
            try self.sendError(response, 500, switch (err) {
                sdk.SdkError.RateLimited => "Rate limit exceeded. Please try again later.",
                sdk.SdkError.NetworkError => "Network error occurred. Please try again.",
                else => "Internal server error occurred.",
            });
            return;
        };
        defer {
            for (players) |*player| {
                player.deinit(self.allocator);
            }
            self.allocator.free(players);
        }
        
        const response_data = PlayersResponse{
            .players = players,
            .game_key = game_key.?,
            .search_query = search_query.?,
            .count = players.len,
        };
        
        try self.sendJson(response, response_data, 200);
    }
    
    fn handleRoster(self: *Self, response: *std.http.Server.Response, target: []const u8) !void {
        if (!self.yahoo_client.isAuthenticated()) {
            try self.sendError(response, 401, "Not authenticated. Please set OAuth tokens.");
            return;
        }
        
        // Extract team key from path: /api/roster/{team_key}
        const team_key = target["/api/roster/".len..];
        if (team_key.len == 0) {
            try self.sendError(response, 400, "Team key is required");
            return;
        }
        
        const roster = self.yahoo_client.getTeamRoster(team_key) catch |err| {
            try self.sendError(response, 500, switch (err) {
                sdk.SdkError.RateLimited => "Rate limit exceeded. Please try again later.",
                sdk.SdkError.NetworkError => "Network error occurred. Please try again.",
                else => "Internal server error occurred.",
            });
            return;
        };
        defer {
            for (roster) |*player| {
                player.deinit(self.allocator);
            }
            self.allocator.free(roster);
        }
        
        const response_data = RosterResponse{
            .roster = roster,
            .team_key = team_key,
            .count = roster.len,
        };
        
        try self.sendJson(response, response_data, 200);
    }
    
    fn handleSetTokens(self: *Self, response: *std.http.Server.Response) !void {
        // Read request body
        var body_buffer: [1024]u8 = undefined;
        const body_len = try response.request.reader().readAll(&body_buffer);
        const body = body_buffer[0..body_len];
        
        // Parse JSON request
        var stream = json.TokenStream.init(body);
        const parsed = json.parse(TokenRequest, &stream, .{
            .allocator = self.allocator,
        }) catch {
            try self.sendError(response, 400, "Invalid JSON format");
            return;
        };
        defer json.parseFree(TokenRequest, parsed, .{ .allocator = self.allocator });
        
        // Set tokens in SDK client
        self.yahoo_client.setTokens(parsed.access_token, parsed.access_token_secret) catch {
            try self.sendError(response, 500, "Failed to set authentication tokens");
            return;
        };
        
        const response_data = TokenResponse{
            .success = true,
            .message = "Authentication tokens set successfully",
            .authenticated = self.yahoo_client.isAuthenticated(),
        };
        
        try self.sendJson(response, response_data, 200);
    }
    
    // ========================================================================
    // Helper Methods
    // ========================================================================
    
    fn sendJson(self: *Self, response: *std.http.Server.Response, data: anytype, status_code: u16) !void {
        const json_str = try json.stringifyAlloc(self.allocator, data, .{});
        defer self.allocator.free(json_str);
        
        response.status = @enumFromInt(status_code);
        response.transfer_encoding = .{ .content_length = json_str.len };
        try response.headers.append("content-type", "application/json");
        try response.headers.append("access-control-allow-origin", "*");
        try response.do();
        
        _ = try response.writeAll(json_str);
        try response.finish();
    }
    
    fn sendError(self: *Self, response: *std.http.Server.Response, status_code: u16, message: []const u8) !void {
        const error_data = ErrorResponse{
            .error = message,
            .status = status_code,
            .timestamp = std.time.timestamp(),
        };
        
        try self.sendJson(response, error_data, status_code);
    }
    
    fn sendNotFound(self: *Self, response: *std.http.Server.Response) !void {
        try self.sendError(response, 404, "Endpoint not found");
    }
};

// ============================================================================
// Response Data Structures
// ============================================================================

const HealthResponse = struct {
    status: []const u8,
    timestamp: i64,
    version: []const u8,
    service: []const u8,
};

const ErrorResponse = struct {
    error: []const u8,
    status: u16,
    timestamp: i64,
};

const GamesResponse = struct {
    games: []sdk.Game,
    count: usize,
};

const LeaguesResponse = struct {
    leagues: []sdk.League,
    game_key: []const u8,
    count: usize,
};

const TeamsResponse = struct {
    teams: []sdk.Team,
    league_key: []const u8,
    count: usize,
};

const PlayersResponse = struct {
    players: []sdk.Player,
    game_key: []const u8,
    search_query: []const u8,
    count: usize,
};

const RosterResponse = struct {
    roster: []sdk.Player,
    team_key: []const u8,
    count: usize,
};

const TokenRequest = struct {
    access_token: []const u8,
    access_token_secret: []const u8,
};

const TokenResponse = struct {
    success: bool,
    message: []const u8,
    authenticated: bool,
};

// ============================================================================
// Demo/Example Usage
// ============================================================================

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    print("Yahoo Fantasy Web API Server (Zig)\n");
    print("===================================\n\n");
    
    // Initialize server
    var server = try WebApiServer.init(
        allocator,
        8080,
        "your_consumer_key",
        "your_consumer_secret",
    );
    defer server.deinit();
    
    print("Server configuration:\n");
    print("  Port: {d}\n", .{server.port});
    print("  SDK Authenticated: {}\n", .{server.yahoo_client.isAuthenticated()});
    print("\nTo authenticate:\n");
    print("  POST /api/auth/tokens\n");
    print("  Body: {{\"access_token\": \"your_token\", \"access_token_secret\": \"your_secret\"}}\n");
    print("\nStarting server...\n\n");
    
    // Start the server (this will block)
    try server.start();
}

// ============================================================================
// Tests
// ============================================================================

test "WebApiServer initialization" {
    const testing = std.testing;
    const allocator = testing.allocator;
    
    var server = try WebApiServer.init(allocator, 8080, "test_key", "test_secret");
    defer server.deinit();
    
    try testing.expect(server.port == 8080);
    try testing.expect(!server.yahoo_client.isAuthenticated());
}

test "Token setting via API" {
    const testing = std.testing;
    const allocator = testing.allocator;
    
    var server = try WebApiServer.init(allocator, 8080, "test_key", "test_secret");
    defer server.deinit();
    
    try server.setTokens("access_token", "access_token_secret");
    try testing.expect(server.yahoo_client.isAuthenticated());
}