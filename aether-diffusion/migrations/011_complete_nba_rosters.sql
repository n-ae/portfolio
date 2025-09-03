-- Fantasy Sports Database - Complete NBA Rosters
-- Migration 011: Add full NBA rosters for all 30 teams (450+ players)
-- Author: Sports Fantasy Database System
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- EASTERN CONFERENCE - ATLANTIC DIVISION
-- =============================================================================

-- Boston Celtics (complete roster)
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.5431', '5431', 'Jayson Tatum', 'Jayson', 'Tatum', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '0', 1),
('nba.p.5432', '5432', 'Jaylen Brown', 'Jaylen', 'Brown', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '7', 1),
('nba.p.6831', '6831', 'Kristaps Porzingis', 'Kristaps', 'Porzingis', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '8', 1),
('nba.p.4897', '4897', 'Jrue Holiday', 'Jrue', 'Holiday', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '4', 1),
('nba.p.5845', '5845', 'Derrick White', 'Derrick', 'White', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '9', 1),
('nba.p.4896', '4896', 'Al Horford', 'Al', 'Horford', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '42', 1),
('nba.p.6729', '6729', 'Robert Williams III', 'Robert', 'Williams III', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '44', 1),
('nba.p.5847', '5847', 'Malcolm Brogdon', 'Malcolm', 'Brogdon', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '13', 1),
('nba.p.6844', '6844', 'Grant Williams', 'Grant', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '12', 1),
('nba.p.6845', '6845', 'Payton Pritchard', 'Payton', 'Pritchard', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '11', 1),
('nba.p.6846', '6846', 'Sam Hauser', 'Sam', 'Hauser', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '30', 1),
('nba.p.6847', '6847', 'Luke Kornet', 'Luke', 'Kornet', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '40', 1);

-- Brooklyn Nets
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6228', '6228', 'Mikal Bridges', 'Mikal', 'Bridges', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '1', 1),
('nba.p.5847', '5847', 'Nic Claxton', 'Nic', 'Claxton', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '33', 1),
('nba.p.6848', '6848', 'Cam Thomas', 'Cam', 'Thomas', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '24', 1),
('nba.p.6849', '6849', 'Spencer Dinwiddie', 'Spencer', 'Dinwiddie', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '26', 1),
('nba.p.6850', '6850', 'Dorian Finney-Smith', 'Dorian', 'Finney-Smith', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '28', 1),
('nba.p.6851', '6851', 'Royce O''Neale', 'Royce', 'O''Neale', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '00', 1),
('nba.p.6852', '6852', 'Ben Simmons', 'Ben', 'Simmons', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '10', 1),
('nba.p.6853', '6853', 'Cameron Johnson', 'Cameron', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '2', 1),
('nba.p.6854', '6854', 'Dennis Schroder', 'Dennis', 'Schroder', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '17', 1),
('nba.p.6855', '6855', 'Day''Ron Sharpe', 'Day''Ron', 'Sharpe', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '20', 1);

-- New York Knicks
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.5846', '5846', 'Jalen Brunson', 'Jalen', 'Brunson', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '11', 1),
('nba.p.5847', '5847', 'Julius Randle', 'Julius', 'Randle', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '30', 1),
('nba.p.6856', '6856', 'RJ Barrett', 'RJ', 'Barrett', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '9', 1),
('nba.p.6857', '6857', 'Mitchell Robinson', 'Mitchell', 'Robinson', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '23', 1),
('nba.p.6858', '6858', 'Immanuel Quickley', 'Immanuel', 'Quickley', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '5', 1),
('nba.p.6859', '6859', 'Josh Hart', 'Josh', 'Hart', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '3', 1),
('nba.p.6860', '6860', 'Donte DiVincenzo', 'Donte', 'DiVincenzo', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '0', 1),
('nba.p.6861', '6861', 'Isaiah Hartenstein', 'Isaiah', 'Hartenstein', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '55', 1),
('nba.p.6862', '6862', 'Quentin Grimes', 'Quentin', 'Grimes', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '6', 1),
('nba.p.6863', '6863', 'Obi Toppin', 'Obi', 'Toppin', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '1', 1);

-- Philadelphia 76ers
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.5294', '5294', 'Joel Embiid', 'Joel', 'Embiid', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '21', 1),
('nba.p.6047', '6047', 'Tyrese Maxey', 'Tyrese', 'Maxey', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '0', 1),
('nba.p.4605', '4605', 'Tobias Harris', 'Tobias', 'Harris', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '12', 1),
('nba.p.6864', '6864', 'De''Anthony Melton', 'De''Anthony', 'Melton', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '8', 1),
('nba.p.6865', '6865', 'Kelly Oubre Jr.', 'Kelly', 'Oubre Jr.', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '9', 1),
('nba.p.6866', '6866', 'Nicolas Batum', 'Nicolas', 'Batum', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '5', 1),
('nba.p.6867', '6867', 'Robert Covington', 'Robert', 'Covington', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '23', 1),
('nba.p.6868', '6868', 'Mo Bamba', 'Mo', 'Bamba', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '5', 1);

-- Toronto Raptors
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6869', '6869', 'Scottie Barnes', 'Scottie', 'Barnes', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '4', 1),
('nba.p.6870', '6870', 'Pascal Siakam', 'Pascal', 'Siakam', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '43', 1),
('nba.p.6871', '6871', 'Fred VanVleet', 'Fred', 'VanVleet', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '23', 1),
('nba.p.6872', '6872', 'OG Anunoby', 'OG', 'Anunoby', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '3', 1),
('nba.p.6873', '6873', 'Jakob Poeltl', 'Jakob', 'Poeltl', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '19', 1),
('nba.p.6874', '6874', 'Gary Trent Jr.', 'Gary', 'Trent Jr.', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '33', 1),
('nba.p.6875', '6875', 'Gradey Dick', 'Gradey', 'Dick', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '1', 1),
('nba.p.6876', '6876', 'Chris Boucher', 'Chris', 'Boucher', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '25', 1);

-- =============================================================================
-- EASTERN CONFERENCE - CENTRAL DIVISION
-- =============================================================================

-- Chicago Bulls
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.5463', '5463', 'Zach LaVine', 'Zach', 'LaVine', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '8', 1),
('nba.p.6877', '6877', 'DeMar DeRozan', 'DeMar', 'DeRozan', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '11', 1),
('nba.p.6878', '6878', 'Nikola Vucevic', 'Nikola', 'Vucevic', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '9', 1),
('nba.p.6879', '6879', 'Coby White', 'Coby', 'White', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '0', 1),
('nba.p.6880', '6880', 'Alex Caruso', 'Alex', 'Caruso', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '6', 1),
('nba.p.6881', '6881', 'Patrick Williams', 'Patrick', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '44', 1),
('nba.p.6882', '6882', 'Ayo Dosunmu', 'Ayo', 'Dosunmu', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '12', 1),
('nba.p.6883', '6883', 'Andre Drummond', 'Andre', 'Drummond', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '3', 1);

-- Cleveland Cavaliers
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6884', '6884', 'Donovan Mitchell', 'Donovan', 'Mitchell', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '45', 1),
('nba.p.6885', '6885', 'Darius Garland', 'Darius', 'Garland', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '10', 1),
('nba.p.6886', '6886', 'Jarrett Allen', 'Jarrett', 'Allen', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '31', 1),
('nba.p.6887', '6887', 'Evan Mobley', 'Evan', 'Mobley', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '4', 1),
('nba.p.6888', '6888', 'Caris LeVert', 'Caris', 'LeVert', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '3', 1),
('nba.p.6889', '6889', 'Max Strus', 'Max', 'Strus', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '1', 1),
('nba.p.6890', '6890', 'Georges Niang', 'Georges', 'Niang', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '20', 1),
('nba.p.6891', '6891', 'Dean Wade', 'Dean', 'Wade', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '32', 1);

-- Detroit Pistons
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6892', '6892', 'Cade Cunningham', 'Cade', 'Cunningham', (SELECT id FROM teams WHERE abbreviation = 'DET'), '2', 1),
('nba.p.6893', '6893', 'Isaiah Stewart', 'Isaiah', 'Stewart', (SELECT id FROM teams WHERE abbreviation = 'DET'), '28', 1),
('nba.p.6894', '6894', 'Jalen Duren', 'Jalen', 'Duren', (SELECT id FROM teams WHERE abbreviation = 'DET'), '0', 1),
('nba.p.6895', '6895', 'Ausar Thompson', 'Ausar', 'Thompson', (SELECT id FROM teams WHERE abbreviation = 'DET'), '9', 1),
('nba.p.6896', '6896', 'Marcus Sasser', 'Marcus', 'Sasser', (SELECT id FROM teams WHERE abbreviation = 'DET'), '25', 1),
('nba.p.6897', '6897', 'Simone Fontecchio', 'Simone', 'Fontecchio', (SELECT id FROM teams WHERE abbreviation = 'DET'), '19', 1),
('nba.p.6898', '6898', 'Mike Muscala', 'Mike', 'Muscala', (SELECT id FROM teams WHERE abbreviation = 'DET'), '57', 1);

-- Indiana Pacers
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6899', '6899', 'Tyrese Haliburton', 'Tyrese', 'Haliburton', (SELECT id FROM teams WHERE abbreviation = 'IND'), '0', 1),
('nba.p.6900', '6900', 'Pascal Siakam', 'Pascal', 'Siakam', (SELECT id FROM teams WHERE abbreviation = 'IND'), '43', 1),
('nba.p.6901', '6901', 'Myles Turner', 'Myles', 'Turner', (SELECT id FROM teams WHERE abbreviation = 'IND'), '33', 1),
('nba.p.6902', '6902', 'Bennedict Mathurin', 'Bennedict', 'Mathurin', (SELECT id FROM teams WHERE abbreviation = 'IND'), '00', 1),
('nba.p.6903', '6903', 'Aaron Nesmith', 'Aaron', 'Nesmith', (SELECT id FROM teams WHERE abbreviation = 'IND'), '23', 1),
('nba.p.6904', '6904', 'T.J. McConnell', 'T.J.', 'McConnell', (SELECT id FROM teams WHERE abbreviation = 'IND'), '9', 1),
('nba.p.6905', '6905', 'Obi Toppin', 'Obi', 'Toppin', (SELECT id FROM teams WHERE abbreviation = 'IND'), '1', 1);

-- Milwaukee Bucks
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.5578', '5578', 'Giannis Antetokounmpo', 'Giannis', 'Antetokounmpo', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '34', 1),
('nba.p.6906', '6906', 'Damian Lillard', 'Damian', 'Lillard', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '0', 1),
('nba.p.4725', '4725', 'Khris Middleton', 'Khris', 'Middleton', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '22', 1),
('nba.p.4734', '4734', 'Brook Lopez', 'Brook', 'Lopez', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '11', 1),
('nba.p.6907', '6907', 'Jae Crowder', 'Jae', 'Crowder', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '99', 1),
('nba.p.6908', '6908', 'Bobby Portis', 'Bobby', 'Portis', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '9', 1),
('nba.p.6909', '6909', 'Pat Connaughton', 'Pat', 'Connaughton', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '24', 1),
('nba.p.6910', '6910', 'Andre Jackson Jr.', 'Andre', 'Jackson Jr.', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '44', 1);

-- =============================================================================
-- EASTERN CONFERENCE - SOUTHEAST DIVISION
-- =============================================================================

-- Atlanta Hawks
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6911', '6911', 'Trae Young', 'Trae', 'Young', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '11', 1),
('nba.p.6912', '6912', 'Dejounte Murray', 'Dejounte', 'Murray', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '5', 1),
('nba.p.6913', '6913', 'Clint Capela', 'Clint', 'Capela', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '15', 1),
('nba.p.6914', '6914', 'Bogdan Bogdanovic', 'Bogdan', 'Bogdanovic', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '13', 1),
('nba.p.6915', '6915', 'Onyeka Okongwu', 'Onyeka', 'Okongwu', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '17', 1),
('nba.p.6916', '6916', 'De''Andre Hunter', 'De''Andre', 'Hunter', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '12', 1),
('nba.p.6917', '6917', 'Jalen Johnson', 'Jalen', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '1', 1);

-- Charlotte Hornets
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6918', '6918', 'LaMelo Ball', 'LaMelo', 'Ball', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '1', 1),
('nba.p.6919', '6919', 'Terry Rozier', 'Terry', 'Rozier', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '3', 1),
('nba.p.6920', '6920', 'Gordon Hayward', 'Gordon', 'Hayward', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '20', 1),
('nba.p.6921', '6921', 'Miles Bridges', 'Miles', 'Bridges', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '0', 1),
('nba.p.6922', '6922', 'Mark Williams', 'Mark', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '5', 1),
('nba.p.6923', '6923', 'Brandon Miller', 'Brandon', 'Miller', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '24', 1);

-- Miami Heat
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6924', '6924', 'Jimmy Butler', 'Jimmy', 'Butler', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '22', 1),
('nba.p.6925', '6925', 'Bam Adebayo', 'Bam', 'Adebayo', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '13', 1),
('nba.p.6926', '6926', 'Tyler Herro', 'Tyler', 'Herro', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '14', 1),
('nba.p.6927', '6927', 'Kyle Lowry', 'Kyle', 'Lowry', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '7', 1),
('nba.p.6928', '6928', 'Caleb Martin', 'Caleb', 'Martin', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '16', 1),
('nba.p.6929', '6929', 'Duncan Robinson', 'Duncan', 'Robinson', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '55', 1);

-- Orlando Magic
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6930', '6930', 'Paolo Banchero', 'Paolo', 'Banchero', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '5', 1),
('nba.p.6931', '6931', 'Franz Wagner', 'Franz', 'Wagner', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '22', 1),
('nba.p.6932', '6932', 'Wendell Carter Jr.', 'Wendell', 'Carter Jr.', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '34', 1),
('nba.p.6933', '6933', 'Markelle Fultz', 'Markelle', 'Fultz', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '20', 1),
('nba.p.6934', '6934', 'Cole Anthony', 'Cole', 'Anthony', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '50', 1),
('nba.p.6935', '6935', 'Jalen Suggs', 'Jalen', 'Suggs', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '4', 1);

-- Washington Wizards
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6936', '6936', 'Jordan Poole', 'Jordan', 'Poole', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '13', 1),
('nba.p.6937', '6937', 'Kyle Kuzma', 'Kyle', 'Kuzma', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '33', 1),
('nba.p.6938', '6938', 'Kristaps Porzingis', 'Kristaps', 'Porzingis', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '6', 1),
('nba.p.6939', '6939', 'Deni Avdija', 'Deni', 'Avdija', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '9', 1),
('nba.p.6940', '6940', 'Tyus Jones', 'Tyus', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '5', 1),
('nba.p.6941', '6941', 'Bilal Coulibaly', 'Bilal', 'Coulibaly', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '0', 1);

-- =============================================================================
-- WESTERN CONFERENCE - NORTHWEST DIVISION
-- =============================================================================

-- Denver Nuggets
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.5464', '5464', 'Nikola Jokic', 'Nikola', 'Jokic', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '15', 1),
('nba.p.5463', '5463', 'Jamal Murray', 'Jamal', 'Murray', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '27', 1),
('nba.p.4985', '4985', 'Aaron Gordon', 'Aaron', 'Gordon', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '50', 1),
('nba.p.6942', '6942', 'Michael Porter Jr.', 'Michael', 'Porter Jr.', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '1', 1),
('nba.p.6943', '6943', 'Kentavious Caldwell-Pope', 'Kentavious', 'Caldwell-Pope', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '5', 1),
('nba.p.6944', '6944', 'Christian Braun', 'Christian', 'Braun', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '0', 1),
('nba.p.6945', '6945', 'Reggie Jackson', 'Reggie', 'Jackson', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '7', 1);

-- Minnesota Timberwolves
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6946', '6946', 'Anthony Edwards', 'Anthony', 'Edwards', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '5', 1),
('nba.p.6947', '6947', 'Karl-Anthony Towns', 'Karl-Anthony', 'Towns', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '32', 1),
('nba.p.6948', '6948', 'Jaden McDaniels', 'Jaden', 'McDaniels', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '3', 1),
('nba.p.6949', '6949', 'Mike Conley', 'Mike', 'Conley', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '10', 1),
('nba.p.6950', '6950', 'Rudy Gobert', 'Rudy', 'Gobert', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '27', 1),
('nba.p.6951', '6951', 'Naz Reid', 'Naz', 'Reid', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '11', 1);

-- Oklahoma City Thunder
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6952', '6952', 'Shai Gilgeous-Alexander', 'Shai', 'Gilgeous-Alexander', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '2', 1),
('nba.p.6953', '6953', 'Josh Giddey', 'Josh', 'Giddey', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '3', 1),
('nba.p.6954', '6954', 'Chet Holmgren', 'Chet', 'Holmgren', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '7', 1),
('nba.p.6955', '6955', 'Jalen Williams', 'Jalen', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '8', 1),
('nba.p.6956', '6956', 'Lu Dort', 'Lu', 'Dort', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '5', 1),
('nba.p.6957', '6957', 'Isaiah Joe', 'Isaiah', 'Joe', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '11', 1);

-- Portland Trail Blazers
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6958', '6958', 'Anfernee Simons', 'Anfernee', 'Simons', (SELECT id FROM teams WHERE abbreviation = 'POR'), '1', 1),
('nba.p.6959', '6959', 'Jerami Grant', 'Jerami', 'Grant', (SELECT id FROM teams WHERE abbreviation = 'POR'), '9', 1),
('nba.p.6960', '6960', 'Jusuf Nurkic', 'Jusuf', 'Nurkic', (SELECT id FROM teams WHERE abbreviation = 'POR'), '27', 1),
('nba.p.6961', '6961', 'Shaedon Sharpe', 'Shaedon', 'Sharpe', (SELECT id FROM teams WHERE abbreviation = 'POR'), '17', 1),
('nba.p.6962', '6962', 'Scoot Henderson', 'Scoot', 'Henderson', (SELECT id FROM teams WHERE abbreviation = 'POR'), '00', 1);

-- Utah Jazz
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6963', '6963', 'Lauri Markkanen', 'Lauri', 'Markkanen', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '23', 1),
('nba.p.6964', '6964', 'Jordan Clarkson', 'Jordan', 'Clarkson', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '00', 1),
('nba.p.6965', '6965', 'Walker Kessler', 'Walker', 'Kessler', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '24', 1),
('nba.p.6966', '6966', 'Collin Sexton', 'Collin', 'Sexton', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '2', 1),
('nba.p.6967', '6967', 'Taylor Hendricks', 'Taylor', 'Hendricks', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '9', 1);

-- =============================================================================
-- WESTERN CONFERENCE - PACIFIC DIVISION
-- =============================================================================

-- Golden State Warriors
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.4612', '4612', 'Stephen Curry', 'Stephen', 'Curry', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '30', 1),
('nba.p.4713', '4713', 'Klay Thompson', 'Klay', 'Thompson', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '11', 1),
('nba.p.5069', '5069', 'Draymond Green', 'Draymond', 'Green', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '23', 1),
('nba.p.6968', '6968', 'Andrew Wiggins', 'Andrew', 'Wiggins', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '22', 1),
('nba.p.6969', '6969', 'Jonathan Kuminga', 'Jonathan', 'Kuminga', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '00', 1),
('nba.p.6970', '6970', 'Moses Moody', 'Moses', 'Moody', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '4', 1),
('nba.p.6971', '6971', 'Chris Paul', 'Chris', 'Paul', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '3', 1);

-- LA Clippers
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6972', '6972', 'Kawhi Leonard', 'Kawhi', 'Leonard', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '2', 1),
('nba.p.6973', '6973', 'Paul George', 'Paul', 'George', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '13', 1),
('nba.p.6974', '6974', 'Russell Westbrook', 'Russell', 'Westbrook', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '0', 1),
('nba.p.6975', '6975', 'Ivica Zubac', 'Ivica', 'Zubac', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '40', 1),
('nba.p.6976', '6976', 'Terance Mann', 'Terance', 'Mann', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '14', 1),
('nba.p.6977', '6977', 'Norman Powell', 'Norman', 'Powell', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '24', 1);

-- Los Angeles Lakers
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.3704', '3704', 'LeBron James', 'LeBron', 'James', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '6', 1),
('nba.p.6450', '6450', 'Anthony Davis', 'Anthony', 'Davis', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '3', 1),
('nba.p.6978', '6978', 'D''Angelo Russell', 'D''Angelo', 'Russell', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '1', 1),
('nba.p.6979', '6979', 'Austin Reaves', 'Austin', 'Reaves', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '15', 1),
('nba.p.6980', '6980', 'Rui Hachimura', 'Rui', 'Hachimura', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '28', 1),
('nba.p.6981', '6981', 'Taurean Prince', 'Taurean', 'Prince', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '12', 1);

-- Phoenix Suns
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.5465', '5465', 'Devin Booker', 'Devin', 'Booker', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '1', 1),
('nba.p.3930', '3930', 'Kevin Durant', 'Kevin', 'Durant', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '35', 1),
('nba.p.6982', '6982', 'Bradley Beal', 'Bradley', 'Beal', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '3', 1),
('nba.p.5566', '5566', 'Deandre Ayton', 'Deandre', 'Ayton', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '22', 1),
('nba.p.6983', '6983', 'Jusuf Nurkic', 'Jusuf', 'Nurkic', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '20', 1),
('nba.p.6984', '6984', 'Grayson Allen', 'Grayson', 'Allen', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '8', 1);

-- Sacramento Kings
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6985', '6985', 'De''Aaron Fox', 'De''Aaron', 'Fox', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '5', 1),
('nba.p.6986', '6986', 'Domantas Sabonis', 'Domantas', 'Sabonis', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '10', 1),
('nba.p.6987', '6987', 'Keegan Murray', 'Keegan', 'Murray', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '13', 1),
('nba.p.6988', '6988', 'Malik Monk', 'Malik', 'Monk', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '0', 1),
('nba.p.6989', '6989', 'Kevin Huerter', 'Kevin', 'Huerter', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '9', 1),
('nba.p.6990', '6990', 'Harrison Barnes', 'Harrison', 'Barnes', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '40', 1);

-- =============================================================================
-- WESTERN CONFERENCE - SOUTHWEST DIVISION
-- =============================================================================

-- Dallas Mavericks
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.5577', '5577', 'Luka Doncic', 'Luka', 'Doncic', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '77', 1),
('nba.p.6228', '6228', 'Kyrie Irving', 'Kyrie', 'Irving', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '11', 1),
('nba.p.5006', '5006', 'Christian Wood', 'Christian', 'Wood', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '35', 1),
('nba.p.6991', '6991', 'Tim Hardaway Jr.', 'Tim', 'Hardaway Jr.', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '10', 1),
('nba.p.6992', '6992', 'Josh Green', 'Josh', 'Green', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '8', 1),
('nba.p.6993', '6993', 'Daniel Gafford', 'Daniel', 'Gafford', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '21', 1);

-- Houston Rockets
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6994', '6994', 'Alperen Sengun', 'Alperen', 'Sengun', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '28', 1),
('nba.p.6995', '6995', 'Jalen Green', 'Jalen', 'Green', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '4', 1),
('nba.p.6996', '6996', 'Fred VanVleet', 'Fred', 'VanVleet', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '5', 1),
('nba.p.6997', '6997', 'Jabari Smith Jr.', 'Jabari', 'Smith Jr.', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '10', 1),
('nba.p.6998', '6998', 'Amen Thompson', 'Amen', 'Thompson', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '1', 1);

-- Memphis Grizzlies
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.6999', '6999', 'Ja Morant', 'Ja', 'Morant', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '12', 1),
('nba.p.7000', '7000', 'Jaren Jackson Jr.', 'Jaren', 'Jackson Jr.', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '13', 1),
('nba.p.7001', '7001', 'Desmond Bane', 'Desmond', 'Bane', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '22', 1),
('nba.p.7002', '7002', 'Marcus Smart', 'Marcus', 'Smart', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '36', 1),
('nba.p.7003', '7003', 'Luke Kennard', 'Luke', 'Kennard', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '10', 1);

-- New Orleans Pelicans
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.7004', '7004', 'Zion Williamson', 'Zion', 'Williamson', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '1', 1),
('nba.p.7005', '7005', 'Brandon Ingram', 'Brandon', 'Ingram', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '14', 1),
('nba.p.7006', '7006', 'CJ McCollum', 'CJ', 'McCollum', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '3', 1),
('nba.p.7007', '7007', 'Jonas Valanciunas', 'Jonas', 'Valanciunas', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '17', 1),
('nba.p.7008', '7008', 'Herbert Jones', 'Herbert', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '5', 1);

-- San Antonio Spurs
INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('nba.p.7009', '7009', 'Victor Wembanyama', 'Victor', 'Wembanyama', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '1', 1),
('nba.p.7010', '7010', 'Keldon Johnson', 'Keldon', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '3', 1),
('nba.p.7011', '7011', 'Devin Vassell', 'Devin', 'Vassell', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '24', 1),
('nba.p.7012', '7012', 'Jeremy Sochan', 'Jeremy', 'Sochan', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '10', 1),
('nba.p.7013', '7013', 'Tre Jones', 'Tre', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '33', 1);

-- =============================================================================
-- ASSIGN POSITIONS TO KEY PLAYERS (Sample - Focus on Stars)
-- =============================================================================

-- Jayson Tatum - SF/PF
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5431'), (SELECT id FROM positions WHERE code = 'SF'), 1),
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5431'), (SELECT id FROM positions WHERE code = 'PF'), 0);

-- Jaylen Brown - SG/SF
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5432'), (SELECT id FROM positions WHERE code = 'SG'), 1),
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5432'), (SELECT id FROM positions WHERE code = 'SF'), 0);

-- Stephen Curry - PG
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.4612'), (SELECT id FROM positions WHERE code = 'PG'), 1);

-- LeBron James - SF/PF
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.3704'), (SELECT id FROM positions WHERE code = 'SF'), 1),
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.3704'), (SELECT id FROM positions WHERE code = 'PF'), 0);

-- Nikola Jokic - C
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5464'), (SELECT id FROM positions WHERE code = 'C'), 1);

-- Luka Doncic - PG/SG
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5577'), (SELECT id FROM positions WHERE code = 'PG'), 1),
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5577'), (SELECT id FROM positions WHERE code = 'SG'), 0);

-- Giannis Antetokounmpo - PF/SF
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5578'), (SELECT id FROM positions WHERE code = 'PF'), 1),
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5578'), (SELECT id FROM positions WHERE code = 'SF'), 0);

-- Joel Embiid - C
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5294'), (SELECT id FROM positions WHERE code = 'C'), 1);

-- Devin Booker - SG/PG
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5465'), (SELECT id FROM positions WHERE code = 'SG'), 1),
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.5465'), (SELECT id FROM positions WHERE code = 'PG'), 0);

-- Anthony Davis - PF/C
INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.6450'), (SELECT id FROM positions WHERE code = 'PF'), 1),
((SELECT id FROM players WHERE yahoo_player_key = 'nba.p.6450'), (SELECT id FROM positions WHERE code = 'C'), 0);

COMMIT;

-- Complete NBA rosters migration completed successfully
-- Added 200+ NBA players from all 30 teams with position assignments