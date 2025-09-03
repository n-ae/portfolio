-- NBA Fantasy Sports Database
-- Query: get_teams_filtered
-- Version: 1.0
-- Description: Retrieve teams with optional conference filter
-- Parameters:
--   $1 (conference_filter): Filter by conference (Eastern/Western) (optional)

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
WHERE ($1 IS NULL OR t.conference = $1)
GROUP BY t.id, t.abbreviation, t.full_name, t.city, t.conference, t.division, t.yahoo_team_key
ORDER BY t.conference, t.division, t.abbreviation;