-- Fantasy Sports Database - Seed Data
-- Migration 002: Insert initial reference data for sports, teams, and positions
-- Author: Sports Fantasy Database System
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- SPORTS REFERENCE DATA (Will be populated by migration runner based on SPORT_TYPE)
-- =============================================================================

-- Note: Sport data will be inserted by the Go migration runner
-- based on the SPORT_TYPE environment variable

-- =============================================================================
-- TEAMS DATA (Will be populated by migration runner based on SPORT_TYPE)
-- =============================================================================

-- Note: Team data will be inserted by the Go migration runner
-- based on the SPORT_TYPE environment variable

-- =============================================================================
-- POSITIONS DATA (Will be populated by migration runner based on SPORT_TYPE)
-- =============================================================================

-- Note: Position data will be inserted by the Go migration runner
-- based on the SPORT_TYPE environment variable

-- =============================================================================
-- APPLICATION CONFIGURATION
-- =============================================================================

INSERT INTO app_config (key, value, description) VALUES
('yahoo_api_base_url', 'https://fantasysports.yahooapis.com/fantasy/v2', 'Yahoo Fantasy Sports API base URL'),
('default_page_size', '25', 'Default number of records per page for API calls'),
('max_api_retries', '3', 'Maximum number of retry attempts for failed API calls'),
('api_rate_limit_delay_ms', '500', 'Delay between API calls in milliseconds'),
('sync_batch_size', '100', 'Number of records to process in each batch during sync'),
('enable_stats_tracking', '1', 'Enable automatic stats collection'),
('stats_retention_days', '365', 'Number of days to retain historical stats'),
('cache_timeout_minutes', '60', 'Cache timeout for API responses in minutes'),
('enable_debug_logging', '0', 'Enable debug logging for troubleshooting');

-- =============================================================================
-- INITIAL SYNC LOG ENTRY
-- =============================================================================

INSERT INTO sync_logs (sport_id, operation_type, status, started_at, completed_at, records_processed) VALUES
(NULL, 'schema_migration', 'completed', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0);

COMMIT;

-- Seed data completed successfully
-- Next: Run 003_add_constraints.sql for additional database constraints