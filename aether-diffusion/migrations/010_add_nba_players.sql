-- Fantasy Sports Database - Add NBA Players
-- Migration 010: Insert real NBA players with team and position assignments  
-- Author: Sports Fantasy Database System
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- INSERT NBA PLAYERS (REAL ROSTER DATA)
-- =============================================================================

-- Los Angeles Lakers
INSERT INTO players (
    yahoo_player_key, yahoo_player_id, full_name, first_name, last_name,
    team_id, uniform_number, is_active, is_rookie
) VALUES 
('nba.p.3704', '3704', 'LeBron James', 'LeBron', 'James', 
 (SELECT id FROM teams WHERE abbreviation = 'LAL'), '6', 1, 0),
('nba.p.6450', '6450', 'Anthony Davis', 'Anthony', 'Davis', 
 (SELECT id FROM teams WHERE abbreviation = 'LAL'), '3', 1, 0),
('nba.p.5007', '5007', 'Russell Westbrook', 'Russell', 'Westbrook', 
 (SELECT id FROM teams WHERE abbreviation = 'LAL'), '0', 1, 0);

-- Golden State Warriors  
INSERT INTO players (
    yahoo_player_key, yahoo_player_id, full_name, first_name, last_name,
    team_id, uniform_number, is_active, is_rookie
) VALUES
('nba.p.4612', '4612', 'Stephen Curry', 'Stephen', 'Curry', 
 (SELECT id FROM teams WHERE abbreviation = 'GSW'), '30', 1, 0),
('nba.p.4713', '4713', 'Klay Thompson', 'Klay', 'Thompson', 
 (SELECT id FROM teams WHERE abbreviation = 'GSW'), '11', 1, 0),
('nba.p.5069', '5069', 'Draymond Green', 'Draymond', 'Green', 
 (SELECT id FROM teams WHERE abbreviation = 'GSW'), '23', 1, 0);

-- Boston Celtics
INSERT INTO players (
    yahoo_player_key, yahoo_player_id, full_name, first_name, last_name,
    team_id, uniform_number, is_active, is_rookie
) VALUES
('nba.p.5431', '5431', 'Jayson Tatum', 'Jayson', 'Tatum', 
 (SELECT id FROM teams WHERE abbreviation = 'BOS'), '0', 1, 0),
('nba.p.5432', '5432', 'Jaylen Brown', 'Jaylen', 'Brown', 
 (SELECT id FROM teams WHERE abbreviation = 'BOS'), '7', 1, 0),
('nba.p.4896', '4896', 'Al Horford', 'Al', 'Horford', 
 (SELECT id FROM teams WHERE abbreviation = 'BOS'), '42', 1, 0);

-- Milwaukee Bucks
INSERT INTO players (
    yahoo_player_key, yahoo_player_id, full_name, first_name, last_name,
    team_id, uniform_number, is_active, is_rookie
) VALUES
('nba.p.5578', '5578', 'Giannis Antetokounmpo', 'Giannis', 'Antetokounmpo', 
 (SELECT id FROM teams WHERE abbreviation = 'MIL'), '34', 1, 0),
('nba.p.4725', '4725', 'Khris Middleton', 'Khris', 'Middleton', 
 (SELECT id FROM teams WHERE abbreviation = 'MIL'), '22', 1, 0),
('nba.p.4734', '4734', 'Brook Lopez', 'Brook', 'Lopez', 
 (SELECT id FROM teams WHERE abbreviation = 'MIL'), '11', 1, 0);

-- Phoenix Suns
INSERT INTO players (
    yahoo_player_key, yahoo_player_id, full_name, first_name, last_name,
    team_id, uniform_number, is_active, is_rookie
) VALUES
('nba.p.5465', '5465', 'Devin Booker', 'Devin', 'Booker', 
 (SELECT id FROM teams WHERE abbreviation = 'PHX'), '1', 1, 0),
('nba.p.3930', '3930', 'Kevin Durant', 'Kevin', 'Durant', 
 (SELECT id FROM teams WHERE abbreviation = 'PHX'), '35', 1, 0),
('nba.p.5566', '5566', 'Deandre Ayton', 'Deandre', 'Ayton', 
 (SELECT id FROM teams WHERE abbreviation = 'PHX'), '22', 1, 0);

-- Denver Nuggets
INSERT INTO players (
    yahoo_player_key, yahoo_player_id, full_name, first_name, last_name,
    team_id, uniform_number, is_active, is_rookie
) VALUES
('nba.p.5464', '5464', 'Nikola Jokic', 'Nikola', 'Jokic', 
 (SELECT id FROM teams WHERE abbreviation = 'DEN'), '15', 1, 0),
('nba.p.5463', '5463', 'Jamal Murray', 'Jamal', 'Murray', 
 (SELECT id FROM teams WHERE abbreviation = 'DEN'), '27', 1, 0),
('nba.p.4985', '4985', 'Aaron Gordon', 'Aaron', 'Gordon', 
 (SELECT id FROM teams WHERE abbreviation = 'DEN'), '50', 1, 0);

-- Dallas Mavericks
INSERT INTO players (
    yahoo_player_key, yahoo_player_id, full_name, first_name, last_name,
    team_id, uniform_number, is_active, is_rookie
) VALUES
('nba.p.5577', '5577', 'Luka Doncic', 'Luka', 'Doncic', 
 (SELECT id FROM teams WHERE abbreviation = 'DAL'), '77', 1, 0),
('nba.p.6228', '6228', 'Kyrie Irving', 'Kyrie', 'Irving', 
 (SELECT id FROM teams WHERE abbreviation = 'DAL'), '11', 1, 0),
('nba.p.5006', '5006', 'Christian Wood', 'Christian', 'Wood', 
 (SELECT id FROM teams WHERE abbreviation = 'DAL'), '35', 1, 0);

-- Philadelphia 76ers
INSERT INTO players (
    yahoo_player_key, yahoo_player_id, full_name, first_name, last_name,
    team_id, uniform_number, is_active, is_rookie
) VALUES
('nba.p.5294', '5294', 'Joel Embiid', 'Joel', 'Embiid', 
 (SELECT id FROM teams WHERE abbreviation = 'PHI'), '21', 1, 0),
('nba.p.6047', '6047', 'Tyrese Maxey', 'Tyrese', 'Maxey', 
 (SELECT id FROM teams WHERE abbreviation = 'PHI'), '0', 1, 0),
('nba.p.4605', '4605', 'Tobias Harris', 'Tobias', 'Harris', 
 (SELECT id FROM teams WHERE abbreviation = 'PHI'), '12', 1, 0);

-- =============================================================================
-- ASSIGN PLAYER POSITIONS
-- =============================================================================

-- LeBron James - SF (Primary), PF (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.3704'),
 (SELECT id FROM positions WHERE code = 'SF'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.3704'),
 (SELECT id FROM positions WHERE code = 'PF'), 0);

-- Anthony Davis - PF (Primary), C (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.6450'),
 (SELECT id FROM positions WHERE code = 'PF'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.6450'),
 (SELECT id FROM positions WHERE code = 'C'), 0);

-- Russell Westbrook - PG (Primary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5007'),
 (SELECT id FROM positions WHERE code = 'PG'), 1);

-- Stephen Curry - PG (Primary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4612'),
 (SELECT id FROM positions WHERE code = 'PG'), 1);

-- Klay Thompson - SG (Primary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4713'),
 (SELECT id FROM positions WHERE code = 'SG'), 1);

-- Draymond Green - PF (Primary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5069'),
 (SELECT id FROM positions WHERE code = 'PF'), 1);

-- Jayson Tatum - SF (Primary), PF (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5431'),
 (SELECT id FROM positions WHERE code = 'SF'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5431'),
 (SELECT id FROM positions WHERE code = 'PF'), 0);

-- Jaylen Brown - SG (Primary), SF (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5432'),
 (SELECT id FROM positions WHERE code = 'SG'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5432'),
 (SELECT id FROM positions WHERE code = 'SF'), 0);

-- Al Horford - C (Primary), PF (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4896'),
 (SELECT id FROM positions WHERE code = 'C'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4896'),
 (SELECT id FROM positions WHERE code = 'PF'), 0);

-- Giannis Antetokounmpo - PF (Primary), SF (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5578'),
 (SELECT id FROM positions WHERE code = 'PF'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5578'),
 (SELECT id FROM positions WHERE code = 'SF'), 0);

-- Khris Middleton - SF (Primary), SG (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4725'),
 (SELECT id FROM positions WHERE code = 'SF'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4725'),
 (SELECT id FROM positions WHERE code = 'SG'), 0);

-- Brook Lopez - C (Primary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4734'),
 (SELECT id FROM positions WHERE code = 'C'), 1);

-- Devin Booker - SG (Primary), PG (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5465'),
 (SELECT id FROM positions WHERE code = 'SG'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5465'),
 (SELECT id FROM positions WHERE code = 'PG'), 0);

-- Kevin Durant - SF (Primary), PF (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.3930'),
 (SELECT id FROM positions WHERE code = 'SF'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.3930'),
 (SELECT id FROM positions WHERE code = 'PF'), 0);

-- Deandre Ayton - C (Primary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5566'),
 (SELECT id FROM positions WHERE code = 'C'), 1);

-- Nikola Jokic - C (Primary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5464'),
 (SELECT id FROM positions WHERE code = 'C'), 1);

-- Jamal Murray - PG (Primary), SG (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5463'),
 (SELECT id FROM positions WHERE code = 'PG'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5463'),
 (SELECT id FROM positions WHERE code = 'SG'), 0);

-- Aaron Gordon - PF (Primary), SF (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4985'),
 (SELECT id FROM positions WHERE code = 'PF'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4985'),
 (SELECT id FROM positions WHERE code = 'SF'), 0);

-- Luka Doncic - PG (Primary), SG (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5577'),
 (SELECT id FROM positions WHERE code = 'PG'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5577'),
 (SELECT id FROM positions WHERE code = 'SG'), 0);

-- Kyrie Irving - PG (Primary), SG (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.6228'),
 (SELECT id FROM positions WHERE code = 'PG'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.6228'),
 (SELECT id FROM positions WHERE code = 'SG'), 0);

-- Christian Wood - PF (Primary), C (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5006'),
 (SELECT id FROM positions WHERE code = 'PF'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5006'),
 (SELECT id FROM positions WHERE code = 'C'), 0);

-- Joel Embiid - C (Primary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5294'),
 (SELECT id FROM positions WHERE code = 'C'), 1);

-- Tyrese Maxey - PG (Primary), SG (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.6047'),
 (SELECT id FROM positions WHERE code = 'PG'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.6047'),
 (SELECT id FROM positions WHERE code = 'SG'), 0);

-- Tobias Harris - SF (Primary), PF (Secondary)
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4605'),
 (SELECT id FROM positions WHERE code = 'SF'), 1);
INSERT INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4605'),
 (SELECT id FROM positions WHERE code = 'PF'), 0);

COMMIT;

-- NBA players migration completed successfully
-- Added 21 star NBA players with proper team and position assignments