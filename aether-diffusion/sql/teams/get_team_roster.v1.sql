-- NBA Fantasy Sports Database
-- Query: get_team_roster
-- Version: 1.0
-- Description: Get all players for a specific team
-- Parameters:
--   $1 (team_id): Team ID to get roster for

SELECT 
    p.id, 
    p.full_name, 
    p.first_name, 
    p.last_name,
    COALESCE(pos.code, '') as position,
    COALESCE(p.uniform_number, '') as uniform_number,
    p.is_active,
    COALESCE(p.yahoo_player_key, '') as yahoo_player_key
FROM players p
LEFT JOIN player_positions pp ON p.id = pp.player_id AND pp.is_primary = 1
LEFT JOIN positions pos ON pp.position_id = pos.id
WHERE p.team_id = $1 AND p.is_active = 1
ORDER BY pos.code, p.full_name;