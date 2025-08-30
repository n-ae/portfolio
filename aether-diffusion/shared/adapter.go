// Mock adapter pattern for Yahoo Fantasy Sports API
// Allows switching between mock data and real API with config change

package main

import (
	"encoding/json"
	"io/ioutil"
	"strings"
	"time"
)

// Data structures
type Game struct {
	GameKey string `json:"game_key"`
	Name    string `json:"name"`
	Code    string `json:"code"`
	Season  int    `json:"season"`
	Type    string `json:"type"`
}

type League struct {
	LeagueKey   string `json:"league_key"`
	Name        string `json:"name"`
	NumTeams    int    `json:"num_teams"`
	CurrentWeek int    `json:"current_week"`
	GameKey     string `json:"game_key"`
}

type Team struct {
	TeamKey        string `json:"team_key"`
	Name           string `json:"name"`
	WaiverPriority *int   `json:"waiver_priority,omitempty"`
	LeagueKey      string `json:"league_key"`
}

type Player struct {
	PlayerKey string `json:"player_key"`
	FullName  string `json:"full_name"`
	Position  string `json:"position"`
	Team      string `json:"team"`
	GameKey   string `json:"game_key,omitempty"`
}

// Configuration structures
type YahooAPIConfig struct {
	BaseURL        string `json:"base_url"`
	ConsumerKey    string `json:"consumer_key"`
	ConsumerSecret string `json:"consumer_secret"`
}

type MockAPIConfig struct {
	DataFile       string `json:"data_file"`
	SimulateDelays bool   `json:"simulate_delays"`
	DelayMS        int    `json:"delay_ms"`
}

type Config struct {
	APIMode   string         `json:"api_mode"`
	YahooAPI  YahooAPIConfig `json:"yahoo_api"`
	MockAPI   MockAPIConfig  `json:"mock_api"`
}

// Mock data structure
type MockData struct {
	Games   []Game              `json:"games"`
	Leagues map[string][]League `json:"leagues"`
	Teams   map[string][]Team   `json:"teams"`
	Players map[string][]Player `json:"players"`
	Rosters map[string][]Player `json:"rosters"`
}

// API Adapter
type YahooAPIAdapter struct {
	config   Config
	mockData *MockData
}

// NewYahooAPIAdapter creates a new adapter instance
func NewYahooAPIAdapter() (*YahooAPIAdapter, error) {
	// Load configuration
	configData, err := ioutil.ReadFile("shared/config.json")
	if err != nil {
		return nil, err
	}
	
	var config Config
	if err := json.Unmarshal(configData, &config); err != nil {
		return nil, err
	}
	
	adapter := &YahooAPIAdapter{
		config: config,
	}
	
	// Load mock data if in mock mode
	if config.APIMode == "mock" {
		mockDataBytes, err := ioutil.ReadFile(config.MockAPI.DataFile)
		if err != nil {
			return nil, err
		}
		
		var mockData MockData
		if err := json.Unmarshal(mockDataBytes, &mockData); err != nil {
			return nil, err
		}
		
		adapter.mockData = &mockData
	}
	
	return adapter, nil
}

// API methods with mock/real switching
func (a *YahooAPIAdapter) GetGames() ([]Game, error) {
	if a.config.APIMode == "mock" {
		return a.getMockGames(), nil
	}
	return a.getRealGames()
}

func (a *YahooAPIAdapter) GetLeagues(gameKey string) ([]League, error) {
	if a.config.APIMode == "mock" {
		return a.getMockLeagues(gameKey), nil
	}
	return a.getRealLeagues(gameKey)
}

func (a *YahooAPIAdapter) GetTeams(leagueKey string) ([]Team, error) {
	if a.config.APIMode == "mock" {
		return a.getMockTeams(leagueKey), nil
	}
	return a.getRealTeams(leagueKey)
}

func (a *YahooAPIAdapter) SearchPlayers(gameKey, searchQuery string) ([]Player, error) {
	if a.config.APIMode == "mock" {
		return a.getMockPlayers(gameKey, searchQuery), nil
	}
	return a.getRealPlayers(gameKey, searchQuery)
}

func (a *YahooAPIAdapter) GetTeamRoster(teamKey string) ([]Player, error) {
	if a.config.APIMode == "mock" {
		return a.getMockRoster(teamKey), nil
	}
	return a.getRealRoster(teamKey)
}

// Mock implementations
func (a *YahooAPIAdapter) getMockGames() []Game {
	if a.config.MockAPI.SimulateDelays {
		time.Sleep(time.Duration(a.config.MockAPI.DelayMS) * time.Millisecond)
	}
	
	return a.mockData.Games
}

func (a *YahooAPIAdapter) getMockLeagues(gameKey string) []League {
	if a.config.MockAPI.SimulateDelays {
		time.Sleep(time.Duration(a.config.MockAPI.DelayMS) * time.Millisecond)
	}
	
	if leagues, exists := a.mockData.Leagues[gameKey]; exists {
		return leagues
	}
	return []League{}
}

func (a *YahooAPIAdapter) getMockTeams(leagueKey string) []Team {
	if a.config.MockAPI.SimulateDelays {
		time.Sleep(time.Duration(a.config.MockAPI.DelayMS) * time.Millisecond)
	}
	
	if teams, exists := a.mockData.Teams[leagueKey]; exists {
		return teams
	}
	
	// Return default mock teams if no specific data found
	return []Team{
		{
			TeamKey:        "423.l.12345.t.1",
			Name:           "Team Alpha",
			WaiverPriority: intPtr(5),
			LeagueKey:      leagueKey,
		},
		{
			TeamKey:        "423.l.12345.t.2",
			Name:           "Team Beta",
			WaiverPriority: intPtr(3),
			LeagueKey:      leagueKey,
		},
	}
}

func (a *YahooAPIAdapter) getMockPlayers(gameKey, searchQuery string) []Player {
	if a.config.MockAPI.SimulateDelays {
		time.Sleep(time.Duration(a.config.MockAPI.DelayMS) * time.Millisecond)
	}
	
	if players, exists := a.mockData.Players[gameKey]; exists {
		// Simple name filtering for search
		if searchQuery != "" {
			var filtered []Player
			for _, player := range players {
				if strings.Contains(strings.ToLower(player.FullName), strings.ToLower(searchQuery)) {
					filtered = append(filtered, player)
				}
			}
			return filtered
		}
		return players
	}
	
	return []Player{}
}

func (a *YahooAPIAdapter) getMockRoster(teamKey string) []Player {
	if a.config.MockAPI.SimulateDelays {
		time.Sleep(time.Duration(a.config.MockAPI.DelayMS) * time.Millisecond)
	}
	
	if roster, exists := a.mockData.Rosters[teamKey]; exists {
		return roster
	}
	
	return []Player{}
}

// Real API implementations (stubs for now)
func (a *YahooAPIAdapter) getRealGames() ([]Game, error) {
	// TODO: Implement actual Yahoo API calls
	return nil, NewInternalError("Real API not implemented yet")
}

func (a *YahooAPIAdapter) getRealLeagues(gameKey string) ([]League, error) {
	// TODO: Implement actual Yahoo API calls
	return nil, NewInternalError("Real API not implemented yet")
}

func (a *YahooAPIAdapter) getRealTeams(leagueKey string) ([]Team, error) {
	// TODO: Implement actual Yahoo API calls
	return nil, NewInternalError("Real API not implemented yet")
}

func (a *YahooAPIAdapter) getRealPlayers(gameKey, searchQuery string) ([]Player, error) {
	// TODO: Implement actual Yahoo API calls
	return nil, NewInternalError("Real API not implemented yet")
}

func (a *YahooAPIAdapter) getRealRoster(teamKey string) ([]Player, error) {
	// TODO: Implement actual Yahoo API calls
	return nil, NewInternalError("Real API not implemented yet")
}

// Helper function
func intPtr(i int) *int {
	return &i
}