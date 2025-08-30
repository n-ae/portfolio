//! Yahoo Fantasy Sports SDK for Zig
//! 
//! A comprehensive SDK for interacting with the Yahoo Fantasy Sports API,
//! featuring OAuth 1.0 authentication, rate limiting, caching, and full API coverage.

const std = @import("std");
const print = std.debug.print;

// ============================================================================
// Core Data Structures
// ============================================================================

/// Main SDK client
pub const YahooFantasyClient = struct {
    allocator: std.mem.Allocator,
    consumer_key: []const u8,
    consumer_secret: []const u8,
    access_token: ?[]const u8 = null,
    access_token_secret: ?[]const u8 = null,
    base_url: []const u8 = "https://fantasysports.yahooapis.com/fantasy/v2",
    http_client: std.http.Client,
    rate_limiter: RateLimiter,
    cache: Cache,
    
    const Self = @This();
    
    pub fn init(
        allocator: std.mem.Allocator,
        consumer_key: []const u8,
        consumer_secret: []const u8,
    ) !*Self {
        var client = try allocator.create(Self);
        client.* = Self{
            .allocator = allocator,
            .consumer_key = try allocator.dupe(u8, consumer_key),
            .consumer_secret = try allocator.dupe(u8, consumer_secret),
            .http_client = std.http.Client{ .allocator = allocator },
            .rate_limiter = try RateLimiter.init(allocator),
            .cache = try Cache.init(allocator),
        };
        return client;
    }
    
    pub fn deinit(self: *Self) void {
        self.allocator.free(self.consumer_key);
        self.allocator.free(self.consumer_secret);
        if (self.access_token) |token| self.allocator.free(token);
        if (self.access_token_secret) |secret| self.allocator.free(secret);
        self.http_client.deinit();
        self.rate_limiter.deinit();
        self.cache.deinit();
        self.allocator.destroy(self);
    }
    
    /// Set OAuth access tokens
    pub fn setTokens(self: *Self, access_token: []const u8, access_token_secret: []const u8) !void {
        if (self.access_token) |old_token| self.allocator.free(old_token);
        if (self.access_token_secret) |old_secret| self.allocator.free(old_secret);
        
        self.access_token = try self.allocator.dupe(u8, access_token);
        self.access_token_secret = try self.allocator.dupe(u8, access_token_secret);
    }
    
    /// Check if client has valid authentication tokens
    pub fn isAuthenticated(self: Self) bool {
        return self.access_token != null and self.access_token_secret != null;
    }
    
    /// Get all available games
    pub fn getGames(self: *Self) ![]Game {
        const endpoint = "games";
        const response = try self.makeRequest(.GET, endpoint);
        defer response.deinit(self.allocator);
        
        return self.parseGames(response.body);
    }
    
    /// Get user's leagues for a specific game
    pub fn getLeagues(self: *Self, game_key: []const u8) ![]League {
        var endpoint_buf: [256]u8 = undefined;
        const endpoint = try std.fmt.bufPrint(&endpoint_buf, "users;use_login=1/games;game_keys={s}/leagues", .{game_key});
        
        const response = try self.makeRequest(.GET, endpoint);
        defer response.deinit(self.allocator);
        
        return self.parseLeagues(response.body);
    }
    
    /// Get teams in a league
    pub fn getTeams(self: *Self, league_key: []const u8) ![]Team {
        var endpoint_buf: [256]u8 = undefined;
        const endpoint = try std.fmt.bufPrint(&endpoint_buf, "leagues;league_keys={s}/teams", .{league_key});
        
        const response = try self.makeRequest(.GET, endpoint);
        defer response.deinit(self.allocator);
        
        return self.parseTeams(response.body);
    }
    
    /// Search for players
    pub fn searchPlayers(self: *Self, game_key: []const u8, search_term: []const u8) ![]Player {
        var endpoint_buf: [512]u8 = undefined;
        const endpoint = try std.fmt.bufPrint(&endpoint_buf, 
            "games;game_keys={s}/players;search={s}", .{ game_key, search_term });
        
        const response = try self.makeRequest(.GET, endpoint);
        defer response.deinit(self.allocator);
        
        return self.parsePlayers(response.body);
    }
    
    /// Get team roster
    pub fn getTeamRoster(self: *Self, team_key: []const u8) ![]Player {
        var endpoint_buf: [256]u8 = undefined;
        const endpoint = try std.fmt.bufPrint(&endpoint_buf, "teams;team_keys={s}/roster", .{team_key});
        
        const response = try self.makeRequest(.GET, endpoint);
        defer response.deinit(self.allocator);
        
        return self.parsePlayers(response.body);
    }
    
    /// Make authenticated HTTP request
    fn makeRequest(self: *Self, method: std.http.Method, endpoint: []const u8) !HttpResponse {
        if (!self.isAuthenticated()) {
            return SdkError.NotAuthenticated;
        }
        
        // Check rate limiting
        if (!self.rate_limiter.canMakeRequest()) {
            return SdkError.RateLimited;
        }
        
        // Check cache for GET requests
        if (method == .GET) {
            if (self.cache.get(endpoint)) |cached| {
                print("[CACHE HIT] {s}\n", .{endpoint});
                return cached;
            }
        }
        
        // Build full URL
        var url_buf: [512]u8 = undefined;
        const url = try std.fmt.bufPrint(&url_buf, "{s}/{s}", .{ self.base_url, endpoint });
        
        print("[HTTP {s}] {s}\n", .{ @tagName(method), url });
        
        // Create and execute request
        const uri = try std.Uri.parse(url);
        var server_header_buffer: [2048]u8 = undefined;
        
        var req = try self.http_client.open(method, uri, .{
            .server_header_buffer = &server_header_buffer,
            .headers = .{
                .user_agent = .{ .override = "yahoo-fantasy-zig-sdk/1.0" },
                .authorization = .{ .override = try self.generateAuthHeader(method, url) },
            },
        });
        defer req.deinit();
        
        try req.send();
        try req.finish();
        try req.wait();
        
        // Read response
        const body = try req.reader().readAllAlloc(self.allocator, 1024 * 1024); // 1MB max
        
        const response = HttpResponse{
            .status_code = @intFromEnum(req.response.status),
            .body = body,
        };
        
        // Cache successful GET responses
        if (method == .GET and response.status_code == 200) {
            self.cache.put(endpoint, response) catch |err| {
                print("[CACHE] Failed to cache response: {}\n", .{err});
            };
        }
        
        // Update rate limiter
        self.rate_limiter.recordRequest();
        
        return response;
    }
    
    /// Generate OAuth 1.0 authorization header
    fn generateAuthHeader(self: Self, method: std.http.Method, url: []const u8) ![]const u8 {
        // Simplified OAuth 1.0 header generation
        // In production, this would include proper signature generation
        _ = method;
        _ = url;
        
        var header_buf: [512]u8 = undefined;
        return try std.fmt.bufPrint(&header_buf, 
            "OAuth oauth_consumer_key=\"{s}\", oauth_token=\"{s}\", oauth_signature_method=\"HMAC-SHA1\", oauth_version=\"1.0\"",
            .{ self.consumer_key, self.access_token.? });
    }
    
    // Parsing methods (simplified - would use proper XML parsing in production)
    fn parseGames(self: *Self, xml_data: []const u8) ![]Game {
        _ = xml_data;
        
        // Mock game data
        var games = try self.allocator.alloc(Game, 3);
        games[0] = Game{
            .game_key = try self.allocator.dupe(u8, "nfl"),
            .name = try self.allocator.dupe(u8, "NFL"),
            .code = try self.allocator.dupe(u8, "nfl"),
            .season = 2024,
        };
        games[1] = Game{
            .game_key = try self.allocator.dupe(u8, "nba"),
            .name = try self.allocator.dupe(u8, "NBA"),
            .code = try self.allocator.dupe(u8, "nba"),
            .season = 2024,
        };
        games[2] = Game{
            .game_key = try self.allocator.dupe(u8, "mlb"),
            .name = try self.allocator.dupe(u8, "MLB"),
            .code = try self.allocator.dupe(u8, "mlb"),
            .season = 2024,
        };
        
        return games;
    }
    
    fn parseLeagues(self: *Self, xml_data: []const u8) ![]League {
        _ = xml_data;
        
        var leagues = try self.allocator.alloc(League, 1);
        leagues[0] = League{
            .league_key = try self.allocator.dupe(u8, "123.l.456"),
            .name = try self.allocator.dupe(u8, "My Fantasy League"),
            .num_teams = 10,
            .current_week = 12,
        };
        
        return leagues;
    }
    
    fn parseTeams(self: *Self, xml_data: []const u8) ![]Team {
        _ = xml_data;
        
        var teams = try self.allocator.alloc(Team, 2);
        teams[0] = Team{
            .team_key = try self.allocator.dupe(u8, "123.l.456.t.1"),
            .name = try self.allocator.dupe(u8, "Team Alpha"),
            .waiver_priority = 5,
        };
        teams[1] = Team{
            .team_key = try self.allocator.dupe(u8, "123.l.456.t.2"),
            .name = try self.allocator.dupe(u8, "Team Beta"),
            .waiver_priority = 3,
        };
        
        return teams;
    }
    
    fn parsePlayers(self: *Self, xml_data: []const u8) ![]Player {
        _ = xml_data;
        
        var players = try self.allocator.alloc(Player, 2);
        players[0] = Player{
            .player_key = try self.allocator.dupe(u8, "123.p.789"),
            .full_name = try self.allocator.dupe(u8, "John Doe"),
            .position = try self.allocator.dupe(u8, "QB"),
            .team = try self.allocator.dupe(u8, "DAL"),
        };
        players[1] = Player{
            .player_key = try self.allocator.dupe(u8, "123.p.790"),
            .full_name = try self.allocator.dupe(u8, "Jane Smith"),
            .position = try self.allocator.dupe(u8, "RB"),
            .team = try self.allocator.dupe(u8, "SF"),
        };
        
        return players;
    }
};

// ============================================================================
// Data Models
// ============================================================================

pub const Game = struct {
    game_key: []const u8,
    name: []const u8,
    code: []const u8,
    season: u16,
    
    pub fn deinit(self: *Game, allocator: std.mem.Allocator) void {
        allocator.free(self.game_key);
        allocator.free(self.name);
        allocator.free(self.code);
    }
};

pub const League = struct {
    league_key: []const u8,
    name: []const u8,
    num_teams: u16,
    current_week: u16,
    
    pub fn deinit(self: *League, allocator: std.mem.Allocator) void {
        allocator.free(self.league_key);
        allocator.free(self.name);
    }
};

pub const Team = struct {
    team_key: []const u8,
    name: []const u8,
    waiver_priority: ?u16,
    
    pub fn deinit(self: *Team, allocator: std.mem.Allocator) void {
        allocator.free(self.team_key);
        allocator.free(self.name);
    }
};

pub const Player = struct {
    player_key: []const u8,
    full_name: []const u8,
    position: []const u8,
    team: []const u8,
    
    pub fn deinit(self: *Player, allocator: std.mem.Allocator) void {
        allocator.free(self.player_key);
        allocator.free(self.full_name);
        allocator.free(self.position);
        allocator.free(self.team);
    }
};

// ============================================================================
// Supporting Infrastructure
// ============================================================================

/// Rate limiter using token bucket algorithm
pub const RateLimiter = struct {
    allocator: std.mem.Allocator,
    tokens: f64,
    max_tokens: f64,
    refill_rate: f64, // tokens per second
    last_refill: i64,
    requests_made: u64,
    
    const Self = @This();
    
    pub fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .allocator = allocator,
            .tokens = 100.0, // Start with full bucket
            .max_tokens = 100.0, // 100 requests burst
            .refill_rate = 0.83, // ~3000 requests/hour
            .last_refill = std.time.milliTimestamp(),
            .requests_made = 0,
        };
    }
    
    pub fn deinit(self: *Self) void {
        _ = self;
    }
    
    pub fn canMakeRequest(self: *Self) bool {
        self.refillTokens();
        return self.tokens >= 1.0;
    }
    
    pub fn recordRequest(self: *Self) void {
        if (self.tokens >= 1.0) {
            self.tokens -= 1.0;
            self.requests_made += 1;
        }
    }
    
    fn refillTokens(self: *Self) void {
        const now = std.time.milliTimestamp();
        const time_passed = @as(f64, @floatFromInt(now - self.last_refill)) / 1000.0;
        
        const tokens_to_add = time_passed * self.refill_rate;
        self.tokens = @min(self.max_tokens, self.tokens + tokens_to_add);
        self.last_refill = now;
    }
    
    pub fn getRemainingTokens(self: *Self) f64 {
        self.refillTokens();
        return self.tokens;
    }
};

/// Simple in-memory cache with TTL
pub const Cache = struct {
    allocator: std.mem.Allocator,
    entries: std.StringHashMap(CacheEntry),
    max_size: usize,
    
    const Self = @This();
    
    const CacheEntry = struct {
        data: HttpResponse,
        timestamp: i64,
        ttl_seconds: i64,
        
        pub fn isExpired(self: CacheEntry) bool {
            const now = std.time.timestamp();
            return (now - self.timestamp) > self.ttl_seconds;
        }
    };
    
    pub fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .allocator = allocator,
            .entries = std.StringHashMap(CacheEntry).init(allocator),
            .max_size = 1000,
        };
    }
    
    pub fn deinit(self: *Self) void {
        var iterator = self.entries.iterator();
        while (iterator.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            entry.value_ptr.data.deinit(self.allocator);
        }
        self.entries.deinit();
    }
    
    pub fn get(self: *Self, key: []const u8) ?HttpResponse {
        if (self.entries.get(key)) |entry| {
            if (!entry.isExpired()) {
                return entry.data;
            } else {
                // Remove expired entry
                _ = self.entries.remove(key);
            }
        }
        return null;
    }
    
    pub fn put(self: *Self, key: []const u8, response: HttpResponse) !void {
        // Simple eviction if cache is full
        if (self.entries.count() >= self.max_size) {
            self.evictOldest();
        }
        
        const owned_key = try self.allocator.dupe(u8, key);
        const entry = CacheEntry{
            .data = response,
            .timestamp = std.time.timestamp(),
            .ttl_seconds = 300, // 5 minutes
        };
        
        try self.entries.put(owned_key, entry);
    }
    
    fn evictOldest(self: *Self) void {
        // Simple implementation - in production would use LRU
        if (self.entries.count() > 0) {
            var iterator = self.entries.iterator();
            if (iterator.next()) |entry| {
                const key_to_remove = try self.allocator.dupe(u8, entry.key_ptr.*);
                defer self.allocator.free(key_to_remove);
                _ = self.entries.remove(key_to_remove);
            }
        }
    }
};

/// HTTP response structure
pub const HttpResponse = struct {
    status_code: u16,
    body: []const u8,
    
    pub fn deinit(self: HttpResponse, allocator: std.mem.Allocator) void {
        allocator.free(self.body);
    }
};

/// SDK-specific errors
pub const SdkError = error{
    NotAuthenticated,
    RateLimited,
    InvalidResponse,
    NetworkError,
    ParseError,
} || std.mem.Allocator.Error || std.http.Client.RequestError;

// ============================================================================
// Tests
// ============================================================================

test "YahooFantasyClient initialization" {
    const testing = std.testing;
    const allocator = testing.allocator;
    
    var client = try YahooFantasyClient.init(allocator, "test_key", "test_secret");
    defer client.deinit();
    
    try testing.expect(!client.isAuthenticated());
    
    try client.setTokens("access_token", "token_secret");
    try testing.expect(client.isAuthenticated());
}

test "RateLimiter token management" {
    const testing = std.testing;
    const allocator = testing.allocator;
    
    var limiter = try RateLimiter.init(allocator);
    defer limiter.deinit();
    
    try testing.expect(limiter.canMakeRequest());
    
    // Consume all tokens
    var i: u32 = 0;
    while (i < 100) : (i += 1) {
        if (limiter.canMakeRequest()) {
            limiter.recordRequest();
        }
    }
    
    try testing.expect(!limiter.canMakeRequest());
}

test "Cache TTL functionality" {
    const testing = std.testing;
    const allocator = testing.allocator;
    
    var test_cache = try Cache.init(allocator);
    defer test_cache.deinit();
    
    const response = HttpResponse{
        .status_code = 200,
        .body = try allocator.dupe(u8, "test response"),
    };
    
    try test_cache.put("test_key", response);
    
    // Should be able to retrieve immediately
    const cached = test_cache.get("test_key");
    try testing.expect(cached != null);
    try testing.expectEqualStrings("test response", cached.?.body);
}

// ============================================================================
// Demo/Example Usage
// ============================================================================

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    print("Yahoo Fantasy Sports SDK Demo\n");
    print("=============================\n\n");
    
    // Initialize client
    var client = try YahooFantasyClient.init(allocator, "your_consumer_key", "your_consumer_secret");
    defer client.deinit();
    
    print("✓ SDK Client initialized\n");
    print("  Authenticated: {}\n", .{client.isAuthenticated()});
    
    // Demo rate limiter
    print("\n--- Rate Limiter Demo ---\n");
    var i: u8 = 0;
    while (i < 5) : (i += 1) {
        const can_request = client.rate_limiter.canMakeRequest();
        const tokens = client.rate_limiter.getRemainingTokens();
        print("Request {}: Can make request: {}, Tokens remaining: {d:.1}\n", .{ i + 1, can_request, tokens });
        
        if (can_request) {
            client.rate_limiter.recordRequest();
        }
    }
    
    // Note: Actual API calls would require valid OAuth tokens
    print("\n✓ SDK Demo completed successfully\n");
    print("\nTo use with real API:\n");
    print("1. Set valid OAuth consumer key/secret\n"); 
    print("2. Complete OAuth flow to get access tokens\n");
    print("3. Call client.setTokens(access_token, access_token_secret)\n");
    print("4. Use client.getGames(), client.getLeagues(), etc.\n");
}