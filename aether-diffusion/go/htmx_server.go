// NBA Fantasy Sports Database - HTMX-Powered Server
package main

import (
	"database/sql"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

type HTMXServer struct {
	db *sql.DB
}

type Player struct {
	ID            int
	FullName      string
	FirstName     string
	LastName      string
	Team          string
	Position      string
	UniformNumber string
	IsActive      bool
	YahooPlayerKey string
}

type Team struct {
	ID           int
	Abbreviation string
	FullName     string
	City         string
	Conference   string
	Division     string
	PlayerCount  int
	YahooTeamKey string
}

type PageData struct {
	Title             string
	CurrentPage       string
	LastUpdated       string
	TotalPlayers      int
	TotalTeams        int
	TeamsWithData     int
	TotalPositions    int
	ActivePlayers     int
	AvgPlayersPerTeam int
	SamplePlayers     []Player
	Teams             []Team
	Players           []Player
}

func NewHTMXServer(dbPath string) (*HTMXServer, error) {
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %v", err)
	}

	return &HTMXServer{
		db: db,
	}, nil
}

func (s *HTMXServer) GetPlayers() ([]Player, error) {
	query := FileSQL.MustGetQuery("get_all_players")
	rows, err := s.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var players []Player
	for rows.Next() {
		var p Player
		err := rows.Scan(&p.ID, &p.FullName, &p.FirstName, &p.LastName, 
			&p.Team, &p.Position, &p.UniformNumber, &p.IsActive, &p.YahooPlayerKey)
		if err != nil {
			continue
		}
		players = append(players, p)
	}

	return players, nil
}

func (s *HTMXServer) GetTeams() ([]Team, error) {
	query := FileSQL.MustGetQuery("get_all_teams")
	rows, err := s.db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var teams []Team
	for rows.Next() {
		var t Team
		err := rows.Scan(&t.ID, &t.Abbreviation, &t.FullName, &t.City,
			&t.Conference, &t.Division, &t.PlayerCount, &t.YahooTeamKey)
		if err != nil {
			continue
		}
		teams = append(teams, t)
	}

	return teams, nil
}

// Dashboard handler - now serves backend-agnostic HTML
func (s *HTMXServer) dashboardHandler(w http.ResponseWriter, r *http.Request) {
	if isHTMXRequest(r) {
		// Serve dashboard content for HTMX requests
		http.ServeFile(w, r, "../templates/dashboard.html")
	} else {
		// Serve base page with dashboard content injected
		w.Header().Set("Content-Type", "text/html")
		content, err := os.ReadFile("../templates/base.html")
		if err != nil {
			http.Error(w, "Template not found", 404)
			return
		}
		
		// Inject dashboard content into main content area
		html := string(content)
		dashboardContent, err := os.ReadFile("../templates/dashboard.html")
		if err == nil {
			html = strings.Replace(html, "<!-- PLACEHOLDER: Main content injected here by backend or HTMX -->", string(dashboardContent), 1)
		}
		
		w.Write([]byte(html))
	}
}

// Players page handler - now serves backend-agnostic HTML
func (s *HTMXServer) playersHandler(w http.ResponseWriter, r *http.Request) {
	if isHTMXRequest(r) {
		// Serve players content for HTMX requests
		http.ServeFile(w, r, "../templates/players.html")
	} else {
		// Serve base page with players content injected
		w.Header().Set("Content-Type", "text/html")
		content, err := os.ReadFile("../templates/base.html")
		if err != nil {
			http.Error(w, "Template not found", 404)
			return
		}
		
		// Update title and main content for players page
		html := string(content)
		html = strings.Replace(html, "Fantasy Sports Database", "Players - Fantasy Sports Database", 1)
		html = strings.Replace(html, "Fantasy Sports Database</h1>", "NBA Players</h1>", 1)
		
		// Inject players content into main content area
		playersContent, err := os.ReadFile("../templates/players.html")
		if err == nil {
			html = strings.Replace(html, "<!-- PLACEHOLDER: Main content injected here by backend or HTMX -->", string(playersContent), 1)
		}
		
		w.Write([]byte(html))
	}
}

// Teams page handler - now serves backend-agnostic HTML
func (s *HTMXServer) teamsHandler(w http.ResponseWriter, r *http.Request) {
	if isHTMXRequest(r) {
		// Serve teams content for HTMX requests
		http.ServeFile(w, r, "../templates/teams.html")
	} else {
		// Serve base page with teams content injected
		w.Header().Set("Content-Type", "text/html")
		content, err := os.ReadFile("../templates/base.html")
		if err != nil {
			http.Error(w, "Template not found", 404)
			return
		}
		
		// Update title and main content for teams page
		html := string(content)
		html = strings.Replace(html, "Fantasy Sports Database", "Teams - Fantasy Sports Database", 1)
		html = strings.Replace(html, "Fantasy Sports Database</h1>", "NBA Teams</h1>", 1)
		
		// Inject teams content into main content area
		teamsContent, err := os.ReadFile("../templates/teams.html")
		if err == nil {
			html = strings.Replace(html, "<!-- PLACEHOLDER: Main content injected here by backend or HTMX -->", string(teamsContent), 1)
		}
		
		w.Write([]byte(html))
	}
}

// HTMX API endpoints
func (s *HTMXServer) apiStatsHandler(w http.ResponseWriter, r *http.Request) {
	players, _ := s.GetPlayers()
	teams, _ := s.GetTeams()
	
	activeTeams := 0
	for _, team := range teams {
		if team.PlayerCount > 0 {
			activeTeams++
		}
	}

	var positionCount int
	query := FileSQL.MustGetQuery("get_position_assignment_count")
	s.db.QueryRow(query).Scan(&positionCount)

	statsHTML := fmt.Sprintf(`
		<div class="stat-card">
			<div class="stat-number">%d</div>
			<div class="stat-label">NBA Players</div>
		</div>
		<div class="stat-card">
			<div class="stat-number">%d</div>
			<div class="stat-label">Teams with Players</div>
		</div>
		<div class="stat-card">
			<div class="stat-number">%d</div>
			<div class="stat-label">Total NBA Teams</div>
		</div>
		<div class="stat-card">
			<div class="stat-number">%d</div>
			<div class="stat-label">Position Assignments</div>
		</div>
	`, len(players), activeTeams, len(teams), positionCount)

	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(statsHTML))
}

func (s *HTMXServer) apiSamplePlayersHandler(w http.ResponseWriter, r *http.Request) {
	players, _ := s.GetPlayers()
	samplePlayers := getSamplePlayers(players, 12)

	var html strings.Builder
	for _, player := range samplePlayers {
		html.WriteString(fmt.Sprintf(`
			<div class="card" onclick="showPlayerDetails(%d)">
				<div class="card-title">%s</div>
				<div class="card-content">
					%s`, player.ID, player.FullName, player.Team))
		
		if player.Position != "" {
			html.WriteString(" • " + player.Position)
		}
		if player.UniformNumber != "" {
			html.WriteString(" • #" + player.UniformNumber)
		}
		
		html.WriteString(`
				</div>
			</div>
		`)
	}

	w.Header().Set("Content-Type", "text/html")
	w.Write([]byte(html.String()))
}

func (s *HTMXServer) apiPlayersViewHandler(w http.ResponseWriter, r *http.Request) {
	viewType := r.URL.Path[len("/api/players/view/"):]
	players, _ := s.GetPlayers()

	w.Header().Set("Content-Type", "text/html")

	if viewType == "table" {
		s.renderPlayersTable(w, players)
	} else {
		s.renderPlayersCards(w, players)
	}
}

func (s *HTMXServer) renderPlayersTable(w http.ResponseWriter, players []Player) {
	var html strings.Builder
	html.WriteString(`
		<div class="data-table-container" style="overflow-x: auto;">
			<table class="data-table">
				<thead>
					<tr>
						<th>Name</th>
						<th>Team</th>
						<th>Position</th>
						<th>Number</th>
						<th>Yahoo Key</th>
					</tr>
				</thead>
				<tbody>
	`)

	for _, player := range players {
		shortKey := player.YahooPlayerKey
		if len(shortKey) > 15 {
			shortKey = shortKey[:15] + "..."
		}
		
		html.WriteString(fmt.Sprintf(`
			<tr onclick="showPlayerDetails(%d)" style="cursor: pointer;">
				<td><strong>%s</strong></td>
				<td>%s</td>
				<td>%s</td>
				<td>%s</td>
				<td><code>%s</code></td>
			</tr>
		`, player.ID, player.FullName, player.Team, player.Position, player.UniformNumber, shortKey))
	}

	html.WriteString(`
				</tbody>
			</table>
		</div>
	`)

	w.Write([]byte(html.String()))
}

func (s *HTMXServer) renderPlayersCards(w http.ResponseWriter, players []Player) {
	var html strings.Builder
	html.WriteString(`<div class="cards-grid">`)

	for _, player := range players {
		html.WriteString(fmt.Sprintf(`
			<div class="card" onclick="showPlayerDetails(%d)">
				<div class="card-title">%s</div>
				<div class="card-content">
					<div>Team: <strong>%s</strong></div>`, 
			player.ID, player.FullName, player.Team))
		
		if player.Position != "" {
			html.WriteString(fmt.Sprintf(`<div>Position: <strong>%s</strong></div>`, player.Position))
		}
		if player.UniformNumber != "" {
			html.WriteString(fmt.Sprintf(`<div>Number: <strong>#%s</strong></div>`, player.UniformNumber))
		}
		
		html.WriteString(`
				</div>
			</div>
		`)
	}

	html.WriteString(`</div>`)
	w.Write([]byte(html.String()))
}

// Original JSON/CSV handlers
func (s *HTMXServer) playersJSONHandler(w http.ResponseWriter, r *http.Request) {
	players, err := s.GetPlayers()
	if err != nil {
		http.Error(w, fmt.Sprintf("Error getting players: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, `{"players": [`)
	
	for i, player := range players {
		if i > 0 {
			fmt.Fprint(w, ",")
		}
		fmt.Fprintf(w, `{
			"id": %d,
			"name": "%s",
			"first_name": "%s", 
			"last_name": "%s",
			"team": "%s",
			"position": "%s",
			"uniform_number": "%s",
			"is_active": %t,
			"yahoo_player_key": "%s"
		}`, player.ID, player.FullName, player.FirstName, player.LastName, 
			player.Team, player.Position, player.UniformNumber, player.IsActive, player.YahooPlayerKey)
	}
	
	fmt.Fprintf(w, `], "count": %d}`, len(players))
}

func (s *HTMXServer) teamsJSONHandler(w http.ResponseWriter, r *http.Request) {
	teams, err := s.GetTeams()
	if err != nil {
		http.Error(w, fmt.Sprintf("Error getting teams: %v", err), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"teams": teams,
		"count": len(teams),
	})
}

func (s *HTMXServer) exportCSVHandler(w http.ResponseWriter, r *http.Request) {
	players, err := s.GetPlayers()
	if err != nil {
		http.Error(w, fmt.Sprintf("Error getting players: %v", err), http.StatusInternalServerError)
		return
	}

	filename := fmt.Sprintf("nba_players_%s.csv", time.Now().Format("2006-01-02"))
	w.Header().Set("Content-Type", "text/csv")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%s", filename))

	csvWriter := csv.NewWriter(w)
	defer csvWriter.Flush()

	// Write header
	header := []string{"ID", "Full Name", "First Name", "Last Name", "Team", "Position", "Uniform Number", "Active", "Yahoo Player Key"}
	csvWriter.Write(header)

	// Write player data
	for _, player := range players {
		record := []string{
			fmt.Sprintf("%d", player.ID),
			player.FullName,
			player.FirstName,
			player.LastName,
			player.Team,
			player.Position,
			player.UniformNumber,
			fmt.Sprintf("%t", player.IsActive),
			player.YahooPlayerKey,
		}
		csvWriter.Write(record)
	}

	log.Printf("📊 Exported %d NBA players to CSV", len(players))
}

// Utility functions
func isHTMXRequest(r *http.Request) bool {
	return r.Header.Get("HX-Request") == "true"
}

func getSamplePlayers(players []Player, count int) []Player {
	if len(players) <= count {
		return players
	}
	return players[:count]
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func main() {
	fmt.Println("🏀 NBA Fantasy Player Database - HTMX Server")
	fmt.Println("===========================================")

	// Initialize file-based SQL queries
	err := InitializeFileSQL("../sql")
	if err != nil {
		log.Fatal("Failed to load SQL queries:", err)
	}
	stats := FileSQL.GetStats()
	fmt.Printf("✅ Loaded %d SQL queries from %s\n", stats["total_queries"], stats["base_path"])

	// Use NBA database
	dbPath := "nba.db"
	if _, err := os.Stat(dbPath); os.IsNotExist(err) {
		log.Fatal("❌ Database not found. Run migrations first: go run migrate.go migrate")
	}

	server, err := NewHTMXServer(dbPath)
	if err != nil {
		log.Fatal("Failed to initialize server:", err)
	}

	// Test database connection
	var count int
	playerCountQuery := FileSQL.MustGetQuery("get_player_count")
	err = server.db.QueryRow(playerCountQuery).Scan(&count)
	if err != nil {
		log.Fatal("Database connection test failed:", err)
	}
	fmt.Printf("✅ Connected to database with %d NBA players\n", count)

	// Setup routes
	http.HandleFunc("/", server.dashboardHandler)
	http.HandleFunc("/players", server.playersHandler)
	http.HandleFunc("/teams", server.teamsHandler)
	
	// HTMX API endpoints
	http.HandleFunc("/api/stats", server.apiStatsHandler)
	http.HandleFunc("/api/sample-players", server.apiSamplePlayersHandler)
	http.HandleFunc("/api/players/view/", server.apiPlayersViewHandler)
	
	// Original JSON/CSV API endpoints
	http.HandleFunc("/api/players", server.playersJSONHandler)
	http.HandleFunc("/api/teams", server.teamsJSONHandler)
	http.HandleFunc("/api/export-csv", server.exportCSVHandler)
	
	// Static files (CSS, images, etc.)
	http.Handle("/styles.css", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/css")
		http.ServeFile(w, r, "../templates/styles.css")
	}))

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("🚀 HTMX NBA Database server starting on http://localhost:%s\n", port)
	fmt.Printf("🏀 Modern interactive interface with HTMX\n")
	fmt.Printf("📊 API endpoints:\n")
	fmt.Printf("   GET  /api/players - All NBA players (JSON)\n")
	fmt.Printf("   GET  /api/teams - All NBA teams (JSON)\n")
	fmt.Printf("   GET  /api/export-csv - Export players (CSV)\n")
	fmt.Printf("\n🎯 Ready to serve NBA Fantasy Sports data!\n")

	log.Fatal(http.ListenAndServe(":"+port, nil))
}