-- Fantasy Sports Database - Additional Constraints
-- Migration 003: Add business logic constraints and validation rules
-- Author: Sports Fantasy Database System  
-- Date: 2025-08-31
-- Note: SQLite constraints are enforced via CHECK constraints in CREATE TABLE

BEGIN TRANSACTION;

-- =============================================================================  
-- NOTE: SQLite doesn't support ALTER TABLE ADD CONSTRAINT
-- Constraints were already added in the initial schema (001_initial_schema.sql)
-- This migration adds additional indexes and views for performance
-- =============================================================================

-- =============================================================================
-- BUSINESS LOGIC CONSTRAINTS
-- =============================================================================

-- Each player can only have one primary position
CREATE UNIQUE INDEX idx_player_positions_one_primary 
ON player_positions(player_id) 
WHERE is_primary = 1;

-- Team abbreviations must be unique within a sport
CREATE UNIQUE INDEX idx_teams_unique_abbr_per_sport
ON teams(sport_id, abbreviation);

-- Position codes must be unique within a sport
CREATE UNIQUE INDEX idx_positions_unique_code_per_sport
ON positions(sport_id, code);

-- Prevent duplicate active sports with same code
CREATE UNIQUE INDEX idx_sports_unique_active_code
ON sports(code) 
WHERE is_active = 1;

-- =============================================================================
-- ADDITIONAL INDEXES FOR PERFORMANCE
-- =============================================================================

-- Composite indexes for common queries
CREATE INDEX idx_players_sport_team_active ON players(sport_id, team_id, is_active);
CREATE INDEX idx_players_name_search ON players(full_name COLLATE NOCASE);
CREATE INDEX idx_players_last_sync ON players(sport_id, last_sync_at);

-- NBA stats performance indexes
CREATE INDEX idx_nba_stats_season_type ON nba_player_stats(season, stat_type);
CREATE INDEX idx_nba_stats_ppg ON nba_player_stats(points_per_game DESC) WHERE points_per_game > 0;
CREATE INDEX idx_nba_stats_rpg ON nba_player_stats(rebounds_per_game DESC) WHERE rebounds_per_game > 0;
CREATE INDEX idx_nba_stats_apg ON nba_player_stats(assists_per_game DESC) WHERE assists_per_game > 0;

-- Team and position lookup indexes
CREATE INDEX idx_teams_name_search ON teams(full_name COLLATE NOCASE);
CREATE INDEX idx_positions_category ON positions(sport_id, category);

-- Sync logs performance
CREATE INDEX idx_sync_logs_recent ON sync_logs(started_at DESC);
CREATE INDEX idx_sync_logs_sport_status ON sync_logs(sport_id, status);

-- =============================================================================
-- CUSTOM FUNCTIONS (SQLite compatible)
-- =============================================================================

-- Note: SQLite doesn't support custom functions in SQL, but we can create views
-- that provide calculated fields commonly needed

-- Player age calculation view
CREATE VIEW v_player_ages AS
SELECT 
    id,
    yahoo_player_key,
    full_name,
    birthdate,
    CASE 
        WHEN birthdate IS NOT NULL 
        THEN CAST((julianday('now') - julianday(birthdate)) / 365.25 AS INTEGER)
        ELSE NULL 
    END as age_years
FROM players
WHERE birthdate IS NOT NULL;

-- Team roster size view
CREATE VIEW v_team_roster_sizes AS
SELECT 
    t.id as team_id,
    t.abbreviation,
    t.full_name,
    s.code as sport_code,
    COUNT(p.id) as total_players,
    COUNT(CASE WHEN p.is_active = 1 THEN 1 END) as active_players,
    COUNT(CASE WHEN p.is_injured = 1 THEN 1 END) as injured_players
FROM teams t
JOIN sports s ON t.sport_id = s.id
LEFT JOIN players p ON t.id = p.team_id
GROUP BY t.id, t.abbreviation, t.full_name, s.code;

-- Player position summary view
CREATE VIEW v_player_position_summary AS
SELECT 
    p.id,
    p.yahoo_player_key,
    p.full_name,
    COUNT(pp.position_id) as position_count,
    GROUP_CONCAT(pos.code, '/') as all_positions,
    MAX(CASE WHEN pp.is_primary = 1 THEN pos.code END) as primary_position
FROM players p
LEFT JOIN player_positions pp ON p.id = pp.player_id
LEFT JOIN positions pos ON pp.position_id = pos.id
GROUP BY p.id, p.yahoo_player_key, p.full_name;

COMMIT;

-- Constraints and additional indexes added successfully
-- Database schema is now fully normalized and optimized
-- Next: Use migrate.go to apply all migrations programmatically