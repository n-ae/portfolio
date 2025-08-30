// Yahoo Fantasy API proxy handlers
//
// These handlers proxy requests to the Yahoo Fantasy API
// while adding caching, error handling, and response transformation.

const std = @import("std");
const Context = @import("../router.zig").Context;
const Client = @import("../../yahoo_fantasy/client.zig").Client;
const OAuth = @import("../../yahoo_fantasy/oauth.zig");
const errors = @import("../../yahoo_fantasy/errors.zig");
const logging = @import("../../yahoo_fantasy/logging.zig");

// Global client instance (in a real app, this might be dependency injected)
var global_client: ?Client = null;
var client_init_once = std.once(initClient);

fn initClient() void {
    const allocator = std.heap.page_allocator;
    
    const consumer_key = std.process.getEnvVarOwned(allocator, "YAHOO_CLIENT_ID") catch {
        logging.err("YAHOO_CLIENT_ID environment variable not set", .{});
        return;
    };
    defer allocator.free(consumer_key);
    
    const consumer_secret = std.process.getEnvVarOwned(allocator, "YAHOO_CLIENT_SECRET") catch {
        logging.err("YAHOO_CLIENT_SECRET environment variable not set", .{});
        return;
    };
    defer allocator.free(consumer_secret);
    
    const credentials = OAuth.Credentials{
        .consumer_key = consumer_key,
        .consumer_secret = consumer_secret,
    };
    
    global_client = Client.init(allocator, credentials) catch |err| {
        logging.err("Failed to initialize Yahoo Fantasy client: {}", .{err});
        return;
    };
    
    logging.info("Yahoo Fantasy client initialized successfully", .{});
}

fn getClient() !*Client {
    client_init_once.call();
    if (global_client) |*client| {
        return client;
    } else {
        return error.ClientNotInitialized;
    }
}

pub fn getGames(ctx: *Context) !void {
    const client = getClient() catch {
        return ctx.internalServerError("Fantasy client not available");
    };
    
    const response = client.get("games", null) catch |err| switch (err) {
        error.Unauthorized => {
            ctx.status(401);
            return ctx.json(.{
                .error = "Unauthorized",
                .message = "Yahoo API authentication failed",
            });
        },
        error.RateLimited => {
            ctx.status(429);
            return ctx.json(.{
                .error = "Rate Limited", 
                .message = "Too many requests to Yahoo API",
            });
        },
        error.NotFound => {
            ctx.status(404);
            return ctx.json(.{
                .error = "Not Found",
                .message = "Games not found",
            });
        },
        else => {
            logging.err("Error fetching games: {}", .{err});
            return ctx.internalServerError("Failed to fetch games");
        },
    };
    
    // Parse and transform the response
    const parsed = std.json.parseFromSlice(
        std.json.Value,
        ctx.allocator,
        response.body,
        .{},
    ) catch {
        return ctx.internalServerError("Failed to parse Yahoo API response");
    };
    defer parsed.deinit();
    
    // Transform the response to our API format
    const transformed_response = transformGamesResponse(ctx.allocator, parsed.value) catch {
        return ctx.internalServerError("Failed to transform response");
    };
    defer ctx.allocator.free(transformed_response);
    
    try ctx.json(transformed_response);
}

pub fn getGame(ctx: *Context) !void {
    const game_id = ctx.getParam("id") orelse {
        return ctx.badRequest("Game ID is required");
    };
    
    const client = getClient() catch {
        return ctx.internalServerError("Fantasy client not available");
    };
    
    const endpoint = try std.fmt.allocPrint(ctx.allocator, "games/{s}", .{game_id});
    defer ctx.allocator.free(endpoint);
    
    const response = client.get(endpoint, null) catch |err| switch (err) {
        error.Unauthorized => {
            ctx.status(401);
            return ctx.json(.{
                .error = "Unauthorized",
                .message = "Yahoo API authentication failed",
            });
        },
        error.NotFound => {
            ctx.status(404);
            return ctx.json(.{
                .error = "Not Found",
                .message = "Game not found",
            });
        },
        else => {
            logging.err("Error fetching game {s}: {}", .{ game_id, err });
            return ctx.internalServerError("Failed to fetch game");
        },
    };
    
    // Return raw response for now (in production, you'd transform it)
    try ctx.response.headers.append("Content-Type", "application/json");
    try ctx.text(response.body);
}

pub fn getLeagues(ctx: *Context) !void {
    // This would typically require user authentication with Yahoo
    const user_token = ctx.request.headers.getFirstValue("X-User-Token");
    
    if (user_token == null) {
        ctx.status(401);
        return ctx.json(.{
            .error = "Unauthorized",
            .message = "User token required for league access",
        });
    }
    
    // For now, return a placeholder response
    const leagues_response = .{
        .leagues = &[_]struct {
            id: []const u8,
            name: []const u8,
            sport: []const u8,
            season: []const u8,
        }{
            .{
                .id = "123456",
                .name = "Demo League",
                .sport = "nfl",
                .season = "2024",
            },
        },
        .total = 1,
    };
    
    try ctx.json(leagues_response);
}

pub fn getLeague(ctx: *Context) !void {
    const league_id = ctx.getParam("id") orelse {
        return ctx.badRequest("League ID is required");
    };
    
    // Placeholder response
    const league_response = .{
        .league = .{
            .id = league_id,
            .name = "Demo League",
            .sport = "nfl",
            .season = "2024",
            .num_teams = 12,
            .settings = .{
                .playoff_start_week = 15,
                .playoff_end_week = 17,
            },
        },
    };
    
    try ctx.json(league_response);
}

pub fn getLeagueTeams(ctx: *Context) !void {
    const league_id = ctx.getParam("id") orelse {
        return ctx.badRequest("League ID is required");
    };
    
    const teams_response = .{
        .teams = &[_]struct {
            id: []const u8,
            name: []const u8,
            owner: []const u8,
            wins: u32,
            losses: u32,
        }{
            .{
                .id = "1",
                .name = "Team 1",
                .owner = "Owner 1",
                .wins = 8,
                .losses = 5,
            },
            .{
                .id = "2", 
                .name = "Team 2",
                .owner = "Owner 2",
                .wins = 7,
                .losses = 6,
            },
        },
        .league_id = league_id,
        .total = 2,
    };
    
    try ctx.json(teams_response);
}

pub fn searchPlayers(ctx: *Context) !void {
    const query = ctx.getQuery("q") orelse {
        return ctx.badRequest("Search query parameter 'q' is required");
    };
    
    const sport = ctx.getQuery("sport") orelse "nfl";
    const season = ctx.getQuery("season") orelse "2024";
    
    // In a real implementation, this would search the Yahoo API
    const search_response = .{
        .players = &[_]struct {
            id: []const u8,
            name: []const u8,
            sport: []const u8,
            position: []const u8,
            team: []const u8,
        }{
            .{
                .id = "123",
                .name = query, // Echo back the search query for demo
                .sport = sport,
                .position = "QB",
                .team = "DAL",
            },
        },
        .query = query,
        .sport = sport,
        .season = season,
        .total = 1,
    };
    
    try ctx.json(search_response);
}

// Response transformation helpers
fn transformGamesResponse(allocator: std.mem.Allocator, yahoo_response: std.json.Value) ![]const u8 {
    // This would parse the Yahoo API response and transform it to our format
    // For now, return a simplified structure
    const transformed = .{
        .games = &[_]struct {
            id: []const u8,
            name: []const u8,
            sport: []const u8,
            season: []const u8,
        }{
            .{
                .id = "nfl",
                .name = "NFL",
                .sport = "football",
                .season = "2024",
            },
            .{
                .id = "nba",
                .name = "NBA", 
                .sport = "basketball",
                .season = "2024",
            },
        },
        .total = 2,
    };
    
    return std.json.stringify(transformed, .{}, allocator);
}

test "client initialization" {
    // This test would need environment variables set
    // For now, just test that the function doesn't crash
    const client_result = getClient();
    
    // Should either return a client or an error
    if (client_result) |_| {
        // Client initialized successfully
    } else |err| {
        try std.testing.expect(err == error.ClientNotInitialized);
    }
}