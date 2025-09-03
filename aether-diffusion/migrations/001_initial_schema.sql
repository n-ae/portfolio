-- Fantasy Sports Database - Initial Schema
-- Migration 001: Create core tables with proper relations and foreign keys
-- Author: Sports Fantasy Database System
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- LEAGUE AGNOSTIC TABLES (Core entities that exist across all sports)
-- =============================================================================

-- Sports/Leagues definition table
CREATE TABLE sports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT UNIQUE NOT NULL,              -- 'nba', 'nfl', 'mlb', 'nhl'
    name TEXT NOT NULL,                     -- 'NBA Basketball', 'NFL Football'
    yahoo_game_key TEXT UNIQUE NOT NULL,   -- Yahoo's game identifier
    season TEXT NOT NULL,                   -- '2025', '2024-25'
    is_active BOOLEAN DEFAULT 1,            -- Is this sport currently active
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Teams table (normalized across all sports)
CREATE TABLE teams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sport_id INTEGER NOT NULL,
    abbreviation TEXT NOT NULL,             -- 'LAL', 'BOS', 'KC'
    full_name TEXT NOT NULL,               -- 'Los Angeles Lakers'
    city TEXT NOT NULL,                    -- 'Los Angeles'
    name TEXT NOT NULL,                    -- 'Lakers'
    yahoo_team_key TEXT,                   -- Yahoo's team identifier
    conference TEXT,                       -- 'Western', 'Eastern', 'AFC', 'NFC'
    division TEXT,                         -- 'Pacific', 'Atlantic', etc.
    logo_url TEXT,
    primary_color TEXT,                    -- Team colors for UI
    secondary_color TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sport_id) REFERENCES sports (id) ON DELETE CASCADE,
    UNIQUE(sport_id, abbreviation),
    UNIQUE(yahoo_team_key)
);

-- Positions table (sport-specific position definitions)
CREATE TABLE positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sport_id INTEGER NOT NULL,
    code TEXT NOT NULL,                    -- 'PG', 'QB', 'SP', 'C'
    name TEXT NOT NULL,                    -- 'Point Guard', 'Quarterback'
    category TEXT,                         -- 'Guard', 'Forward', 'Center', 'Offense', 'Defense'
    sort_order INTEGER DEFAULT 0,         -- For display ordering
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sport_id) REFERENCES sports (id) ON DELETE CASCADE,
    UNIQUE(sport_id, code)
);

-- Players table (core player information, league agnostic)
CREATE TABLE players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    yahoo_player_key TEXT UNIQUE NOT NULL, -- Yahoo's unique player identifier
    yahoo_player_id TEXT NOT NULL,         -- Yahoo's internal player ID
    sport_id INTEGER NOT NULL,
    team_id INTEGER,                       -- NULL if free agent or retired
    
    -- Personal Information
    first_name TEXT,
    last_name TEXT,
    full_name TEXT NOT NULL,
    birthdate DATE,
    height_inches INTEGER,                 -- Height in inches for consistency
    weight_pounds INTEGER,                 -- Weight in pounds for consistency
    
    -- Yahoo-specific data
    uniform_number TEXT,
    yahoo_image_url TEXT,
    yahoo_headshot_url TEXT,
    yahoo_profile_url TEXT,
    yahoo_editorial_player_key TEXT,
    yahoo_editorial_team_key TEXT,
    
    -- Status information
    is_active BOOLEAN DEFAULT 1,           -- Is player currently active
    is_undroppable BOOLEAN DEFAULT 0,      -- Yahoo fantasy setting
    is_injured BOOLEAN DEFAULT 0,          -- Current injury status
    injury_note TEXT,                      -- Injury description
    status_description TEXT,               -- General status (healthy, doubtful, out, etc.)
    
    -- Metadata
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_sync_at DATETIME DEFAULT CURRENT_TIMESTAMP,  -- Last Yahoo API sync
    
    FOREIGN KEY (sport_id) REFERENCES sports (id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE SET NULL
);

-- Player positions (many-to-many relationship)
CREATE TABLE player_positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    position_id INTEGER NOT NULL,
    is_primary BOOLEAN DEFAULT 0,          -- Is this the primary position
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE,
    FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE CASCADE,
    UNIQUE(player_id, position_id)
);

-- =============================================================================
-- LEAGUE SPECIFIC TABLES (Sport-specific stats and data)
-- =============================================================================

-- NBA specific player stats
CREATE TABLE nba_player_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    season TEXT NOT NULL,                  -- '2024-25'
    stat_type TEXT NOT NULL,               -- 'season', 'career', 'playoffs'
    
    -- Basic stats
    games_played INTEGER DEFAULT 0,
    games_started INTEGER DEFAULT 0,
    minutes_per_game REAL DEFAULT 0.0,
    
    -- Scoring
    points_per_game REAL DEFAULT 0.0,
    field_goals_made REAL DEFAULT 0.0,
    field_goals_attempted REAL DEFAULT 0.0,
    field_goal_percentage REAL DEFAULT 0.0,
    three_pointers_made REAL DEFAULT 0.0,
    three_pointers_attempted REAL DEFAULT 0.0,
    three_point_percentage REAL DEFAULT 0.0,
    free_throws_made REAL DEFAULT 0.0,
    free_throws_attempted REAL DEFAULT 0.0,
    free_throw_percentage REAL DEFAULT 0.0,
    
    -- Rebounding
    rebounds_per_game REAL DEFAULT 0.0,
    offensive_rebounds REAL DEFAULT 0.0,
    defensive_rebounds REAL DEFAULT 0.0,
    
    -- Playmaking
    assists_per_game REAL DEFAULT 0.0,
    turnovers_per_game REAL DEFAULT 0.0,
    
    -- Defense
    steals_per_game REAL DEFAULT 0.0,
    blocks_per_game REAL DEFAULT 0.0,
    personal_fouls REAL DEFAULT 0.0,
    
    -- Advanced stats
    player_efficiency_rating REAL DEFAULT 0.0,
    true_shooting_percentage REAL DEFAULT 0.0,
    usage_rate REAL DEFAULT 0.0,
    
    -- Metadata
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE,
    UNIQUE(player_id, season, stat_type)
);

-- NFL specific player stats (placeholder - can be extended)
CREATE TABLE nfl_player_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    season TEXT NOT NULL,
    stat_type TEXT NOT NULL,
    
    -- Basic stats
    games_played INTEGER DEFAULT 0,
    games_started INTEGER DEFAULT 0,
    
    -- Generic stat data (JSON) for position-specific stats
    -- QB: passing_yards, passing_tds, interceptions, completion_percentage
    -- RB: rushing_yards, rushing_tds, receptions, receiving_yards
    -- WR/TE: receptions, receiving_yards, receiving_tds, targets
    -- DEF: tackles, sacks, interceptions, fumble_recoveries
    stat_data TEXT, -- JSON object for flexible stats
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE,
    UNIQUE(player_id, season, stat_type)
);

-- MLB specific player stats (placeholder)
CREATE TABLE mlb_player_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    season TEXT NOT NULL,
    stat_type TEXT NOT NULL,
    
    games_played INTEGER DEFAULT 0,
    stat_data TEXT, -- JSON for batting/pitching stats
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE,
    UNIQUE(player_id, season, stat_type)
);

-- NHL specific player stats (placeholder)
CREATE TABLE nhl_player_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    season TEXT NOT NULL,
    stat_type TEXT NOT NULL,
    
    games_played INTEGER DEFAULT 0,
    stat_data TEXT, -- JSON for goals, assists, penalty_minutes, etc.
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE,
    UNIQUE(player_id, season, stat_type)
);

-- =============================================================================
-- SYSTEM TABLES (Application metadata)
-- =============================================================================

-- Track data sync operations
CREATE TABLE sync_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sport_id INTEGER,
    operation_type TEXT NOT NULL,          -- 'full_sync', 'incremental', 'manual'
    status TEXT NOT NULL,                  -- 'started', 'completed', 'failed'
    records_processed INTEGER DEFAULT 0,
    records_added INTEGER DEFAULT 0,
    records_updated INTEGER DEFAULT 0,
    error_message TEXT,
    started_at DATETIME NOT NULL,
    completed_at DATETIME,
    duration_seconds INTEGER,
    
    FOREIGN KEY (sport_id) REFERENCES sports (id) ON DELETE SET NULL
);

-- Application configuration
CREATE TABLE app_config (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key TEXT UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Players table indexes
CREATE INDEX idx_players_sport ON players(sport_id);
CREATE INDEX idx_players_team ON players(team_id);
CREATE INDEX idx_players_name ON players(full_name);
CREATE INDEX idx_players_active ON players(is_active);
CREATE INDEX idx_players_yahoo_key ON players(yahoo_player_key);
CREATE INDEX idx_players_sync ON players(last_sync_at);

-- Teams table indexes
CREATE INDEX idx_teams_sport ON teams(sport_id);
CREATE INDEX idx_teams_abbreviation ON teams(abbreviation);
CREATE INDEX idx_teams_active ON teams(is_active);

-- Positions table indexes
CREATE INDEX idx_positions_sport ON positions(sport_id);
CREATE INDEX idx_positions_code ON positions(code);

-- Player positions indexes
CREATE INDEX idx_player_positions_player ON player_positions(player_id);
CREATE INDEX idx_player_positions_position ON player_positions(position_id);
CREATE INDEX idx_player_positions_primary ON player_positions(is_primary);

-- NBA stats indexes
CREATE INDEX idx_nba_stats_player ON nba_player_stats(player_id);
CREATE INDEX idx_nba_stats_season ON nba_player_stats(season);
CREATE INDEX idx_nba_stats_type ON nba_player_stats(stat_type);

-- Sync logs indexes
CREATE INDEX idx_sync_logs_sport ON sync_logs(sport_id);
CREATE INDEX idx_sync_logs_status ON sync_logs(status);
CREATE INDEX idx_sync_logs_date ON sync_logs(started_at);

-- =============================================================================
-- VIEWS FOR CONVENIENT DATA ACCESS
-- =============================================================================

-- Complete player view with team and position info
CREATE VIEW v_players_complete AS
SELECT 
    p.id,
    p.yahoo_player_key,
    p.full_name,
    p.first_name,
    p.last_name,
    p.uniform_number,
    s.code as sport_code,
    s.name as sport_name,
    t.abbreviation as team_abbr,
    t.full_name as team_name,
    t.city as team_city,
    GROUP_CONCAT(pos.code, ',') as position_codes,
    GROUP_CONCAT(pos.name, ',') as position_names,
    (SELECT pos2.code FROM player_positions pp2 
     JOIN positions pos2 ON pp2.position_id = pos2.id 
     WHERE pp2.player_id = p.id AND pp2.is_primary = 1) as primary_position,
    p.height_inches,
    p.weight_pounds,
    p.birthdate,
    p.is_active,
    p.is_injured,
    p.status_description,
    p.yahoo_image_url,
    p.updated_at
FROM players p
JOIN sports s ON p.sport_id = s.id
LEFT JOIN teams t ON p.team_id = t.id
LEFT JOIN player_positions pp ON p.id = pp.player_id
LEFT JOIN positions pos ON pp.position_id = pos.id
GROUP BY p.id, p.yahoo_player_key, p.full_name, s.code, t.abbreviation;

-- NBA players with current season stats
CREATE VIEW v_nba_players_current AS
SELECT 
    pc.*,
    nba.games_played,
    nba.points_per_game,
    nba.rebounds_per_game,
    nba.assists_per_game,
    nba.steals_per_game,
    nba.blocks_per_game,
    nba.field_goal_percentage,
    nba.three_point_percentage,
    nba.free_throw_percentage
FROM v_players_complete pc
LEFT JOIN nba_player_stats nba ON pc.id = nba.player_id 
    AND nba.season = '2024-25' 
    AND nba.stat_type = 'season'
WHERE pc.sport_code = 'nba';

-- Team rosters view
CREATE VIEW v_team_rosters AS
SELECT 
    t.id as team_id,
    t.abbreviation as team_abbr,
    t.full_name as team_name,
    s.code as sport_code,
    COUNT(p.id) as player_count,
    GROUP_CONCAT(p.full_name, '; ') as player_names
FROM teams t
JOIN sports s ON t.sport_id = s.id
LEFT JOIN players p ON t.id = p.team_id AND p.is_active = 1
GROUP BY t.id, t.abbreviation, t.full_name, s.code;

-- =============================================================================
-- TRIGGERS FOR DATA CONSISTENCY
-- =============================================================================

-- Update players.updated_at on any change
CREATE TRIGGER trg_players_updated_at 
    AFTER UPDATE ON players
    FOR EACH ROW
BEGIN
    UPDATE players SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Update teams.updated_at on any change
CREATE TRIGGER trg_teams_updated_at 
    AFTER UPDATE ON teams
    FOR EACH ROW
BEGIN
    UPDATE teams SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- Ensure only one primary position per player
CREATE TRIGGER trg_player_positions_primary_unique
    BEFORE INSERT ON player_positions
    FOR EACH ROW
    WHEN NEW.is_primary = 1
BEGIN
    UPDATE player_positions SET is_primary = 0 WHERE player_id = NEW.player_id;
END;

COMMIT;

-- Migration completed successfully
-- Next: Run 002_seed_data.sql to populate initial reference data