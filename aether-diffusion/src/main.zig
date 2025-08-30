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

    std.log.info("Yahoo Fantasy API Zig Wrapper Demo", .{});
    std.log.info("===================================", .{});

    // Get credentials from environment variables (via dotenv)
    const consumer_key = env.get("YAHOO_CONSUMER_KEY") orelse "demo_consumer_key";
    const consumer_secret = env.get("YAHOO_CONSUMER_SECRET") orelse "demo_consumer_secret";
    const access_token = env.get("YAHOO_ACCESS_TOKEN");
    const access_token_secret = env.get("YAHOO_ACCESS_TOKEN_SECRET");

    const credentials = aether_diffusion.OAuth.Credentials{
        .consumer_key = consumer_key,
        .consumer_secret = consumer_secret,
        .access_token = if (access_token != null and access_token.?.len > 0) access_token else null,
        .access_token_secret = if (access_token_secret != null and access_token_secret.?.len > 0) access_token_secret else null,
    };

    std.log.info("✓ Environment variables loaded from .env file", .{});
    std.log.info("  Consumer Key: {s}", .{if (std.mem.eql(u8, consumer_key, "demo_consumer_key")) "demo (not real)" else "configured"});
    std.log.info("  Consumer Secret: {s}", .{if (std.mem.eql(u8, consumer_secret, "demo_consumer_secret")) "demo (not real)" else "configured"});
    std.log.info("  Access Token: {s}", .{if (credentials.access_token != null) "configured" else "not set"});
    
    if (credentials.access_token == null or credentials.access_token_secret == null) {
        std.log.warn("Access tokens not provided. Real API calls will require OAuth authentication.", .{});
    }

    // Initialize client
    var client = aether_diffusion.Client.init(allocator, credentials) catch |err| {
        std.log.err("Failed to initialize Yahoo Fantasy API client: {}", .{err});
        return;
    };
    defer client.deinit();

    std.log.info("✓ Yahoo Fantasy API client initialized", .{});
    
    // Initialize resources
    const game_resource = aether_diffusion.Game.GameResource.init(&client);
    const league_resource = aether_diffusion.League.LeagueResource.init(&client);
    const team_resource = aether_diffusion.Team.TeamResource.init(&client);
    const player_resource = aether_diffusion.Player.PlayerResource.init(&client);

    std.log.info("✓ API resources initialized:", .{});
    std.log.info("  - Games API", .{});
    std.log.info("  - Leagues API", .{});
    std.log.info("  - Teams API", .{});
    std.log.info("  - Players API", .{});

    // Demo OAuth client functionality
    std.log.info("✓ OAuth authentication system ready", .{});
    
    // Demo JSON parsing with sample data
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
        return;
    };
    defer game.deinit(allocator);

    std.log.info("✓ JSON parsing demonstration:", .{});
    std.log.info("  Game: {s} ({s})", .{ game.name, @tagName(game.code) });
    std.log.info("  Season: {d}", .{game.season});
    std.log.info("  Is Offseason: {}", .{game.is_offseason});

    std.log.info("", .{});
    std.log.info("Demo completed successfully!", .{});
    std.log.info("", .{});
    std.log.info("To use with real Yahoo Fantasy API:", .{});
    std.log.info("1. Register app at https://developer.yahoo.com/", .{});
    std.log.info("2. Copy .env.example to .env and fill in your credentials:", .{});
    std.log.info("   YAHOO_CONSUMER_KEY=your_key", .{});
    std.log.info("   YAHOO_CONSUMER_SECRET=your_secret", .{});
    std.log.info("3. Complete OAuth flow to get access tokens", .{});
    std.log.info("4. Add access tokens to .env file", .{});
    std.log.info("5. Run again to use the API client with real data", .{});

    _ = game_resource;
    _ = league_resource;
    _ = team_resource;
    _ = player_resource;
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
