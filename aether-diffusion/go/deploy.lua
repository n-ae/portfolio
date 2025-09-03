#!/usr/bin/env lua

-- NBA Fantasy Sports Database - Deployment Manager
-- Master script for deployment, testing, and system management

local os = os
local io = io
local string = string

-- Configuration
local config = {
    app_name = "nba-fantasy-db",
    version = "1.0.0",
    lua_scripts = {
        "build.lua",
        "migrate.lua", 
        "yahoo_api.lua",
        "deploy.lua"
    },
    go_files = {
        "htmx_server.go"
    },
    required_files = {
        "nba.db",
        "templates/base.html",
        "templates/dashboard.html", 
        "templates/players.html",
        "templates/teams.html",
        "go.mod",
        "go.sum"
    },
    build_dir = "dist",
    deployment_targets = {
        "linux-amd64",
        "darwin-amd64", 
        "darwin-arm64",
        "windows-amd64"
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
        DEPLOY = "🚀"
    }
    print(string.format("[%s] %s %s", timestamp, prefix[level] or "🔹", message))
end

local function exec(command, capture_output)
    log("DEPLOY", "Executing: " .. command)
    if capture_output then
        local handle = io.popen(command)
        local result = handle:read("*a")
        local success = handle:close()
        return success, result:gsub("\n$", "")
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

local function get_file_size(path)
    local file = io.open(path, "r")
    if not file then return 0 end
    local size = file:seek("end")
    file:close()
    return size
end

-- System checks
local function check_system_requirements()
    log("INFO", "🔍 Checking system requirements...")
    
    local checks = {
        {cmd = "lua -v", name = "Lua"},
        {cmd = "go version", name = "Go"}, 
        {cmd = "sqlite3 --version", name = "SQLite3"},
    }
    
    local all_passed = true
    
    for _, check in ipairs(checks) do
        local success, output = exec(check.cmd, true)
        if success then
            log("SUCCESS", check.name .. " found: " .. output:match("([^\n]+)"))
        else
            log("ERROR", check.name .. " not found or not working")
            all_passed = false
        end
    end
    
    -- Check Lua libraries (optional)
    local lua_libs = {
        {name = "lsqlite3", test = 'lua -e "require(\\"lsqlite3\\")"'},
        {name = "luasocket", test = 'lua -e "require(\\"socket.http\\"); require(\\"ltn12\\")"'},
        {name = "json", test = 'lua -e "require(\\"json\\") or require(\\"cjson\\")"'}
    }
    
    log("INFO", "📚 Checking optional Lua libraries...")
    for _, lib in ipairs(lua_libs) do
        local success = exec(lib.test, false)
        if success then
            log("SUCCESS", lib.name .. " available")
        else
            log("WARNING", lib.name .. " not available (will use fallback)")
        end
    end
    
    return all_passed
end

local function check_project_files()
    log("INFO", "📁 Checking project files...")
    
    local missing_files = {}
    local total_size = 0
    
    -- Check required files
    for _, file in ipairs(config.required_files) do
        if file_exists(file) then
            local size = get_file_size(file)
            total_size = total_size + size
            log("SUCCESS", string.format("%s (%d bytes)", file, size))
        else
            table.insert(missing_files, file)
            log("ERROR", "Missing: " .. file)
        end
    end
    
    -- Check Lua scripts
    for _, script in ipairs(config.lua_scripts) do
        if file_exists(script) then
            local size = get_file_size(script)
            total_size = total_size + size
            log("SUCCESS", string.format("%s (%d bytes)", script, size))
        else
            log("WARNING", "Lua script missing: " .. script)
        end
    end
    
    -- Check Go files
    for _, gofile in ipairs(config.go_files) do
        if file_exists(gofile) then
            local size = get_file_size(gofile)
            total_size = total_size + size
            log("SUCCESS", string.format("%s (%d bytes)", gofile, size))
        else
            log("ERROR", "Go file missing: " .. gofile)
            table.insert(missing_files, gofile)
        end
    end
    
    if #missing_files > 0 then
        log("ERROR", string.format("Missing %d required files", #missing_files))
        return false
    end
    
    log("SUCCESS", string.format("All files present (total: %.1f KB)", total_size / 1024))
    return true
end

-- Deployment functions
local function run_full_build()
    log("DEPLOY", "🔨 Running full build process...")
    
    -- Run migrations
    log("INFO", "Running database migrations...")
    local success = exec("lua migrate.lua migrate", false)
    if not success then
        log("ERROR", "Migration failed")
        return false
    end
    
    -- Run build
    log("INFO", "Building application...")
    success = exec("lua build.lua build", false)
    if not success then
        log("ERROR", "Build failed")
        return false
    end
    
    return true
end

local function create_deployment_archive()
    log("DEPLOY", "📦 Creating deployment archive...")
    
    local archive_name = string.format("%s-v%s-complete.tar.gz", config.app_name, config.version)
    local files_to_archive = {}
    
    -- Add Lua scripts
    for _, script in ipairs(config.lua_scripts) do
        if file_exists(script) then
            table.insert(files_to_archive, script)
        end
    end
    
    -- Add essential files
    table.insert(files_to_archive, "nba.db")
    table.insert(files_to_archive, "templates")
    table.insert(files_to_archive, "go.mod")
    table.insert(files_to_archive, "go.sum")
    table.insert(files_to_archive, "htmx_server.go")
    
    -- Add build directory if it exists
    if file_exists(config.build_dir) then
        table.insert(files_to_archive, config.build_dir)
    end
    
    local tar_command = string.format("tar -czf %s %s", 
        archive_name, table.concat(files_to_archive, " "))
    
    local success = exec(tar_command, false)
    if success then
        local size = get_file_size(archive_name)
        log("SUCCESS", string.format("Created %s (%.1f MB)", archive_name, size / 1024 / 1024))
        return archive_name
    else
        log("ERROR", "Failed to create deployment archive")
        return nil
    end
end

local function test_deployment()
    log("DEPLOY", "🧪 Testing deployment...")
    
    -- Test Lua scripts
    local lua_tests = {
        {script = "migrate.lua", args = "status"},
        {script = "build.lua", args = "deps"},
        {script = "yahoo_api.lua", args = "help"}
    }
    
    for _, test in ipairs(lua_tests) do
        if file_exists(test.script) then
            local cmd = string.format("lua %s %s", test.script, test.args)
            local success = exec(cmd, false)
            if success then
                log("SUCCESS", test.script .. " working")
            else
                log("WARNING", test.script .. " test failed (may need dependencies)")
            end
        end
    end
    
    -- Test Go compilation
    local success = exec("go build -o /tmp/test_binary htmx_server.go", false)
    if success then
        exec("rm -f /tmp/test_binary", false)
        log("SUCCESS", "Go compilation working")
    else
        log("ERROR", "Go compilation failed")
        return false
    end
    
    return true
end

local function show_deployment_summary()
    log("INFO", "📋 Deployment Summary")
    print("\n" .. string.rep("=", 50))
    print("🏀 NBA Fantasy Sports Database - Deployment Status")
    print(string.rep("=", 50))
    
    -- System info
    print("\n📊 System Information:")
    local success, os_info = exec("uname -a", true)
    if success then
        print("   OS: " .. os_info)
    end
    
    local success, lua_version = exec("lua -v", true)
    if success then
        print("   Lua: " .. lua_version)
    end
    
    local success, go_version = exec("go version", true)
    if success then  
        print("   Go: " .. go_version)
    end
    
    -- File status
    print("\n📁 Project Files:")
    for _, file in ipairs(config.required_files) do
        local status = file_exists(file) and "✅" or "❌"
        local size = file_exists(file) and get_file_size(file) or 0
        print(string.format("   %s %s (%d bytes)", status, file, size))
    end
    
    print("\n🔧 Lua Scripts:")
    for _, script in ipairs(config.lua_scripts) do
        local status = file_exists(script) and "✅" or "❌"
        print(string.format("   %s %s", status, script))
    end
    
    -- Build status
    print("\n🏗️ Build Artifacts:")
    if file_exists(config.build_dir) then
        local success, build_info = exec("ls -la " .. config.build_dir, true)
        if success then
            print("   Build directory exists:")
            for line in build_info:gmatch("([^\n]+)") do
                if line:match("%.") and not line:match("^total") then
                    print("   " .. line)
                end
            end
        end
    else
        print("   ❌ No build artifacts (run: lua build.lua build)")
    end
    
    -- Usage instructions
    print("\n🚀 Usage Instructions:")
    print("   Development:  lua deploy.lua dev")
    print("   Build:        lua deploy.lua build")  
    print("   Deploy:       lua deploy.lua deploy")
    print("   Test:         lua deploy.lua test")
    print("   Clean:        lua deploy.lua clean")
    print("\n" .. string.rep("=", 50))
end

-- Command functions
local commands = {}

commands.check = function()
    log("INFO", "🔍 System Check")
    local system_ok = check_system_requirements()
    local files_ok = check_project_files()
    return system_ok and files_ok
end

commands.build = function()
    if not commands.check() then
        log("ERROR", "System check failed")
        return false
    end
    return run_full_build()
end

commands.deploy = function()
    if not commands.build() then
        log("ERROR", "Build failed, cannot deploy")
        return false
    end
    
    local archive = create_deployment_archive()
    if archive then
        log("SUCCESS", "Deployment package ready: " .. archive)
        return true
    else
        return false
    end
end

commands.test = function()
    return test_deployment()
end

commands.clean = function()
    log("INFO", "🧹 Cleaning build artifacts...")
    exec("rm -rf " .. config.build_dir, false)
    exec("rm -f *.tar.gz", false)
    exec("rm -f /tmp/test_binary", false)
    log("SUCCESS", "Clean completed")
    return true
end

commands.dev = function()
    log("INFO", "🔧 Starting development environment...")
    if not commands.check() then
        log("WARNING", "System check failed, continuing anyway...")
    end
    
    log("INFO", "Available development commands:")
    print("   lua migrate.lua migrate    # Run database migrations")
    print("   lua build.lua dev          # Start development server") 
    print("   lua yahoo_api.lua test     # Test Yahoo API connection")
    print("   lua deploy.lua status      # Show system status")
    
    return true
end

commands.status = function()
    show_deployment_summary()
    return true
end

commands.help = function()
    print([[
🏀 NBA Fantasy Sports Database - Deployment Manager

Commands:
  check   - Check system requirements and project files
  build   - Run full build process (migrate + build)
  deploy  - Create deployment package
  test    - Test deployment integrity
  clean   - Clean build artifacts
  dev     - Development environment info
  status  - Show detailed system status
  help    - Show this help

Examples:
  lua deploy.lua check    # Verify system ready
  lua deploy.lua build    # Build all targets
  lua deploy.lua deploy   # Create deployment package
  lua deploy.lua status   # Show detailed status

The system uses Lua scripts for all automation:
  - migrate.lua   # Database migrations
  - build.lua     # Build system  
  - yahoo_api.lua # Yahoo API integration
  - deploy.lua    # This deployment manager
]])
    return true
end

-- Main execution
local function main()
    local command = arg[1] or "status"
    
    log("INFO", string.format("%s v%s - Deployment Manager", config.app_name, config.version))
    log("INFO", "Command: " .. command)
    
    if commands[command] then
        local success = commands[command]()
        if success ~= false then
            log("SUCCESS", "Operation completed successfully")
            os.exit(0)
        else
            log("ERROR", "Operation failed")
            os.exit(1)
        end
    else
        log("ERROR", "Unknown command: " .. command)
        commands.help()
        os.exit(1)
    end
end

-- Execute
main()