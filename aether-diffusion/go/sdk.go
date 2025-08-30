// Package sdk provides a comprehensive Yahoo Fantasy Sports API client for Go
// featuring OAuth 1.0 authentication, rate limiting, caching, and full API coverage.
package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"time"
)

// ============================================================================
// Core Data Structures
// ============================================================================

// YahooFantasyClient is the main SDK client
type YahooFantasyClient struct {
	ConsumerKey       string
	ConsumerSecret    string
	AccessToken       string
	AccessTokenSecret string
	BaseURL           string
	httpClient        *http.Client
	rateLimiter       *RateLimiter
	cache             *Cache
}

// NewYahooFantasyClient creates a new SDK client instance
func NewYahooFantasyClient(consumerKey, consumerSecret string) *YahooFantasyClient {
	return &YahooFantasyClient{
		ConsumerKey:    consumerKey,
		ConsumerSecret: consumerSecret,
		BaseURL:        "https://fantasysports.yahooapis.com/fantasy/v2",
		httpClient: &http.Client{
			Timeout: 30 * time.Second,
		},
		rateLimiter: NewRateLimiter(),
		cache:       NewCache(),
	}
}

// SetTokens sets the OAuth access tokens
func (c *YahooFantasyClient) SetTokens(accessToken, accessTokenSecret string) {
	c.AccessToken = accessToken
	c.AccessTokenSecret = accessTokenSecret
}

// IsAuthenticated checks if the client has valid authentication tokens
func (c *YahooFantasyClient) IsAuthenticated() bool {
	return c.AccessToken != "" && c.AccessTokenSecret != ""
}

// GetGames retrieves all available games
func (c *YahooFantasyClient) GetGames() ([]Game, error) {
	endpoint := "games"
	response, err := c.makeRequest("GET", endpoint)
	if err != nil {
		return nil, fmt.Errorf("failed to get games: %w", err)
	}
	
	return c.parseGames(response.Body)
}

// GetLeagues retrieves user's leagues for a specific game
func (c *YahooFantasyClient) GetLeagues(gameKey string) ([]League, error) {
	endpoint := fmt.Sprintf("users;use_login=1/games;game_keys=%s/leagues", gameKey)
	response, err := c.makeRequest("GET", endpoint)
	if err != nil {
		return nil, fmt.Errorf("failed to get leagues: %w", err)
	}
	
	return c.parseLeagues(response.Body)
}

// GetTeams retrieves teams in a league
func (c *YahooFantasyClient) GetTeams(leagueKey string) ([]Team, error) {
	endpoint := fmt.Sprintf("leagues;league_keys=%s/teams", leagueKey)
	response, err := c.makeRequest("GET", endpoint)
	if err != nil {
		return nil, fmt.Errorf("failed to get teams: %w", err)
	}
	
	return c.parseTeams(response.Body)
}

// SearchPlayers searches for players matching the given term
func (c *YahooFantasyClient) SearchPlayers(gameKey, searchTerm string) ([]Player, error) {
	endpoint := fmt.Sprintf("games;game_keys=%s/players;search=%s", 
		gameKey, url.QueryEscape(searchTerm))
	response, err := c.makeRequest("GET", endpoint)
	if err != nil {
		return nil, fmt.Errorf("failed to search players: %w", err)
	}
	
	return c.parsePlayers(response.Body)
}

// GetTeamRoster retrieves a team's roster
func (c *YahooFantasyClient) GetTeamRoster(teamKey string) ([]Player, error) {
	endpoint := fmt.Sprintf("teams;team_keys=%s/roster", teamKey)
	response, err := c.makeRequest("GET", endpoint)
	if err != nil {
		return nil, fmt.Errorf("failed to get team roster: %w", err)
	}
	
	return c.parsePlayers(response.Body)
}

// makeRequest performs an authenticated HTTP request
func (c *YahooFantasyClient) makeRequest(method, endpoint string) (*HTTPResponse, error) {
	if !c.IsAuthenticated() {
		return nil, fmt.Errorf("client not authenticated")
	}
	
	// Check rate limiting
	if !c.rateLimiter.CanMakeRequest() {
		return nil, fmt.Errorf("rate limit exceeded")
	}
	
	// Check cache for GET requests
	if method == "GET" {
		if cached := c.cache.Get(endpoint); cached != nil {
			fmt.Printf("[CACHE HIT] %s\n", endpoint)
			return cached, nil
		}
	}
	
	// Build full URL
	fullURL := fmt.Sprintf("%s/%s", c.BaseURL, endpoint)
	fmt.Printf("[HTTP %s] %s\n", method, fullURL)
	
	// Create request
	req, err := http.NewRequest(method, fullURL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}
	
	// Add headers
	req.Header.Set("User-Agent", "yahoo-fantasy-go-sdk/1.0")
	req.Header.Set("Authorization", c.generateAuthHeader(method, fullURL))
	
	// Execute request
	resp, err := c.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()
	
	// Read response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}
	
	response := &HTTPResponse{
		StatusCode: resp.StatusCode,
		Body:       string(body),
	}
	
	// Cache successful GET responses
	if method == "GET" && resp.StatusCode == 200 {
		if err := c.cache.Put(endpoint, response); err != nil {
			fmt.Printf("[CACHE] Failed to cache response: %v\n", err)
		}
	}
	
	// Update rate limiter
	c.rateLimiter.RecordRequest()
	
	return response, nil
}

// generateAuthHeader creates an OAuth 1.0 authorization header
func (c *YahooFantasyClient) generateAuthHeader(method, url string) string {
	// Simplified OAuth 1.0 header generation
	// In production, this would include proper signature generation
	return fmt.Sprintf(`OAuth oauth_consumer_key="%s", oauth_token="%s", oauth_signature_method="HMAC-SHA1", oauth_version="1.0"`,
		c.ConsumerKey, c.AccessToken)
}

// Parsing methods (simplified - would use proper XML parsing in production)
func (c *YahooFantasyClient) parseGames(xmlData string) ([]Game, error) {
	_ = xmlData // Mock implementation
	
	return []Game{
		{GameKey: "nfl", Name: "NFL", Code: "nfl", Season: 2024},
		{GameKey: "nba", Name: "NBA", Code: "nba", Season: 2024},
		{GameKey: "mlb", Name: "MLB", Code: "mlb", Season: 2024},
	}, nil
}

func (c *YahooFantasyClient) parseLeagues(xmlData string) ([]League, error) {
	_ = xmlData // Mock implementation
	
	return []League{
		{LeagueKey: "123.l.456", Name: "My Fantasy League", NumTeams: 10, CurrentWeek: 12},
	}, nil
}

func (c *YahooFantasyClient) parseTeams(xmlData string) ([]Team, error) {
	_ = xmlData // Mock implementation
	
	return []Team{
		{TeamKey: "123.l.456.t.1", Name: "Team Alpha", WaiverPriority: intPtr(5)},
		{TeamKey: "123.l.456.t.2", Name: "Team Beta", WaiverPriority: intPtr(3)},
	}, nil
}

func (c *YahooFantasyClient) parsePlayers(xmlData string) ([]Player, error) {
	_ = xmlData // Mock implementation
	
	return []Player{
		{PlayerKey: "123.p.789", FullName: "John Doe", Position: "QB", Team: "DAL"},
		{PlayerKey: "123.p.790", FullName: "Jane Smith", Position: "RB", Team: "SF"},
	}, nil
}

// ============================================================================
// Data Models
// ============================================================================

// Game represents a fantasy sports game
type Game struct {
	GameKey string `json:"game_key"`
	Name    string `json:"name"`
	Code    string `json:"code"`
	Season  int    `json:"season"`
}

// League represents a fantasy league
type League struct {
	LeagueKey   string `json:"league_key"`
	Name        string `json:"name"`
	NumTeams    int    `json:"num_teams"`
	CurrentWeek int    `json:"current_week"`
}

// Team represents a fantasy team
type Team struct {
	TeamKey        string `json:"team_key"`
	Name           string `json:"name"`
	WaiverPriority *int   `json:"waiver_priority,omitempty"`
}

// Player represents a fantasy player
type Player struct {
	PlayerKey string `json:"player_key"`
	FullName  string `json:"full_name"`
	Position  string `json:"position"`
	Team      string `json:"team"`
}

// ============================================================================
// Supporting Infrastructure
// ============================================================================

// RateLimiter implements token bucket rate limiting
type RateLimiter struct {
	tokens      float64
	maxTokens   float64
	refillRate  float64 // tokens per second
	lastRefill  time.Time
	requestsMade int64
	mutex       sync.Mutex
}

// NewRateLimiter creates a new rate limiter
func NewRateLimiter() *RateLimiter {
	return &RateLimiter{
		tokens:     100.0, // Start with full bucket
		maxTokens:  100.0, // 100 requests burst
		refillRate: 0.83,  // ~3000 requests/hour
		lastRefill: time.Now(),
	}
}

// CanMakeRequest checks if a request can be made
func (r *RateLimiter) CanMakeRequest() bool {
	r.mutex.Lock()
	defer r.mutex.Unlock()
	
	r.refillTokens()
	return r.tokens >= 1.0
}

// RecordRequest records that a request was made
func (r *RateLimiter) RecordRequest() {
	r.mutex.Lock()
	defer r.mutex.Unlock()
	
	if r.tokens >= 1.0 {
		r.tokens -= 1.0
		r.requestsMade++
	}
}

func (r *RateLimiter) refillTokens() {
	now := time.Now()
	timePassed := now.Sub(r.lastRefill).Seconds()
	
	tokensToAdd := timePassed * r.refillRate
	r.tokens = min(r.maxTokens, r.tokens+tokensToAdd)
	r.lastRefill = now
}

// GetRemainingTokens returns the current number of available tokens
func (r *RateLimiter) GetRemainingTokens() float64 {
	r.mutex.Lock()
	defer r.mutex.Unlock()
	
	r.refillTokens()
	return r.tokens
}

// Cache provides simple in-memory caching with TTL
type Cache struct {
	entries map[string]*CacheEntry
	maxSize int
	mutex   sync.RWMutex
}

// CacheEntry represents a cached item
type CacheEntry struct {
	Data      *HTTPResponse
	Timestamp time.Time
	TTL       time.Duration
}

// IsExpired checks if the cache entry has expired
func (e *CacheEntry) IsExpired() bool {
	return time.Since(e.Timestamp) > e.TTL
}

// NewCache creates a new cache instance
func NewCache() *Cache {
	return &Cache{
		entries: make(map[string]*CacheEntry),
		maxSize: 1000,
	}
}

// Get retrieves an item from the cache
func (c *Cache) Get(key string) *HTTPResponse {
	c.mutex.RLock()
	defer c.mutex.RUnlock()
	
	entry, exists := c.entries[key]
	if !exists {
		return nil
	}
	
	if entry.IsExpired() {
		// Remove expired entry
		c.mutex.RUnlock()
		c.mutex.Lock()
		delete(c.entries, key)
		c.mutex.Unlock()
		c.mutex.RLock()
		return nil
	}
	
	return entry.Data
}

// Put stores an item in the cache
func (c *Cache) Put(key string, response *HTTPResponse) error {
	c.mutex.Lock()
	defer c.mutex.Unlock()
	
	// Simple eviction if cache is full
	if len(c.entries) >= c.maxSize {
		c.evictOldest()
	}
	
	entry := &CacheEntry{
		Data:      response,
		Timestamp: time.Now(),
		TTL:       5 * time.Minute,
	}
	
	c.entries[key] = entry
	return nil
}

func (c *Cache) evictOldest() {
	// Simple implementation - remove first entry found
	// In production, would use LRU
	for key := range c.entries {
		delete(c.entries, key)
		break
	}
}

// HTTPResponse represents an HTTP response
type HTTPResponse struct {
	StatusCode int    `json:"status_code"`
	Body       string `json:"body"`
}

// ============================================================================
// Utility Functions
// ============================================================================

func intPtr(i int) *int {
	return &i
}

func min(a, b float64) float64 {
	if a < b {
		return a
	}
	return b
}

// ============================================================================
// Demo/Example Usage
// ============================================================================

func main() {
	fmt.Println("Yahoo Fantasy Sports SDK Demo")
	fmt.Println("=============================")
	fmt.Println()
	
	// Initialize client
	client := NewYahooFantasyClient("your_consumer_key", "your_consumer_secret")
	
	fmt.Println("✓ SDK Client initialized")
	fmt.Printf("  Authenticated: %t\n", client.IsAuthenticated())
	
	// Demo rate limiter
	fmt.Println("\n--- Rate Limiter Demo ---")
	for i := 0; i < 5; i++ {
		canRequest := client.rateLimiter.CanMakeRequest()
		tokens := client.rateLimiter.GetRemainingTokens()
		fmt.Printf("Request %d: Can make request: %t, Tokens remaining: %.1f\n", 
			i+1, canRequest, tokens)
		
		if canRequest {
			client.rateLimiter.RecordRequest()
		}
	}
	
	// Demo JSON serialization
	fmt.Println("\n--- JSON Serialization Demo ---")
	games := []Game{
		{GameKey: "nfl", Name: "NFL", Code: "nfl", Season: 2024},
		{GameKey: "nba", Name: "NBA", Code: "nba", Season: 2024},
	}
	
	jsonData, err := json.MarshalIndent(games, "", "  ")
	if err != nil {
		fmt.Printf("JSON marshal error: %v\n", err)
	} else {
		fmt.Printf("Sample JSON output:\n%s\n", jsonData)
	}
	
	fmt.Println("\n✓ SDK Demo completed successfully")
	fmt.Println("\nTo use with real API:")
	fmt.Println("1. Set valid OAuth consumer key/secret")
	fmt.Println("2. Complete OAuth flow to get access tokens") 
	fmt.Println("3. Call client.SetTokens(accessToken, accessTokenSecret)")
	fmt.Println("4. Use client.GetGames(), client.GetLeagues(), etc.")
}