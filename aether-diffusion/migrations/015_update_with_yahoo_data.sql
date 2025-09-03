-- Migration 015: Update existing data with Yahoo API information
-- This updates teams and adds Yahoo team keys without recreating all data

-- Update teams with Yahoo team keys (extracted from player data)
UPDATE teams SET yahoo_team_key = 'nba.t.1', yahoo_team_id = '1' WHERE abbreviation = 'ATL';
UPDATE teams SET yahoo_team_key = 'nba.t.2', yahoo_team_id = '2' WHERE abbreviation = 'BOS'; 
UPDATE teams SET yahoo_team_key = 'nba.t.3', yahoo_team_id = '3' WHERE abbreviation = 'BKN';
UPDATE teams SET yahoo_team_key = 'nba.t.4', yahoo_team_id = '4' WHERE abbreviation = 'CHA';
UPDATE teams SET yahoo_team_key = 'nba.t.5', yahoo_team_id = '5' WHERE abbreviation = 'CHI';
UPDATE teams SET yahoo_team_key = 'nba.t.6', yahoo_team_id = '6' WHERE abbreviation = 'CLE';
UPDATE teams SET yahoo_team_key = 'nba.t.7', yahoo_team_id = '7' WHERE abbreviation = 'DEN';
UPDATE teams SET yahoo_team_key = 'nba.t.8', yahoo_team_id = '8' WHERE abbreviation = 'DET';
UPDATE teams SET yahoo_team_key = 'nba.t.9', yahoo_team_id = '9' WHERE abbreviation = 'GSW';
UPDATE teams SET yahoo_team_key = 'nba.t.10', yahoo_team_id = '10' WHERE abbreviation = 'HOU';
UPDATE teams SET yahoo_team_key = 'nba.t.11', yahoo_team_id = '11' WHERE abbreviation = 'IND';
UPDATE teams SET yahoo_team_key = 'nba.t.12', yahoo_team_id = '12' WHERE abbreviation = 'LAC';
UPDATE teams SET yahoo_team_key = 'nba.t.13', yahoo_team_id = '13' WHERE abbreviation = 'LAL';
UPDATE teams SET yahoo_team_key = 'nba.t.14', yahoo_team_id = '14' WHERE abbreviation = 'MEM';
UPDATE teams SET yahoo_team_key = 'nba.t.15', yahoo_team_id = '15' WHERE abbreviation = 'MIL';
UPDATE teams SET yahoo_team_key = 'nba.t.16', yahoo_team_id = '16' WHERE abbreviation = 'MIN';
UPDATE teams SET yahoo_team_key = 'nba.t.17', yahoo_team_id = '17' WHERE abbreviation = 'NOP';
UPDATE teams SET yahoo_team_key = 'nba.t.18', yahoo_team_id = '18' WHERE abbreviation = 'NYK';
UPDATE teams SET yahoo_team_key = 'nba.t.19', yahoo_team_id = '19' WHERE abbreviation = 'OKC';
UPDATE teams SET yahoo_team_key = 'nba.t.20', yahoo_team_id = '20' WHERE abbreviation = 'ORL';
UPDATE teams SET yahoo_team_key = 'nba.t.21', yahoo_team_id = '21' WHERE abbreviation = 'PHI';
UPDATE teams SET yahoo_team_key = 'nba.t.22', yahoo_team_id = '22' WHERE abbreviation = 'PHX';
UPDATE teams SET yahoo_team_key = 'nba.t.23', yahoo_team_id = '23' WHERE abbreviation = 'POR';
UPDATE teams SET yahoo_team_key = 'nba.t.24', yahoo_team_id = '24' WHERE abbreviation = 'SAS';
UPDATE teams SET yahoo_team_key = 'nba.t.25', yahoo_team_id = '25' WHERE abbreviation = 'SAC';
UPDATE teams SET yahoo_team_key = 'nba.t.26', yahoo_team_id = '26' WHERE abbreviation = 'TOR';
UPDATE teams SET yahoo_team_key = 'nba.t.27', yahoo_team_id = '27' WHERE abbreviation = 'UTA';
UPDATE teams SET yahoo_team_key = 'nba.t.28', yahoo_team_id = '28' WHERE abbreviation = 'WAS';
UPDATE teams SET yahoo_team_key = 'nba.t.29', yahoo_team_id = '29' WHERE abbreviation = 'MIA';
UPDATE teams SET yahoo_team_key = 'nba.t.30', yahoo_team_id = '30' WHERE abbreviation = 'DAL';