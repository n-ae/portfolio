package yahoo

import (
	"encoding/xml"
	"time"
)

// Player represents an NBA player from Yahoo Fantasy Sports API
type Player struct {
	Key              string            `xml:"player_key" json:"player_key"`
	PlayerID         string            `xml:"player_id" json:"player_id"`
	Name             PlayerName        `xml:"name" json:"name"`
	EditorialTeamKey string            `xml:"editorial_team_key" json:"editorial_team_key"`
	EditorialTeamAbbr string           `xml:"editorial_team_abbr" json:"editorial_team_abbr"`
	EditorialTeamFullName string       `xml:"editorial_team_full_name" json:"editorial_team_full_name"`
	UniformNumber    string            `xml:"uniform_number" json:"uniform_number"`
	DisplayPosition  string            `xml:"display_position" json:"display_position"`
	Headshot         PlayerHeadshot    `xml:"headshot" json:"headshot"`
	ImageURL         string            `xml:"image_url" json:"image_url"`
	IsUndroppable    string            `xml:"is_undroppable" json:"is_undroppable"`
	PositionType     string            `xml:"position_type" json:"position_type"`
	EligiblePositions []string         `xml:"eligible_positions>position" json:"eligible_positions"`
	HasPlayerNotes   string            `xml:"has_player_notes" json:"has_player_notes"`
	PlayerNotes      PlayerNotes       `xml:"player_notes" json:"player_notes"`
	SelectedPosition SelectedPosition  `xml:"selected_position" json:"selected_position"`
	Status           string            `xml:"status" json:"status"`
	StatusFull       string            `xml:"status_full" json:"status_full"`
	InjuryNote       string            `xml:"injury_note" json:"injury_note"`
	Stats            []PlayerStats     `xml:"player_stats>stats>stat" json:"stats"`
	
	// Normalized fields for easier access
	FullName         string `json:"full_name"`
	FirstName        string `json:"first_name"`
	LastName         string `json:"last_name"`
	TeamAbbreviation string `json:"team"`
	Position         string `json:"position"`
	IsActive         bool   `json:"is_active"`
	YahooPlayerKey   string `json:"yahoo_player_key"`
}

// PlayerName represents a player's name structure
type PlayerName struct {
	Full       string `xml:"full" json:"full"`
	First      string `xml:"first" json:"first"`
	Last       string `xml:"last" json:"last"`
	ASCIIFirst string `xml:"ascii_first" json:"ascii_first"`
	ASCIILast  string `xml:"ascii_last" json:"ascii_last"`
}

// PlayerHeadshot represents player headshot image information
type PlayerHeadshot struct {
	URL    string `xml:"url" json:"url"`
	Size   string `xml:"size" json:"size"`
}

// PlayerNotes represents player notes information
type PlayerNotes struct {
	TimeCreated string `xml:"time_created" json:"time_created"`
	Note        string `xml:"note" json:"note"`
}

// SelectedPosition represents a player's selected position
type SelectedPosition struct {
	CoverageType string `xml:"coverage_type" json:"coverage_type"`
	Date         string `xml:"date" json:"date"`
	Position     string `xml:"position" json:"position"`
}

// PlayerStats represents individual player statistics
type PlayerStats struct {
	StatID string `xml:"stat_id" json:"stat_id"`
	Value  string `xml:"value" json:"value"`
}

// Team represents an NBA team from Yahoo Fantasy Sports API
type Team struct {
	Key              string `xml:"team_key" json:"team_key"`
	TeamID           string `xml:"team_id" json:"team_id"`
	Name             string `xml:"name" json:"name"`
	Abbreviation     string `xml:"abbreviation" json:"abbreviation"`
	City             string `xml:"city" json:"city"`
	Conference       string `xml:"conference" json:"conference"`
	Division         string `xml:"division" json:"division"`
	
	// Normalized fields
	ID               int    `json:"id"`
	FullName         string `json:"full_name"`
	PlayerCount      int    `json:"player_count"`
	YahooTeamKey     string `json:"yahoo_team_key"`
}

// League represents a fantasy league
type League struct {
	Key             string    `xml:"league_key" json:"league_key"`
	LeagueID        string    `xml:"league_id" json:"league_id"`
	Name            string    `xml:"name" json:"name"`
	URL             string    `xml:"url" json:"url"`
	LogoURL         string    `xml:"logo_url" json:"logo_url"`
	Password        string    `xml:"password" json:"password"`
	DraftStatus     string    `xml:"draft_status" json:"draft_status"`
	NumTeams        int       `xml:"num_teams" json:"num_teams"`
	EditKey         string    `xml:"edit_key" json:"edit_key"`
	WeeklyDeadline  string    `xml:"weekly_deadline" json:"weekly_deadline"`
	LeagueUpdateTimestamp string `xml:"league_update_timestamp" json:"league_update_timestamp"`
	ScoringType     string    `xml:"scoring_type" json:"scoring_type"`
	LeagueType      string    `xml:"league_type" json:"league_type"`
	Renew           string    `xml:"renew" json:"renew"`
	Renewed         string    `xml:"renewed" json:"renewed"`
	ShortInvitationURL string `xml:"short_invitation_url" json:"short_invitation_url"`
	IsProLeague     string    `xml:"is_pro_league" json:"is_pro_league"`
	CurrentWeek     int       `xml:"current_week" json:"current_week"`
	StartWeek       int       `xml:"start_week" json:"start_week"`
	StartDate       string    `xml:"start_date" json:"start_date"`
	EndWeek         int       `xml:"end_week" json:"end_week"`
	EndDate         string    `xml:"end_date" json:"end_date"`
	GameCode        string    `xml:"game_code" json:"game_code"`
	Season          string    `xml:"season" json:"season"`
}

// Game represents a fantasy game
type Game struct {
	Key         string `xml:"game_key" json:"game_key"`
	GameID      string `xml:"game_id" json:"game_id"`
	Name        string `xml:"name" json:"name"`
	Code        string `xml:"code" json:"code"`
	Type        string `xml:"type" json:"type"`
	URL         string `xml:"url" json:"url"`
	Season      string `xml:"season" json:"season"`
	IsRegistrationOver string `xml:"is_registration_over" json:"is_registration_over"`
	IsGameOver  string `xml:"is_game_over" json:"is_game_over"`
	IsOffseason string `xml:"is_offseason" json:"is_offseason"`
}

// APIResponse represents the top-level Yahoo API response
type APIResponse struct {
	XMLName xml.Name `xml:"fantasy_content"`
	Lang    string   `xml:"lang,attr"`
	URI     string   `xml:"uri,attr"`
	Time    string   `xml:"time,attr"`
	
	// Different response types
	Game     *Game     `xml:"game,omitempty"`
	League   *League   `xml:"league,omitempty"`
	Teams    *Teams    `xml:"teams,omitempty"`
	Players  *Players  `xml:"players,omitempty"`
	User     *User     `xml:"user,omitempty"`
}

// Players represents a collection of players
type Players struct {
	Count  int      `xml:"count,attr"`
	Player []Player `xml:"player"`
}

// Teams represents a collection of teams
type Teams struct {
	Count int    `xml:"count,attr"`
	Team  []Team `xml:"team"`
}

// User represents a Yahoo user
type User struct {
	GUID     string `xml:"guid" json:"guid"`
	Games    *Games `xml:"games" json:"games"`
}

// Games represents a collection of games
type Games struct {
	Count int    `xml:"count,attr"`
	Game  []Game `xml:"game"`
}

// Roster represents a team roster
type Roster struct {
	CoverageType string   `xml:"coverage_type" json:"coverage_type"`
	Week         string   `xml:"week" json:"week"`
	IsEditable   string   `xml:"is_editable" json:"is_editable"`
	Players      *Players `xml:"players" json:"players"`
}

// Transaction represents a fantasy transaction
type Transaction struct {
	Key             string    `xml:"transaction_key" json:"transaction_key"`
	TransactionID   string    `xml:"transaction_id" json:"transaction_id"`
	Type            string    `xml:"type" json:"type"`
	Status          string    `xml:"status" json:"status"`
	Timestamp       string    `xml:"timestamp" json:"timestamp"`
	Players         *Players  `xml:"players" json:"players"`
}

// APIError represents an error from the Yahoo API
type APIError struct {
	StatusCode int    `json:"status_code"`
	Message    string `json:"message"`
	Details    string `json:"details"`
}

func (e *APIError) Error() string {
	return e.Message
}

// RateLimitError represents a rate limiting error
type RateLimitError struct {
	RetryAfter time.Duration `json:"retry_after"`
	Message    string        `json:"message"`
}

func (e *RateLimitError) Error() string {
	return e.Message
}

// Normalize converts Yahoo API player data to normalized format
func (p *Player) Normalize() {
	p.FullName = p.Name.Full
	p.FirstName = p.Name.First
	p.LastName = p.Name.Last
	p.TeamAbbreviation = p.EditorialTeamAbbr
	p.Position = p.DisplayPosition
	p.YahooPlayerKey = p.Key
	p.IsActive = p.Status != "NA" && p.Status != "O"
}

// Normalize converts Yahoo API team data to normalized format
func (t *Team) Normalize() {
	t.FullName = t.Name
	t.YahooTeamKey = t.Key
	// TeamID conversion would need additional logic based on mapping
}

// GetStatValue returns the value for a specific stat ID
func (p *Player) GetStatValue(statID string) string {
	for _, stat := range p.Stats {
		if stat.StatID == statID {
			return stat.Value
		}
	}
	return ""
}

// HasPosition checks if player is eligible for a specific position
func (p *Player) HasPosition(position string) bool {
	for _, pos := range p.EligiblePositions {
		if pos == position {
			return true
		}
	}
	return false
}

// IsInjured checks if player has injury status
func (p *Player) IsInjured() bool {
	return p.Status == "DTD" || p.Status == "O" || p.Status == "IR" || p.InjuryNote != ""
}