#!/usr/bin/env lua

-- NBA Fantasy Sports Database - Lua Build System
-- Handles building, testing, and deployment of the Go application

local json = pcall(require, "json") and require("json") or 
             pcall(require, "cjson") and require("cjson") or {}
local os = os
local io = io
local string = string

-- Configuration
local config = {
    app_name = "nba-fantasy-db",
    main_file = "htmx_server.go",
    db_file = "nba.db",
    templates_dir = "templates",
    migrations_dir = "../migrations",
    build_dir = "dist",
    targets = {
        {os = "linux", arch = "amd64"},
        {os = "darwin", arch = "amd64"},
        {os = "darwin", arch = "arm64"},
        {os = "windows", arch = "amd64"}
    }
}

-- Utility functions
local function log(level, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local prefix = {
        INFO = "ℹ️",
        SUCCESS = "✅",
        ERROR = "❌",
        WARNING = "⚠️",
        BUILD = "🔨"
    }
    print(string.format("[%s] %s %s", timestamp, prefix[level] or "🔹", message))
end

local function exec(command, capture_output)
    log("BUILD", "Executing: " .. command)
    if capture_output then
        local handle = io.popen(command)
        local result = handle:read("*a")
        local success = handle:close()
        return success, result
    else
        local result = os.execute(command)
        return result == 0, ""
    end
end

local function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function create_dir(path)
    local success = exec("mkdir -p " .. path, false)
    if success then
        log("SUCCESS", "Created directory: " .. path)
    else
        log("ERROR", "Failed to create directory: " .. path)
    end
    return success
end

local function copy_file(src, dest)
    local success = exec("cp " .. src .. " " .. dest, false)
    if success then
        log("SUCCESS", "Copied: " .. src .. " -> " .. dest)
    else
        log("ERROR", "Failed to copy: " .. src .. " -> " .. dest)
    end
    return success
end

local function copy_dir(src, dest)
    local success = exec("cp -r " .. src .. " " .. dest, false)
    if success then
        log("SUCCESS", "Copied directory: " .. src .. " -> " .. dest)
    else
        log("ERROR", "Failed to copy directory: " .. src .. " -> " .. dest)
    end
    return success
end

-- Build functions
local function check_dependencies()
    log("INFO", "Checking dependencies...")
    
    -- Check Go installation
    local success, version = exec("go version", true)
    if not success then
        log("ERROR", "Go is not installed or not in PATH")
        return false
    end
    log("SUCCESS", "Go found: " .. version:gsub("\n", ""))
    
    -- Check database file
    if not file_exists(config.db_file) then
        log("ERROR", "Database file not found: " .. config.db_file)
        log("INFO", "Run migrations first: lua migrate.lua")
        return false
    end
    log("SUCCESS", "Database file found: " .. config.db_file)
    
    -- Check templates
    if not file_exists(config.templates_dir) then
        log("ERROR", "Templates directory not found: " .. config.templates_dir)
        return false
    end
    log("SUCCESS", "Templates directory found: " .. config.templates_dir)
    
    return true
end

local function run_tests()
    log("INFO", "Running tests...")
    
    -- Check if main file compiles
    local success = exec("go build -o /tmp/test_build " .. config.main_file, false)
    if not success then
        log("ERROR", "Compilation failed")
        return false
    end
    
    -- Clean up test build
    exec("rm -f /tmp/test_build", false)
    log("SUCCESS", "Compilation test passed")
    
    -- Test database connection
    log("INFO", "Testing database connection...")
    local db_test = [[
package main
import (
    "database/sql"
    "fmt"
    _ "github.com/mattn/go-sqlite3"
)
func main() {
    db, err := sql.Open("sqlite3", "]] .. config.db_file .. [[")
    if err != nil { panic(err) }
    var count int
    err = db.QueryRow("SELECT COUNT(*) FROM players").Scan(&count)
    if err != nil { panic(err) }
    fmt.Printf("Players: %d\n", count)
    db.Close()
}
]]
    
    local test_file = "/tmp/db_test.go"
    local file = io.open(test_file, "w")
    file:write(db_test)
    file:close()
    
    local success, output = exec("cd /tmp && go run db_test.go", true)
    if success then
        log("SUCCESS", "Database test passed: " .. output:gsub("\n", ""))
    else
        log("ERROR", "Database test failed")
        return false
    end
    
    exec("rm -f " .. test_file, false)
    return true
end

local function build_binary(target_os, target_arch)
    log("BUILD", string.format("Building for %s/%s", target_os, target_arch))
    
    local binary_name = config.app_name
    if target_os == "windows" then
        binary_name = binary_name .. ".exe"
    end
    
    local build_path = string.format("%s/%s-%s", config.build_dir, target_os, target_arch)
    local binary_path = string.format("%s/%s", build_path, binary_name)
    
    -- Create build directory
    if not create_dir(build_path) then
        return false
    end
    
    -- Set environment variables for cross-compilation
    local env_vars = string.format("GOOS=%s GOARCH=%s CGO_ENABLED=1", target_os, target_arch)
    local build_cmd = string.format("%s go build -ldflags='-w -s' -o %s %s", 
        env_vars, binary_path, config.main_file)
    
    local success = exec(build_cmd, false)
    if not success then
        log("ERROR", string.format("Build failed for %s/%s", target_os, target_arch))
        return false
    end
    
    -- Copy required files
    copy_file(config.db_file, build_path .. "/" .. config.db_file)
    copy_dir(config.templates_dir, build_path .. "/" .. config.templates_dir)
    
    -- Create run script
    local run_script_content
    if target_os == "windows" then
        run_script_content = string.format([[
@echo off
echo Starting NBA Fantasy Sports Database...
./%s
pause
]], binary_name)
        local run_script = io.open(build_path .. "/run.bat", "w")
        run_script:write(run_script_content)
        run_script:close()
    else
        run_script_content = string.format([[
#!/bin/bash
echo "🏀 Starting NBA Fantasy Sports Database..."
echo "📊 Server will be available at http://localhost:8080"
echo "🔗 Press Ctrl+C to stop"
echo ""
./%s
]], binary_name)
        local run_script = io.open(build_path .. "/run.sh", "w")
        run_script:write(run_script_content)
        run_script:close()
        exec("chmod +x " .. build_path .. "/run.sh", false)
    end
    
    -- Create README
    local readme_content = string.format([[
# NBA Fantasy Sports Database - %s/%s

## 🏀 About
Complete NBA Fantasy Sports database with 625+ players sourced from Yahoo Sports API.

## 🚀 Quick Start
%s

## 📊 Features
- ✅ 625 NBA players with Yahoo API integration
- ✅ All 30 NBA teams with conference/division data
- ✅ Position assignments for fantasy sports
- ✅ Modern HTMX-powered web interface
- ✅ CSV export functionality
- ✅ Real-time search and filtering

## 🌐 Usage
1. Run the application using the run script
2. Open your browser to http://localhost:8080
3. Explore players, teams, and export data

## 📁 Files
- %s - Main application binary
- %s - SQLite database with NBA data
- %s/ - HTML templates for web interface
- run%s - Start script

## 🔗 API Endpoints
- GET  /api/players - All NBA players (JSON)
- GET  /api/teams - All NBA teams (JSON)  
- GET  /api/export-csv - Export players (CSV)

Built with Go, SQLite, HTMX, and powered by Yahoo Fantasy Sports API.
]], target_os, target_arch, 
   target_os == "windows" and "run.bat" or "./run.sh",
   binary_name, config.db_file, config.templates_dir,
   target_os == "windows" and ".bat" or ".sh")
    
    local readme = io.open(build_path .. "/README.md", "w")
    readme:write(readme_content)
    readme:close()
    
    log("SUCCESS", string.format("Built %s/%s -> %s", target_os, target_arch, binary_path))
    return true
end

local function create_deployment_package()
    log("INFO", "Creating deployment packages...")
    
    for _, target in ipairs(config.targets) do
        local archive_name = string.format("%s-%s-%s.tar.gz", config.app_name, target.os, target.arch)
        local build_path = string.format("%s/%s-%s", config.build_dir, target.os, target.arch)
        
        if file_exists(build_path) then
            local tar_cmd = string.format("cd %s && tar -czf ../%s .", build_path, archive_name)
            local success = exec(tar_cmd, false)
            if success then
                log("SUCCESS", "Created package: " .. config.build_dir .. "/" .. archive_name)
            else
                log("ERROR", "Failed to create package: " .. archive_name)
            end
        end
    end
end

-- Main commands
local commands = {}

commands.clean = function()
    log("INFO", "Cleaning build directory...")
    exec("rm -rf " .. config.build_dir, false)
    log("SUCCESS", "Build directory cleaned")
end

commands.deps = function()
    log("INFO", "Installing Go dependencies...")
    local success = exec("go mod tidy", false)
    if success then
        log("SUCCESS", "Dependencies updated")
    else
        log("ERROR", "Failed to update dependencies")
        return false
    end
    return check_dependencies()
end

commands.test = function()
    if not check_dependencies() then
        return false
    end
    return run_tests()
end

commands.build = function()
    if not check_dependencies() then
        return false
    end
    
    if not run_tests() then
        log("ERROR", "Tests failed, aborting build")
        return false
    end
    
    -- Clean and create build directory
    commands.clean()
    create_dir(config.build_dir)
    
    -- Build for all targets
    local success_count = 0
    for _, target in ipairs(config.targets) do
        if build_binary(target.os, target.arch) then
            success_count = success_count + 1
        end
    end
    
    log("INFO", string.format("Built %d/%d targets successfully", success_count, #config.targets))
    
    if success_count > 0 then
        create_deployment_package()
        log("SUCCESS", "Build completed!")
        log("INFO", "Deployment packages available in: " .. config.build_dir)
        return true
    else
        log("ERROR", "All builds failed")
        return false
    end
end

commands.dev = function()
    log("INFO", "Starting development server...")
    if not check_dependencies() then
        return false
    end
    
    log("INFO", "🏀 NBA Fantasy Sports Database - Development Mode")
    log("INFO", "📊 Server will start at http://localhost:8080")
    log("INFO", "🔄 Press Ctrl+C to stop")
    
    local success = exec("go run " .. config.main_file, false)
    if not success then
        log("ERROR", "Failed to start development server")
        return false
    end
    return true
end

commands.help = function()
    print([[
🏀 NBA Fantasy Sports Database - Lua Build System

Commands:
  deps    - Install dependencies and check requirements
  test    - Run tests and validation
  build   - Build binaries for all platforms
  clean   - Clean build directory
  dev     - Start development server
  help    - Show this help message

Examples:
  lua build.lua deps     # Install dependencies
  lua build.lua test     # Run tests
  lua build.lua build    # Build all targets
  lua build.lua dev      # Start dev server

Supported platforms:
  - linux/amd64
  - darwin/amd64 (Intel Mac)
  - darwin/arm64 (Apple Silicon)
  - windows/amd64
]])
end

-- Main execution
local function main()
    local command = arg[1] or "help"
    
    log("INFO", "NBA Fantasy Sports Database - Build System")
    log("INFO", "Command: " .. command)
    
    if commands[command] then
        local success = commands[command]()
        if success ~= false then
            log("SUCCESS", "Command completed successfully")
            os.exit(0)
        else
            log("ERROR", "Command failed")
            os.exit(1)
        end
    else
        log("ERROR", "Unknown command: " .. command)
        commands.help()
        os.exit(1)
    end
end

-- Execute main function
main()