-- Migration 012: Complete NBA All Players (600+ from Yahoo API)
-- Generated: 2025-08-31 15:41:26
-- Total Players: 625

DELETE FROM player_positions;
DELETE FROM players;

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5352', '5352', 'Nikola Jokić', 'Nikola', 'Jokić', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5352'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10094', '10094', 'Victor Wembanyama', 'Victor', 'Wembanyama', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10094'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6014', '6014', 'Luka Dončić', 'Luka', 'Dončić', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '77', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6014'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6014'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6355', '6355', 'Anthony Edwards', 'Anthony', 'Edwards', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6355'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6355'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6016', '6016', 'Trae Young', 'Trae', 'Young', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6016'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6702', '6702', 'Jalen Williams', 'Jalen', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6702'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6702'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6395', '6395', 'LaMelo Ball', 'LaMelo', 'Ball', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6395'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6395'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5185', '5185', 'Giannis Antetokounmpo', 'Giannis', 'Antetokounmpo', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '34', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5185'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5185'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5432', '5432', 'Karl-Anthony Towns', 'Karl-Anthony', 'Towns', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '32', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5432'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5432'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5473', '5473', 'Devin Booker', 'Devin', 'Booker', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5473'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5473'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4563', '4563', 'James Harden', 'James', 'Harden', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4563'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4563'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6044', '6044', 'Jalen Brunson', 'Jalen', 'Brunson', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6044'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5602', '5602', 'Jaylen Brown', 'Jaylen', 'Brown', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5602'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5602'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6558', '6558', 'Alperen Sengun', 'Alperen', 'Sengun', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '28', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6558'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6022', '6022', 'Shai Gilgeous-Alexander', 'Shai', 'Gilgeous-Alexander', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6022'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6512', '6512', 'Cade Cunningham', 'Cade', 'Cunningham', (SELECT id FROM teams WHERE abbreviation = 'DET'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6512'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6512'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5007', '5007', 'Anthony Davis', 'Anthony', 'Davis', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5007'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5007'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.3704', '3704', 'LeBron James', 'LeBron', 'James', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.3704'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.3704'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6515', '6515', 'Scottie Barnes', 'Scottie', 'Barnes', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6515'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6515'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6515'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5642', '5642', 'Domantas Sabonis', 'Domantas', 'Sabonis', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5642'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6413', '6413', 'Tyrese Maxey', 'Tyrese', 'Maxey', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6413'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6562', '6562', 'Jalen Johnson', 'Jalen', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6562'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6562'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5767', '5767', 'De''Aaron Fox', 'De''Aaron', 'Fox', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5767'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5767'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6514', '6514', 'Evan Mobley', 'Evan', 'Mobley', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6514'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6514'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6691', '6691', 'Paolo Banchero', 'Paolo', 'Banchero', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6691'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6691'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6548', '6548', 'Josh Giddey', 'Josh', 'Giddey', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6548'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6548'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6163', '6163', 'Zion Williamson', 'Zion', 'Williamson', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6163'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6163'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4244', '4244', 'Kevin Durant', 'Kevin', 'Durant', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4244'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4244'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6164', '6164', 'Ja Morant', 'Ja', 'Morant', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6164'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5294', '5294', 'Joel Embiid', 'Joel', 'Embiid', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5294'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5843', '5843', 'Josh Hart', 'Josh', 'Hart', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5843'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5843'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5843'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6698', '6698', 'Dyson Daniels', 'Dyson', 'Daniels', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6698'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6698'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6698'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4612', '4612', 'Stephen Curry', 'Stephen', 'Curry', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4612'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5658', '5658', 'Pascal Siakam', 'Pascal', 'Siakam', (SELECT id FROM teams WHERE abbreviation = 'IND'), '43', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5658'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5658'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5827', '5827', 'Bam Adebayo', 'Bam', 'Adebayo', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5827'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5827'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5638', '5638', 'Jamal Murray', 'Jamal', 'Murray', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '27', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5638'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5638'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5769', '5769', 'Lauri Markkanen', 'Lauri', 'Markkanen', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5769'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5769'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6175', '6175', 'Tyler Herro', 'Tyler', 'Herro', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6175'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6175'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5826', '5826', 'Donovan Mitchell', 'Donovan', 'Mitchell', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '45', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5826'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5826'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5663', '5663', 'Ivica Zubac', 'Ivica', 'Zubac', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '40', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5663'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6692', '6692', 'Chet Holmgren', 'Chet', 'Holmgren', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6692'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6692'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6550', '6550', 'Franz Wagner', 'Franz', 'Wagner', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6550'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6550'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6559', '6559', 'Trey Murphy III', 'Trey', 'Murphy III', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6559'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6559'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4896', '4896', 'Kawhi Leonard', 'Kawhi', 'Leonard', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4896'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4896'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10108', '10108', 'Amen Thompson', 'Amen', 'Thompson', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10108'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10108'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10108'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6422', '6422', 'Desmond Bane', 'Desmond', 'Bane', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6422'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6422'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5842', '5842', 'Derrick White', 'Derrick', 'White', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5842'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5842'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6015', '6015', 'Jaren Jackson Jr.', 'Jaren', 'Jackson Jr.', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6015'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6015'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5464', '5464', 'Kristaps Porziņģis', 'Kristaps', 'Porziņģis', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5464'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5464'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10468', '10468', 'Cooper Flagg', 'Cooper', 'Flagg', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '32', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10468'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6401', '6401', 'Deni Avdija', 'Deni', 'Avdija', (SELECT id FROM teams WHERE abbreviation = 'POR'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6401'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6401'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5324', '5324', 'Zach LaVine', 'Zach', 'LaVine', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5324'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5324'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10104', '10104', 'Brandon Miller', 'Brandon', 'Miller', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10104'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10104'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6025', '6025', 'Michael Porter Jr.', 'Michael', 'Porter Jr.', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6025'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6025'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6712', '6712', 'Walker Kessler', 'Walker', 'Kessler', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6712'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5835', '5835', 'Jarrett Allen', 'Jarrett', 'Allen', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '31', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5835'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6167', '6167', 'Darius Garland', 'Darius', 'Garland', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6167'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4897', '4897', 'Nikola Vučević', 'Nikola', 'Vučević', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4897'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6606', '6606', 'Austin Reaves', 'Austin', 'Reaves', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6606'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6606'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5318', '5318', 'Julius Randle', 'Julius', 'Randle', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5318'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5318'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6169', '6169', 'Coby White', 'Coby', 'White', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6169'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6169'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6216', '6216', 'Jordan Poole', 'Jordan', 'Poole', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6216'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6216'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6721', '6721', 'Andrew Nembhard', 'Andrew', 'Nembhard', (SELECT id FROM teams WHERE abbreviation = 'IND'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6721'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6721'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6513', '6513', 'Jalen Green', 'Jalen', 'Green', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6513'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6513'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4725', '4725', 'Paul George', 'Paul', 'George', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4725'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4725'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4725'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4912', '4912', 'Jimmy Butler III', 'Jimmy', 'Butler III', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4912'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4912'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6023', '6023', 'Miles Bridges', 'Miles', 'Bridges', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6023'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6023'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4614', '4614', 'DeMar DeRozan', 'DeMar', 'DeRozan', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4614'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5958', '5958', 'Deandre Ayton', 'Deandre', 'Ayton', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5958'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6165', '6165', 'RJ Barrett', 'RJ', 'Barrett', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6165'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6165'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5471', '5471', 'Myles Turner', 'Myles', 'Turner', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5471'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10294', '10294', 'Alex Sarr', 'Alex', 'Sarr', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10294'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6703', '6703', 'Jalen Duren', 'Jalen', 'Duren', (SELECT id FROM teams WHERE abbreviation = 'DET'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6703'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6569', '6569', 'Cam Thomas', 'Cam', 'Thomas', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6569'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6569'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5836', '5836', 'OG Anunoby', 'OG', 'Anunoby', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5836'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5836'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6516', '6516', 'Jalen Suggs', 'Jalen', 'Suggs', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6516'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6697', '6697', 'Shaedon Sharpe', 'Shaedon', 'Sharpe', (SELECT id FROM teams WHERE abbreviation = 'POR'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6697'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6697'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5161', '5161', 'CJ McCollum', 'CJ', 'McCollum', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5161'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5161'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6021', '6021', 'Mikal Bridges', 'Mikal', 'Bridges', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6021'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6021'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5197', '5197', 'Rudy Gobert', 'Rudy', 'Gobert', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '27', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5197'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6417', '6417', 'Immanuel Quickley', 'Immanuel', 'Quickley', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6417'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6417'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5292', '5292', 'Andrew Wiggins', 'Andrew', 'Wiggins', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5292'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5292'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5824', '5824', 'Malik Monk', 'Malik', 'Monk', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5824'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5009', '5009', 'Bradley Beal', 'Bradley', 'Beal', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5009'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5009'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6418', '6418', 'Payton Pritchard', 'Payton', 'Pritchard', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6418'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6398', '6398', 'Onyeka Okongwu', 'Onyeka', 'Okongwu', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6398'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5832', '5832', 'John Collins', 'John', 'Collins', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5832'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5832'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6035', '6035', 'Anfernee Simons', 'Anfernee', 'Simons', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6035'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6035'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5727', '5727', 'Fred VanVleet', 'Fred', 'VanVleet', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5727'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10274', '10274', 'Kel''el Ware', 'Kel''el', 'Ware', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10274'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10274'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6173', '6173', 'Cameron Johnson', 'Cameron', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6173'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6173'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5601', '5601', 'Brandon Ingram', 'Brandon', 'Ingram', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5601'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5601'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5601'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6403', '6403', 'Devin Vassell', 'Devin', 'Vassell', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6403'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6403'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6705', '6705', 'Mark Williams', 'Mark', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6705'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10100', '10100', 'Keyonte George', 'Keyonte', 'George', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10100'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10100'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10285', '10285', 'Donovan Clingan', 'Donovan', 'Clingan', (SELECT id FROM teams WHERE abbreviation = 'POR'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10285'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6696', '6696', 'Bennedict Mathurin', 'Bennedict', 'Mathurin', (SELECT id FROM teams WHERE abbreviation = 'IND'), '00', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6696'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6696'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5506', '5506', 'Norman Powell', 'Norman', 'Powell', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5506'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5506'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5856', '5856', 'Isaiah Hartenstein', 'Isaiah', 'Hartenstein', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '55', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5856'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5640', '5640', 'Jakob Poeltl', 'Jakob', 'Poeltl', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '19', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5640'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.3930', '3930', 'Chris Paul', 'Chris', 'Paul', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.3930'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6420', '6420', 'Jaden McDaniels', 'Jaden', 'McDaniels', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6420'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6420'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6711', '6711', 'Christian Braun', 'Christian', 'Braun', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6711'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6711'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10096', '10096', 'Ausar Thompson', 'Ausar', 'Thompson', (SELECT id FROM teams WHERE abbreviation = 'DET'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10096'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10096'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5295', '5295', 'Aaron Gordon', 'Aaron', 'Gordon', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '32', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5295'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5295'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5069', '5069', 'Draymond Green', 'Draymond', 'Green', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5069'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5069'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6219', '6219', 'Nic Claxton', 'Nic', 'Claxton', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '33', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6219'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10265', '10265', 'Matas Buzelis', 'Matas', 'Buzelis', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10265'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10265'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5482', '5482', 'Bobby Portis', 'Bobby', 'Portis', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5482'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5482'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4901', '4901', 'Tobias Harris', 'Tobias', 'Harris', (SELECT id FROM teams WHERE abbreviation = 'DET'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4901'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10065', '10065', 'Toumani Camara', 'Toumani', 'Camara', (SELECT id FROM teams WHERE abbreviation = 'POR'), '33', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10065'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10065'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10287', '10287', 'Zach Edey', 'Zach', 'Edey', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10287'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10290', '10290', 'Stephon Castle', 'Stephon', 'Castle', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10290'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10290'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6572', '6572', 'Santi Aldama', 'Santi', 'Aldama', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6572'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6572'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6699', '6699', 'Jeremy Sochan', 'Jeremy', 'Sochan', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6699'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6699'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6580', '6580', 'Ayo Dosunmu', 'Ayo', 'Dosunmu', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6580'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6580'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10115', '10115', 'Brandin Podziemski', 'Brandin', 'Podziemski', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10115'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10115'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6694', '6694', 'Keegan Murray', 'Keegan', 'Murray', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6694'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6694'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6695', '6695', 'Jaden Ivey', 'Jaden', 'Ivey', (SELECT id FROM teams WHERE abbreviation = 'DET'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6695'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6695'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6253', '6253', 'Naz Reid', 'Naz', 'Reid', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6253'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6253'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5433', '5433', 'D''Angelo Russell', 'D''Angelo', 'Russell', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5433'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10097', '10097', 'Dereck Lively II', 'Dereck', 'Lively II', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10097'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4622', '4622', 'Jrue Holiday', 'Jrue', 'Holiday', (SELECT id FROM teams WHERE abbreviation = 'POR'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4622'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4622'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6693', '6693', 'Jabari Smith Jr.', 'Jabari', 'Smith Jr.', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6693'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6693'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6707', '6707', 'Tari Eason', 'Tari', 'Eason', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6707'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6707'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6226', '6226', 'Daniel Gafford', 'Daniel', 'Gafford', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6226'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4892', '4892', 'Klay Thompson', 'Klay', 'Thompson', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '31', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4892'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4892'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4390', '4390', 'Russell Westbrook', 'Russell', 'Westbrook', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4390'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6171', '6171', 'Rui Hachimura', 'Rui', 'Hachimura', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '28', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6171'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6171'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10048', '10048', 'Scoot Henderson', 'Scoot', 'Henderson', (SELECT id FROM teams WHERE abbreviation = 'POR'), '00', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10048'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10288', '10288', 'Reed Sheppard', 'Reed', 'Sheppard', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10288'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10288'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5840', '5840', 'Kyle Kuzma', 'Kyle', 'Kuzma', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5840'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5840'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6549', '6549', 'Jonathan Kuminga', 'Jonathan', 'Kuminga', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '00', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6549'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6549'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6205', '6205', 'Nickeil Alexander-Walker', 'Nickeil', 'Alexander-Walker', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6205'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6205'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10467', '10467', 'Dylan Harper', 'Dylan', 'Harper', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10467'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6019', '6019', 'Collin Sexton', 'Collin', 'Sexton', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6019'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6019'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6577', '6577', 'Herbert Jones', 'Herbert', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6577'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6577'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5350', '5350', 'Jerami Grant', 'Jerami', 'Grant', (SELECT id FROM teams WHERE abbreviation = 'POR'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5350'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5350'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5651', '5651', 'Caris LeVert', 'Caris', 'LeVert', (SELECT id FROM teams WHERE abbreviation = 'DET'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5651'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5651'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10448', '10448', 'Tre Johnson', 'Tre', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10448'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10454', '10454', 'VJ Edgecombe', 'VJ', 'Edgecombe', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '77', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10454'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6028', '6028', 'Donte DiVincenzo', 'Donte', 'DiVincenzo', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6028'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6028'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6032', '6032', 'Grayson Allen', 'Grayson', 'Allen', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6032'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6032'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10462', '10462', 'Ace Bailey', 'Ace', 'Bailey', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '19', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10462'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6166', '6166', 'De''Andre Hunter', 'De''Andre', 'Hunter', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6166'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6166'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6174', '6174', 'P.J. Washington', 'P.J.', 'Washington', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6174'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6174'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10099', '10099', 'Bilal Coulibaly', 'Bilal', 'Coulibaly', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10099'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10099'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10296', '10296', 'Zaccharie Risacher', 'Zaccharie', 'Risacher', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10296'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10296'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4472', '4472', 'Brook Lopez', 'Brook', 'Lopez', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4472'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5336', '5336', 'Clint Capela', 'Clint', 'Capela', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5336'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5159', '5159', 'Kentavious Caldwell-Pope', 'Kentavious', 'Caldwell-Pope', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5159'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5159'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4246', '4246', 'Mike Conley', 'Mike', 'Conley', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4246'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5013', '5013', 'Harrison Barnes', 'Harrison', 'Barnes', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '40', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5013'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5013'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5636', '5636', 'Kris Dunn', 'Kris', 'Dunn', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5636'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5636'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6754', '6754', 'Julian Champagnie', 'Julian', 'Champagnie', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6754'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6754'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5475', '5475', 'Kelly Oubre Jr.', 'Kelly', 'Oubre Jr.', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5475'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5475'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4245', '4245', 'Al Horford', 'Al', 'Horford', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '42', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4245'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4245'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6753', '6753', 'Keon Ellis', 'Keon', 'Ellis', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6753'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6753'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6254', '6254', 'Luguentz Dort', 'Luguentz', 'Dort', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6254'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6254'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5905', '5905', 'Royce O''Neale', 'Royce', 'O''Neale', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '00', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5905'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5905'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6597', '6597', 'Aaron Wiggins', 'Aaron', 'Wiggins', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6597'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6597'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6048', '6048', 'Gary Trent Jr.', 'Gary', 'Trent Jr.', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6048'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6048'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5012', '5012', 'Damian Lillard', 'Damian', 'Lillard', (SELECT id FROM teams WHERE abbreviation = 'POR'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5012'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4840', '4840', 'Kyrie Irving', 'Kyrie', 'Irving', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4840'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5484', '5484', 'Tyus Jones', 'Tyus', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5484'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4886', '4886', 'Jonas Valančiūnas', 'Jonas', 'Valančiūnas', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4886'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10107', '10107', 'Cason Wallace', 'Cason', 'Wallace', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10107'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10107'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5637', '5637', 'Buddy Hield', 'Buddy', 'Hield', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5637'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5637'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5765', '5765', 'Jayson Tatum', 'Jayson', 'Tatum', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5765'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5765'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5650', '5650', 'Malik Beasley', 'Malik', 'Beasley', (SELECT id FROM teams WHERE abbreviation = 'DET'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5650'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5650'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6400', '6400', 'Obi Toppin', 'Obi', 'Toppin', (SELECT id FROM teams WHERE abbreviation = 'IND'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6400'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5858', '5858', 'Dillon Brooks', 'Dillon', 'Brooks', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5858'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5858'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5754', '5754', 'Alex Caruso', 'Alex', 'Caruso', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5754'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5754'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5643', '5643', 'Taurean Prince', 'Taurean', 'Prince', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5643'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6404', '6404', 'Tyrese Haliburton', 'Tyrese', 'Haliburton', (SELECT id FROM teams WHERE abbreviation = 'IND'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6404'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6404'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5582', '5582', 'T.J. McConnell', 'T.J.', 'McConnell', (SELECT id FROM teams WHERE abbreviation = 'IND'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5582'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6217', '6217', 'Keldon Johnson', 'Keldon', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6217'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6217'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6441', '6441', 'Isaiah Joe', 'Isaiah', 'Joe', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6441'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6704', '6704', 'Ochai Agbaji', 'Ochai', 'Agbaji', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6704'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6704'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6720', '6720', 'Peyton Watson', 'Peyton', 'Watson', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6720'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6720'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5338', '5338', 'Bogdan Bogdanović', 'Bogdan', 'Bogdanović', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5338'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5338'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6406', '6406', 'Aaron Nesmith', 'Aaron', 'Nesmith', (SELECT id FROM teams WHERE abbreviation = 'IND'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6406'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6567', '6567', 'Quentin Grimes', 'Quentin', 'Grimes', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6567'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6567'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5903', '5903', 'Luke Kornet', 'Luke', 'Kornet', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5903'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5747', '5747', 'Derrick Jones Jr.', 'Derrick', 'Jones Jr.', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5747'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5747'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6757', '6757', 'Scotty Pippen Jr.', 'Scotty', 'Pippen Jr.', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6757'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6757'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6212', '6212', 'Ty Jerome', 'Ty', 'Jerome', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6212'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6155', '6155', 'Haywood Highsmith', 'Haywood', 'Highsmith', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6155'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6155'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5194', '5194', 'Tim Hardaway Jr.', 'Tim', 'Hardaway Jr.', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5194'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5194'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6578', '6578', 'Miles McBride', 'Miles', 'McBride', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6578'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6578'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5187', '5187', 'Dennis Schröder', 'Dennis', 'Schröder', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5187'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5187'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6206', '6206', 'Goga Bitadze', 'Goga', 'Bitadze', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '35', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6206'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5349', '5349', 'Spencer Dinwiddie', 'Spencer', 'Dinwiddie', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '26', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5349'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5349'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6499', '6499', 'Naji Marshall', 'Naji', 'Marshall', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6499'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6499'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6619', '6619', 'Sam Hauser', 'Sam', 'Hauser', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6619'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6619'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6073', '6073', 'Duncan Robinson', 'Duncan', 'Robinson', (SELECT id FROM teams WHERE abbreviation = 'DET'), '55', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6073'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6073'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6030', '6030', 'Kevin Huerter', 'Kevin', 'Huerter', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6030'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6030'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6725', '6725', 'Max Christie', 'Max', 'Christie', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '00', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6725'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6725'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6408', '6408', 'Isaiah Stewart', 'Isaiah', 'Stewart', (SELECT id FROM teams WHERE abbreviation = 'DET'), '28', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6408'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6556', '6556', 'Moses Moody', 'Moses', 'Moody', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6556'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6556'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5647', '5647', 'Guerschon Yabusele', 'Guerschon', 'Yabusele', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '28', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5647'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5647'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6632', '6632', 'Justin Champagnie', 'Justin', 'Champagnie', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6632'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6632'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6402', '6402', 'Jalen Smith', 'Jalen', 'Smith', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6402'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5476', '5476', 'Terry Rozier', 'Terry', 'Rozier', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5476'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10095', '10095', 'Anthony Black', 'Anthony', 'Black', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10095'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10095'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10092', '10092', 'Jaime Jaquez Jr.', 'Jaime', 'Jaquez Jr.', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10092'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10092'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6552', '6552', 'Ziaire Williams', 'Ziaire', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6552'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6552'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6267', '6267', 'Max Strus', 'Max', 'Strus', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6267'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6267'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6434', '6434', 'Nick Richards', 'Nick', 'Richards', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6434'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10273', '10273', 'Bub Carrington', 'Bub', 'Carrington', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10273'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10273'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5660', '5660', 'Dejounte Murray', 'Dejounte', 'Murray', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5660'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5660'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6018', '6018', 'Wendell Carter Jr.', 'Wendell', 'Carter Jr.', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '34', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6018'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5681', '5681', 'Georges Niang', 'Georges', 'Niang', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '31', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5681'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5825', '5825', 'Luke Kennard', 'Luke', 'Kennard', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5825'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5825'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6452', '6452', 'Sam Merrill', 'Sam', 'Merrill', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6452'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6452'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10289', '10289', 'Yves Missi', 'Yves', 'Missi', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10289'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6433', '6433', 'Tre Jones', 'Tre', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6433'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6433'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5768', '5768', 'Jonathan Isaac', 'Jonathan', 'Isaac', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5768'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5768'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6613', '6613', 'Jose Alvarado', 'Jose', 'Alvarado', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6613'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6315', '6315', 'Amir Coffey', 'Amir', 'Coffey', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6315'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6315'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6407', '6407', 'Cole Anthony', 'Cole', 'Anthony', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '50', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6407'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6557', '6557', 'Corey Kispert', 'Corey', 'Kispert', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6557'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6557'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6551', '6551', 'Davion Mitchell', 'Davion', 'Mitchell', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '45', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6551'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5693', '5693', 'Dorian Finney-Smith', 'Dorian', 'Finney-Smith', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5693'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5693'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4487', '4487', 'Nicolas Batum', 'Nicolas', 'Batum', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '33', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4487'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4487'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10272', '10272', 'Kyshawn George', 'Kyshawn', 'George', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '18', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10272'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10272'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5327', '5327', 'Jusuf Nurkić', 'Jusuf', 'Nurkić', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5327'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10101', '10101', 'Gradey Dick', 'Gradey', 'Dick', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10101'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10101'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5855', '5855', 'Thomas Bryant', 'Thomas', 'Bryant', (SELECT id FROM teams WHERE abbreviation = 'IND'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5855'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6571', '6571', 'Day''Ron Sharpe', 'Day''Ron', 'Sharpe', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6571'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6755', '6755', 'AJ Green', 'AJ', 'Green', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6755'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6755'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5164', '5164', 'Kelly Olynyk', 'Kelly', 'Olynyk', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5164'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5164'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5073', '5073', 'Khris Middleton', 'Khris', 'Middleton', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5073'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5073'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6209', '6209', 'Brandon Clarke', 'Brandon', 'Clarke', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6209'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6209'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6236', '6236', 'Terance Mann', 'Terance', 'Mann', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6236'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6236'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6218', '6218', 'Kevin Porter Jr.', 'Kevin', 'Porter Jr.', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6218'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6218'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6076', '6076', 'Kenrich Williams', 'Kenrich', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '34', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6076'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5192', '5192', 'Mason Plumlee', 'Mason', 'Plumlee', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5192'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6563', '6563', 'Keon Johnson', 'Keon', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '45', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6563'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6563'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5474', '5474', 'Cameron Payne', 'Cameron', 'Payne', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5474'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5474'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5490', '5490', 'Kevon Looney', 'Kevon', 'Looney', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '55', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5490'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6412', '6412', 'Precious Achiuwa', 'Precious', 'Achiuwa', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6412'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6412'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5739', '5739', 'Gary Payton II', 'Gary', 'Payton II', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5739'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5472', '5472', 'Trey Lyles', 'Trey', 'Lyles', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '41', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5472'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5472'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5823', '5823', 'Zach Collins', 'Zach', 'Collins', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5823'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10122', '10122', 'Brice Sensabaugh', 'Brice', 'Sensabaugh', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '28', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10122'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10122'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5341', '5341', 'Kyle Anderson', 'Kyle', 'Anderson', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5341'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6410', '6410', 'Josh Green', 'Josh', 'Green', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6410'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6410'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10340', '10340', 'Jaylen Wells', 'Jaylen', 'Wells', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10340'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10340'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6256', '6256', 'Dean Wade', 'Dean', 'Wade', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '32', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6256'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6256'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6766', '6766', 'Simone Fontecchio', 'Simone', 'Fontecchio', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6766'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6766'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6762', '6762', 'Johnny Juzang', 'Johnny', 'Juzang', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '33', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6762'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6762'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6170', '6170', 'Jaxson Hayes', 'Jaxson', 'Hayes', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6170'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6269', '6269', 'Javonte Green', 'Javonte', 'Green', (SELECT id FROM teams WHERE abbreviation = 'DET'), '31', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6269'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6269'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6397', '6397', 'Isaac Okoro', 'Isaac', 'Okoro', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '35', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6397'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6397'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10291', '10291', 'Dalton Knecht', 'Dalton', 'Knecht', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10291'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10291'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10292', '10292', 'Ryan Dunn', 'Ryan', 'Dunn', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10292'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10292'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10077', '10077', 'Jalen Wilson', 'Jalen', 'Wilson', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10077'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10077'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6224', '6224', 'Cody Martin', 'Cody', 'Martin', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6224'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6224'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6224'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10113', '10113', 'Ben Sheppard', 'Ben', 'Sheppard', (SELECT id FROM teams WHERE abbreviation = 'IND'), '26', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10113'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10113'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6617', '6617', 'Jay Huff', 'Jay', 'Huff', (SELECT id FROM teams WHERE abbreviation = 'IND'), '32', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6617'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6574', '6574', 'Jeremiah Robinson-Earl', 'Jeremiah', 'Robinson-Earl', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '50', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6574'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6574'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10330', '10330', 'Jonathan Mogbo', 'Jonathan', 'Mogbo', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10330'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10330'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10103', '10103', 'Jarace Walker', 'Jarace', 'Walker', (SELECT id FROM teams WHERE abbreviation = 'IND'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10103'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10103'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6396', '6396', 'Patrick Williams', 'Patrick', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '44', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6396'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6717', '6717', 'Nikola Jović', 'Nikola', 'Jović', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6717'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10315', '10315', 'Kyle Filipowski', 'Kyle', 'Filipowski', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10315'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10315'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6724', '6724', 'Jaylin Williams', 'Jaylin', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '6', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6724'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6724'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6429', '6429', 'Vít Krejčí', 'Vít', 'Krejčí', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '27', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6429'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6429'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6450', '6450', 'Paul Reed', 'Paul', 'Reed', (SELECT id FROM teams WHERE abbreviation = 'DET'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6450'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6582', '6582', 'Jared Butler', 'Jared', 'Butler', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6582'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6582'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6709', '6709', 'Jake LaRavia', 'Jake', 'LaRavia', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6709'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6709'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5894', '5894', 'Chris Boucher', 'Chris', 'Boucher', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5894'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5894'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10080', '10080', 'Trayce Jackson-Davis', 'Trayce', 'Jackson-Davis', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '32', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10080'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10112', '10112', 'Julian Strawther', 'Julian', 'Strawther', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10112'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10112'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10333', '10333', 'Jamal Shead', 'Jamal', 'Shead', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10333'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6053', '6053', 'Bruce Brown', 'Bruce', 'Brown', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6053'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10098', '10098', 'Jordan Hawkins', 'Jordan', 'Hawkins', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10098'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10098'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5600', '5600', 'Ben Simmons', 'Ben', 'Simmons', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5600'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5600'), (SELECT id FROM positions WHERE code = 'PG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10335', '10335', 'Adem Bona', 'Adem', 'Bona', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10335'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6747', '6747', 'Jabari Walker', 'Jabari', 'Walker', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '33', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6747'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6747'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6109', '6109', 'Drew Eubanks', 'Drew', 'Eubanks', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '19', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6109'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6036', '6036', 'Moritz Wagner', 'Moritz', 'Wagner', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6036'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5015', '5015', 'Andre Drummond', 'Andre', 'Drummond', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5015'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6733', '6733', 'Moussa Diabaté', 'Moussa', 'Diabaté', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6733'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10275', '10275', 'Tristan da Silva', 'Tristan', 'da Silva', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10275'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10275'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6581', '6581', 'Neemias Queta', 'Neemias', 'Queta', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '88', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6581'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6581'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6353', '6353', 'Gabe Vincent', 'Gabe', 'Vincent', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6353'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6353'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6588', '6588', 'Dalano Banton', 'Dalano', 'Banton', (SELECT id FROM teams WHERE abbreviation = 'POR'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6588'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6588'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6255', '6255', 'John Konchar', 'John', 'Konchar', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '46', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6255'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6255'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4469', '4469', 'Eric Gordon', 'Eric', 'Gordon', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4469'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4469'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4152', '4152', 'Kyle Lowry', 'Kyle', 'Lowry', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4152'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5245', '5245', 'Seth Curry', 'Seth', 'Curry', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5245'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6596', '6596', 'Sandro Mamukelashvili', 'Sandro', 'Mamukelashvili', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '54', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6596'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6596'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6275', '6275', 'Caleb Martin', 'Caleb', 'Martin', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '16', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6275'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6275'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6742', '6742', 'Karlo Matković', 'Karlo', 'Matković', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6742'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6742'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6034', '6034', 'Aaron Holiday', 'Aaron', 'Holiday', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6034'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6034'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10114', '10114', 'Marcus Sasser', 'Marcus', 'Sasser', (SELECT id FROM teams WHERE abbreviation = 'DET'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10114'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4893', '4893', 'Alec Burks', 'Alec', 'Burks', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '18', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4893'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4893'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5357', '5357', 'Jordan Clarkson', 'Jordan', 'Clarkson', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '00', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5357'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5357'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10083', '10083', 'Julian Phillips', 'Julian', 'Phillips', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10083'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10083'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5487', '5487', 'Larry Nance Jr.', 'Larry', 'Nance Jr.', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5487'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5487'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10282', '10282', 'Isaiah Collier', 'Isaiah', 'Collier', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10282'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10282'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10125', '10125', 'Ricky Council IV', 'Ricky', 'Council IV', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10125'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10125'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6616', '6616', 'Jordan Goodwin', 'Jordan', 'Goodwin', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6616'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6616'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6604', '6604', 'Trendon Watford', 'Trendon', 'Watford', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6604'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6604'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6259', '6259', 'Garrison Mathews', 'Garrison', 'Mathews', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6259'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6259'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6741', '6741', 'Tyrese Martin', 'Tyrese', 'Martin', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6741'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6741'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6741'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10391', '10391', 'Jamison Battle', 'Jamison', 'Battle', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '77', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10391'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10391'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10278', '10278', 'Ja''Kobe Walter', 'Ja''Kobe', 'Walter', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10278'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10278'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6234', '6234', 'Talen Horton-Tucker', 'Talen', 'Horton-Tucker', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6234'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6234'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10118', '10118', 'Cam Whitmore', 'Cam', 'Whitmore', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10118'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10118'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10263', '10263', 'Ronald Holland II', 'Ronald', 'Holland II', (SELECT id FROM teams WHERE abbreviation = 'DET'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10263'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10263'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10310', '10310', 'Justin Edwards', 'Justin', 'Edwards', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10310'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6208', '6208', 'Matisse Thybulle', 'Matisse', 'Thybulle', (SELECT id FROM teams WHERE abbreviation = 'POR'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6208'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6208'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10121', '10121', 'Noah Clowney', 'Noah', 'Clowney', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10121'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10121'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6708', '6708', 'Dalen Terry', 'Dalen', 'Terry', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6708'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6708'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5497', '5497', 'Richaun Holmes', 'Richaun', 'Holmes', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5497'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6210', '6210', 'Grant Williams', 'Grant', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6210'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6210'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6734', '6734', 'Ryan Rollins', 'Ryan', 'Rollins', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6734'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6031', '6031', 'Josh Okogie', 'Josh', 'Okogie', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6031'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6031'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6593', '6593', 'Brandon Boston', 'Brandon', 'Boston', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6593'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6593'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5764', '5764', 'Lonzo Ball', 'Lonzo', 'Ball', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5764'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5764'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10120', '10120', 'Nick Smith Jr.', 'Nick', 'Smith Jr.', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10120'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10120'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6444', '6444', 'KJ Martin', 'KJ', 'Martin', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '99', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6444'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6444'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10069', '10069', 'Mouhamed Gueye', 'Mouhamed', 'Gueye', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '18', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10069'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10069'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5317', '5317', 'Marcus Smart', 'Marcus', 'Smart', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '36', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5317'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5317'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6052', '6052', 'Jarred Vanderbilt', 'Jarred', 'Vanderbilt', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6052'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6052'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5501', '5501', 'Pat Connaughton', 'Pat', 'Connaughton', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5501'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5501'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6232', '6232', 'Bol Bol', 'Bol', 'Bol', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6232'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6232'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6414', '6414', 'Zeke Nnaji', 'Zeke', 'Nnaji', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6414'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6414'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6065', '6065', 'Shake Milton', 'Shake', 'Milton', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6065'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6065'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5480', '5480', 'Delon Wright', 'Delon', 'Wright', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5480'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5480'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6636', '6636', 'Jeff Dowtin Jr.', 'Jeff', 'Dowtin Jr.', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6636'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6636'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10119', '10119', 'Kris Murray', 'Kris', 'Murray', (SELECT id FROM teams WHERE abbreviation = 'POR'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10119'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10119'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6737', '6737', 'Vince Williams Jr.', 'Vince', 'Williams Jr.', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6737'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6737'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10164', '10164', 'Duop Reath', 'Duop', 'Reath', (SELECT id FROM teams WHERE abbreviation = 'POR'), '26', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10164'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10308', '10308', 'Quinten Post', 'Quinten', 'Post', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10308'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10082', '10082', 'Andre Jackson Jr.', 'Andre', 'Jackson Jr.', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '44', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10082'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10082'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5330', '5330', 'Gary Harris', 'Gary', 'Harris', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5330'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5330'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6586', '6586', 'Kessler Edwards', 'Kessler', 'Edwards', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6586'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6586'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5356', '5356', 'Dwight Powell', 'Dwight', 'Powell', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5356'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6463', '6463', 'Jae''Sean Tate', 'Jae''Sean', 'Tate', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6463'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6463'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5667', '5667', 'Malcolm Brogdon', 'Malcolm', 'Brogdon', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5667'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5667'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6722', '6722', 'Caleb Houstan', 'Caleb', 'Houstan', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6722'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6722'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6276', '6276', 'DaQuan Jeffries', 'DaQuan', 'Jeffries', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6276'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6276'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6687', '6687', 'Lindy Waters III', 'Lindy', 'Waters III', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '43', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6687'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6687'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6037', '6037', 'Landry Shamet', 'Landry', 'Shamet', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '44', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6037'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6037'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6802', '6802', 'Orlando Robinson', 'Orlando', 'Robinson', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6802'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10313', '10313', 'Oso Ighodaro', 'Oso', 'Ighodaro', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10313'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10145', '10145', 'Craig Porter Jr.', 'Craig', 'Porter Jr.', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10145'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10145'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10295', '10295', 'Tidjane Salaün', 'Tidjane', 'Salaün', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '31', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10295'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4247', '4247', 'Jeff Green', 'Jeff', 'Green', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '32', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4247'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6679', '6679', 'Brandon Williams', 'Brandon', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6679'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6655', '6655', 'Micah Potter', 'Micah', 'Potter', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6655'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6655'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5893', '5893', 'Torrey Craig', 'Torrey', 'Craig', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5893'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5893'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6745', '6745', 'Gui Santos', 'Gui', 'Santos', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6745'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6745'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6038', '6038', 'Robert Williams III', 'Robert', 'Williams III', (SELECT id FROM teams WHERE abbreviation = 'POR'), '35', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6038'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10078', '10078', 'Tristan Vukcevic', 'Tristan', 'Vukcevic', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '00', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10078'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10078'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6614', '6614', 'Jock Landale', 'Jock', 'Landale', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6614'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6727', '6727', 'Jaden Hardy', 'Jaden', 'Hardy', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6727'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6727'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6751', '6751', 'Collin Gillespie', 'Collin', 'Gillespie', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6751'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6595', '6595', 'Charles Bassey', 'Charles', 'Bassey', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '28', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6595'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6058', '6058', 'Svi Mykhailiuk', 'Svi', 'Mykhailiuk', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6058'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5864', '5864', 'Monté Morris', 'Monté', 'Morris', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5864'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6047', '6047', 'Mitchell Robinson', 'Mitchell', 'Robinson', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6047'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4911', '4911', 'Cory Joseph', 'Cory', 'Joseph', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4911'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10074', '10074', 'Jalen Pickett', 'Jalen', 'Pickett', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10074'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10074'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4391', '4391', 'Kevin Love', 'Kevin', 'Love', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '42', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4391'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4391'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4497', '4497', 'DeAndre Jordan', 'DeAndre', 'Jordan', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '6', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4497'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6710', '6710', 'Malaki Branham', 'Malaki', 'Branham', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6710'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6710'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6029', '6029', 'Lonnie Walker IV', 'Lonnie', 'Walker IV', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '16', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6029'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6029'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6600', '6600', 'Jericho Sims', 'Jericho', 'Sims', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '00', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6600'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10304', '10304', 'Ajay Mitchell', 'Ajay', 'Mitchell', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10304'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10304'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6561', '6561', 'Kai Jones', 'Kai', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6561'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10199', '10199', 'Tosan Evbuomwan', 'Tosan', 'Evbuomwan', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10199'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10199'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6713', '6713', 'David Roddy', 'David', 'Roddy', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '45', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6713'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6560', '6560', 'Tre Mann', 'Tre', 'Mann', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6560'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6560'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6133', '6133', 'Jordan McLaughlin', 'Jordan', 'McLaughlin', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6133'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6133'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6701', '6701', 'Ousmane Dieng', 'Ousmane', 'Dieng', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6701'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6701'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6570', '6570', 'Jaden Springer', 'Jaden', 'Springer', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6570'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6715', '6715', 'Blake Wesley', 'Blake', 'Wesley', (SELECT id FROM teams WHERE abbreviation = 'POR'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6715'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6715'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10323', '10323', 'KJ Simpson', 'KJ', 'Simpson', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10323'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6791', '6791', 'Dominick Barlow', 'Dominick', 'Barlow', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6791'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6791'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6801', '6801', 'Jamal Cain', 'Jamal', 'Cain', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6801'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6801'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10276', '10276', 'Jared McCain', 'Jared', 'McCain', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10276'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10276'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5959', '5959', 'Marvin Bagley III', 'Marvin', 'Bagley III', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '35', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5959'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5959'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10053', '10053', 'Keaton Wallace', 'Keaton', 'Wallace', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10053'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10053'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5892', '5892', 'Maxi Kleber', 'Maxi', 'Kleber', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5892'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5892'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10087', '10087', 'Colby Jones', 'Colby', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'DET'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10087'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10087'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6568', '6568', 'Bones Hyland', 'Bones', 'Hyland', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '77', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6568'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6735', '6735', 'Josh Minott', 'Josh', 'Minott', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6735'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6735'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10338', '10338', 'Antonio Reeves', 'Antonio', 'Reeves', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10338'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10338'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5316', '5316', 'Danté Exum', 'Danté', 'Exum', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5316'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5316'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10312', '10312', 'Pelle Larsson', 'Pelle', 'Larsson', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10312'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10312'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6043', '6043', 'Jevon Carter', 'Jevon', 'Carter', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6043'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6043'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6500', '6500', 'Trevelin Queen', 'Trevelin', 'Queen', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6500'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6500'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10070', '10070', 'GG Jackson', 'GG', 'Jackson', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '45', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10070'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10070'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10086', '10086', 'Jaylen Clark', 'Jaylen', 'Clark', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10086'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10086'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4888', '4888', 'Bismack Biyombo', 'Bismack', 'Biyombo', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4888'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10116', '10116', 'Olivier-Maxence Prosper', 'Olivier-Maxence', 'Prosper', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10116'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10116'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10305', '10305', 'Johnny Furphy', 'Johnny', 'Furphy', (SELECT id FROM teams WHERE abbreviation = 'IND'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10305'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10305'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10127', '10127', 'Oscar Tshiebwe', 'Oscar', 'Tshiebwe', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '34', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10127'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10127'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5321', '5321', 'Elfrid Payton', 'Elfrid', 'Payton', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5321'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5321'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4660', '4660', 'Patty Mills', 'Patty', 'Mills', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '88', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4660'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10342', '10342', 'Branden Carlson', 'Branden', 'Carlson', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10342'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6411', '6411', 'Saddiq Bey', 'Saddiq', 'Bey', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '41', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6411'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6411'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5323', '5323', 'Dario Šarić', 'Dario', 'Šarić', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5323'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10279', '10279', 'Jaylon Tyson', 'Jaylon', 'Tyson', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10279'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6427', '6427', 'Xavier Tillman', 'Xavier', 'Tillman', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '26', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6427'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6427'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5363', '5363', 'Vasilije Micić', 'Vasilije', 'Micić', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '18', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5363'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5363'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6057', '6057', 'De''Anthony Melton', 'De''Anthony', 'Melton', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6057'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6057'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6564', '6564', 'Isaiah Jackson', 'Isaiah', 'Jackson', (SELECT id FROM teams WHERE abbreviation = 'IND'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6564'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10106', '10106', 'Jett Howard', 'Jett', 'Howard', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10106'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6723', '6723', 'Christian Koloko', 'Christian', 'Koloko', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6723'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4631', '4631', 'Taj Gibson', 'Taj', 'Gibson', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '67', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4631'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4631'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10332', '10332', 'Reece Beekman', 'Reece', 'Beekman', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10332'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6603', '6603', 'A.J. Lawson', 'A.J.', 'Lawson', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6603'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6603'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6716', '6716', 'Wendell Moore Jr.', 'Wendell', 'Moore Jr.', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6716'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5163', '5163', 'Steven Adams', 'Steven', 'Adams', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5163'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6776', '6776', 'Quenton Jackson', 'Quenton', 'Jackson', (SELECT id FROM teams WHERE abbreviation = 'IND'), '29', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6776'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6776'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5156', '5156', 'Alex Len', 'Alex', 'Len', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '27', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5156'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5322', '5322', 'Doug McDermott', 'Doug', 'McDermott', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5322'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5322'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6652', '6652', 'Dru Smith', 'Dru', 'Smith', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6652'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6652'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10283', '10283', 'Cody Williams', 'Cody', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10283'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10283'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10064', '10064', 'Rayan Rupert', 'Rayan', 'Rupert', (SELECT id FROM teams WHERE abbreviation = 'POR'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10064'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10064'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10413', '10413', 'Alex Reese', 'Alex', 'Reese', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '65', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10413'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10280', '10280', 'Terrence Shannon Jr.', 'Terrence', 'Shannon Jr.', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10280'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10280'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10220', '10220', 'Trey Jemison III', 'Trey', 'Jemison III', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '55', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10220'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10220'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10147', '10147', 'Colin Castleton', 'Colin', 'Castleton', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10147'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10147'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10300', '10300', 'AJ Johnson', 'AJ', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10300'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10300'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10110', '10110', 'Taylor Hendricks', 'Taylor', 'Hendricks', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10110'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10110'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6579', '6579', 'JT Thor', 'JT', 'Thor', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6579'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6459', '6459', 'Lamar Stevens', 'Lamar', 'Stevens', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '18', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6459'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6459'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10067', '10067', 'Hunter Tyson', 'Hunter', 'Tyson', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10067'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10067'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4682', '4682', 'Garrett Temple', 'Garrett', 'Temple', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4682'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4682'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10277', '10277', 'Baylor Scheierman', 'Baylor', 'Scheierman', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '55', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10277'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10409', '10409', 'Keion Brooks Jr.', 'Keion', 'Brooks Jr.', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10409'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10409'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10327', '10327', 'Cam Spencer', 'Cam', 'Spencer', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10327'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10084', '10084', 'Jordan Miller', 'Jordan', 'Miller', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10084'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10281', '10281', 'Rob Dillingham', 'Rob', 'Dillingham', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10281'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5393', '5393', 'Joe Ingles', 'Joe', 'Ingles', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5393'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5068', '5068', 'Jae Crowder', 'Jae', 'Crowder', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '99', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5068'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5068'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6803', '6803', 'Jared Rhoden', 'Jared', 'Rhoden', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6803'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6803'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5763', '5763', 'Markelle Fultz', 'Markelle', 'Fultz', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5763'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5763'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10284', '10284', 'Dillon Jones', 'Dillon', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '33', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10284'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10284'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10117', '10117', 'Kobe Brown', 'Kobe', 'Brown', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10117'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10117'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6204', '6204', 'Chuma Okeke', 'Chuma', 'Okeke', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '18', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6204'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6471', '6471', 'Anthony Gill', 'Anthony', 'Gill', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '16', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6471'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10075', '10075', 'Jordan Walsh', 'Jordan', 'Walsh', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '27', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10075'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10075'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10293', '10293', 'Devin Carter', 'Devin', 'Carter', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10293'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6020', '6020', 'Kevin Knox II', 'Kevin', 'Knox II', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '31', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6020'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6020'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10111', '10111', 'Dariq Whitehead', 'Dariq', 'Whitehead', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10111'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10111'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6750', '6750', 'Lester Quinones', 'Lester', 'Quinones', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6750'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6750'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10206', '10206', 'Drew Peterson', 'Drew', 'Peterson', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10206'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10206'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10262', '10262', 'Tyler Smith', 'Tyler', 'Smith', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10262'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10262'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5733', '5733', 'Damion Lee', 'Damion', 'Lee', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5733'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5733'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4163', '4163', 'P.J. Tucker', 'P.J.', 'Tucker', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4163'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10079', '10079', 'Maxwell Lewis', 'Maxwell', 'Lewis', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '27', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10079'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10079'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6356', '6356', 'James Wiseman', 'James', 'Wiseman', (SELECT id FROM teams WHERE abbreviation = 'IND'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6356'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10134', '10134', 'Jaylen Martin', 'Jaylen', 'Martin', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10134'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10134'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5841', '5841', 'Tony Bradley', 'Tony', 'Bradley', (SELECT id FROM teams WHERE abbreviation = 'IND'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5841'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6730', '6730', 'Bryce McGowens', 'Bryce', 'McGowens', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6730'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6730'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10343', '10343', 'Alex Ducas', 'Alex', 'Ducas', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '88', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10343'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10311', '10311', 'Keshad Johnson', 'Keshad', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '16', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10311'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10314', '10314', 'Tyler Kolek', 'Tyler', 'Kolek', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10314'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10341', '10341', 'Isaac Jones', 'Isaac', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10341'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10341'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6594', '6594', 'Luka Garza', 'Luka', 'Garza', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '52', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6594'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10109', '10109', 'Jalen Hood-Schifino', 'Jalen', 'Hood-Schifino', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10109'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10109'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6718', '6718', 'Patrick Baldwin Jr.', 'Patrick', 'Baldwin Jr.', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6718'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6772', '6772', 'Pat Spencer', 'Pat', 'Spencer', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '61', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6772'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6772'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6714', '6714', 'MarJon Beauchamp', 'MarJon', 'Beauchamp', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6714'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6714'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10213', '10213', 'Damion Baugh', 'Damion', 'Baugh', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10213'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10213'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6782', '6782', 'Stanley Umude', 'Stanley', 'Umude', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6782'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10141', '10141', 'Drew Timme', 'Drew', 'Timme', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '26', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10141'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10423', '10423', 'Elijah Harkless', 'Elijah', 'Harkless', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '16', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10423'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10393', '10393', 'Spencer Jones', 'Spencer', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10393'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10393'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6240', '6240', 'Jalen McDaniels', 'Jalen', 'McDaniels', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '26', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6240'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6240'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10066', '10066', 'Emoni Bates', 'Emoni', 'Bates', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10066'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10066'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10416', '10416', 'RayJ Dennis', 'RayJ', 'Dennis', (SELECT id FROM teams WHERE abbreviation = 'IND'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10416'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10329', '10329', 'PJ Hall', 'PJ', 'Hall', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10329'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10105', '10105', 'Kobe Bufkin', 'Kobe', 'Bufkin', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10105'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10105'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10168', '10168', 'Pete Nance', 'Pete', 'Nance', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '35', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10168'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10088', '10088', 'Chris Livingston', 'Chris', 'Livingston', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10088'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6731', '6731', 'E.J. Liddell', 'E.J.', 'Liddell', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '32', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6731'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6731'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10317', '10317', 'Ariel Hukporti', 'Ariel', 'Hukporti', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '55', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10317'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4894', '4894', 'Markieff Morris', 'Markieff', 'Morris', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '88', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4894'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4894'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10328', '10328', 'N''Faly Dante', 'N''Faly', 'Dante', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10328'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6786', '6786', 'Daeqwon Plowden', 'Daeqwon', 'Plowden', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '29', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6786'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6786'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10050', '10050', 'Leonard Miller', 'Leonard', 'Miller', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '33', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10050'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10415', '10415', 'Yuki Kawamura', 'Yuki', 'Kawamura', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10415'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10129', '10129', 'Jacob Toppin', 'Jacob', 'Toppin', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10129'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10324', '10324', 'Enrique Freeman', 'Enrique', 'Freeman', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10324'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6806', '6806', 'Nate Williams', 'Nate', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '19', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6806'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6806'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10061', '10061', 'Justin Minaya', 'Justin', 'Minaya', (SELECT id FROM teams WHERE abbreviation = 'POR'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10061'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10061'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10244', '10244', 'Adam Flagler', 'Adam', 'Flagler', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10244'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10244'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5862', '5862', 'Vlatko Čančar', 'Vlatko', 'Čančar', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '31', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5862'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5862'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6785', '6785', 'Tyson Etienne', 'Tyson', 'Etienne', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6785'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4884', '4884', 'Tristan Thompson', 'Tristan', 'Thompson', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4884'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10339', '10339', 'Bronny James', 'Bronny', 'James', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10339'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10339'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10297', '10297', 'Pacôme Dadiet', 'Pacôme', 'Dadiet', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10297'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10297'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6453', '6453', 'Mason Jones', 'Mason', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6453'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6453'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10358', '10358', 'Jackson Rowe', 'Jackson', 'Rowe', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '44', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10358'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10358'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6624', '6624', 'David Duke Jr.', 'David', 'Duke Jr.', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6624'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6624'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10402', '10402', 'Jahmir Young', 'Jahmir', 'Young', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10402'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10320', '10320', 'Isaiah Crawford', 'Isaiah', 'Crawford', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10320'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10389', '10389', 'Jack McVeigh', 'Jack', 'McVeigh', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '58', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10389'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10418', '10418', 'Tolu Smith', 'Tolu', 'Smith', (SELECT id FROM teams WHERE abbreviation = 'DET'), '35', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10418'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6743', '6743', 'JD Davison', 'JD', 'Davison', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6743'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6743'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6800', '6800', 'Jamaree Bouyea', 'Jamaree', 'Bouyea', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6800'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.4621', '4621', 'James Johnson', 'James', 'Johnson', (SELECT id FROM teams WHERE abbreviation = 'IND'), '16', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.4621'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5659', '5659', 'Skal Labissière', 'Skal', 'Labissière', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5659'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5659'), (SELECT id FROM positions WHERE code = 'PF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6584', '6584', 'Isaiah Livers', 'Isaiah', 'Livers', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '18', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6584'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6584'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10410', '10410', 'Emanuel Miller', 'Emanuel', 'Miller', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10410'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10397', '10397', 'Nae''Qwan Tomlin', 'Nae''Qwan', 'Tomlin', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10397'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10303', '10303', 'Kevin McCullar Jr.', 'Kevin', 'McCullar Jr.', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10303'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10303'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10385', '10385', 'Trey Alexander', 'Trey', 'Alexander', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10385'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6566', '6566', 'Josh Christopher', 'Josh', 'Christopher', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6566'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6566'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10331', '10331', 'Bobi Klintman', 'Bobi', 'Klintman', (SELECT id FROM teams WHERE abbreviation = 'DET'), '34', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10331'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10337', '10337', 'Cam Christie', 'Cam', 'Christie', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10337'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10337'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10336', '10336', 'Harrison Ingram', 'Harrison', 'Ingram', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '55', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10336'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6719', '6719', 'TyTy Washington Jr.', 'TyTy', 'Washington Jr.', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6719'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10148', '10148', 'Miles Norris', 'Miles', 'Norris', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10148'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10148'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10051', '10051', 'Sidy Cissoko', 'Sidy', 'Cissoko', (SELECT id FROM teams WHERE abbreviation = 'POR'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10051'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10051'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6749', '6749', 'Alondes Williams', 'Alondes', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '31', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6749'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6761', '6761', 'Ron Harper Jr.', 'Ron', 'Harper Jr.', (SELECT id FROM teams WHERE abbreviation = 'DET'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6761'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10520', '10520', 'RJ Davis', 'RJ', 'Davis', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10520'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10476', '10476', 'Ryan Kalkbrenner', 'Ryan', 'Kalkbrenner', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10476'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10507', '10507', 'Eric Dixon', 'Eric', 'Dixon', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10507'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10480', '10480', 'Rocco Zikarsky', 'Rocco', 'Zikarsky', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10480'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6746', '6746', 'Luke Travers', 'Luke', 'Travers', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '33', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6746'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10494', '10494', 'Javon Small', 'Javon', 'Small', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10494'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10513', '10513', 'Cameron Matthews', 'Cameron', 'Matthews', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10513'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10286', '10286', 'DaRon Holmes II', 'DaRon', 'Holmes II', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10286'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6767', '6767', 'Kevon Harris', 'Kevon', 'Harris', (SELECT id FROM teams WHERE abbreviation = 'HOU'), '00', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6767'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10456', '10456', 'Danny Wolf', 'Danny', 'Wolf', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10456'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10466', '10466', 'Carter Bryant', 'Carter', 'Bryant', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10466'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10511', '10511', 'Ryan Nembhard', 'Ryan', 'Nembhard', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10511'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10495', '10495', 'Rasheer Fleming', 'Rasheer', 'Fleming', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10495'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10325', '10325', 'Ulrich Chomche', 'Ulrich', 'Chomche', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10325'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10387', '10387', 'Jesse Edwards', 'Jesse', 'Edwards', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10387'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6628', '6628', 'Mac McClung', 'Mac', 'McClung', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6628'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6628'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10367', '10367', 'Riley Minix', 'Riley', 'Minix', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '27', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10367'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10486', '10486', 'Chaz Lanier', 'Chaz', 'Lanier', (SELECT id FROM teams WHERE abbreviation = 'DET'), '20', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10486'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10441', '10441', 'Yanic Konan Niederhäuser', 'Yanic', 'Konan Niederhäuser', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10441'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10301', '10301', 'Nikola Topić', 'Nikola', 'Topić', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '44', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10301'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10461', '10461', 'Walter Clayton Jr.', 'Walter', 'Clayton Jr.', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10461'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10321', '10321', 'Anton Watson', 'Anton', 'Watson', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '28', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10321'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10395', '10395', 'Trentyn Flowers', 'Trentyn', 'Flowers', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10395'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10383', '10383', 'Isaiah Stevens', 'Isaiah', 'Stevens', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10383'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10510', '10510', 'Dylan Cardwell', 'Dylan', 'Cardwell', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10510'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10503', '10503', 'RJ Luis Jr.', 'RJ', 'Luis Jr.', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10503'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10478', '10478', 'Brooks Barnhizer', 'Brooks', 'Barnhizer', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10478'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10493', '10493', 'John Tonje', 'John', 'Tonje', (SELECT id FROM teams WHERE abbreviation = 'UTA'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10493'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10463', '10463', 'Thomas Sorber', 'Thomas', 'Sorber', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10463'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10479', '10479', 'Noah Penda', 'Noah', 'Penda', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '93', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10479'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6637', '6637', 'Ethan Thompson', 'Ethan', 'Thompson', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '55', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6637'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10474', '10474', 'Johni Broome', 'Johni', 'Broome', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10474'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10460', '10460', 'Joan Beringer', 'Joan', 'Beringer', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '19', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10460'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10505', '10505', 'Vladislav Goldin', 'Vladislav', 'Goldin', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '50', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10505'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10515', '10515', 'Curtis Jones', 'Curtis', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10515'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10509', '10509', 'Tamar Bates', 'Tamar', 'Bates', (SELECT id FROM teams WHERE abbreviation = 'DEN'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10509'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10491', '10491', 'Jahmai Mashack', 'Jahmai', 'Mashack', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10491'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10475', '10475', 'Koby Brea', 'Koby', 'Brea', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10475'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10447', '10447', 'Khaman Maluach', 'Khaman', 'Maluach', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '10', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10447'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10485', '10485', 'Will Richard', 'Will', 'Richard', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '3', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10485'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10471', '10471', 'Mohamed Diawara', 'Mohamed', 'Diawara', (SELECT id FROM teams WHERE abbreviation = 'NYK'), '51', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10471'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10442', '10442', 'Noa Essengue', 'Noa', 'Essengue', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10442'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10458', '10458', 'Ben Saraf', 'Ben', 'Saraf', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '77', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10458'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10492', '10492', 'Taelon Peter', 'Taelon', 'Peter', (SELECT id FROM teams WHERE abbreviation = 'IND'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10492'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10450', '10450', 'Kon Knueppel', 'Kon', 'Knueppel', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10450'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10440', '10440', 'Jeremiah Fears', 'Jeremiah', 'Fears', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '0', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10440'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10455', '10455', 'Nolan Traoré', 'Nolan', 'Traoré', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '88', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10455'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10444', '10444', 'Derik Queen', 'Derik', 'Queen', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10444'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10449', '10449', 'Will Riley', 'Will', 'Riley', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '27', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10449'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10504', '10504', 'Miles Kelly', 'Miles', 'Kelly', (SELECT id FROM teams WHERE abbreviation = 'DAL'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10504'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10470', '10470', 'Kobe Sanders', 'Kobe', 'Sanders', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10470'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10472', '10472', 'Tyrese Proctor', 'Tyrese', 'Proctor', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10472'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10322', '10322', 'Nikola Đurišić', 'Nikola', 'Đurišić', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10322'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10488', '10488', 'Adou Thiero', 'Adou', 'Thiero', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10488'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10506', '10506', 'Chucky Hepburn', 'Chucky', 'Hepburn', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '24', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10506'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10499', '10499', 'Hunter Sallis', 'Hunter', 'Sallis', (SELECT id FROM teams WHERE abbreviation = 'PHI'), '45', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10499'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10465', '10465', 'Cedric Coward', 'Cedric', 'Coward', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10465'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10508', '10508', 'Caleb Love', 'Caleb', 'Love', (SELECT id FROM teams WHERE abbreviation = 'POR'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10508'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10518', '10518', 'Augustas Marciulionis', 'Augustas', 'Marciulionis', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10518'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10453', '10453', 'Jase Richardson', 'Jase', 'Richardson', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '11', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10453'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10512', '10512', 'CJ Huntley', 'CJ', 'Huntley', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10512'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10459', '10459', 'Hugo González', 'Hugo', 'González', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '28', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10459'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10501', '10501', 'Hunter Dickinson', 'Hunter', 'Dickinson', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10501'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10483', '10483', 'Max Shulga', 'Max', 'Shulga', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '29', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10483'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.5908', '5908', 'Nigel Hayes-Davis', 'Nigel', 'Hayes-Davis', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '21', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.5908'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10452', '10452', 'Kasparas Jakučionis', 'Kasparas', 'Jakučionis', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10452'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10473', '10473', 'Amari Williams', 'Amari', 'Williams', (SELECT id FROM teams WHERE abbreviation = 'BOS'), '77', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10473'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10451', '10451', 'Asa Newell', 'Asa', 'Newell', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10451'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10445', '10445', 'Egor Demin', 'Egor', 'Demin', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '8', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10445'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10489', '10489', 'Jamir Watkins', 'Jamir', 'Watkins', (SELECT id FROM teams WHERE abbreviation = 'WAS'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10489'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10516', '10516', 'Chris Mañon', 'Chris', 'Mañon', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10516'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10457', '10457', 'Drake Powell', 'Drake', 'Powell', (SELECT id FROM teams WHERE abbreviation = 'BKN'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10457'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10435', '10435', 'Taran Armstrong', 'Taran', 'Armstrong', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '1', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10435'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10484', '10484', 'Alex Toohey', 'Alex', 'Toohey', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '22', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10484'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10519', '10519', 'Arthur Kaluma', 'Arthur', 'Kaluma', (SELECT id FROM teams WHERE abbreviation = 'LAL'), '', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10519'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10446', '10446', 'Liam McNeeley', 'Liam', 'McNeeley', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '33', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10446'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10443', '10443', 'Collin Murray-Boyles', 'Collin', 'Murray-Boyles', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10443'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10481', '10481', 'Saliou Niang', 'Saliou', 'Niang', (SELECT id FROM teams WHERE abbreviation = 'CLE'), '77', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10481'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10344', '10344', 'Zyon Pullin', 'Zyon', 'Pullin', (SELECT id FROM teams WHERE abbreviation = 'MEM'), '2', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10344'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10411', '10411', 'Malevy Leons', 'Malevy', 'Leons', (SELECT id FROM teams WHERE abbreviation = 'OKC'), '17', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10411'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10487', '10487', 'Kam Jones', 'Kam', 'Jones', (SELECT id FROM teams WHERE abbreviation = 'IND'), '7', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10487'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10517', '10517', 'Myron Gardner', 'Myron', 'Gardner', (SELECT id FROM teams WHERE abbreviation = 'MIA'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10517'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10372', '10372', 'David Jones-Garcia', 'David', 'Jones-Garcia', (SELECT id FROM teams WHERE abbreviation = 'SAS'), '25', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10372'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10482', '10482', 'Lachlan Olbrich', 'Lachlan', 'Olbrich', (SELECT id FROM teams WHERE abbreviation = 'CHI'), '47', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10482'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10073', '10073', 'Seth Lundy', 'Seth', 'Lundy', (SELECT id FROM teams WHERE abbreviation = 'LAC'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10073'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6280', '6280', 'Terence Davis', 'Terence', 'Davis', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '9', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6280'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6280'), (SELECT id FROM positions WHERE code = 'SG'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6686', '6686', 'Braxton Key', 'Braxton', 'Key', (SELECT id FROM teams WHERE abbreviation = 'GSW'), '12', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6686'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6686'), (SELECT id FROM positions WHERE code = 'SF'), false);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10309', '10309', 'Jalen Bridges', 'Jalen', 'Bridges', (SELECT id FROM teams WHERE abbreviation = 'PHX'), '15', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10309'), (SELECT id FROM positions WHERE code = 'SF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10498', '10498', 'Sion James', 'Sion', 'James', (SELECT id FROM teams WHERE abbreviation = 'CHA'), '4', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10498'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10502', '10502', 'Eli John Ndiaye', 'Eli John', 'Ndiaye', (SELECT id FROM teams WHERE abbreviation = 'ATL'), '30', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10502'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10469', '10469', 'Nique Clifford', 'Nique', 'Clifford', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '5', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10469'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10464', '10464', 'Yang Hansen', 'Yang', 'Hansen', (SELECT id FROM teams WHERE abbreviation = 'POR'), '16', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10464'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10500', '10500', 'Mark Sears', 'Mark', 'Sears', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '19', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10500'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10496', '10496', 'Maxime Raynaud', 'Maxime', 'Raynaud', (SELECT id FROM teams WHERE abbreviation = 'SAC'), '42', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10496'), (SELECT id FROM positions WHERE code = 'C'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10477', '10477', 'Bogoljub Marković', 'Bogoljub', 'Marković', (SELECT id FROM teams WHERE abbreviation = 'MIL'), '23', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10477'), (SELECT id FROM positions WHERE code = 'PF'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10318', '10318', 'Tristen Newton', 'Tristen', 'Newton', (SELECT id FROM teams WHERE abbreviation = 'MIN'), '13', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10318'), (SELECT id FROM positions WHERE code = 'PG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10490', '10490', 'Alijah Martin', 'Alijah', 'Martin', (SELECT id FROM teams WHERE abbreviation = 'TOR'), '55', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10490'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.10497', '10497', 'Micah Peavy', 'Micah', 'Peavy', (SELECT id FROM teams WHERE abbreviation = 'NOP'), '14', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.10497'), (SELECT id FROM positions WHERE code = 'SG'), true);

INSERT OR IGNORE INTO players (yahoo_player_key, yahoo_player_id, full_name, first_name, last_name, team_id, uniform_number, is_active) VALUES
('466.p.6661', '6661', 'Jalen Crutcher', 'Jalen', 'Crutcher', (SELECT id FROM teams WHERE abbreviation = 'ORL'), '40', 1);

INSERT OR IGNORE INTO player_positions (player_id, position_id, is_primary) VALUES
((SELECT id FROM players WHERE yahoo_player_key = '466.p.6661'), (SELECT id FROM positions WHERE code = 'PG'), true);

