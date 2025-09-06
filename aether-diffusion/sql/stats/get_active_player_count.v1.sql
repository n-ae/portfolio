-- NBA Fantasy Sports Database
-- Query: get_active_player_count
-- Version: 1.0
-- Description: Get count of active players
-- Returns: count (integer)

SELECT COUNT(*) FROM players WHERE is_active = 1;