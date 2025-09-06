-- NBA Fantasy Sports Database
-- Query: get_all_teams
-- Version: 1.0
-- Description: Retrieve all NBA teams with player counts
-- Returns: id, abbreviation, full_name, city, conference, division, player_count, yahoo_team_key

SELECT 
    t.id, 
    t.abbreviation, 
    t.full_name, 
    t.city, 
    t.conference, 
    t.division,
    COUNT(p.id) as player_count,
    COALESCE(t.yahoo_team_key, '') as yahoo_team_key
FROM teams t
LEFT JOIN players p ON t.id = p.team_id AND p.is_active = 1
GROUP BY t.id, t.abbreviation, t.full_name, t.city, t.conference, t.division, t.yahoo_team_key
ORDER BY t.conference, t.division, t.abbreviation;