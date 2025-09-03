-- NBA Fantasy Sports Database
-- Query: get_teams_with_players_count
-- Version: 1.0
-- Description: Get count of teams that have active players
-- Returns: count (integer)

SELECT COUNT(DISTINCT p.team_id) 
FROM players p 
WHERE p.is_active = 1 AND p.team_id IS NOT NULL;