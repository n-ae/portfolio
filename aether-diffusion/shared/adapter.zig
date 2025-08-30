//! Mock adapter pattern for Yahoo Fantasy Sports API
//! Allows switching between mock data and real API with config change

const std = @import("std");
const json = std.json;

// Data structures
pub const Game = struct {
    game_key: []const u8,
    name: []const u8,
    code: []const u8,
    season: i32,
    type: []const u8,
    
    pub fn deinit(self: *Game, allocator: std.mem.Allocator) void {
        allocator.free(self.game_key);
        allocator.free(self.name);
        allocator.free(self.code);
        allocator.free(self.type);
    }
};

pub const League = struct {
    league_key: []const u8,
    name: []const u8,
    num_teams: i32,
    current_week: i32,
    game_key: []const u8,
    
    pub fn deinit(self: *League, allocator: std.mem.Allocator) void {
        allocator.free(self.league_key);
        allocator.free(self.name);
        allocator.free(self.game_key);
    }
};

pub const Team = struct {
    team_key: []const u8,
    name: []const u8,
    waiver_priority: ?i32,
    league_key: []const u8,
    
    pub fn deinit(self: *Team, allocator: std.mem.Allocator) void {
        allocator.free(self.team_key);
        allocator.free(self.name);
        allocator.free(self.league_key);
    }
};

pub const Player = struct {
    player_key: []const u8,
    full_name: []const u8,
    position: []const u8,
    team: []const u8,
    game_key: ?[]const u8 = null,
    
    pub fn deinit(self: *Player, allocator: std.mem.Allocator) void {
        allocator.free(self.player_key);
        allocator.free(self.full_name);
        allocator.free(self.position);
        allocator.free(self.team);
        if (self.game_key) |gk| {
            allocator.free(gk);
        }
    }
};

// Configuration structure
pub const Config = struct {
    api_mode: []const u8, // "mock" or "real"
    yahoo_api: struct {
        base_url: []const u8,
        consumer_key: []const u8,
        consumer_secret: []const u8,
    },
    mock_api: struct {
        data_file: []const u8,
        simulate_delays: bool,
        delay_ms: u32,
    },
};

// API Adapter interface
pub const YahooApiAdapter = struct {
    allocator: std.mem.Allocator,
    config: Config,
    mock_data: ?[]const u8,
    
    const Self = @This();
    
    pub fn init(allocator: std.mem.Allocator) !*Self {
        var adapter = try allocator.create(Self);
        
        // Load configuration
        const config_content = std.fs.cwd().readFileAlloc(allocator, "shared/config.json", 1024 * 1024) catch |err| {
            return err;
        };
        defer allocator.free(config_content);
        
        var parsed = json.parseFromSlice(json.Value, allocator, config_content, .{}) catch |err| {
            return err;
        };
        defer parsed.deinit();
        
        const root = parsed.value;
        
        adapter.* = Self{
            .allocator = allocator,
            .config = try parseConfig(allocator, root),
            .mock_data = null,
        };
        
        // Load mock data if in mock mode
        if (std.mem.eql(u8, adapter.config.api_mode, "mock")) {
            adapter.mock_data = std.fs.cwd().readFileAlloc(allocator, adapter.config.mock_api.data_file, 1024 * 1024) catch |err| {
                return err;
            };
        }
        
        return adapter;
    }
    
    pub fn deinit(self: *Self) void {
        if (self.mock_data) |data| {
            self.allocator.free(data);
        }
        self.allocator.destroy(self);
    }
    
    // API methods with mock/real switching
    pub fn getGames(self: *Self) ![]Game {
        if (std.mem.eql(u8, self.config.api_mode, "mock")) {
            return self.getMockGames();
        } else {
            return self.getRealGames();
        }
    }
    
    pub fn getLeagues(self: *Self, game_key: []const u8) ![]League {
        if (std.mem.eql(u8, self.config.api_mode, "mock")) {
            return self.getMockLeagues(game_key);
        } else {
            return self.getRealLeagues(game_key);
        }
    }
    
    pub fn getTeams(self: *Self, league_key: []const u8) ![]Team {
        if (std.mem.eql(u8, self.config.api_mode, "mock")) {
            return self.getMockTeams(league_key);
        } else {
            return self.getRealTeams(league_key);
        }
    }
    
    pub fn searchPlayers(self: *Self, game_key: []const u8, search_query: []const u8) ![]Player {
        if (std.mem.eql(u8, self.config.api_mode, "mock")) {
            return self.getMockPlayers(game_key, search_query);
        } else {
            return self.getRealPlayers(game_key, search_query);
        }
    }
    
    pub fn getTeamRoster(self: *Self, team_key: []const u8) ![]Player {
        if (std.mem.eql(u8, self.config.api_mode, "mock")) {
            return self.getMockRoster(team_key);
        } else {
            return self.getRealRoster(team_key);
        }
    }
    
    // Mock implementations
    fn getMockGames(self: *Self) ![]Game {
        if (self.config.mock_api.simulate_delays) {
            std.time.sleep(self.config.mock_api.delay_ms * std.time.ns_per_ms);
        }
        
        var parsed = json.parseFromSlice(json.Value, self.allocator, self.mock_data.?, .{}) catch |err| {
            return err;
        };
        defer parsed.deinit();
        
        const games_array = parsed.value.object.get("games").?.array;
        var games = try self.allocator.alloc(Game, games_array.items.len);
        
        for (games_array.items, 0..) |game_json, i| {
            const game_obj = game_json.object;
            games[i] = Game{
                .game_key = try self.allocator.dupe(u8, game_obj.get("game_key").?.string),
                .name = try self.allocator.dupe(u8, game_obj.get("name").?.string),
                .code = try self.allocator.dupe(u8, game_obj.get("code").?.string),
                .season = @intCast(game_obj.get("season").?.integer),
                .type = try self.allocator.dupe(u8, game_obj.get("type").?.string),
            };
        }
        
        return games;
    }
    
    fn getMockLeagues(self: *Self, game_key: []const u8) ![]League {
        if (self.config.mock_api.simulate_delays) {
            std.time.sleep(self.config.mock_api.delay_ms * std.time.ns_per_ms);
        }
        
        var parsed = json.parseFromSlice(json.Value, self.allocator, self.mock_data.?, .{}) catch |err| {
            return err;
        };
        defer parsed.deinit();
        
        const leagues_obj = parsed.value.object.get("leagues").?.object;
        
        if (leagues_obj.get(game_key)) |leagues_array| {
            const leagues_items = leagues_array.array;
            var leagues = try self.allocator.alloc(League, leagues_items.items.len);
            
            for (leagues_items.items, 0..) |league_json, i| {
                const league_obj = league_json.object;
                leagues[i] = League{
                    .league_key = try self.allocator.dupe(u8, league_obj.get("league_key").?.string),
                    .name = try self.allocator.dupe(u8, league_obj.get("name").?.string),
                    .num_teams = @intCast(league_obj.get("num_teams").?.integer),
                    .current_week = @intCast(league_obj.get("current_week").?.integer),
                    .game_key = try self.allocator.dupe(u8, league_obj.get("game_key").?.string),
                };
            }
            
            return leagues;
        } else {
            return try self.allocator.alloc(League, 0);
        }
    }
    
    fn getMockTeams(self: *Self, league_key: []const u8) ![]Team {
        _ = league_key; // Mock implementation returns default teams
        
        if (self.config.mock_api.simulate_delays) {
            std.time.sleep(self.config.mock_api.delay_ms * std.time.ns_per_ms);
        }
        
        // Return mock team data
        var teams = try self.allocator.alloc(Team, 2);
        teams[0] = Team{
            .team_key = try self.allocator.dupe(u8, "423.l.12345.t.1"),
            .name = try self.allocator.dupe(u8, "Team Alpha"),
            .waiver_priority = 5,
            .league_key = try self.allocator.dupe(u8, "423.l.12345"),
        };
        teams[1] = Team{
            .team_key = try self.allocator.dupe(u8, "423.l.12345.t.2"),
            .name = try self.allocator.dupe(u8, "Team Beta"),
            .waiver_priority = 3,
            .league_key = try self.allocator.dupe(u8, "423.l.12345"),
        };
        
        return teams;
    }
    
    fn getMockPlayers(self: *Self, game_key: []const u8, search_query: []const u8) ![]Player {
        _ = search_query; // Simplified mock
        
        if (self.config.mock_api.simulate_delays) {
            std.time.sleep(self.config.mock_api.delay_ms * std.time.ns_per_ms);
        }
        
        var parsed = json.parseFromSlice(json.Value, self.allocator, self.mock_data.?, .{}) catch |err| {
            return err;
        };
        defer parsed.deinit();
        
        const players_obj = parsed.value.object.get("players").?.object;
        
        if (players_obj.get(game_key)) |players_array| {
            const players_items = players_array.array;
            var players = try self.allocator.alloc(Player, players_items.items.len);
            
            for (players_items.items, 0..) |player_json, i| {
                const player_obj = player_json.object;
                players[i] = Player{
                    .player_key = try self.allocator.dupe(u8, player_obj.get("player_key").?.string),
                    .full_name = try self.allocator.dupe(u8, player_obj.get("full_name").?.string),
                    .position = try self.allocator.dupe(u8, player_obj.get("position").?.string),
                    .team = try self.allocator.dupe(u8, player_obj.get("team").?.string),
                };
            }
            
            return players;
        } else {
            return try self.allocator.alloc(Player, 0);
        }
    }
    
    fn getMockRoster(self: *Self, team_key: []const u8) ![]Player {
        if (self.config.mock_api.simulate_delays) {
            std.time.sleep(self.config.mock_api.delay_ms * std.time.ns_per_ms);
        }
        
        var parsed = json.parseFromSlice(json.Value, self.allocator, self.mock_data.?, .{}) catch |err| {
            return err;
        };
        defer parsed.deinit();
        
        const rosters_obj = parsed.value.object.get("rosters").?.object;
        
        if (rosters_obj.get(team_key)) |roster_array| {
            const roster_items = roster_array.array;
            var players = try self.allocator.alloc(Player, roster_items.items.len);
            
            for (roster_items.items, 0..) |player_json, i| {
                const player_obj = player_json.object;
                players[i] = Player{
                    .player_key = try self.allocator.dupe(u8, player_obj.get("player_key").?.string),
                    .full_name = try self.allocator.dupe(u8, player_obj.get("full_name").?.string),
                    .position = try self.allocator.dupe(u8, player_obj.get("position").?.string),
                    .team = try self.allocator.dupe(u8, player_obj.get("team").?.string),
                };
            }
            
            return players;
        } else {
            return try self.allocator.alloc(Player, 0);
        }
    }
    
    // Real API implementations (stubs for now)
    fn getRealGames(self: *Self) ![]Game {
        _ = self;
        // TODO: Implement actual Yahoo API calls
        return error.NotImplemented;
    }
    
    fn getRealLeagues(self: *Self, game_key: []const u8) ![]League {
        _ = self;
        _ = game_key;
        return error.NotImplemented;
    }
    
    fn getRealTeams(self: *Self, league_key: []const u8) ![]Team {
        _ = self;
        _ = league_key;
        return error.NotImplemented;
    }
    
    fn getRealPlayers(self: *Self, game_key: []const u8, search_query: []const u8) ![]Player {
        _ = self;
        _ = game_key;
        _ = search_query;
        return error.NotImplemented;
    }
    
    fn getRealRoster(self: *Self, team_key: []const u8) ![]Player {
        _ = self;
        _ = team_key;
        return error.NotImplemented;
    }
};

// Helper function to parse configuration
fn parseConfig(allocator: std.mem.Allocator, root: json.Value) !Config {
    const obj = root.object;
    
    return Config{
        .api_mode = try allocator.dupe(u8, obj.get("api_mode").?.string),
        .yahoo_api = .{
            .base_url = try allocator.dupe(u8, obj.get("yahoo_api").?.object.get("base_url").?.string),
            .consumer_key = try allocator.dupe(u8, obj.get("yahoo_api").?.object.get("consumer_key").?.string),
            .consumer_secret = try allocator.dupe(u8, obj.get("yahoo_api").?.object.get("consumer_secret").?.string),
        },
        .mock_api = .{
            .data_file = try allocator.dupe(u8, obj.get("mock_api").?.object.get("data_file").?.string),
            .simulate_delays = obj.get("mock_api").?.object.get("simulate_delays").?.bool,
            .delay_ms = @intCast(obj.get("mock_api").?.object.get("delay_ms").?.integer),
        },
    };
}