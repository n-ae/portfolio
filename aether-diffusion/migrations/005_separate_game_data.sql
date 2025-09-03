-- Fantasy Sports Database - Separate Game-Specific Data
-- Migration 005: Properly separate real-world player data from fantasy game settings
-- Author: Sports Fantasy Database System
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- DROP EXISTING VIEWS THAT REFERENCE OLD PLAYERS TABLE STRUCTURE  
-- =============================================================================

DROP VIEW IF EXISTS v_players_complete;
DROP VIEW IF EXISTS v_nba_players_current; 
DROP VIEW IF EXISTS v_team_rosters;
DROP VIEW IF EXISTS v_player_ages;
DROP VIEW IF EXISTS v_team_roster_sizes;
DROP VIEW IF EXISTS v_player_position_summary;
DROP VIEW IF EXISTS v_players_needing_refresh;
DROP VIEW IF EXISTS v_player_cache_effectiveness;
DROP VIEW IF EXISTS v_cache_key_generator;

-- =============================================================================
-- FANTASY GAME CONFIGURATION
-- =============================================================================

-- Fantasy game settings (Yahoo-specific configurations)
CREATE TABLE fantasy_games (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sport_id INTEGER NOT NULL,
    yahoo_game_key TEXT UNIQUE NOT NULL,     -- Yahoo's game key (e.g., '466')
    game_name TEXT NOT NULL,                 -- 'NBA 2024-25 Season'
    season TEXT NOT NULL,                    -- '2024-25'
    game_type TEXT NOT NULL,                 -- 'season', 'playoff', 'dynasty'
    
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
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sport_id) REFERENCES sports (id) ON DELETE CASCADE,
    UNIQUE(sport_id, season)
);

-- =============================================================================
-- FANTASY-SPECIFIC PLAYER DATA (separate from real-world data)
-- =============================================================================

-- Fantasy player settings and metadata (Yahoo-specific)
CREATE TABLE fantasy_player_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,              -- Links to real player
    fantasy_game_id INTEGER NOT NULL,        -- Which fantasy game/season
    
    -- Yahoo Fantasy specific settings
    is_undroppable BOOLEAN DEFAULT 0,        -- Fantasy game setting (moved from players table)
    yahoo_ownership_percentage REAL,         -- % of Yahoo leagues that own this player
    yahoo_start_percentage REAL,             -- % of Yahoo leagues that start this player
    yahoo_add_percentage REAL,               -- % of leagues adding this player
    yahoo_drop_percentage REAL,              -- % of leagues dropping this player
    
    -- Fantasy projections and rankings
    yahoo_projected_rank INTEGER,            -- Yahoo's projected rank
    yahoo_current_rank INTEGER,              -- Current season rank
    preseason_rank INTEGER,                  -- Pre-season fantasy rank
    expert_consensus_rank INTEGER,           -- Expert consensus ranking
    
    -- Fantasy eligibility
    is_fantasy_eligible BOOLEAN DEFAULT 1,   -- Can be drafted/added in fantasy
    fantasy_status TEXT,                     -- 'active', 'suspended', 'ineligible'
    fantasy_notes TEXT,                      -- Fantasy-relevant notes
    
    -- Price/salary data (for salary cap leagues)
    yahoo_salary INTEGER,                    -- Salary for daily fantasy
    salary_change INTEGER,                   -- Change from previous day
    
    -- Performance tracking
    fantasy_points_total REAL DEFAULT 0,     -- Total fantasy points
    fantasy_points_per_game REAL DEFAULT 0,  -- Average fantasy points per game
    consistency_rating REAL,                 -- How consistent are their fantasy scores
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE,
    FOREIGN KEY (fantasy_game_id) REFERENCES fantasy_games (id) ON DELETE CASCADE,
    UNIQUE(player_id, fantasy_game_id)
);

-- =============================================================================
-- REAL-WORLD PLAYER DATA (game-agnostic)
-- =============================================================================

-- Real-world injury tracking (separate from fantasy status)
CREATE TABLE player_injuries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    
    -- Injury details
    injury_type TEXT,                        -- 'knee', 'shoulder', 'concussion'
    injury_description TEXT,                 -- Detailed description
    body_part TEXT,                          -- 'left knee', 'right shoulder'
    severity TEXT,                           -- 'minor', 'moderate', 'severe'
    
    -- Timeline
    injury_date DATE,                        -- When injury occurred
    reported_date DATE DEFAULT (date('now')), -- When injury was reported
    expected_return_date DATE,               -- Estimated return
    actual_return_date DATE,                 -- Actual return date
    
    -- Status
    current_status TEXT NOT NULL,            -- 'out', 'day-to-day', 'probable', 'recovered'
    is_active BOOLEAN DEFAULT 1,            -- Is this the current injury status
    
    -- Sources
    source_type TEXT,                        -- 'team_report', 'media', 'yahoo_api'
    source_url TEXT,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE
);

-- Real-world player contracts and team history (NBA example)
CREATE TABLE nba_player_contracts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    
    -- Contract details
    contract_type TEXT,                      -- 'rookie', 'veteran', 'max', 'minimum'
    start_date DATE,
    end_date DATE,
    total_value BIGINT,                      -- Contract value in cents
    guaranteed_value BIGINT,                 -- Guaranteed money in cents
    annual_value BIGINT,                     -- Annual average value in cents
    
    -- Contract options
    has_player_option BOOLEAN DEFAULT 0,
    has_team_option BOOLEAN DEFAULT 0,
    has_early_termination BOOLEAN DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT 1,
    contract_status TEXT,                    -- 'active', 'expired', 'voided'
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE
);

-- Player career milestones (game-agnostic achievements)
CREATE TABLE player_milestones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    
    -- Milestone details
    milestone_type TEXT NOT NULL,            -- 'points', 'games', 'awards', 'records'
    milestone_name TEXT NOT NULL,            -- '1000 career points', 'Rookie of the Year'
    milestone_value INTEGER,                 -- Numeric value if applicable
    achievement_date DATE,
    season TEXT,
    
    -- Context
    description TEXT,
    team_id INTEGER,                         -- Team when milestone achieved
    opponent_team_id INTEGER,                -- Opponent if game-specific
    game_date DATE,
    
    -- Verification
    is_verified BOOLEAN DEFAULT 0,
    source_url TEXT,
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE SET NULL,
    FOREIGN KEY (opponent_team_id) REFERENCES teams (id) ON DELETE SET NULL
);

-- =============================================================================
-- UPDATE EXISTING TABLES (Remove game-specific data)
-- =============================================================================

-- Create new clean players table without fantasy-specific columns
CREATE TABLE players_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    yahoo_player_key TEXT UNIQUE NOT NULL,
    yahoo_player_id TEXT NOT NULL,
    sport_id INTEGER NOT NULL,
    team_id INTEGER,
    
    -- Personal Information (real-world data only)
    first_name TEXT,
    last_name TEXT,
    full_name TEXT NOT NULL,
    birthdate DATE,
    height_inches INTEGER,
    weight_pounds INTEGER,
    
    -- Professional information
    uniform_number TEXT,
    years_pro INTEGER,                       -- Years as professional
    college TEXT,                            -- College attended
    draft_year INTEGER,                      -- Year drafted
    draft_round INTEGER,                     -- Round drafted
    draft_pick INTEGER,                      -- Pick number in draft
    
    -- Real-world status (not fantasy status)
    is_active BOOLEAN DEFAULT 1,            -- Is currently playing professionally
    is_rookie BOOLEAN DEFAULT 0,            -- Is in rookie season
    current_injury_status TEXT,             -- 'healthy', 'injured', 'day-to-day'
    
    -- Yahoo API metadata (for sync purposes)
    yahoo_image_url TEXT,
    yahoo_headshot_url TEXT,
    yahoo_profile_url TEXT,
    yahoo_editorial_player_key TEXT,
    yahoo_editorial_team_key TEXT,
    
    -- Metadata
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_sync_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sport_id) REFERENCES sports (id) ON DELETE CASCADE,
    FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE SET NULL
);

-- =============================================================================
-- DATA MIGRATION FROM OLD TO NEW STRUCTURE
-- =============================================================================

-- Migrate existing player data to new structure
INSERT INTO players_new (
    yahoo_player_key, yahoo_player_id, sport_id, team_id,
    first_name, last_name, full_name, birthdate, height_inches, weight_pounds,
    uniform_number, is_active, yahoo_image_url, yahoo_headshot_url, 
    yahoo_profile_url, yahoo_editorial_player_key, yahoo_editorial_team_key,
    created_at, updated_at, last_sync_at
)
SELECT 
    yahoo_player_key, yahoo_player_id, sport_id, team_id,
    first_name, last_name, full_name, birthdate, height_inches, weight_pounds,
    uniform_number, is_active, yahoo_image_url, yahoo_headshot_url,
    yahoo_profile_url, yahoo_editorial_player_key, yahoo_editorial_team_key,
    created_at, updated_at, last_sync_at
FROM players;

-- Create fantasy games for current NBA season
INSERT INTO fantasy_games (
    sport_id, yahoo_game_key, game_name, season, game_type,
    is_registration_open, is_active, is_offseason, is_live_draft_active
)
SELECT 
    id, yahoo_game_key, name || ' ' || season, season, 'season',
    1, is_active, 0, 1
FROM sports;

-- Migrate fantasy-specific data
INSERT INTO fantasy_player_data (
    player_id, fantasy_game_id, is_undroppable,
    is_fantasy_eligible, fantasy_status
)
SELECT 
    pn.id,
    fg.id,
    COALESCE(p.is_undroppable, 0),
    1,
    CASE WHEN p.is_active = 1 THEN 'active' ELSE 'inactive' END
FROM players_new pn
JOIN sports s ON pn.sport_id = s.id
JOIN fantasy_games fg ON fg.sport_id = s.id
LEFT JOIN players p ON p.yahoo_player_key = pn.yahoo_player_key;

-- Migrate injury data
INSERT INTO player_injuries (
    player_id, injury_description, current_status, 
    is_active, source_type, last_updated
)
SELECT 
    pn.id,
    p.injury_note,
    CASE WHEN p.is_injured = 1 THEN 'out' ELSE 'healthy' END,
    CASE WHEN p.is_injured = 1 THEN 1 ELSE 0 END,
    'yahoo_api',
    p.updated_at
FROM players_new pn
LEFT JOIN players p ON p.yahoo_player_key = pn.yahoo_player_key
WHERE p.injury_note IS NOT NULL OR p.is_injured = 1;

-- =============================================================================
-- REPLACE OLD TABLE WITH NEW STRUCTURE
-- =============================================================================

-- Drop the old players table and rename new one
DROP TABLE players;
ALTER TABLE players_new RENAME TO players;

-- Recreate foreign key constraints and indexes
CREATE INDEX idx_players_sport ON players(sport_id);
CREATE INDEX idx_players_team ON players(team_id);
CREATE INDEX idx_players_name ON players(full_name);
CREATE INDEX idx_players_active ON players(is_active);
CREATE INDEX idx_players_yahoo_key ON players(yahoo_player_key);
CREATE INDEX idx_players_sync ON players(last_sync_at);
CREATE INDEX idx_players_sport_team_active ON players(sport_id, team_id, is_active);
CREATE INDEX idx_players_name_search ON players(full_name COLLATE NOCASE);
CREATE INDEX idx_players_draft ON players(draft_year, draft_round, draft_pick);

-- =============================================================================
-- INDEXES FOR NEW TABLES
-- =============================================================================

CREATE INDEX idx_fantasy_games_sport ON fantasy_games(sport_id);
CREATE INDEX idx_fantasy_games_active ON fantasy_games(is_active);
CREATE INDEX idx_fantasy_games_season ON fantasy_games(season);

CREATE INDEX idx_fantasy_player_data_player ON fantasy_player_data(player_id);
CREATE INDEX idx_fantasy_player_data_game ON fantasy_player_data(fantasy_game_id);
CREATE INDEX idx_fantasy_player_data_undroppable ON fantasy_player_data(is_undroppable) WHERE is_undroppable = 1;
CREATE INDEX idx_fantasy_player_data_rank ON fantasy_player_data(yahoo_current_rank);

CREATE INDEX idx_player_injuries_player ON player_injuries(player_id);
CREATE INDEX idx_player_injuries_active ON player_injuries(is_active) WHERE is_active = 1;
CREATE INDEX idx_player_injuries_status ON player_injuries(current_status);
CREATE INDEX idx_player_injuries_date ON player_injuries(injury_date);

CREATE INDEX idx_nba_contracts_player ON nba_player_contracts(player_id);
CREATE INDEX idx_nba_contracts_team ON nba_player_contracts(team_id);
CREATE INDEX idx_nba_contracts_active ON nba_player_contracts(is_active) WHERE is_active = 1;
CREATE INDEX idx_nba_contracts_value ON nba_player_contracts(total_value);

CREATE INDEX idx_player_milestones_player ON player_milestones(player_id);
CREATE INDEX idx_player_milestones_type ON player_milestones(milestone_type);
CREATE INDEX idx_player_milestones_date ON player_milestones(achievement_date);

-- =============================================================================
-- UPDATED VIEWS FOR NEW STRUCTURE
-- =============================================================================

-- Complete player view with fantasy data
DROP VIEW IF EXISTS v_players_complete;
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
    p.current_injury_status,
    p.yahoo_image_url,
    -- Fantasy data
    fpd.is_undroppable,
    fpd.yahoo_ownership_percentage,
    fpd.fantasy_points_per_game,
    fpd.yahoo_current_rank,
    -- Current injury
    pi.current_status as injury_status,
    pi.injury_description,
    p.updated_at
FROM players p
JOIN sports s ON p.sport_id = s.id
LEFT JOIN teams t ON p.team_id = t.id
LEFT JOIN player_positions pp ON p.id = pp.player_id
LEFT JOIN positions pos ON pp.position_id = pos.id
LEFT JOIN fantasy_games fg ON fg.sport_id = s.id AND fg.is_active = 1
LEFT JOIN fantasy_player_data fpd ON fpd.player_id = p.id AND fpd.fantasy_game_id = fg.id
LEFT JOIN player_injuries pi ON pi.player_id = p.id AND pi.is_active = 1
GROUP BY p.id, p.yahoo_player_key, p.full_name, s.code, t.abbreviation;

-- Fantasy-focused view for draft/roster management
CREATE VIEW v_fantasy_players AS
SELECT 
    p.full_name,
    t.abbreviation as team,
    (SELECT pos.code FROM player_positions pp 
     JOIN positions pos ON pp.position_id = pos.id 
     WHERE pp.player_id = p.id AND pp.is_primary = 1) as position,
    fpd.is_undroppable,
    fpd.yahoo_ownership_percentage,
    fpd.yahoo_current_rank,
    fpd.fantasy_points_per_game,
    fpd.expert_consensus_rank,
    pi.current_status as injury_status,
    p.is_active as is_playing,
    fpd.is_fantasy_eligible
FROM players p
JOIN fantasy_player_data fpd ON fpd.player_id = p.id
JOIN fantasy_games fg ON fpd.fantasy_game_id = fg.id AND fg.is_active = 1
JOIN sports s ON fg.sport_id = s.id
LEFT JOIN teams t ON p.team_id = t.id
LEFT JOIN player_injuries pi ON pi.player_id = p.id AND pi.is_active = 1
WHERE fpd.is_fantasy_eligible = 1;

COMMIT;

-- Game-agnostic data separation completed successfully
-- Real-world player data is now separate from fantasy game settings
-- Next: Update application code to use new normalized structure