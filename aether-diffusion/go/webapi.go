// Yahoo Fantasy Web API Server (Go)
//
// RESTful HTTP API server that exposes Yahoo Fantasy Sports functionality
// through clean JSON endpoints, using the underlying SDK for data access.

package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"
)

// ============================================================================
// Core Web API Server
// ============================================================================

// WebAPIServer represents the main HTTP server
type WebAPIServer struct {
	Port         int
	YahooClient  *YahooFantasyClient
	server       *http.Server
}

// NewWebAPIServer creates a new web API server instance
func NewWebAPIServer(port int, consumerKey, consumerSecret string) *WebAPIServer {
	return &WebAPIServer{
		Port:        port,
		YahooClient: NewYahooFantasyClient(consumerKey, consumerSecret),
	}
}

// SetTokens sets OAuth tokens for the underlying SDK client
func (s *WebAPIServer) SetTokens(accessToken, accessTokenSecret string) {
	s.YahooClient.SetTokens(accessToken, accessTokenSecret)
}

// Start begins serving HTTP requests
func (s *WebAPIServer) Start() error {
	fmt.Printf("Starting Yahoo Fantasy Web API Server on port %d\n", s.Port)
	fmt.Println("Available endpoints:")
	fmt.Println("  GET  /health             - Health check")
	fmt.Println("  GET  /api/games          - Get all games")
	fmt.Println("  GET  /api/leagues/{game} - Get leagues for game")
	fmt.Println("  GET  /api/teams/{league} - Get teams in league")
	fmt.Println("  GET  /api/players/search?game={game}&q={query} - Search players")
	fmt.Println("  GET  /api/roster/{team}  - Get team roster")
	fmt.Println("  POST /api/auth/tokens    - Set OAuth tokens")
	fmt.Printf("\nServer ready at http://localhost:%d\n", s.Port)
	
	// Set up routes
	mux := http.NewServeMux()
	
	// Add logging middleware
	loggedMux := s.withLogging(mux)
	
	// Register routes
	mux.HandleFunc("/health", s.handleHealth)
	mux.HandleFunc("/api/games", s.handleGames)
	mux.HandleFunc("/api/leagues/", s.handleLeagues)
	mux.HandleFunc("/api/teams/", s.handleTeams)
	mux.HandleFunc("/api/players/search", s.handlePlayerSearch)
	mux.HandleFunc("/api/roster/", s.handleRoster)
	mux.HandleFunc("/api/auth/tokens", s.handleSetTokens)
	
	// Configure server
	s.server = &http.Server{
		Addr:         fmt.Sprintf(":%d", s.Port),
		Handler:      loggedMux,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}
	
	// Start server
	return s.server.ListenAndServe()
}

// withLogging adds request logging middleware
func (s *WebAPIServer) withLogging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		
		// Add CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		
		// Handle preflight requests
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		
		// Wrap ResponseWriter to capture status code
		wrapped := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}
		
		// Call next handler
		next.ServeHTTP(wrapped, r)
		
		// Log request
		duration := time.Since(start)
		fmt.Printf("[%s] %s %s - %d (%v)\n", 
			r.Method, r.URL.Path, r.URL.RawQuery, wrapped.statusCode, duration)
	})
}

// responseWriter wraps http.ResponseWriter to capture status code
type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

// ============================================================================
// Route Handlers
// ============================================================================

func (s *WebAPIServer) handleHealth(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		s.sendError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}
	
	health := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now().Unix(),
		Version:   "1.0.0",
		Service:   "yahoo-fantasy-webapi-go",
	}
	
	s.sendJSON(w, health, http.StatusOK)
}

func (s *WebAPIServer) handleGames(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		s.sendError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}
	
	if !s.YahooClient.IsAuthenticated() {
		s.sendError(w, http.StatusUnauthorized, "Not authenticated. Please set OAuth tokens.")
		return
	}
	
	games, err := s.YahooClient.GetGames()
	if err != nil {
		s.handleSDKError(w, err)
		return
	}
	
	response := GamesResponse{
		Games: games,
		Count: len(games),
	}
	
	s.sendJSON(w, response, http.StatusOK)
}

func (s *WebAPIServer) handleLeagues(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		s.sendError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}
	
	if !s.YahooClient.IsAuthenticated() {
		s.sendError(w, http.StatusUnauthorized, "Not authenticated. Please set OAuth tokens.")
		return
	}
	
	// Extract game key from path: /api/leagues/{game_key}
	gameKey := strings.TrimPrefix(r.URL.Path, "/api/leagues/")
	if gameKey == "" {
		s.sendError(w, http.StatusBadRequest, "Game key is required")
		return
	}
	
	leagues, err := s.YahooClient.GetLeagues(gameKey)
	if err != nil {
		s.handleSDKError(w, err)
		return
	}
	
	response := LeaguesResponse{
		Leagues: leagues,
		GameKey: gameKey,
		Count:   len(leagues),
	}
	
	s.sendJSON(w, response, http.StatusOK)
}

func (s *WebAPIServer) handleTeams(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		s.sendError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}
	
	if !s.YahooClient.IsAuthenticated() {
		s.sendError(w, http.StatusUnauthorized, "Not authenticated. Please set OAuth tokens.")
		return
	}
	
	// Extract league key from path: /api/teams/{league_key}
	leagueKey := strings.TrimPrefix(r.URL.Path, "/api/teams/")
	if leagueKey == "" {
		s.sendError(w, http.StatusBadRequest, "League key is required")
		return
	}
	
	teams, err := s.YahooClient.GetTeams(leagueKey)
	if err != nil {
		s.handleSDKError(w, err)
		return
	}
	
	response := TeamsResponse{
		Teams:     teams,
		LeagueKey: leagueKey,
		Count:     len(teams),
	}
	
	s.sendJSON(w, response, http.StatusOK)
}

func (s *WebAPIServer) handlePlayerSearch(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		s.sendError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}
	
	if !s.YahooClient.IsAuthenticated() {
		s.sendError(w, http.StatusUnauthorized, "Not authenticated. Please set OAuth tokens.")
		return
	}
	
	// Parse query parameters
	gameKey := r.URL.Query().Get("game")
	searchQuery := r.URL.Query().Get("q")
	
	if gameKey == "" || searchQuery == "" {
		s.sendError(w, http.StatusBadRequest, "Both 'game' and 'q' parameters are required")
		return
	}
	
	players, err := s.YahooClient.SearchPlayers(gameKey, searchQuery)
	if err != nil {
		s.handleSDKError(w, err)
		return
	}
	
	response := PlayersResponse{
		Players:     players,
		GameKey:     gameKey,
		SearchQuery: searchQuery,
		Count:       len(players),
	}
	
	s.sendJSON(w, response, http.StatusOK)
}

func (s *WebAPIServer) handleRoster(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		s.sendError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}
	
	if !s.YahooClient.IsAuthenticated() {
		s.sendError(w, http.StatusUnauthorized, "Not authenticated. Please set OAuth tokens.")
		return
	}
	
	// Extract team key from path: /api/roster/{team_key}
	teamKey := strings.TrimPrefix(r.URL.Path, "/api/roster/")
	if teamKey == "" {
		s.sendError(w, http.StatusBadRequest, "Team key is required")
		return
	}
	
	roster, err := s.YahooClient.GetTeamRoster(teamKey)
	if err != nil {
		s.handleSDKError(w, err)
		return
	}
	
	response := RosterResponse{
		Roster:  roster,
		TeamKey: teamKey,
		Count:   len(roster),
	}
	
	s.sendJSON(w, response, http.StatusOK)
}

func (s *WebAPIServer) handleSetTokens(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		s.sendError(w, http.StatusMethodNotAllowed, "Method not allowed")
		return
	}
	
	// Read request body
	body, err := io.ReadAll(r.Body)
	if err != nil {
		s.sendError(w, http.StatusBadRequest, "Failed to read request body")
		return
	}
	defer r.Body.Close()
	
	// Parse JSON request
	var tokenReq TokenRequest
	if err := json.Unmarshal(body, &tokenReq); err != nil {
		s.sendError(w, http.StatusBadRequest, "Invalid JSON format")
		return
	}
	
	// Set tokens in SDK client
	s.YahooClient.SetTokens(tokenReq.AccessToken, tokenReq.AccessTokenSecret)
	
	response := TokenResponse{
		Success:       true,
		Message:       "Authentication tokens set successfully",
		Authenticated: s.YahooClient.IsAuthenticated(),
	}
	
	s.sendJSON(w, response, http.StatusOK)
}

// ============================================================================
// Helper Methods
// ============================================================================

func (s *WebAPIServer) sendJSON(w http.ResponseWriter, data interface{}, statusCode int) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)
	
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("Failed to encode JSON response: %v", err)
	}
}

func (s *WebAPIServer) sendError(w http.ResponseWriter, statusCode int, message string) {
	errorResponse := ErrorResponse{
		Error:     message,
		Status:    statusCode,
		Timestamp: time.Now().Unix(),
	}
	
	s.sendJSON(w, errorResponse, statusCode)
}

func (s *WebAPIServer) handleSDKError(w http.ResponseWriter, err error) {
	message := "Internal server error occurred."
	statusCode := http.StatusInternalServerError
	
	// Map SDK errors to HTTP status codes
	errorStr := err.Error()
	if strings.Contains(errorStr, "rate limit") {
		message = "Rate limit exceeded. Please try again later."
		statusCode = http.StatusTooManyRequests
	} else if strings.Contains(errorStr, "not authenticated") {
		message = "Not authenticated. Please set OAuth tokens."
		statusCode = http.StatusUnauthorized
	} else if strings.Contains(errorStr, "network") {
		message = "Network error occurred. Please try again."
		statusCode = http.StatusBadGateway
	}
	
	s.sendError(w, statusCode, message)
}

// ============================================================================
// Response Data Structures
// ============================================================================

// HealthResponse represents the health check response
type HealthResponse struct {
	Status    string `json:"status"`
	Timestamp int64  `json:"timestamp"`
	Version   string `json:"version"`
	Service   string `json:"service"`
}

// ErrorResponse represents an error response
type ErrorResponse struct {
	Error     string `json:"error"`
	Status    int    `json:"status"`
	Timestamp int64  `json:"timestamp"`
}

// GamesResponse represents the games endpoint response
type GamesResponse struct {
	Games []Game `json:"games"`
	Count int    `json:"count"`
}

// LeaguesResponse represents the leagues endpoint response
type LeaguesResponse struct {
	Leagues []League `json:"leagues"`
	GameKey string   `json:"game_key"`
	Count   int      `json:"count"`
}

// TeamsResponse represents the teams endpoint response
type TeamsResponse struct {
	Teams     []Team `json:"teams"`
	LeagueKey string `json:"league_key"`
	Count     int    `json:"count"`
}

// PlayersResponse represents the players search endpoint response
type PlayersResponse struct {
	Players     []Player `json:"players"`
	GameKey     string   `json:"game_key"`
	SearchQuery string   `json:"search_query"`
	Count       int      `json:"count"`
}

// RosterResponse represents the roster endpoint response
type RosterResponse struct {
	Roster  []Player `json:"roster"`
	TeamKey string   `json:"team_key"`
	Count   int      `json:"count"`
}

// TokenRequest represents the OAuth token setting request
type TokenRequest struct {
	AccessToken       string `json:"access_token"`
	AccessTokenSecret string `json:"access_token_secret"`
}

// TokenResponse represents the OAuth token setting response
type TokenResponse struct {
	Success       bool   `json:"success"`
	Message       string `json:"message"`
	Authenticated bool   `json:"authenticated"`
}

// ============================================================================
// Demo/Example Usage
// ============================================================================

func main() {
	fmt.Println("Yahoo Fantasy Web API Server (Go)")
	fmt.Println("==================================")
	fmt.Println()
	
	// Initialize server
	server := NewWebAPIServer(8080, "your_consumer_key", "your_consumer_secret")
	
	fmt.Printf("Server configuration:\n")
	fmt.Printf("  Port: %d\n", server.Port)
	fmt.Printf("  SDK Authenticated: %t\n", server.YahooClient.IsAuthenticated())
	fmt.Println("\nTo authenticate:")
	fmt.Println("  POST /api/auth/tokens")
	fmt.Println(`  Body: {"access_token": "your_token", "access_token_secret": "your_secret"}`)
	fmt.Println("\nStarting server...")
	fmt.Println()
	
	// Start the server (this will block)
	if err := server.Start(); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}