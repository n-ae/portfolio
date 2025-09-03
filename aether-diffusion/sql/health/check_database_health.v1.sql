-- NBA Fantasy Sports Database
-- Query: check_database_health
-- Version: 1.0
-- Description: Basic database connectivity and data integrity check
-- Returns: total_players, total_teams, total_positions, available_positions

SELECT 
    (SELECT COUNT(*) FROM players) as total_players,
    (SELECT COUNT(*) FROM teams) as total_teams,
    (SELECT COUNT(*) FROM player_positions) as total_positions,
    (SELECT COUNT(*) FROM positions) as available_positions;