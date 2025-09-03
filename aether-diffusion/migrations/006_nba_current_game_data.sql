-- Fantasy Sports Database - NBA Current Game Data
-- Migration 006: Add current NBA game settings and active fantasy games
-- Author: Sports Fantasy Database System
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- CURRENT NBA FANTASY GAME CONFIGURATION
-- =============================================================================

-- Create or update current NBA fantasy game for 2024-25 season
INSERT OR IGNORE INTO fantasy_games (
    sport_id, yahoo_game_key, game_name, season, game_type,
    registration_start, registration_end, season_start, season_end,
    is_registration_open, is_active, is_offseason, is_live_draft_active,
    max_teams_per_league, roster_size, starting_lineup_size, bench_size, ir_slots
)
SELECT 
    id, '466', 'NBA 2024-25 Season', '2024-25', 'season',
    '2024-09-01', '2024-10-15', '2024-10-16', '2025-04-13',
    0, 1, 0, 0,
    12, 13, 10, 3, 3
FROM sports WHERE code = 'nba';

-- =============================================================================
-- NBA SEASON SCHEDULE AND KEY DATES  
-- =============================================================================

-- Teams and positions are already active from previous migrations
-- No updates needed for current season

-- =============================================================================
-- CURRENT NBA SEASON CONFIGURATION
-- =============================================================================

-- Add NBA-specific configuration for current season
INSERT OR REPLACE INTO app_config (key, value, description) VALUES
('nba_current_season', '2024-25', 'Current NBA season'),
('nba_season_start', '2024-10-16', 'NBA regular season start date'),
('nba_season_end', '2025-04-13', 'NBA regular season end date'), 
('nba_playoffs_start', '2025-04-19', 'NBA playoffs start date'),
('nba_playoffs_end', '2025-06-20', 'NBA playoffs end date (estimated)'),
('nba_trade_deadline', '2025-02-06', 'NBA trade deadline'),
('nba_all_star_break_start', '2025-02-14', 'NBA All-Star break start'),
('nba_all_star_break_end', '2025-02-18', 'NBA All-Star break end'),
('nba_roster_size', '15', 'NBA active roster size'),
('nba_salary_cap', '140588000', 'NBA salary cap for 2024-25 season (in cents)'),
('nba_luxury_tax', '170814000', 'NBA luxury tax threshold (in cents)'),
('yahoo_nba_game_key', '466', 'Yahoo Fantasy NBA game key for current season'),
('fantasy_playoffs_start', '2025-03-10', 'Fantasy playoffs start (week 20)'),
('fantasy_championship', '2025-03-24', 'Fantasy championship week'),
('fantasy_draft_season', 'active', 'Current fantasy draft status');

-- =============================================================================
-- NBA CURRENT STANDINGS PLACEHOLDERS (to be updated via API)
-- =============================================================================

-- These will be populated by the application via Yahoo API calls
-- Just creating the structure for now

-- Conference and division data already set during team seeding
-- NBA teams are already properly configured with Eastern/Western conferences

-- =============================================================================
-- FANTASY SCORING SETTINGS (Standard Yahoo Scoring)
-- =============================================================================

-- Create cache configuration specifically for NBA
INSERT OR REPLACE INTO cache_config (data_type, ttl_minutes, max_age_minutes, refresh_threshold_hours) VALUES
('nba_player_list', 60, 360, 6),
('nba_player_detail', 30, 180, 3),
('nba_player_stats', 240, 1440, 24),
('nba_team_roster', 120, 720, 12),
('nba_standings', 60, 360, 6),
('nba_schedule', 1440, 4320, 72),
('nba_injury_report', 30, 120, 2);

-- =============================================================================
-- SYNC LOG ENTRY FOR NBA SETUP
-- =============================================================================

INSERT INTO sync_logs (sport_id, operation_type, status, started_at, completed_at, records_processed) VALUES
((SELECT id FROM sports WHERE code = 'nba'), 'nba_game_setup', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0);

COMMIT;

-- NBA current game data migration completed successfully
-- Next: Use application to sync current player data from Yahoo API