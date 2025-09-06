-- Fantasy Sports Database - Players with Position and Team Relations
-- Migration 008: Create player insertion utilities with proper position/team handling
-- Author: Sports Fantasy Database System  
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- PLAYER INSERTION HELPERS
-- =============================================================================

-- Function to resolve team ID from abbreviation (implemented as view for SQLite)
CREATE VIEW v_team_lookup AS
SELECT 
    s.code as sport_code,
    t.abbreviation as team_abbr,
    t.id as team_id,
    t.full_name as team_name
FROM teams t
JOIN sports s ON t.sport_id = s.id;

-- Function to resolve position ID from code
CREATE VIEW v_position_lookup AS  
SELECT
    s.code as sport_code,
    p.code as position_code,
    p.id as position_id,
    p.name as position_name
FROM positions p
JOIN sports s ON p.sport_id = s.id;

-- View to get fantasy categories for positions
CREATE VIEW v_position_categories_lookup AS
SELECT 
    s.code as sport_code,
    p.code as position_code,
    pc.code as category_code,
    pc.name as category_name,
    pc.is_fantasy_position
FROM positions p
JOIN sports s ON p.sport_id = s.id
JOIN position_category_mapping pcm ON p.id = pcm.position_id
JOIN position_categories pc ON pcm.category_id = pc.id;

-- =============================================================================
-- PLAYER DATA VALIDATION
-- =============================================================================

-- Check for duplicate players by Yahoo player key
CREATE VIEW v_duplicate_players AS
SELECT 
    yahoo_player_key,
    COUNT(*) as duplicate_count
FROM players 
GROUP BY yahoo_player_key
HAVING COUNT(*) > 1;

-- Players without team assignments
CREATE VIEW v_players_no_team AS
SELECT 
    p.id,
    p.yahoo_player_key,
    p.full_name,
    s.code as sport_code
FROM players p
JOIN sports s ON p.sport_id = s.id
WHERE p.team_id IS NULL;

-- Players without position assignments  
CREATE VIEW v_players_no_positions AS
SELECT
    p.id,
    p.yahoo_player_key, 
    p.full_name,
    s.code as sport_code
FROM players p
JOIN sports s ON p.sport_id = s.id
LEFT JOIN player_positions pp ON p.id = pp.player_id
WHERE pp.player_id IS NULL;

-- =============================================================================
-- CURRENT NBA ROSTER STATS (for reference)
-- =============================================================================

-- Team roster counts
CREATE VIEW v_nba_roster_stats AS
SELECT 
    t.abbreviation,
    t.full_name,
    t.conference,
    t.division,
    COUNT(p.id) as active_players,
    GROUP_CONCAT(
        CASE WHEN pp.is_primary = 1 
        THEN p.full_name || ' (' || pos.code || ')'
        END, ', '
    ) as primary_positions
FROM teams t
JOIN sports s ON t.sport_id = s.id
LEFT JOIN players p ON t.id = p.team_id AND p.is_active = 1
LEFT JOIN player_positions pp ON p.id = pp.player_id AND pp.is_primary = 1
LEFT JOIN positions pos ON pp.position_id = pos.id
WHERE s.code = 'nba'
GROUP BY t.id, t.abbreviation, t.full_name
ORDER BY t.conference, t.division, t.abbreviation;

-- Position distribution across NBA
CREATE VIEW v_nba_position_stats AS
SELECT 
    pos.code,
    pos.name,
    COUNT(pp.player_id) as player_count,
    COUNT(CASE WHEN pp.is_primary = 1 THEN 1 END) as primary_count
FROM positions pos
JOIN sports s ON pos.sport_id = s.id
LEFT JOIN player_positions pp ON pos.id = pp.position_id
LEFT JOIN players p ON pp.player_id = p.id AND p.is_active = 1
WHERE s.code = 'nba'
GROUP BY pos.id, pos.code, pos.name
ORDER BY pos.sort_order;

-- =============================================================================
-- SAMPLE PLAYER DATA STRUCTURE (for API integration)
-- =============================================================================

-- This shows the expected structure for importing players from Yahoo API
-- Actual player data will be inserted by the Go application

/*
Example player insertion pattern:

-- 1. Insert player with basic info
INSERT INTO players (
    yahoo_player_key, yahoo_player_id, sport_id, team_id,
    first_name, last_name, full_name, uniform_number,
    is_active, yahoo_image_url
) VALUES (
    'nba.p.3704', '3704', 
    (SELECT id FROM sports WHERE code = 'nba'),
    (SELECT id FROM teams WHERE abbreviation = 'LAL' AND sport_id = (SELECT id FROM sports WHERE code = 'nba')),
    'LeBron', 'James', 'LeBron James', '6',
    1, 'https://s.yimg.com/iu/api/res/1.2/...'
);

-- 2. Assign primary position  
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES (
    (SELECT id FROM players WHERE yahoo_player_key = 'nba.p.3704'),
    (SELECT id FROM positions WHERE code = 'SF' AND sport_id = (SELECT id FROM sports WHERE code = 'nba')),
    1
);

-- 3. Assign eligible positions
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES (
    (SELECT id FROM players WHERE yahoo_player_key = 'nba.p.3704'),
    (SELECT id FROM positions WHERE code = 'PF' AND sport_id = (SELECT id FROM sports WHERE code = 'nba')),
    0
);
*/

-- =============================================================================  
-- PLAYER IMPORT SUMMARY
-- =============================================================================

-- Summary of current player data in the database
CREATE VIEW v_player_import_summary AS
SELECT 
    s.code as sport,
    COUNT(p.id) as total_players,
    COUNT(CASE WHEN p.is_active = 1 THEN 1 END) as active_players,
    COUNT(CASE WHEN p.team_id IS NOT NULL THEN 1 END) as players_with_teams,
    COUNT(CASE WHEN pp.player_id IS NOT NULL THEN 1 END) as players_with_positions,
    COUNT(DISTINCT p.team_id) as teams_with_players,
    COUNT(CASE WHEN p.yahoo_image_url IS NOT NULL THEN 1 END) as players_with_photos
FROM sports s
LEFT JOIN players p ON s.id = p.sport_id  
LEFT JOIN player_positions pp ON p.id = pp.player_id
GROUP BY s.id, s.code;

COMMIT;

-- Players migration with relations created successfully
-- Ready for API data import with proper team/position handling