-- Migration 014: Add Yahoo Team ID column to teams table
-- This adds the missing yahoo_team_id column needed for Yahoo API integration

-- Add yahoo_team_id column to teams table
ALTER TABLE teams ADD COLUMN yahoo_team_id TEXT;

-- Create index for yahoo_team_id
CREATE INDEX IF NOT EXISTS idx_teams_yahoo_team_id ON teams(yahoo_team_id);