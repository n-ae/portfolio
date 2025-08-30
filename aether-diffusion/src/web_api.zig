const std = @import("std");
const http = std.http;
const aether_diffusion = @import("aether_diffusion");
const Client = aether_diffusion.Client;
const OAuth = aether_diffusion.OAuth;

pub const ApiError = error{
    InvalidRequest,
    AuthenticationFailed,
    NotFound,
    InternalServerError,
} || std.mem.Allocator.Error;

pub const WebApiServer = struct {
    allocator: std.mem.Allocator,
    yahoo_client: Client,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, credentials: OAuth.Credentials) !Self {
        return Self{
            .allocator = allocator,
            .yahoo_client = try Client.init(allocator, credentials),
        };
    }

    pub fn deinit(self: *Self) void {
        self.yahoo_client.deinit();
    }

    pub fn start(self: *Self, port: u16) !void {
        const address = std.net.Address.initIp4([4]u8{ 127, 0, 0, 1 }, port);
        var listener = try address.listen(.{ .reuse_address = true });
        defer listener.deinit();
        
        std.log.info("Yahoo Fantasy API server starting on http://localhost:{d}", .{port});
        std.log.info("Available endpoints:", .{});
        std.log.info("  GET /health - Health check", .{});
        std.log.info("  GET /games - List all games", .{});
        std.log.info("  GET /games/:game_key - Get specific game", .{});
        std.log.info("  GET /leagues/:game_key - Get user leagues for game", .{});
        std.log.info("  GET /league/:league_key - Get league details", .{});
        std.log.info("  GET /league/:league_key/standings - Get league standings", .{});
        std.log.info("  GET /league/:league_key/scoreboard - Get league scoreboard", .{});
        std.log.info("  GET /league/:league_key/teams - Get league teams", .{});
        std.log.info("  GET /team/:team_key - Get team details", .{});
        std.log.info("  GET /team/:team_key/roster - Get team roster", .{});
        std.log.info("  GET /player/:player_key - Get player details", .{});
        std.log.info("  GET /players/search?q=<query>&game=<game_key> - Search players", .{});

        while (true) {
            const connection = try listener.accept();
            defer connection.stream.close();

            try self.handleConnection(connection);
        }
    }

    fn handleConnection(self: *Self, connection: std.net.Server.Connection) !void {
        var buffer: [4096]u8 = undefined;
        const bytes_read = try connection.stream.readAll(buffer[0..]);
        
        if (bytes_read == 0) return;
        
        const request = buffer[0..bytes_read];
        
        // Parse HTTP request line
        var lines = std.mem.split(u8, request, "\r\n");
        const request_line = lines.next() orelse return;
        
        var parts = std.mem.split(u8, request_line, " ");
        const method = parts.next() orelse return;
        const uri = parts.next() orelse return;
        
        std.log.info("{s} {s}", .{ method, uri });
        
        if (std.mem.eql(u8, method, "GET")) {
            try self.handleGetRequest(connection, uri);
        } else if (std.mem.eql(u8, method, "OPTIONS")) {
            try self.handleOptionsRequest(connection);
        } else {
            try self.sendHttpError(connection, 405, "Method Not Allowed");
        }
    }

    fn handleGet(self: *Self, response: *std.http.Server.Response, uri: []const u8) !void {
        if (std.mem.eql(u8, uri, "/health")) {
            try self.handleHealth(response);
        } else if (std.mem.eql(u8, uri, "/games")) {
            try self.handleGames(response);
        } else if (std.mem.startsWith(u8, uri, "/games/")) {
            const game_key = uri[7..];
            try self.handleGameDetails(response, game_key);
        } else if (std.mem.startsWith(u8, uri, "/leagues/")) {
            const game_key = uri[9..];
            try self.handleUserLeagues(response, game_key);
        } else if (std.mem.startsWith(u8, uri, "/league/")) {
            try self.handleLeagueEndpoints(response, uri);
        } else if (std.mem.startsWith(u8, uri, "/team/")) {
            try self.handleTeamEndpoints(response, uri);
        } else if (std.mem.startsWith(u8, uri, "/player/")) {
            const player_key = uri[8..];
            try self.handlePlayerDetails(response, player_key);
        } else if (std.mem.startsWith(u8, uri, "/players/search")) {
            try self.handlePlayerSearch(response, uri);
        } else {
            try self.sendError(response, .not_found, "Endpoint not found");
        }
    }

    fn handleOptions(self: *Self, response: *std.http.Server.Response) !void {
        _ = self;
        try response.headers.append("Access-Control-Allow-Origin", "*");
        try response.headers.append("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        try response.headers.append("Access-Control-Allow-Headers", "Content-Type, Authorization");
        response.status = .no_content;
        try response.do();
        try response.finish();
    }

    fn handleHealth(self: *Self, response: *std.http.Server.Response) !void {
        const health_response = 
            \\{"status": "healthy", "service": "yahoo-fantasy-api", "timestamp": "
        ;
        
        const timestamp = std.time.timestamp();
        const full_response = try std.fmt.allocPrint(self.allocator, "{s}{d}\"}", .{ health_response, timestamp });
        defer self.allocator.free(full_response);

        try self.sendJsonResponse(response, .ok, full_response);
    }

    fn handleGames(self: *Self, response: *std.http.Server.Response) !void {
        const game_resource = aether_diffusion.Game.GameResource.init(&self.yahoo_client);
        
        const games = game_resource.getGames() catch |err| switch (err) {
            error.RequestFailed => {
                try self.sendError(response, .bad_gateway, "Failed to fetch games from Yahoo API");
                return;
            },
            else => return err,
        };
        
        var games_json = std.ArrayList(u8).init(self.allocator);
        defer games_json.deinit();

        try games_json.appendSlice("{\"games\": [");
        for (games.items, 0..) |game, i| {
            if (i > 0) try games_json.appendSlice(", ");
            
            const game_json = try std.fmt.allocPrint(self.allocator, 
                \\{{"game_key": "{s}", "game_id": {d}, "name": "{s}", "code": "{s}", "season": {d}}}
            , .{ game.game_key, game.game_id, game.name, @tagName(game.code), game.season });
            defer self.allocator.free(game_json);
            
            try games_json.appendSlice(game_json);
        }
        try games_json.appendSlice("]}");

        try self.sendJsonResponse(response, .ok, games_json.items);
    }

    fn handleGameDetails(self: *Self, response: *std.http.Server.Response, game_key: []const u8) !void {
        const game_resource = aether_diffusion.Game.GameResource.init(&self.yahoo_client);
        
        const game = game_resource.getGame(game_key) catch |err| switch (err) {
            error.RequestFailed => {
                try self.sendError(response, .not_found, "Game not found");
                return;
            },
            else => return err,
        };
        
        const game_json = try std.fmt.allocPrint(self.allocator,
            \\{{"game_key": "{s}", "game_id": {d}, "name": "{s}", "code": "{s}", "type": "{s}", "season": {d}, "is_offseason": {}}}
        , .{ game.game_key, game.game_id, game.name, @tagName(game.code), @tagName(game.type), game.season, game.is_offseason });
        defer self.allocator.free(game_json);

        try self.sendJsonResponse(response, .ok, game_json);
    }

    fn handleUserLeagues(self: *Self, response: *std.http.Server.Response, game_key: []const u8) !void {
        const league_resource = aether_diffusion.League.LeagueResource.init(&self.yahoo_client);
        
        const leagues = league_resource.getUserLeagues(game_key) catch |err| switch (err) {
            error.RequestFailed => {
                try self.sendError(response, .bad_gateway, "Failed to fetch leagues from Yahoo API");
                return;
            },
            else => return err,
        };
        
        var leagues_json = std.ArrayList(u8).init(self.allocator);
        defer leagues_json.deinit();

        try leagues_json.appendSlice("{\"leagues\": [");
        for (leagues.items, 0..) |league, i| {
            if (i > 0) try leagues_json.appendSlice(", ");
            
            const league_json = try std.fmt.allocPrint(self.allocator,
                \\{{"league_key": "{s}", "league_id": {d}, "name": "{s}", "num_teams": {d}, "scoring_type": "{s}"}}
            , .{ league.league_key, league.league_id, league.name, league.num_teams, @tagName(league.scoring_type) });
            defer self.allocator.free(league_json);
            
            try leagues_json.appendSlice(league_json);
        }
        try leagues_json.appendSlice("]}");

        try self.sendJsonResponse(response, .ok, leagues_json.items);
    }

    fn handleLeagueEndpoints(self: *Self, response: *std.http.Server.Response, uri: []const u8) !void {
        // Parse league key from URI like /league/449.l.123456 or /league/449.l.123456/standings
        const path_after_league = uri[8..]; // Skip "/league/"
        
        var parts = std.mem.split(u8, path_after_league, "/");
        const league_key = parts.first();
        const sub_resource = parts.next();

        const league_resource = aether_diffusion.League.LeagueResource.init(&self.yahoo_client);

        if (sub_resource == null) {
            // Get league details
            const league = league_resource.getLeague(league_key) catch |err| switch (err) {
                error.RequestFailed => {
                    try self.sendError(response, .not_found, "League not found");
                    return;
                },
                else => return err,
            };
            
            const league_json = try std.fmt.allocPrint(self.allocator,
                \\{{"league_key": "{s}", "league_id": {d}, "name": "{s}", "num_teams": {d}, "scoring_type": "{s}", "current_week": {d}}}
            , .{ league.league_key, league.league_id, league.name, league.num_teams, @tagName(league.scoring_type), league.current_week });
            defer self.allocator.free(league_json);

            try self.sendJsonResponse(response, .ok, league_json);
        } else if (std.mem.eql(u8, sub_resource.?, "standings")) {
            const standings = league_resource.getLeagueStandings(league_key) catch |err| switch (err) {
                error.RequestFailed => {
                    try self.sendError(response, .not_found, "League standings not found");
                    return;
                },
                else => return err,
            };
            
            const standings_json = try std.json.stringifyAlloc(self.allocator, standings, .{});
            defer self.allocator.free(standings_json);
            
            try self.sendJsonResponse(response, .ok, standings_json);
        } else if (std.mem.eql(u8, sub_resource.?, "scoreboard")) {
            const scoreboard = league_resource.getLeagueScoreboard(league_key, null) catch |err| switch (err) {
                error.RequestFailed => {
                    try self.sendError(response, .not_found, "League scoreboard not found");
                    return;
                },
                else => return err,
            };
            
            const scoreboard_json = try std.json.stringifyAlloc(self.allocator, scoreboard, .{});
            defer self.allocator.free(scoreboard_json);
            
            try self.sendJsonResponse(response, .ok, scoreboard_json);
        } else if (std.mem.eql(u8, sub_resource.?, "teams")) {
            const team_resource = aether_diffusion.Team.TeamResource.init(&self.yahoo_client);
            const teams = team_resource.getLeagueTeams(league_key) catch |err| switch (err) {
                error.RequestFailed => {
                    try self.sendError(response, .not_found, "League teams not found");
                    return;
                },
                else => return err,
            };
            
            var teams_json = std.ArrayList(u8).init(self.allocator);
            defer teams_json.deinit();

            try teams_json.appendSlice("{\"teams\": [");
            for (teams.items, 0..) |team, i| {
                if (i > 0) try teams_json.appendSlice(", ");
                
                const team_json = try std.fmt.allocPrint(self.allocator,
                    \\{{"team_key": "{s}", "team_id": {d}, "name": "{s}", "waiver_priority": {d}}}
                , .{ team.team_key, team.team_id, team.name, team.waiver_priority });
                defer self.allocator.free(team_json);
                
                try teams_json.appendSlice(team_json);
            }
            try teams_json.appendSlice("]}");

            try self.sendJsonResponse(response, .ok, teams_json.items);
        } else {
            try self.sendError(response, .not_found, "League sub-resource not found");
        }
    }

    fn handleTeamEndpoints(self: *Self, response: *std.http.Server.Response, uri: []const u8) !void {
        const path_after_team = uri[6..]; // Skip "/team/"
        
        var parts = std.mem.split(u8, path_after_team, "/");
        const team_key = parts.first();
        const sub_resource = parts.next();

        const team_resource = aether_diffusion.Team.TeamResource.init(&self.yahoo_client);

        if (sub_resource == null) {
            // Get team details
            const team = team_resource.getTeam(team_key) catch |err| switch (err) {
                error.RequestFailed => {
                    try self.sendError(response, .not_found, "Team not found");
                    return;
                },
                else => return err,
            };
            
            const team_json = try std.fmt.allocPrint(self.allocator,
                \\{{"team_key": "{s}", "team_id": {d}, "name": "{s}", "waiver_priority": {d}, "number_of_moves": {d}}}
            , .{ team.team_key, team.team_id, team.name, team.waiver_priority, team.number_of_moves });
            defer self.allocator.free(team_json);

            try self.sendJsonResponse(response, .ok, team_json);
        } else if (std.mem.eql(u8, sub_resource.?, "roster")) {
            const roster = team_resource.getTeamRoster(team_key, null) catch |err| switch (err) {
                error.RequestFailed => {
                    try self.sendError(response, .not_found, "Team roster not found");
                    return;
                },
                else => return err,
            };
            
            const roster_json = try std.json.stringifyAlloc(self.allocator, roster, .{});
            defer self.allocator.free(roster_json);
            
            try self.sendJsonResponse(response, .ok, roster_json);
        } else {
            try self.sendError(response, .not_found, "Team sub-resource not found");
        }
    }

    fn handlePlayerDetails(self: *Self, response: *std.http.Server.Response, player_key: []const u8) !void {
        const player_resource = aether_diffusion.Player.PlayerResource.init(&self.yahoo_client);
        
        const player = player_resource.getPlayer(player_key) catch |err| switch (err) {
            error.RequestFailed => {
                try self.sendError(response, .not_found, "Player not found");
                return;
            },
            else => return err,
        };
        
        const player_json = try std.fmt.allocPrint(self.allocator,
            \\{{"player_key": "{s}", "player_id": {d}, "name": "{s}", "team": "{s}", "position": "{s}"}}
        , .{ player.player_key, player.player_id, player.name.full, player.editorial_team_abbr, player.primary_position });
        defer self.allocator.free(player_json);

        try self.sendJsonResponse(response, .ok, player_json);
    }

    fn handlePlayerSearch(self: *Self, response: *std.http.Server.Response, uri: []const u8) !void {
        // Parse query parameters from URI like /players/search?q=Tom+Brady&game=nfl
        var query_params = std.StringHashMap([]const u8).init(self.allocator);
        defer query_params.deinit();

        if (std.mem.indexOf(u8, uri, "?")) |query_start| {
            const query_string = uri[query_start + 1..];
            var params = std.mem.split(u8, query_string, "&");
            while (params.next()) |param| {
                if (std.mem.indexOf(u8, param, "=")) |eq_pos| {
                    const key = param[0..eq_pos];
                    const value = param[eq_pos + 1..];
                    try query_params.put(key, value);
                }
            }
        }

        const search_query = query_params.get("q") orelse {
            try self.sendError(response, .bad_request, "Missing search query parameter 'q'");
            return;
        };

        const game_key = query_params.get("game") orelse {
            try self.sendError(response, .bad_request, "Missing game parameter 'game'");
            return;
        };

        const player_resource = aether_diffusion.Player.PlayerResource.init(&self.yahoo_client);
        const players = player_resource.searchPlayers(search_query, game_key) catch |err| switch (err) {
            error.RequestFailed => {
                try self.sendError(response, .bad_gateway, "Failed to search players from Yahoo API");
                return;
            },
            else => return err,
        };
        
        var players_json = std.ArrayList(u8).init(self.allocator);
        defer players_json.deinit();

        try players_json.appendSlice("{\"players\": [");
        for (players.items, 0..) |player, i| {
            if (i > 0) try players_json.appendSlice(", ");
            
            const player_json = try std.fmt.allocPrint(self.allocator,
                \\{{"player_key": "{s}", "player_id": {d}, "name": "{s}", "team": "{s}", "position": "{s}"}}
            , .{ player.player_key, player.player_id, player.name.full, player.editorial_team_abbr, player.primary_position });
            defer self.allocator.free(player_json);
            
            try players_json.appendSlice(player_json);
        }
        try players_json.appendSlice("]}");

        try self.sendJsonResponse(response, .ok, players_json.items);
    }

    fn sendJsonResponse(self: *Self, response: *std.http.Server.Response, status: std.http.Status, json_body: []const u8) !void {
        _ = self;
        response.status = status;
        try response.headers.append("Content-Type", "application/json");
        try response.headers.append("Access-Control-Allow-Origin", "*");
        try response.do();
        try response.writeAll(json_body);
        try response.finish();
    }

    fn sendError(self: *Self, response: *std.http.Server.Response, status: std.http.Status, message: []const u8) !void {
        const error_json = try std.fmt.allocPrint(self.allocator, "{{\"error\": \"{s}\"}}", .{message});
        defer self.allocator.free(error_json);
        
        try self.sendJsonResponse(response, status, error_json);
    }
};

test "web api server initialization" {
    const allocator = std.testing.allocator;
    const credentials = OAuth.Credentials{
        .consumer_key = "test_key",
        .consumer_secret = "test_secret",
    };

    var server = try WebApiServer.init(allocator, credentials);
    defer server.deinit();

    try std.testing.expectEqualSlices(u8, "test_key", server.yahoo_client.oauth_client.credentials.consumer_key);
}