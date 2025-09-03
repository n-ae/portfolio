#!/usr/bin/env lua

-- NBA Fantasy Sports Database - Lua Migration System
-- Applies SQL migration scripts and tracks migration history

local sqlite3 = require("lsqlite3") or require("sqlite3")
local os = os
local io = io
local string = string
local table = table

-- Configuration
local config = {
    db_path = "nba.db",
    migrations_dir = "../migrations",
    sport_type = os.getenv("SPORT_TYPE") or "nba"
}

-- Update database path based on sport type
if config.sport_type ~= "nba" then
    config.db_path = config.sport_type .. ".db"
end

-- Utility functions
local function log(level, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local prefix = {
        INFO = "ℹ️",
        SUCCESS = "✅", 
        ERROR = "❌",
        WARNING = "⚠️",
        MIGRATE = "🔄"
    }
    print(string.format("[%s] %s %s", timestamp, prefix[level] or "🔹", message))
end

local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function read_file(path)
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

local function get_migration_files(directory)
    local files = {}
    local handle = io.popen("find " .. directory .. " -name '*.sql' -type f | sort")
    if handle then
        for filename in handle:lines() do
            -- Extract migration number and name from filename
            local basename = filename:match("([^/]+)%.sql$")
            if basename then
                local number_str = basename:match("^(%d+)")
                if number_str then
                    local number = tonumber(number_str)
                    local name = basename:match("^%d+_(.+)$") or basename
                    table.insert(files, {
                        id = number,
                        name = name,
                        filename = filename,
                        basename = basename
                    })
                end
            end
        end
        handle:close()
    end
    
    -- Sort by migration number
    table.sort(files, function(a, b) return a.id < b.id end)
    return files
end

-- Database functions
local function open_database()
    local db = sqlite3.open(config.db_path)
    if not db then
        log("ERROR", "Failed to open database: " .. config.db_path)
        return nil
    end
    
    -- Enable foreign keys
    db:exec("PRAGMA foreign_keys = ON")
    return db
end

local function create_migrations_table(db)
    local sql = [[
        CREATE TABLE IF NOT EXISTS schema_migrations (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            filename TEXT NOT NULL,
            applied_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            checksum TEXT,
            UNIQUE(id)
        )
    ]]
    
    local result = db:exec(sql)
    if result ~= sqlite3.OK then
        log("ERROR", "Failed to create migrations table: " .. db:errmsg())
        return false
    end
    return true
end

local function get_applied_migrations(db)
    local applied = {}
    local stmt = db:prepare("SELECT id, name, filename, applied_at FROM schema_migrations ORDER BY id")
    
    if stmt then
        for row in stmt:nrows() do
            applied[row.id] = {
                id = row.id,
                name = row.name,
                filename = row.filename,
                applied_at = row.applied_at
            }
        end
        stmt:finalize()
    end
    
    return applied
end

local function calculate_checksum(content)
    -- Simple checksum calculation (could use proper hash if available)
    local sum = 0
    for i = 1, #content do
        sum = sum + string.byte(content, i)
    end
    return tostring(sum)
end

local function apply_migration(db, migration)
    log("MIGRATE", "Applying migration " .. migration.id .. ": " .. migration.name)
    
    -- Read migration file
    local content = read_file(migration.filename)
    if not content then
        log("ERROR", "Failed to read migration file: " .. migration.filename)
        return false
    end
    
    -- Calculate checksum
    local checksum = calculate_checksum(content)
    
    -- Begin transaction
    local start_time = os.clock()
    db:exec("BEGIN TRANSACTION")
    
    -- Execute migration SQL
    local result = db:exec(content)
    if result ~= sqlite3.OK then
        db:exec("ROLLBACK")
        log("ERROR", "Failed to execute migration: " .. db:errmsg())
        return false
    end
    
    -- Record migration as applied
    local stmt = db:prepare([[
        INSERT INTO schema_migrations (id, name, filename, checksum) 
        VALUES (?, ?, ?, ?)
    ]])
    
    if stmt then
        stmt:bind_values(migration.id, migration.name, migration.basename, checksum)
        local insert_result = stmt:step()
        stmt:finalize()
        
        if insert_result ~= sqlite3.DONE then
            db:exec("ROLLBACK")
            log("ERROR", "Failed to record migration: " .. db:errmsg())
            return false
        end
    else
        db:exec("ROLLBACK")
        log("ERROR", "Failed to prepare migration record statement")
        return false
    end
    
    -- Commit transaction
    db:exec("COMMIT")
    
    local duration = (os.clock() - start_time) * 1000
    log("SUCCESS", string.format("Migration %d completed in %.3fms", migration.id, duration))
    return true
end

local function run_migrations()
    log("INFO", string.format("🏀 Using %s database: %s", config.sport_type:upper(), config.db_path))
    log("INFO", "🚀 Starting database migrations...")
    
    -- Open database
    local db = open_database()
    if not db then
        return false
    end
    
    -- Create migrations table
    if not create_migrations_table(db) then
        db:close()
        return false
    end
    
    -- Get migration files
    local migration_files = get_migration_files(config.migrations_dir)
    if #migration_files == 0 then
        log("WARNING", "No migration files found in: " .. config.migrations_dir)
        db:close()
        return true
    end
    
    -- Get applied migrations
    local applied_migrations = get_applied_migrations(db)
    
    log("INFO", string.format("📋 Found %d migration files, %d already applied", 
        #migration_files, table.getn and table.getn(applied_migrations) or 0))
    
    -- Apply pending migrations
    local applied_count = 0
    local skipped_count = 0
    
    for _, migration in ipairs(migration_files) do
        if applied_migrations[migration.id] then
            log("INFO", string.format("⏭️  Skipping migration %03d: %s (already applied)", 
                migration.id, migration.name))
            skipped_count = skipped_count + 1
        else
            if apply_migration(db, migration) then
                applied_count = applied_count + 1
            else
                log("ERROR", "Migration failed, stopping")
                db:close()
                return false
            end
        end
    end
    
    db:close()
    
    if applied_count > 0 then
        log("SUCCESS", string.format("🎉 Successfully applied %d migrations", applied_count))
    else
        log("INFO", "✨ All migrations are up to date")
    end
    
    return true
end

local function show_status()
    log("INFO", "📊 Migration Status")
    
    local db = open_database()
    if not db then
        return false
    end
    
    if not create_migrations_table(db) then
        db:close()
        return false
    end
    
    local migration_files = get_migration_files(config.migrations_dir)
    local applied_migrations = get_applied_migrations(db)
    
    print("\n📋 Migration Status:")
    print("==================")
    
    for _, migration in ipairs(migration_files) do
        local status = applied_migrations[migration.id] and "✅ Applied" or "⏳ Pending"
        local applied_at = applied_migrations[migration.id] and 
            (" at " .. applied_migrations[migration.id].applied_at) or ""
        
        print(string.format("%03d: %s - %s%s", 
            migration.id, migration.name, status, applied_at))
    end
    
    print(string.format("\nSummary: %d total, %d applied, %d pending",
        #migration_files,
        table.getn and table.getn(applied_migrations) or 0,
        #migration_files - (table.getn and table.getn(applied_migrations) or 0)))
    
    db:close()
    return true
end

local function reset_database()
    log("WARNING", "🗑️  Resetting database (removing all data)")
    
    local confirm = io.read()
    if confirm ~= "yes" then
        log("INFO", "Reset cancelled")
        return true
    end
    
    -- Remove database file
    os.remove(config.db_path)
    log("SUCCESS", "Database reset completed")
    
    -- Run migrations to recreate
    return run_migrations()
end

local function create_migration(name)
    if not name or name == "" then
        log("ERROR", "Migration name is required")
        return false
    end
    
    -- Get next migration number
    local migration_files = get_migration_files(config.migrations_dir)
    local next_number = 1
    
    for _, migration in ipairs(migration_files) do
        if migration.id >= next_number then
            next_number = migration.id + 1
        end
    end
    
    -- Create migration filename
    local safe_name = name:gsub("[^%w_-]", "_"):lower()
    local filename = string.format("%s/%03d_%s.sql", config.migrations_dir, next_number, safe_name)
    
    -- Create migration template
    local template = string.format([[-- Migration %03d: %s
-- Created: %s

-- Add your SQL statements here
-- Example:
-- CREATE TABLE example (
--     id INTEGER PRIMARY KEY,
--     name TEXT NOT NULL
-- );

]], next_number, name, os.date("%Y-%m-%d %H:%M:%S"))
    
    -- Write migration file
    local file = io.open(filename, "w")
    if not file then
        log("ERROR", "Failed to create migration file: " .. filename)
        return false
    end
    
    file:write(template)
    file:close()
    
    log("SUCCESS", "Created migration: " .. filename)
    return true
end

-- Command functions
local commands = {}

commands.migrate = function()
    return run_migrations()
end

commands.status = function()
    return show_status()
end

commands.reset = function()
    print("⚠️  This will delete all data. Type 'yes' to continue:")
    return reset_database()
end

commands.create = function()
    local name = arg[2]
    if not name then
        print("Usage: lua migrate.lua create <migration_name>")
        return false
    end
    return create_migration(name)
end

commands.help = function()
    print([[
🏀 NBA Fantasy Sports Database - Migration System

Commands:
  migrate   - Run pending migrations
  status    - Show migration status
  reset     - Reset database (WARNING: deletes all data)
  create    - Create new migration file
  help      - Show this help

Environment Variables:
  SPORT_TYPE - Database type (nba, nfl, mlb, nhl) - default: nba

Examples:
  lua migrate.lua migrate
  lua migrate.lua status
  lua migrate.lua create add_player_stats
  SPORT_TYPE=nfl lua migrate.lua migrate
]])
    return true
end

-- Main execution
local function main()
    local command = arg[1] or "migrate"
    
    log("INFO", "Database Migration System")
    log("INFO", "Command: " .. command)
    log("INFO", "Sport: " .. config.sport_type:upper())
    
    if commands[command] then
        local success = commands[command]()
        if success ~= false then
            os.exit(0)
        else
            os.exit(1)
        end
    else
        log("ERROR", "Unknown command: " .. command)
        commands.help()
        os.exit(1)
    end
end

-- Execute if sqlite3 library is available
if sqlite3 then
    main()
else
    print("❌ SQLite3 Lua library not available")
    print("📋 Install with: luarocks install lsqlite3")
    print("🔄 Falling back to Go migration system...")
    
    local command = arg[1] or "migrate"
    local go_command = "go run migrate.go " .. command
    
    if arg[2] then
        go_command = go_command .. " " .. arg[2]
    end
    
    os.exit(os.execute(go_command) and 0 or 1)
end