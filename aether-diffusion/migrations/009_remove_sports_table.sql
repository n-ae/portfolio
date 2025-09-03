-- Fantasy Sports Database - Remove Sports Table
-- Migration 009: Remove sports table and use app_config for sport type
-- Author: Sports Fantasy Database System
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- DROP ALL VIEWS FIRST (to avoid dependency issues during table operations)
-- =============================================================================

-- Drop all views that reference the old table structure
DROP VIEW IF EXISTS v_players_with_categories;
DROP VIEW IF EXISTS v_team_rosters;
DROP VIEW IF EXISTS v_team_lookup;
DROP VIEW IF EXISTS v_position_lookup;
DROP VIEW IF EXISTS v_position_categories_lookup;
DROP VIEW IF EXISTS v_nba_roster_stats;
DROP VIEW IF EXISTS v_nba_position_stats;
DROP VIEW IF EXISTS v_player_import_summary;
DROP VIEW IF EXISTS v_duplicate_players;
DROP VIEW IF EXISTS v_players_no_team;
DROP VIEW IF EXISTS v_players_no_positions;

-- =============================================================================
-- MIGRATE SPORT-SPECIFIC DATA TO APP_CONFIG
-- =============================================================================

-- Note: Sport configuration will be populated by migration runner after table creation

-- =============================================================================
-- UPDATE TABLES TO REMOVE SPORT_ID FOREIGN KEYS
-- =============================================================================

-- Create new teams table without sport_id reference
CREATE TABLE teams_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    abbreviation TEXT UNIQUE NOT NULL,      -- 'LAL', 'BOS', 'KC'
    full_name TEXT NOT NULL,               -- 'Los Angeles Lakers'
    city TEXT NOT NULL,                    -- 'Los Angeles'
    name TEXT NOT NULL,                    -- 'Lakers'
    yahoo_team_key TEXT UNIQUE,            -- Yahoo's team identifier
    conference TEXT,                       -- 'Western', 'Eastern', 'AFC', 'NFC'
    division TEXT,                         -- 'Pacific', 'Atlantic', etc.
    logo_url TEXT,
    primary_color TEXT,                    -- Team colors for UI
    secondary_color TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Migrate teams data (removing sport_id dependency)
INSERT INTO teams_new (
    abbreviation, full_name, city, name, yahoo_team_key, conference, division,
    logo_url, primary_color, secondary_color, is_active, created_at, updated_at
)
SELECT 
    abbreviation, full_name, city, name, yahoo_team_key, conference, division,
    logo_url, primary_color, secondary_color, is_active, created_at, updated_at
FROM teams;

-- Create new positions table without sport_id reference
CREATE TABLE positions_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT UNIQUE NOT NULL,             -- 'PG', 'SG', 'SF', 'PF', 'C'
    name TEXT NOT NULL,                    -- 'Point Guard'
    category TEXT,                         -- 'Guard', 'Forward', 'Center'
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Migrate positions data
INSERT INTO positions_new (code, name, category, sort_order, is_active, created_at)
SELECT code, name, category, sort_order, is_active, created_at
FROM positions;

-- Create new position_categories table without sport_id reference
CREATE TABLE position_categories_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT UNIQUE NOT NULL,             -- 'G', 'F', 'C', 'UTIL'
    name TEXT NOT NULL,                    -- 'Guard', 'Forward', 'Center', 'Utility'
    description TEXT,                      -- 'Eligible positions: PG, SG'
    sort_order INTEGER DEFAULT 0,
    is_fantasy_position BOOLEAN DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Migrate position categories data
INSERT INTO position_categories_new (
    code, name, description, sort_order, is_fantasy_position, is_active, created_at
)
SELECT code, name, description, sort_order, is_fantasy_position, is_active, created_at
FROM position_categories;

-- Create new players table without sport_id reference
CREATE TABLE players_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    yahoo_player_key TEXT UNIQUE NOT NULL,
    yahoo_player_id TEXT NOT NULL,
    team_id INTEGER,                       -- References teams.id (same database)
    
    -- Personal information (real-world data only)
    first_name TEXT,
    last_name TEXT,
    full_name TEXT NOT NULL,
    birthdate TEXT,
    height_inches INTEGER,
    weight_pounds INTEGER,
    
    -- Professional information
    uniform_number TEXT,
    years_pro INTEGER,
    college TEXT,
    draft_year INTEGER,
    draft_round INTEGER,
    draft_pick INTEGER,
    
    -- Real-world status (not fantasy status)
    is_active BOOLEAN DEFAULT 1,
    is_rookie BOOLEAN DEFAULT 0,
    current_injury_status TEXT,            -- 'healthy', 'injured', 'day-to-day'
    
    -- Yahoo API metadata
    yahoo_image_url TEXT,
    yahoo_headshot_url TEXT,
    yahoo_profile_url TEXT,
    yahoo_editorial_player_key TEXT,
    yahoo_editorial_team_key TEXT,
    
    -- Metadata
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_sync_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (team_id) REFERENCES teams_new (id) ON DELETE SET NULL
);

-- Migrate players data
INSERT INTO players_new (
    yahoo_player_key, yahoo_player_id, team_id,
    first_name, last_name, full_name, birthdate, height_inches, weight_pounds,
    uniform_number, years_pro, college, draft_year, draft_round, draft_pick,
    is_active, is_rookie, current_injury_status,
    yahoo_image_url, yahoo_headshot_url, yahoo_profile_url,
    yahoo_editorial_player_key, yahoo_editorial_team_key,
    created_at, updated_at, last_sync_at
)
SELECT 
    yahoo_player_key, yahoo_player_id, team_id,
    first_name, last_name, full_name, birthdate, height_inches, weight_pounds,
    uniform_number, years_pro, college, draft_year, draft_round, draft_pick,
    is_active, is_rookie, current_injury_status,
    yahoo_image_url, yahoo_headshot_url, yahoo_profile_url,
    yahoo_editorial_player_key, yahoo_editorial_team_key,
    created_at, updated_at, last_sync_at
FROM players;

-- Update fantasy_games to remove sport_id reference
CREATE TABLE fantasy_games_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    yahoo_game_key TEXT UNIQUE NOT NULL,   -- Yahoo's game key (e.g., '466')
    game_name TEXT NOT NULL,               -- 'NBA 2024-25 Season'
    season TEXT NOT NULL,                  -- '2024-25'
    game_type TEXT NOT NULL,               -- 'season', 'playoff', 'dynasty'
    
    -- Game timeline
    registration_start DATE,
    registration_end DATE,
    season_start DATE,
    season_end DATE,
    playoffs_start DATE,
    playoffs_end DATE,
    
    -- Game status
    is_registration_open BOOLEAN DEFAULT 1,
    is_active BOOLEAN DEFAULT 1,
    is_offseason BOOLEAN DEFAULT 0,
    is_live_draft_active BOOLEAN DEFAULT 0,
    
    -- Game settings
    max_teams_per_league INTEGER DEFAULT 12,
    roster_size INTEGER,
    starting_lineup_size INTEGER,
    bench_size INTEGER,
    ir_slots INTEGER DEFAULT 0,
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(season, game_type)
);

-- Migrate fantasy games data
INSERT INTO fantasy_games_new (
    yahoo_game_key, game_name, season, game_type,
    registration_start, registration_end, season_start, season_end, playoffs_start, playoffs_end,
    is_registration_open, is_active, is_offseason, is_live_draft_active,
    max_teams_per_league, roster_size, starting_lineup_size, bench_size, ir_slots,
    created_at
)
SELECT 
    yahoo_game_key, game_name, season, game_type,
    registration_start, registration_end, season_start, season_end, playoffs_start, playoffs_end,
    is_registration_open, is_active, is_offseason, is_live_draft_active,
    max_teams_per_league, roster_size, starting_lineup_size, bench_size, ir_slots,
    created_at
FROM fantasy_games;

-- =============================================================================
-- REPLACE TABLES WITH NEW VERSIONS
-- =============================================================================

-- Drop old tables and rename new ones
DROP TABLE teams;
ALTER TABLE teams_new RENAME TO teams;

DROP TABLE positions;
ALTER TABLE positions_new RENAME TO positions;

DROP TABLE position_categories;
ALTER TABLE position_categories_new RENAME TO position_categories;

DROP TABLE players;
ALTER TABLE players_new RENAME TO players;

DROP TABLE fantasy_games;
ALTER TABLE fantasy_games_new RENAME TO fantasy_games;

-- Drop the sports table since we no longer need it
DROP TABLE sports;

-- =============================================================================
-- RECREATE INDEXES AND CONSTRAINTS
-- =============================================================================

-- Teams indexes
CREATE INDEX idx_teams_abbreviation ON teams(abbreviation);
CREATE INDEX idx_teams_active ON teams(is_active);
CREATE INDEX idx_teams_name_search ON teams(full_name COLLATE NOCASE);

-- Positions indexes
CREATE INDEX idx_positions_code ON positions(code);
CREATE INDEX idx_positions_category ON positions(category);

-- Position categories indexes
CREATE INDEX idx_position_categories_code ON position_categories(code);
CREATE INDEX idx_position_categories_fantasy ON position_categories(is_fantasy_position) WHERE is_fantasy_position = 1;

-- Players indexes  
CREATE INDEX idx_players_team ON players(team_id);
CREATE INDEX idx_players_name ON players(full_name);
CREATE INDEX idx_players_active ON players(is_active);
CREATE INDEX idx_players_yahoo_key ON players(yahoo_player_key);
CREATE INDEX idx_players_sync ON players(last_sync_at);
CREATE INDEX idx_players_name_search ON players(full_name COLLATE NOCASE);

-- Recreate updated triggers
CREATE TRIGGER trg_teams_updated_at 
    AFTER UPDATE ON teams
    FOR EACH ROW
BEGIN
    UPDATE teams SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

CREATE TRIGGER trg_players_updated_at 
    AFTER UPDATE ON players
    FOR EACH ROW
BEGIN
    UPDATE players SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
END;

-- =============================================================================
-- RECREATE VIEWS WITHOUT SPORTS TABLE REFERENCES
-- =============================================================================
CREATE VIEW v_players_with_categories AS
SELECT 
    p.id,
    p.yahoo_player_key,
    p.full_name,
    p.first_name,
    p.last_name,
    p.uniform_number,
    'nba' as sport_code,  -- Will be dynamically set by migration runner
    'NBA Basketball' as sport_name,  -- Will be dynamically set by migration runner
    t.abbreviation as team_abbr,
    t.full_name as team_name,
    -- Primary position
    (SELECT pos.code FROM player_positions pp 
     JOIN positions pos ON pp.position_id = pos.id 
     WHERE pp.player_id = p.id AND pp.is_primary = 1) as primary_position,
    -- All positions
    GROUP_CONCAT(DISTINCT pos.code, ',') as all_positions,
    -- Fantasy categories this player is eligible for  
    GROUP_CONCAT(DISTINCT pc.code, ',') as fantasy_categories,
    p.is_active,
    p.yahoo_image_url,
    p.updated_at
FROM players p
LEFT JOIN teams t ON p.team_id = t.id
LEFT JOIN player_positions pp ON p.id = pp.player_id
LEFT JOIN positions pos ON pp.position_id = pos.id
LEFT JOIN position_category_mapping pcm ON pos.id = pcm.position_id
LEFT JOIN position_categories pc ON pcm.category_id = pc.id
GROUP BY p.id, p.yahoo_player_key, p.full_name, t.abbreviation;

CREATE VIEW v_team_rosters AS
SELECT 
    t.id as team_id,
    t.abbreviation as team_abbr,
    t.full_name as team_name,
    t.city,
    t.conference,
    t.division,
    'nba' as sport_code,  -- Will be dynamically set by migration runner
    COUNT(p.id) as player_count,
    GROUP_CONCAT(p.full_name, '; ') as player_names
FROM teams t
LEFT JOIN players p ON t.id = p.team_id AND p.is_active = 1
GROUP BY t.id, t.abbreviation, t.full_name;

CREATE VIEW v_player_import_summary AS
SELECT 
    'nba' as sport,  -- Will be dynamically set by migration runner
    COUNT(p.id) as total_players,
    COUNT(CASE WHEN p.is_active = 1 THEN 1 END) as active_players,
    COUNT(CASE WHEN p.team_id IS NOT NULL THEN 1 END) as players_with_teams,
    COUNT(CASE WHEN pp.player_id IS NOT NULL THEN 1 END) as players_with_positions,
    COUNT(DISTINCT p.team_id) as teams_with_players,
    COUNT(CASE WHEN p.yahoo_image_url IS NOT NULL THEN 1 END) as players_with_photos
FROM players p
LEFT JOIN player_positions pp ON p.id = pp.player_id;

COMMIT;

-- Sports table removed successfully
-- Sport-specific configuration now stored in app_config