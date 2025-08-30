// Yahoo Fantasy Web Client (Go)
//
// Frontend web application that provides a user-friendly interface for
// Yahoo Fantasy Sports data by consuming the Web API endpoints.

package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

// ============================================================================
// Core Web Client
// ============================================================================

// WebClient represents the main HTTP server for the frontend
type WebClient struct {
	Port        int
	APIBaseURL  string
	server      *http.Server
	templates   *template.Template
}

// NewWebClient creates a new web client instance
func NewWebClient(port int, apiBaseURL string) *WebClient {
	return &WebClient{
		Port:       port,
		APIBaseURL: apiBaseURL,
	}
}

// Start begins serving the web application
func (wc *WebClient) Start() error {
	fmt.Printf("Starting Yahoo Fantasy Web Client on port %d\n", wc.Port)
	fmt.Printf("API Base URL: %s\n", wc.APIBaseURL)
	fmt.Printf("Web Client ready at http://localhost:%d\n", wc.Port)
	
	// Initialize templates
	wc.initTemplates()
	
	// Set up routes
	mux := http.NewServeMux()
	
	// Static routes
	mux.HandleFunc("/", wc.handleHome)
	mux.HandleFunc("/games", wc.handleGames)
	mux.HandleFunc("/leagues", wc.handleLeagues)
	mux.HandleFunc("/teams", wc.handleTeams)
	mux.HandleFunc("/roster", wc.handleRoster)
	mux.HandleFunc("/search", wc.handleSearch)
	mux.HandleFunc("/auth", wc.handleAuth)
	
	// API proxy routes
	mux.HandleFunc("/api/auth/tokens", wc.handleSetTokens)
	
	// Add logging middleware
	loggedMux := wc.withLogging(mux)
	
	// Configure server
	wc.server = &http.Server{
		Addr:         fmt.Sprintf(":%d", wc.Port),
		Handler:      loggedMux,
		ReadTimeout:  30 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  120 * time.Second,
	}
	
	// Start server
	return wc.server.ListenAndServe()
}

// withLogging adds request logging middleware
func (wc *WebClient) withLogging(next http.Handler) http.Handler {
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
		
		// Call next handler
		next.ServeHTTP(w, r)
		
		// Log request
		duration := time.Since(start)
		fmt.Printf("[%s] %s - (%v)\n", r.Method, r.URL.Path, duration)
	})
}

// ============================================================================
// Template Initialization
// ============================================================================

func (wc *WebClient) initTemplates() {
	wc.templates = template.Must(template.New("").Parse(`
{{define "layout"}}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{.Title}} - Yahoo Fantasy Client</title>
    <script src="https://unpkg.com/htmx.org@1.9.6"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            background: rgba(255, 255, 255, 0.95);
            padding: 1rem 0;
            margin-bottom: 2rem;
            border-radius: 12px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
        }
        
        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }
        
        .logo {
            font-size: 1.8rem;
            font-weight: bold;
            color: #4c51bf;
        }
        
        .nav-links {
            display: flex;
            gap: 1.5rem;
            flex-wrap: wrap;
        }
        
        .nav-links a {
            color: #4a5568;
            text-decoration: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            transition: all 0.2s;
            font-weight: 500;
        }
        
        .nav-links a:hover, .nav-links a.active {
            background: #4c51bf;
            color: white;
            transform: translateY(-1px);
        }
        
        .card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 12px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            backdrop-filter: blur(10px);
        }
        
        .card h2 {
            color: #2d3748;
            margin-bottom: 1.5rem;
            font-size: 1.5rem;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #4a5568;
        }
        
        .form-group input, .form-group select {
            width: 100%;
            padding: 0.75rem;
            border: 2px solid #e2e8f0;
            border-radius: 6px;
            font-size: 1rem;
            transition: border-color 0.2s;
        }
        
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #4c51bf;
        }
        
        .btn {
            background: #4c51bf;
            color: white;
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1rem;
            font-weight: 600;
            transition: all 0.2s;
            display: inline-block;
            text-decoration: none;
        }
        
        .btn:hover {
            background: #434190;
            transform: translateY(-1px);
        }
        
        .btn-secondary {
            background: #718096;
        }
        
        .btn-secondary:hover {
            background: #4a5568;
        }
        
        .grid {
            display: grid;
            gap: 1.5rem;
        }
        
        .grid-2 {
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
        }
        
        .grid-3 {
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        }
        
        .item {
            background: #f7fafc;
            padding: 1rem;
            border-radius: 8px;
            border-left: 4px solid #4c51bf;
        }
        
        .item h3 {
            color: #2d3748;
            margin-bottom: 0.5rem;
        }
        
        .item p {
            color: #718096;
            margin-bottom: 0.25rem;
        }
        
        .loading {
            text-align: center;
            padding: 2rem;
            color: #718096;
        }
        
        .error {
            background: #fed7d7;
            color: #c53030;
            padding: 1rem;
            border-radius: 6px;
            margin-bottom: 1rem;
            border-left: 4px solid #e53e3e;
        }
        
        .success {
            background: #c6f6d5;
            color: #25543e;
            padding: 1rem;
            border-radius: 6px;
            margin-bottom: 1rem;
            border-left: 4px solid #38a169;
        }
        
        .search-bar {
            display: flex;
            gap: 1rem;
            margin-bottom: 2rem;
            flex-wrap: wrap;
        }
        
        .search-bar input {
            flex: 1;
            min-width: 200px;
        }
        
        @media (max-width: 768px) {
            .nav-links {
                justify-content: center;
                width: 100%;
            }
            
            .search-bar {
                flex-direction: column;
            }
            
            .grid-2, .grid-3 {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <nav>
                <div class="logo">🏈 Fantasy Dashboard</div>
                <div class="nav-links">
                    <a href="/" {{if eq .ActivePage "home"}}class="active"{{end}}>Home</a>
                    <a href="/games" {{if eq .ActivePage "games"}}class="active"{{end}}>Games</a>
                    <a href="/search" {{if eq .ActivePage "search"}}class="active"{{end}}>Search</a>
                    <a href="/auth" {{if eq .ActivePage "auth"}}class="active"{{end}}>Settings</a>
                </div>
            </nav>
        </header>
        
        <main>
            {{template "content" .}}
        </main>
    </div>
</body>
</html>
{{end}}

{{define "home"}}
{{template "layout" .}}
{{define "content"}}
<div class="card">
    <h2>Welcome to Yahoo Fantasy Dashboard</h2>
    <p>Your comprehensive dashboard for Yahoo Fantasy Sports data. Get started by setting up your authentication credentials and exploring your fantasy data.</p>
    
    <div class="grid grid-2" style="margin-top: 2rem;">
        <div>
            <h3>Quick Start</h3>
            <ol style="padding-left: 1.5rem; color: #4a5568;">
                <li style="margin-bottom: 0.5rem;">Configure your OAuth tokens in <a href="/auth" style="color: #4c51bf;">Settings</a></li>
                <li style="margin-bottom: 0.5rem;">Browse available <a href="/games" style="color: #4c51bf;">Games</a></li>
                <li style="margin-bottom: 0.5rem;">Search for <a href="/search" style="color: #4c51bf;">Players</a></li>
            </ol>
        </div>
        
        <div>
            <h3>Features</h3>
            <ul style="padding-left: 1.5rem; color: #4a5568;">
                <li style="margin-bottom: 0.5rem;">View all available fantasy games</li>
                <li style="margin-bottom: 0.5rem;">Browse your leagues and teams</li>
                <li style="margin-bottom: 0.5rem;">Search players across games</li>
                <li style="margin-bottom: 0.5rem;">View team rosters</li>
            </ul>
        </div>
    </div>
</div>

<div class="card">
    <h2>System Status</h2>
    <div id="api-status" hx-get="/api/health" hx-trigger="load">
        <div class="loading">Checking API status...</div>
    </div>
</div>
{{end}}
{{end}}

{{define "games"}}
{{template "layout" .}}
{{define "content"}}
<div class="card">
    <h2>Available Games</h2>
    <p>Browse all available Yahoo Fantasy Sports games and leagues.</p>
    
    <div id="games-list" hx-get="{{.APIBaseURL}}/api/games" hx-trigger="load">
        <div class="loading">Loading games...</div>
    </div>
</div>
{{end}}
{{end}}

{{define "leagues"}}
{{template "layout" .}}
{{define "content"}}
<div class="card">
    <h2>Leagues for {{.GameKey}}</h2>
    
    <div id="leagues-list" hx-get="{{.APIBaseURL}}/api/leagues/{{.GameKey}}" hx-trigger="load">
        <div class="loading">Loading leagues...</div>
    </div>
</div>
{{end}}
{{end}}

{{define "teams"}}
{{template "layout" .}}
{{define "content"}}
<div class="card">
    <h2>Teams in League {{.LeagueKey}}</h2>
    
    <div id="teams-list" hx-get="{{.APIBaseURL}}/api/teams/{{.LeagueKey}}" hx-trigger="load">
        <div class="loading">Loading teams...</div>
    </div>
</div>
{{end}}
{{end}}

{{define "roster"}}
{{template "layout" .}}
{{define "content"}}
<div class="card">
    <h2>Roster for {{.TeamKey}}</h2>
    
    <div id="roster-list" hx-get="{{.APIBaseURL}}/api/roster/{{.TeamKey}}" hx-trigger="load">
        <div class="loading">Loading roster...</div>
    </div>
</div>
{{end}}
{{end}}

{{define "search"}}
{{template "layout" .}}
{{define "content"}}
<div class="card">
    <h2>Player Search</h2>
    <p>Search for players across different fantasy games.</p>
    
    <form class="search-bar">
        <select name="game" id="game-select" required>
            <option value="">Select a game...</option>
            <option value="nfl">NFL</option>
            <option value="nba">NBA</option>
            <option value="mlb">MLB</option>
        </select>
        <input type="text" name="q" id="search-query" placeholder="Enter player name..." required>
        <button type="submit" class="btn" 
                hx-get="{{.APIBaseURL}}/api/players/search"
                hx-target="#search-results"
                hx-include="[name='game'], [name='q']">
            Search
        </button>
    </form>
    
    <div id="search-results">
        <div style="text-align: center; padding: 2rem; color: #718096;">
            Enter search criteria and click Search to find players
        </div>
    </div>
</div>
{{end}}
{{end}}

{{define "auth"}}
{{template "layout" .}}
{{define "content"}}
<div class="card">
    <h2>Authentication Settings</h2>
    <p>Configure your Yahoo Fantasy API OAuth credentials to access your data.</p>
    
    <form id="auth-form">
        <div class="form-group">
            <label for="access_token">Access Token</label>
            <input type="text" id="access_token" name="access_token" required 
                   placeholder="Your OAuth access token">
        </div>
        
        <div class="form-group">
            <label for="access_token_secret">Access Token Secret</label>
            <input type="text" id="access_token_secret" name="access_token_secret" required 
                   placeholder="Your OAuth access token secret">
        </div>
        
        <button type="submit" class="btn"
                hx-post="/api/auth/tokens"
                hx-target="#auth-response"
                hx-include="#access_token, #access_token_secret">
            Save Credentials
        </button>
    </form>
    
    <div id="auth-response" style="margin-top: 1rem;"></div>
    
    <div style="margin-top: 2rem; padding: 1rem; background: #f7fafc; border-radius: 6px;">
        <h3 style="margin-bottom: 0.5rem;">How to get OAuth credentials:</h3>
        <ol style="padding-left: 1.5rem; color: #4a5568;">
            <li>Go to Yahoo Developer Console</li>
            <li>Create a new application</li>
            <li>Complete the OAuth flow</li>
            <li>Copy your access tokens here</li>
        </ol>
    </div>
</div>
{{end}}
{{end}}
`))
}

// ============================================================================
// Route Handlers
// ============================================================================

func (wc *WebClient) handleHome(w http.ResponseWriter, r *http.Request) {
	data := PageData{
		Title:      "Home",
		ActivePage: "home",
		APIBaseURL: wc.APIBaseURL,
	}
	
	if err := wc.templates.ExecuteTemplate(w, "home", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (wc *WebClient) handleGames(w http.ResponseWriter, r *http.Request) {
	data := PageData{
		Title:      "Games",
		ActivePage: "games",
		APIBaseURL: wc.APIBaseURL,
	}
	
	if err := wc.templates.ExecuteTemplate(w, "games", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (wc *WebClient) handleLeagues(w http.ResponseWriter, r *http.Request) {
	gameKey := r.URL.Query().Get("game")
	if gameKey == "" {
		http.Redirect(w, r, "/games", http.StatusSeeOther)
		return
	}
	
	data := PageData{
		Title:      "Leagues",
		ActivePage: "games",
		APIBaseURL: wc.APIBaseURL,
		GameKey:    gameKey,
	}
	
	if err := wc.templates.ExecuteTemplate(w, "leagues", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (wc *WebClient) handleTeams(w http.ResponseWriter, r *http.Request) {
	leagueKey := r.URL.Query().Get("league")
	if leagueKey == "" {
		http.Redirect(w, r, "/games", http.StatusSeeOther)
		return
	}
	
	data := PageData{
		Title:      "Teams",
		ActivePage: "games",
		APIBaseURL: wc.APIBaseURL,
		LeagueKey:  leagueKey,
	}
	
	if err := wc.templates.ExecuteTemplate(w, "teams", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (wc *WebClient) handleRoster(w http.ResponseWriter, r *http.Request) {
	teamKey := r.URL.Query().Get("team")
	if teamKey == "" {
		http.Redirect(w, r, "/games", http.StatusSeeOther)
		return
	}
	
	data := PageData{
		Title:      "Roster",
		ActivePage: "games",
		APIBaseURL: wc.APIBaseURL,
		TeamKey:    teamKey,
	}
	
	if err := wc.templates.ExecuteTemplate(w, "roster", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (wc *WebClient) handleSearch(w http.ResponseWriter, r *http.Request) {
	data := PageData{
		Title:      "Search Players",
		ActivePage: "search",
		APIBaseURL: wc.APIBaseURL,
	}
	
	if err := wc.templates.ExecuteTemplate(w, "search", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func (wc *WebClient) handleAuth(w http.ResponseWriter, r *http.Request) {
	data := PageData{
		Title:      "Authentication",
		ActivePage: "auth",
		APIBaseURL: wc.APIBaseURL,
	}
	
	if err := wc.templates.ExecuteTemplate(w, "auth", data); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// handleSetTokens proxies token setting requests to the API server
func (wc *WebClient) handleSetTokens(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}
	
	// Read request body
	body, err := io.ReadAll(r.Body)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, `<div class="error">Failed to read request body</div>`)
		return
	}
	defer r.Body.Close()
	
	// Parse form data
	if err := r.ParseForm(); err != nil {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, `<div class="error">Invalid form data</div>`)
		return
	}
	
	// Extract tokens from form
	accessToken := r.FormValue("access_token")
	accessTokenSecret := r.FormValue("access_token_secret")
	
	if accessToken == "" || accessTokenSecret == "" {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, `<div class="error">Both access token and access token secret are required</div>`)
		return
	}
	
	// Create JSON payload
	tokenData := map[string]string{
		"access_token":        accessToken,
		"access_token_secret": accessTokenSecret,
	}
	
	jsonData, err := json.Marshal(tokenData)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, `<div class="error">Failed to encode request</div>`)
		return
	}
	
	// Forward request to API server
	apiURL := fmt.Sprintf("%s/api/auth/tokens", wc.APIBaseURL)
	resp, err := http.Post(apiURL, "application/json", strings.NewReader(string(jsonData)))
	if err != nil {
		w.WriteHeader(http.StatusBadGateway)
		fmt.Fprintf(w, `<div class="error">Failed to connect to API server</div>`)
		return
	}
	defer resp.Body.Close()
	
	// Read API response
	respBody, err := io.ReadAll(resp.Body)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, `<div class="error">Failed to read API response</div>`)
		return
	}
	
	// Parse response
	var tokenResponse TokenResponse
	if err := json.Unmarshal(respBody, &tokenResponse); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, `<div class="error">Invalid API response format</div>`)
		return
	}
	
	// Return formatted response
	if tokenResponse.Success {
		fmt.Fprintf(w, `<div class="success">✓ %s</div>`, tokenResponse.Message)
	} else {
		fmt.Fprintf(w, `<div class="error">✗ Authentication failed</div>`)
	}
}

// ============================================================================
// Data Structures
// ============================================================================

// PageData represents template data
type PageData struct {
	Title      string
	ActivePage string
	APIBaseURL string
	GameKey    string
	LeagueKey  string
	TeamKey    string
}

// TokenResponse represents the token API response
type TokenResponse struct {
	Success       bool   `json:"success"`
	Message       string `json:"message"`
	Authenticated bool   `json:"authenticated"`
}

// ============================================================================
// Demo/Example Usage
// ============================================================================

func main() {
	fmt.Println("Yahoo Fantasy Web Client (Go)")
	fmt.Println("=============================")
	fmt.Println()
	
	// Initialize client
	client := NewWebClient(3000, "http://localhost:8080")
	
	fmt.Printf("Client configuration:\n")
	fmt.Printf("  Port: %d\n", client.Port)
	fmt.Printf("  API Base URL: %s\n", client.APIBaseURL)
	fmt.Println("\nFeatures:")
	fmt.Println("  • Server-side HTML rendering with Go templates")
	fmt.Println("  • HTMX integration for dynamic content")
	fmt.Println("  • Responsive design with professional styling")
	fmt.Println("  • OAuth token management")
	fmt.Println("  • API proxy for authentication")
	fmt.Println("\nStarting server...")
	fmt.Println()
	
	// Start the server (this will block)
	if err := client.Start(); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}