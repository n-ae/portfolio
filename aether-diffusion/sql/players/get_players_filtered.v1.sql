-- NBA Fantasy Sports Database
-- Query: get_players_filtered
-- Version: 1.0
-- Description: Retrieve players with optional filters
-- Parameters: 
--   $1 (team_filter): Filter by team abbreviation (optional)
--   $2 (position_filter): Filter by position code (optional) 
--   $3 (search_query): Search in player names (optional)
--   $4 (limit): Maximum number of results (default: 50)
--   $5 (offset): Number of records to skip (default: 0)

SELECT 
    p.id, 
    p.full_name, 
    p.first_name, 
    p.last_name,
    COALESCE(t.abbreviation, 'FA') as team,
    COALESCE(pos.code, '') as position,
    COALESCE(p.uniform_number, '') as uniform_number,
    p.is_active,
    COALESCE(p.yahoo_player_key, '') as yahoo_player_key
FROM players p
LEFT JOIN teams t ON p.team_id = t.id
LEFT JOIN player_positions pp ON p.id = pp.player_id AND pp.is_primary = 1
LEFT JOIN positions pos ON pp.position_id = pos.id
WHERE 
    ($1 IS NULL OR t.abbreviation = $1) AND
    ($2 IS NULL OR pos.code = $2) AND
    ($3 IS NULL OR p.full_name LIKE '%' || $3 || '%' 
                 OR p.first_name LIKE '%' || $3 || '%' 
                 OR p.last_name LIKE '%' || $3 || '%')
ORDER BY t.abbreviation, p.full_name
LIMIT $4 OFFSET $5;