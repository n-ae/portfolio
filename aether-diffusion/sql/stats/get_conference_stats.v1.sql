-- NBA Fantasy Sports Database
-- Query: get_conference_stats
-- Version: 1.0
-- Description: Get team counts by conference
-- Returns: conference, team_count, teams_with_players

SELECT 
    conference,
    COUNT(*) as team_count,
    SUM(CASE WHEN player_counts.player_count > 0 THEN 1 ELSE 0 END) as teams_with_players
FROM teams t
LEFT JOIN (
    SELECT team_id, COUNT(*) as player_count
    FROM players 
    WHERE is_active = 1
    GROUP BY team_id
) player_counts ON t.id = player_counts.team_id
WHERE conference IN ('Eastern', 'Western')
GROUP BY conference
ORDER BY conference;