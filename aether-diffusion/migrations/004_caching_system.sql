-- Fantasy Sports Database - Caching System
-- Migration 004: Add intelligent caching based on API last updated times
-- Author: Sports Fantasy Database System
-- Date: 2025-08-31

BEGIN TRANSACTION;

-- =============================================================================
-- API CACHING TABLES
-- =============================================================================

-- Cache metadata for API responses
CREATE TABLE api_cache (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cache_key TEXT UNIQUE NOT NULL,            -- Unique identifier for cached data
    endpoint_url TEXT NOT NULL,                -- Full API endpoint URL
    sport_id INTEGER,                          -- Related sport (if applicable)
    
    -- Caching metadata
    last_modified TEXT,                        -- Last-Modified header from API
    etag TEXT,                                 -- ETag header from API  
    api_timestamp TEXT,                        -- Yahoo's timestamp from response
    response_size INTEGER DEFAULT 0,           -- Size of cached response in bytes
    
    -- Cache control
    cached_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,                       -- When cache expires
    hit_count INTEGER DEFAULT 0,              -- Number of cache hits
    last_hit_at DATETIME,                     -- Last time cache was used
    
    -- Response data
    response_headers TEXT,                     -- JSON of all response headers
    response_body TEXT,                        -- Compressed/encoded response body
    is_compressed BOOLEAN DEFAULT 0,          -- Is response_body compressed
    
    -- Status
    is_valid BOOLEAN DEFAULT 1,               -- Is cache entry valid
    invalidated_at DATETIME,                   -- When was cache invalidated
    invalidation_reason TEXT,                  -- Why was cache invalidated
    
    FOREIGN KEY (sport_id) REFERENCES sports (id) ON DELETE CASCADE
);

-- Player cache tracking (for individual player data)
CREATE TABLE player_cache_status (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    
    -- Yahoo API metadata
    yahoo_last_modified TEXT,                 -- Yahoo's last modified timestamp
    yahoo_etag TEXT,                          -- Yahoo's ETag for this player
    
    -- Our cache status
    last_fetched_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    cache_expiry DATETIME,
    
    -- Change tracking
    data_hash TEXT,                           -- Hash of player data to detect changes
    stats_hash TEXT,                          -- Hash of player stats to detect changes
    has_changes BOOLEAN DEFAULT 0,           -- Were changes detected in last fetch
    
    -- Fetch metadata
    fetch_count INTEGER DEFAULT 1,           -- How many times we've fetched this player
    last_fetch_duration_ms INTEGER,          -- Duration of last fetch in milliseconds
    
    FOREIGN KEY (player_id) REFERENCES players (id) ON DELETE CASCADE,
    UNIQUE(player_id)
);

-- Team roster cache status
CREATE TABLE team_cache_status (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_id INTEGER NOT NULL,
    
    -- Cache metadata
    roster_last_modified TEXT,                -- Last modified timestamp for roster
    roster_hash TEXT,                         -- Hash of current roster
    last_roster_check DATETIME DEFAULT CURRENT_TIMESTAMP,
    roster_cache_expiry DATETIME,
    
    -- Roster changes
    player_count INTEGER DEFAULT 0,          -- Current active player count
    roster_changes_detected BOOLEAN DEFAULT 0,
    last_roster_change_at DATETIME,
    
    FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
    UNIQUE(team_id)
);

-- =============================================================================
-- SMART CACHING FUNCTIONS (via triggers and views)
-- =============================================================================

-- View to identify stale cache entries that need refresh
CREATE VIEW v_stale_cache AS
SELECT 
    ac.*,
    CASE 
        WHEN ac.expires_at < CURRENT_TIMESTAMP THEN 'expired'
        WHEN ac.cached_at < datetime('now', '-1 day') AND ac.hit_count = 0 THEN 'unused'
        WHEN ac.is_valid = 0 THEN 'invalidated'
        ELSE 'valid'
    END as cache_status,
    (julianday('now') - julianday(ac.cached_at)) * 24 as hours_old
FROM api_cache ac
WHERE cache_status != 'valid'
ORDER BY ac.cached_at ASC;

-- View to identify players needing data refresh
CREATE VIEW v_players_needing_refresh AS
SELECT 
    p.id,
    p.yahoo_player_key,
    p.full_name,
    p.last_sync_at,
    pcs.last_fetched_at,
    pcs.cache_expiry,
    CASE 
        WHEN pcs.cache_expiry IS NULL THEN 'never_cached'
        WHEN pcs.cache_expiry < CURRENT_TIMESTAMP THEN 'expired'
        WHEN p.last_sync_at < datetime('now', '-6 hours') THEN 'stale'
        WHEN pcs.has_changes = 1 THEN 'changes_detected'
        ELSE 'fresh'
    END as refresh_reason,
    (julianday('now') - julianday(COALESCE(pcs.last_fetched_at, p.last_sync_at))) * 24 as hours_since_fetch
FROM players p
LEFT JOIN player_cache_status pcs ON p.id = pcs.player_id
WHERE p.is_active = 1
    AND (pcs.cache_expiry IS NULL 
         OR pcs.cache_expiry < CURRENT_TIMESTAMP
         OR p.last_sync_at < datetime('now', '-6 hours')
         OR pcs.has_changes = 1)
ORDER BY hours_since_fetch DESC;

-- =============================================================================
-- CACHE MANAGEMENT TRIGGERS
-- =============================================================================

-- Automatically update cache status when player data changes
CREATE TRIGGER trg_player_cache_invalidate
    AFTER UPDATE ON players
    FOR EACH ROW
BEGIN
    INSERT OR REPLACE INTO player_cache_status (
        player_id, 
        last_updated_at, 
        has_changes,
        data_hash
    ) VALUES (
        NEW.id, 
        CURRENT_TIMESTAMP, 
        1,
        -- Simple hash based on key fields (SQLite doesn't have built-in hash functions)
        substr(NEW.full_name || NEW.team_id || NEW.uniform_number || NEW.is_active, 1, 32)
    );
END;

-- Update cache hit counter when cache is accessed
CREATE TRIGGER trg_api_cache_hit
    AFTER UPDATE ON api_cache
    FOR EACH ROW
    WHEN NEW.hit_count > OLD.hit_count
BEGIN
    UPDATE api_cache 
    SET last_hit_at = CURRENT_TIMESTAMP 
    WHERE id = NEW.id;
END;

-- =============================================================================
-- INTELLIGENT CACHE CONFIGURATION
-- =============================================================================

-- Cache configuration per data type
CREATE TABLE cache_config (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    data_type TEXT UNIQUE NOT NULL,           -- 'player_list', 'player_detail', 'team_roster', etc.
    ttl_minutes INTEGER NOT NULL,             -- Time to live in minutes
    max_age_minutes INTEGER,                  -- Maximum age before forced refresh
    refresh_threshold_hours INTEGER DEFAULT 6, -- Hours after which to consider refresh
    
    -- Conditional refresh settings
    enable_etag_validation BOOLEAN DEFAULT 1, -- Use ETag for conditional requests
    enable_last_modified BOOLEAN DEFAULT 1,   -- Use Last-Modified headers
    enable_smart_refresh BOOLEAN DEFAULT 1,   -- Enable smart refresh based on change detection
    
    -- Performance settings
    max_cache_size_mb INTEGER DEFAULT 10,     -- Maximum cache size per type
    compression_enabled BOOLEAN DEFAULT 1,    -- Enable response compression
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Insert default cache configurations
INSERT INTO cache_config (data_type, ttl_minutes, max_age_minutes, refresh_threshold_hours) VALUES
('player_list', 60, 360, 6),               -- Player lists: 1hr TTL, 6hr max age
('player_detail', 30, 180, 3),             -- Individual players: 30min TTL, 3hr max age  
('player_stats', 240, 1440, 24),           -- Player stats: 4hr TTL, 24hr max age
('team_roster', 120, 720, 12),             -- Team rosters: 2hr TTL, 12hr max age
('team_info', 1440, 10080, 168),           -- Team info: 24hr TTL, 7 day max age
('league_info', 10080, 43200, 720),        -- League info: 7 day TTL, 30 day max age
('game_info', 10080, 43200, 720);          -- Game info: 7 day TTL, 30 day max age

-- =============================================================================
-- CACHE STATISTICS AND MONITORING
-- =============================================================================

-- Cache performance statistics
CREATE VIEW v_cache_stats AS
SELECT 
    cc.data_type,
    COUNT(ac.id) as cache_entries,
    SUM(ac.hit_count) as total_hits,
    AVG(ac.hit_count) as avg_hits_per_entry,
    SUM(ac.response_size) as total_size_bytes,
    AVG(ac.response_size) as avg_size_bytes,
    MIN(ac.cached_at) as oldest_entry,
    MAX(ac.cached_at) as newest_entry,
    COUNT(CASE WHEN ac.expires_at < CURRENT_TIMESTAMP THEN 1 END) as expired_entries,
    COUNT(CASE WHEN ac.is_valid = 0 THEN 1 END) as invalid_entries
FROM cache_config cc
LEFT JOIN api_cache ac ON ac.cache_key LIKE cc.data_type || '%'
GROUP BY cc.data_type;

-- Player cache effectiveness
CREATE VIEW v_player_cache_effectiveness AS
SELECT 
    s.code as sport,
    COUNT(p.id) as total_players,
    COUNT(pcs.id) as cached_players,
    COUNT(CASE WHEN pcs.cache_expiry > CURRENT_TIMESTAMP THEN 1 END) as fresh_cache,
    COUNT(CASE WHEN pcs.has_changes = 1 THEN 1 END) as players_with_changes,
    AVG(pcs.fetch_count) as avg_fetch_count,
    AVG(pcs.last_fetch_duration_ms) as avg_fetch_duration_ms
FROM players p
JOIN sports s ON p.sport_id = s.id
LEFT JOIN player_cache_status pcs ON p.id = pcs.player_id
WHERE p.is_active = 1
GROUP BY s.code;

-- =============================================================================
-- CACHE CLEANUP AND MAINTENANCE
-- =============================================================================

-- Automatic cache cleanup trigger (removes old unused entries)
CREATE TRIGGER trg_cache_cleanup
    AFTER INSERT ON api_cache
    FOR EACH ROW
    WHEN (SELECT COUNT(*) FROM api_cache) > 1000
BEGIN
    -- Remove oldest unused cache entries
    DELETE FROM api_cache 
    WHERE id IN (
        SELECT id FROM api_cache 
        WHERE hit_count = 0 
            AND cached_at < datetime('now', '-7 days')
        ORDER BY cached_at ASC 
        LIMIT 100
    );
END;

-- =============================================================================
-- INDEXES FOR CACHE PERFORMANCE
-- =============================================================================

CREATE INDEX idx_api_cache_key ON api_cache(cache_key);
CREATE INDEX idx_api_cache_expires ON api_cache(expires_at);
CREATE INDEX idx_api_cache_sport ON api_cache(sport_id);
CREATE INDEX idx_api_cache_valid ON api_cache(is_valid, expires_at);
CREATE INDEX idx_api_cache_cleanup ON api_cache(hit_count, cached_at) WHERE hit_count = 0;

CREATE INDEX idx_player_cache_status_player ON player_cache_status(player_id);
CREATE INDEX idx_player_cache_status_expiry ON player_cache_status(cache_expiry);
CREATE INDEX idx_player_cache_status_changes ON player_cache_status(has_changes) WHERE has_changes = 1;

CREATE INDEX idx_team_cache_status_team ON team_cache_status(team_id);
CREATE INDEX idx_team_cache_status_expiry ON team_cache_status(roster_cache_expiry);

-- =============================================================================
-- CACHE UTILITY FUNCTIONS (as VIEWS since SQLite doesn't support functions)
-- =============================================================================

-- View to generate cache keys consistently
CREATE VIEW v_cache_key_generator AS
SELECT 
    'player_list_' || s.code as player_list_key,
    'team_roster_' || t.abbreviation as team_roster_key,
    'player_detail_' || p.yahoo_player_key as player_detail_key
FROM sports s
CROSS JOIN teams t ON t.sport_id = s.id
CROSS JOIN players p ON p.sport_id = s.id
WHERE s.is_active = 1 AND t.is_active = 1 AND p.is_active = 1;

COMMIT;

-- Caching system migration completed successfully
-- Next: Update application code to use intelligent caching with ETag and Last-Modified headers