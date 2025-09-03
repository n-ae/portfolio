-- Fantasy Sports Database - Schema Simplification  
-- Migration 007: Remove redundant tables and create position category relations
-- Author: Sports Fantasy Database System
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- DROP REDUNDANT AND UNAVAILABLE DATA TABLES
-- =============================================================================

-- Drop views first (they depend on tables)
DROP VIEW IF EXISTS v_players_complete;
DROP VIEW IF EXISTS v_fantasy_players; 
DROP VIEW IF EXISTS v_stale_cache;
DROP VIEW IF EXISTS v_cache_stats;

-- Drop sport-specific stats tables (we only have NBA)
DROP TABLE IF EXISTS nfl_player_stats;
DROP TABLE IF EXISTS mlb_player_stats; 
DROP TABLE IF EXISTS nhl_player_stats;

-- Drop data we don't actually have
DROP TABLE IF EXISTS nba_player_contracts;
DROP TABLE IF EXISTS player_milestones;
DROP TABLE IF EXISTS player_injuries;
DROP TABLE IF EXISTS fantasy_player_data;

-- Drop overcomplicated caching system
DROP TABLE IF EXISTS api_cache;
DROP TABLE IF EXISTS player_cache_status;
DROP TABLE IF EXISTS team_cache_status;
DROP TABLE IF EXISTS cache_config;

-- =============================================================================
-- CREATE POSITION CATEGORY RELATIONS
-- =============================================================================

-- Position categories (Guard, Forward, Center, etc.)
CREATE TABLE position_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sport_id INTEGER NOT NULL,
    code TEXT NOT NULL,                    -- 'G', 'F', 'C', 'UTIL'
    name TEXT NOT NULL,                    -- 'Guard', 'Forward', 'Center', 'Utility'
    description TEXT,                      -- 'Eligible positions: PG, SG'
    sort_order INTEGER DEFAULT 0,
    is_fantasy_position BOOLEAN DEFAULT 0, -- Is this a fantasy umbrella position
    is_active BOOLEAN DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (sport_id) REFERENCES sports (id) ON DELETE CASCADE,
    UNIQUE(sport_id, code)
);

-- Relation between specific positions and categories
CREATE TABLE position_category_mapping (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    position_id INTEGER NOT NULL,          -- Links to specific position (PG, SG)
    category_id INTEGER NOT NULL,          -- Links to category (Guard)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (position_id) REFERENCES positions (id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES position_categories (id) ON DELETE CASCADE,
    UNIQUE(position_id, category_id)
);

-- =============================================================================
-- SEED NBA POSITION CATEGORIES
-- =============================================================================

-- Insert NBA position categories
INSERT INTO position_categories (sport_id, code, name, description, sort_order, is_fantasy_position) 
SELECT 
    id, 'G', 'Guard', 'Point Guard and Shooting Guard positions', 1, 1
FROM sports WHERE code = 'nba';

INSERT INTO position_categories (sport_id, code, name, description, sort_order, is_fantasy_position) 
SELECT 
    id, 'F', 'Forward', 'Small Forward and Power Forward positions', 2, 1  
FROM sports WHERE code = 'nba';

INSERT INTO position_categories (sport_id, code, name, description, sort_order, is_fantasy_position) 
SELECT 
    id, 'C', 'Center', 'Center position', 3, 1
FROM sports WHERE code = 'nba';

INSERT INTO position_categories (sport_id, code, name, description, sort_order, is_fantasy_position) 
SELECT 
    id, 'UTIL', 'Utility', 'Any position (universal flex spot)', 4, 1
FROM sports WHERE code = 'nba';

-- Map specific NBA positions to categories
-- Guards: PG, SG -> G
INSERT INTO position_category_mapping (position_id, category_id)
SELECT p.id, pc.id
FROM positions p
JOIN sports s ON p.sport_id = s.id  
JOIN position_categories pc ON pc.sport_id = s.id
WHERE s.code = 'nba' 
    AND p.code IN ('PG', 'SG')
    AND pc.code = 'G';

-- Forwards: SF, PF -> F  
INSERT INTO position_category_mapping (position_id, category_id)
SELECT p.id, pc.id
FROM positions p
JOIN sports s ON p.sport_id = s.id
JOIN position_categories pc ON pc.sport_id = s.id  
WHERE s.code = 'nba'
    AND p.code IN ('SF', 'PF')
    AND pc.code = 'F';

-- Centers: C -> C
INSERT INTO position_category_mapping (position_id, category_id)
SELECT p.id, pc.id
FROM positions p
JOIN sports s ON p.sport_id = s.id
JOIN position_categories pc ON pc.sport_id = s.id
WHERE s.code = 'nba'
    AND p.code = 'C'
    AND pc.code = 'C';

-- All positions -> UTIL
INSERT INTO position_category_mapping (position_id, category_id)  
SELECT p.id, pc.id
FROM positions p
JOIN sports s ON p.sport_id = s.id
JOIN position_categories pc ON pc.sport_id = s.id
WHERE s.code = 'nba'
    AND p.code IN ('PG', 'SG', 'SF', 'PF', 'C')
    AND pc.code = 'UTIL';

-- =============================================================================
-- REMOVE REDUNDANT POSITION ENTRIES
-- =============================================================================

-- Remove the old fantasy positions from positions table since we now have categories
DELETE FROM positions 
WHERE sport_id = (SELECT id FROM sports WHERE code = 'nba')
    AND code IN ('G', 'F', 'UTIL');

-- =============================================================================
-- SIMPLIFIED VIEWS
-- =============================================================================

-- Simple player view with position categories
CREATE VIEW v_players_with_categories AS
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
JOIN sports s ON p.sport_id = s.id
LEFT JOIN teams t ON p.team_id = t.id
LEFT JOIN player_positions pp ON p.id = pp.player_id
LEFT JOIN positions pos ON pp.position_id = pos.id
LEFT JOIN position_category_mapping pcm ON pos.id = pcm.position_id
LEFT JOIN position_categories pc ON pcm.category_id = pc.id
GROUP BY p.id, p.yahoo_player_key, p.full_name, s.code, t.abbreviation;

-- Simple team roster view
CREATE VIEW v_team_rosters AS
SELECT 
    t.id as team_id,
    t.abbreviation as team_abbr,
    t.full_name as team_name,
    t.city,
    t.conference,
    t.division,
    s.code as sport_code,
    COUNT(p.id) as player_count,
    GROUP_CONCAT(p.full_name, '; ') as player_names
FROM teams t
JOIN sports s ON t.sport_id = s.id
LEFT JOIN players p ON t.id = p.team_id AND p.is_active = 1
GROUP BY t.id, t.abbreviation, t.full_name, s.code;

-- =============================================================================
-- CLEANUP APP CONFIG
-- =============================================================================

-- Remove unused configuration
DELETE FROM app_config WHERE key LIKE '%cache%';
DELETE FROM app_config WHERE key LIKE '%stats_retention%';

-- =============================================================================
-- INDEXES FOR NEW TABLES
-- =============================================================================

CREATE INDEX idx_position_categories_sport ON position_categories(sport_id);
CREATE INDEX idx_position_categories_code ON position_categories(code);
CREATE INDEX idx_position_categories_fantasy ON position_categories(is_fantasy_position) WHERE is_fantasy_position = 1;

CREATE INDEX idx_position_mapping_position ON position_category_mapping(position_id);
CREATE INDEX idx_position_mapping_category ON position_category_mapping(category_id);

COMMIT;

-- Schema simplification completed successfully
-- Removed redundant tables and created position category relations