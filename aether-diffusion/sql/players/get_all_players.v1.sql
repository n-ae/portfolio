-- NBA Fantasy Sports Database
-- Query: get_all_players
-- Version: 1.0
-- Description: Retrieve all NBA players with team and position information
-- Returns: id, full_name, first_name, last_name, team, position, uniform_number, is_active, yahoo_player_key

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
ORDER BY t.abbreviation, p.full_name;