package yahoo

import (
	"context"
	"encoding/xml"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/time/rate"
)

// Client is the main Yahoo Fantasy Sports SDK client
type Client struct {
	config      Config
	auth        *AuthManager
	httpClient  *http.Client
	rateLimiter *rate.Limiter
	baseURL     string
}

// NewClient creates a new Yahoo Fantasy Sports SDK client
func NewClient(config Config) (*Client, error) {
	// Apply defaults for unset values
	if config.BaseURL == "" {
		defaultConfig := DefaultConfig()
		config.BaseURL = defaultConfig.BaseURL
		config.APIVersion = defaultConfig.APIVersion
		config.RateLimit = defaultConfig.RateLimit
		config.Timeout = defaultConfig.Timeout
		config.BurstLimit = defaultConfig.BurstLimit
		config.MaxRetries = defaultConfig.MaxRetries
		config.RetryDelay = defaultConfig.RetryDelay
		config.RetryMaxDelay = defaultConfig.RetryMaxDelay
	}

	if err := config.Validate(); err != nil {
		return nil, fmt.Errorf("invalid configuration: %w", err)
	}

	// Create rate limiter (Yahoo allows 1000 requests per hour)
	rps := float64(config.RateLimit) / 3600.0 // Convert requests per hour to requests per second
	rateLimiter := rate.NewLimiter(rate.Limit(rps), config.BurstLimit)

	client := &Client{
		config:      config,
		auth:        NewAuthManager(config),
		httpClient:  &http.Client{Timeout: config.Timeout},
		rateLimiter: rateLimiter,
		baseURL:     strings.TrimSuffix(config.BaseURL, "/"),
	}

	return client, nil
}


// SetToken sets a pre-obtained OAuth token
func (c *Client) SetToken(token *oauth2.Token) {
	c.auth.SetToken(token)
}

// GetAuthURL returns the OAuth authorization URL for manual authentication
func (c *Client) GetAuthURL(state string) string {
	return c.auth.GetAuthURL(state)
}

// ExchangeCode exchanges an authorization code for an access token
func (c *Client) ExchangeCode(ctx context.Context, code string) (*oauth2.Token, error) {
	return c.auth.ExchangeCode(ctx, code)
}

// IsAuthenticated checks if the client is authenticated
func (c *Client) IsAuthenticated() bool {
	return c.auth.IsAuthenticated()
}

// GetNBAPlayers retrieves all NBA players from Yahoo Fantasy Sports API
func (c *Client) GetNBAPlayers(ctx context.Context) ([]Player, error) {

	var allPlayers []Player
	start := 0
	count := 25 // Yahoo API pagination limit

	for {
		players, hasMore, err := c.getNBAPlayersPage(ctx, start, count)
		if err != nil {
			return nil, fmt.Errorf("failed to get players page (start=%d): %w", start, err)
		}

		allPlayers = append(allPlayers, players...)

		if !hasMore || len(players) < count {
			break
		}

		start += count

		// Add small delay between requests to be respectful
		time.Sleep(100 * time.Millisecond)
	}

	// Normalize player data
	for i := range allPlayers {
		allPlayers[i].Normalize()
	}

	return allPlayers, nil
}

// getNBAPlayersPage gets a single page of NBA players
func (c *Client) getNBAPlayersPage(ctx context.Context, start, count int) ([]Player, bool, error) {
	// Build URL for NBA players
	gameKey := "nba" // Current NBA season game key
	endpoint := fmt.Sprintf("/game/%s/players;start=%d;count=%d", gameKey, start, count)

	response, err := c.makeAPIRequest(ctx, endpoint)
	if err != nil {
		return nil, false, err
	}

	var apiResponse APIResponse
	if err := xml.Unmarshal(response, &apiResponse); err != nil {
		return nil, false, fmt.Errorf("failed to unmarshal players response: %w", err)
	}

	players := []Player{}
	if apiResponse.Players != nil {
		players = apiResponse.Players.Player
	}

	// Check if there are more pages
	hasMore := len(players) == count

	return players, hasMore, nil
}

// GetNBATeams retrieves all NBA teams from Yahoo Fantasy Sports API
func (c *Client) GetNBATeams(ctx context.Context) ([]Team, error) {

	// Build URL for NBA teams
	gameKey := "nba" // Current NBA season game key
	endpoint := fmt.Sprintf("/game/%s/teams", gameKey)

	response, err := c.makeAPIRequest(ctx, endpoint)
	if err != nil {
		return nil, fmt.Errorf("failed to get teams: %w", err)
	}

	var apiResponse APIResponse
	if err := xml.Unmarshal(response, &apiResponse); err != nil {
		return nil, fmt.Errorf("failed to unmarshal teams response: %w", err)
	}

	teams := []Team{}
	if apiResponse.Teams != nil {
		teams = apiResponse.Teams.Team
		
		// Normalize team data
		for i := range teams {
			teams[i].Normalize()
		}
	}

	return teams, nil
}

// GetPlayerStats retrieves statistics for a specific player
func (c *Client) GetPlayerStats(ctx context.Context, playerKey string) (*Player, error) {

	endpoint := fmt.Sprintf("/player/%s/stats", playerKey)

	response, err := c.makeAPIRequest(ctx, endpoint)
	if err != nil {
		return nil, fmt.Errorf("failed to get player stats: %w", err)
	}

	var apiResponse APIResponse
	if err := xml.Unmarshal(response, &apiResponse); err != nil {
		return nil, fmt.Errorf("failed to unmarshal player stats response: %w", err)
	}

	if apiResponse.Players == nil || len(apiResponse.Players.Player) == 0 {
		return nil, fmt.Errorf("no player data found for key: %s", playerKey)
	}

	player := &apiResponse.Players.Player[0]
	player.Normalize()

	return player, nil
}

// GetTeamRoster retrieves the roster for a specific team
func (c *Client) GetTeamRoster(ctx context.Context, teamKey string) (*Roster, error) {

	endpoint := fmt.Sprintf("/team/%s/roster", teamKey)

	response, err := c.makeAPIRequest(ctx, endpoint)
	if err != nil {
		return nil, fmt.Errorf("failed to get team roster: %w", err)
	}

	// Parse roster response (this would need proper XML structure parsing)
	var roster Roster
	if err := xml.Unmarshal(response, &roster); err != nil {
		return nil, fmt.Errorf("failed to unmarshal roster response: %w", err)
	}

	// Normalize player data in roster
	if roster.Players != nil {
		for i := range roster.Players.Player {
			roster.Players.Player[i].Normalize()
		}
	}

	return &roster, nil
}

// makeAPIRequest makes an authenticated request to the Yahoo API
func (c *Client) makeAPIRequest(ctx context.Context, endpoint string) ([]byte, error) {
	// Apply rate limiting
	if err := c.rateLimiter.Wait(ctx); err != nil {
		return nil, fmt.Errorf("rate limiting error: %w", err)
	}

	// Get authenticated HTTP client
	httpClient, err := c.auth.GetHTTPClient(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get authenticated HTTP client: %w", err)
	}

	// Build full URL
	fullURL := c.baseURL + endpoint
	if !strings.Contains(fullURL, "format=") {
		// Add format parameter if not already present
		separator := "?"
		if strings.Contains(fullURL, "?") {
			separator = "&"
		}
		fullURL += separator + "format=xml"
	}


	// Create request with timeout
	reqCtx, cancel := context.WithTimeout(ctx, c.config.Timeout)
	defer cancel()

	req, err := http.NewRequestWithContext(reqCtx, "GET", fullURL, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	// Add headers
	req.Header.Set("User-Agent", "NBA-Fantasy-SDK-Go/1.0")
	req.Header.Set("Accept", "application/xml")

	// Make request
	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("request failed: %w", err)
	}
	defer resp.Body.Close()

	// Read response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// Check for API errors
	if resp.StatusCode != http.StatusOK {
		return nil, &APIError{
			StatusCode: resp.StatusCode,
			Message:    fmt.Sprintf("API request failed with status %d", resp.StatusCode),
			Details:    string(body),
		}
	}

	// Check for rate limiting
	if resp.StatusCode == http.StatusTooManyRequests {
		retryAfter := resp.Header.Get("Retry-After")
		if retryAfter != "" {
			if seconds, err := strconv.Atoi(retryAfter); err == nil {
				return nil, &RateLimitError{
					RetryAfter: time.Duration(seconds) * time.Second,
					Message:    "Rate limit exceeded",
				}
			}
		}
		return nil, &RateLimitError{
			RetryAfter: time.Minute,
			Message:    "Rate limit exceeded",
		}
	}


	return body, nil
}

