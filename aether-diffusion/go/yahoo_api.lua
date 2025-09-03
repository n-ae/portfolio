#!/usr/bin/env lua

-- NBA Fantasy Sports Database - Yahoo API Integration (Lua)
-- Handles OAuth token refresh and player data fetching

local json = require("json") or require("cjson") or {}
local http = require("socket.http") or require("http")
local ltn12 = require("ltn12") or {}
local os = os
local io = io
local string = string

-- Configuration
local config = {
    consumer_key = os.getenv("YAHOO_CONSUMER_KEY"),
    consumer_secret = os.getenv("YAHOO_CONSUMER_SECRET"), 
    access_token = os.getenv("YAHOO_ACCESS_TOKEN"),
    refresh_token = os.getenv("YAHOO_REFRESH_TOKEN"),
    nba_game_key = "466",
    api_base = "https://fantasysports.yahooapis.com/fantasy/v2",
    token_url = "https://api.login.yahoo.com/oauth2/get_token"
}

-- Utility functions
local function log(level, message)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local prefix = {
        INFO = "ℹ️",
        SUCCESS = "✅",
        ERROR = "❌", 
        WARNING = "⚠️",
        API = "📡"
    }
    print(string.format("[%s] %s %s", timestamp, prefix[level] or "🔹", message))
end

local function url_encode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w %-%_%.%~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

local function load_env_file(filename)
    local file = io.open(filename or ".env", "r")
    if not file then
        return false
    end
    
    for line in file:lines() do
        local key, value = line:match("^([^=]+)=(.*)$")
        if key and value and not line:match("^#") then
            key = key:gsub("^%s*(.-)%s*$", "%1")
            value = value:gsub("^%s*(.-)%s*$", "%1") 
            os.execute(string.format("export %s='%s'", key, value))
            if key == "YAHOO_CONSUMER_KEY" then config.consumer_key = value end
            if key == "YAHOO_CONSUMER_SECRET" then config.consumer_secret = value end
            if key == "YAHOO_ACCESS_TOKEN" then config.access_token = value end
            if key == "YAHOO_REFRESH_TOKEN" then config.refresh_token = value end
        end
    end
    file:close()
    return true
end

local function http_request(url, method, headers, body)
    method = method or "GET"
    headers = headers or {}
    
    local response_body = {}
    local request_body = body and ltn12.source.string(body) or nil
    
    local result, status_code, response_headers = http.request{
        url = url,
        method = method,
        headers = headers,
        source = request_body,
        sink = ltn12.sink.table(response_body)
    }
    
    local response_text = table.concat(response_body)
    
    if result then
        return true, status_code, response_text, response_headers
    else
        return false, status_code, response_text
    end
end

local function check_credentials()
    log("API", "🔐 Checking Yahoo API credentials")
    
    if not config.consumer_key or config.consumer_key == "" then
        log("ERROR", "YAHOO_CONSUMER_KEY not set")
        return false
    end
    
    if not config.consumer_secret or config.consumer_secret == "" then
        log("ERROR", "YAHOO_CONSUMER_SECRET not set") 
        return false
    end
    
    if not config.access_token or config.access_token == "" then
        log("ERROR", "YAHOO_ACCESS_TOKEN not set")
        return false
    end
    
    log("SUCCESS", string.format("Consumer Key: %s...", 
        config.consumer_key:sub(1, math.min(10, #config.consumer_key))))
    log("SUCCESS", "All credentials found")
    
    return true
end

local function refresh_access_token()
    if not config.refresh_token or config.refresh_token == "" then
        log("ERROR", "No refresh token available")
        return false
    end
    
    log("API", "🔄 Refreshing access token...")
    
    local post_data = string.format(
        "grant_type=refresh_token&refresh_token=%s&client_id=%s&client_secret=%s",
        url_encode(config.refresh_token),
        url_encode(config.consumer_key), 
        url_encode(config.consumer_secret)
    )
    
    local headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Content-Length"] = tostring(#post_data),
        ["User-Agent"] = "NBA-Fantasy-Database/1.0"
    }
    
    local success, status, response = http_request(config.token_url, "POST", headers, post_data)
    
    if not success or status ~= 200 then
        log("ERROR", string.format("Token refresh failed (%s): %s", status or "unknown", response or "no response"))
        return false
    end
    
    -- Parse JSON response
    local token_data
    if json.decode then
        token_data = json.decode(response)
    else
        log("WARNING", "JSON library not available, manual parsing")
        -- Basic manual parsing for access_token
        local access_token = response:match('"access_token"%s*:%s*"([^"]+)"')
        local refresh_token = response:match('"refresh_token"%s*:%s*"([^"]+)"')
        local expires_in = response:match('"expires_in"%s*:%s*(%d+)')
        
        if access_token then
            token_data = {
                access_token = access_token,
                refresh_token = refresh_token,
                expires_in = tonumber(expires_in)
            }
        end
    end
    
    if not token_data or not token_data.access_token then
        log("ERROR", "Failed to parse token response")
        return false
    end
    
    -- Update configuration
    config.access_token = token_data.access_token
    if token_data.refresh_token then
        config.refresh_token = token_data.refresh_token
    end
    
    local expires_in = token_data.expires_in or 3600
    log("SUCCESS", string.format("New access token: %s...", 
        config.access_token:sub(1, math.min(20, #config.access_token))))
    log("SUCCESS", string.format("Token expires in: %d seconds (%d minutes)", 
        expires_in, math.floor(expires_in/60)))
    
    -- Update .env file if it exists
    update_env_file()
    
    return true
end

function update_env_file()
    local env_file = ".env"
    local temp_file = env_file .. ".tmp"
    
    -- Read existing .env file
    local existing_lines = {}
    local file = io.open(env_file, "r")
    if file then
        for line in file:lines() do
            table.insert(existing_lines, line)
        end
        file:close()
    end
    
    -- Write updated .env file
    local temp = io.open(temp_file, "w")
    if not temp then
        log("WARNING", "Could not update .env file")
        return
    end
    
    local updated_access_token = false
    local updated_refresh_token = false
    
    for _, line in ipairs(existing_lines) do
        if line:match("^YAHOO_ACCESS_TOKEN=") then
            temp:write("YAHOO_ACCESS_TOKEN=" .. config.access_token .. "\n")
            updated_access_token = true
        elseif line:match("^YAHOO_REFRESH_TOKEN=") and config.refresh_token then
            temp:write("YAHOO_REFRESH_TOKEN=" .. config.refresh_token .. "\n")
            updated_refresh_token = true
        else
            temp:write(line .. "\n")
        end
    end
    
    -- Add new tokens if they weren't updated
    if not updated_access_token then
        temp:write("YAHOO_ACCESS_TOKEN=" .. config.access_token .. "\n")
    end
    if not updated_refresh_token and config.refresh_token then
        temp:write("YAHOO_REFRESH_TOKEN=" .. config.refresh_token .. "\n")
    end
    
    temp:close()
    
    -- Replace original file
    os.rename(temp_file, env_file)
    log("SUCCESS", ".env file updated with new tokens")
end

local function test_api_connection()
    log("API", "🌐 Testing Yahoo API connection")
    
    local test_url = string.format("%s/game/%s?format=json", config.api_base, config.nba_game_key)
    local headers = {
        ["Authorization"] = "Bearer " .. config.access_token,
        ["User-Agent"] = "NBA-Fantasy-Database/1.0"
    }
    
    local success, status, response = http_request(test_url, "GET", headers)
    
    if not success or status ~= 200 then
        if status == 401 then
            log("WARNING", "Access token expired, attempting refresh...")
            if refresh_access_token() then
                return test_api_connection() -- Retry with new token
            end
        end
        log("ERROR", string.format("API test failed (%s): %s", status or "unknown", response or "no response"))
        return false
    end
    
    log("SUCCESS", "API connection successful!")
    
    -- Try to extract game info
    if response:match('"name"%s*:%s*"Basketball"') then
        log("SUCCESS", "🏀 Connected to NBA Fantasy Sports API")
    end
    
    return true
end

local function fetch_players_sample()
    log("API", "👥 Fetching sample NBA players")
    
    local players_url = string.format("%s/game/%s/players?count=10&start=0&format=json", 
        config.api_base, config.nba_game_key)
    
    local headers = {
        ["Authorization"] = "Bearer " .. config.access_token,
        ["User-Agent"] = "NBA-Fantasy-Database/1.0"
    }
    
    local success, status, response = http_request(players_url, "GET", headers)
    
    if not success or status ~= 200 then
        log("ERROR", string.format("Players fetch failed (%s): %s", status or "unknown", response or "no response"))
        return false
    end
    
    -- Basic player extraction (without full JSON parsing)
    local player_count = 0
    for name in response:gmatch('"full"%s*:%s*"([^"]+)"') do
        if player_count < 5 then
            log("SUCCESS", string.format("Player: %s", name))
        end
        player_count = player_count + 1
    end
    
    log("SUCCESS", string.format("Found %d+ players in sample", player_count))
    return true
end

-- Command functions
local commands = {}

commands.check = function()
    load_env_file()
    return check_credentials()
end

commands.refresh = function()
    load_env_file()
    if not check_credentials() then
        return false
    end
    return refresh_access_token()
end

commands.test = function()
    load_env_file()
    if not check_credentials() then
        return false
    end
    return test_api_connection()
end

commands.sample = function()
    load_env_file()
    if not check_credentials() then
        return false
    end
    if not test_api_connection() then
        return false
    end
    return fetch_players_sample()
end

commands.setup = function()
    print([[
🏀 Yahoo Fantasy Sports API Setup

1. Create Yahoo Developer App:
   - Go to https://developer.yahoo.com/apps/
   - Create app with Fantasy Sports API access
   - Note Consumer Key and Consumer Secret

2. Set Environment Variables in .env file:
   YAHOO_CONSUMER_KEY=your_consumer_key
   YAHOO_CONSUMER_SECRET=your_consumer_secret
   YAHOO_ACCESS_TOKEN=your_access_token
   YAHOO_REFRESH_TOKEN=your_refresh_token

3. Test connection:
   lua yahoo_api.lua test

4. If using Go fallback for full data fetching:
   go run setup_yahoo_api.go
]])
    return true
end

commands.help = function()
    print([[
🏀 Yahoo Fantasy Sports API - Lua Integration

Commands:
  check    - Check API credentials
  refresh  - Refresh access token
  test     - Test API connection
  sample   - Fetch sample players
  setup    - Show setup instructions
  help     - Show this help

Examples:
  lua yahoo_api.lua check
  lua yahoo_api.lua refresh
  lua yahoo_api.lua test
]])
    return true
end

-- Main execution
local function main()
    local command = arg[1] or "help"
    
    log("INFO", "Yahoo Fantasy Sports API - Lua Integration")
    log("INFO", "Command: " .. command)
    
    if commands[command] then
        local success = commands[command]()
        if success ~= false then
            log("SUCCESS", "Command completed")
            os.exit(0)
        else
            log("ERROR", "Command failed")
            
            -- Fallback to Go implementation for complex operations
            if command == "sample" or command == "refresh" then
                log("INFO", "🔄 Falling back to Go implementation...")
                local go_files = {
                    refresh = "refresh_token.go",
                    sample = "setup_yahoo_api.go"
                }
                
                local go_file = go_files[command]
                if go_file then
                    local go_command = "go run " .. go_file
                    os.exit(os.execute(go_command) and 0 or 1)
                end
            end
            
            os.exit(1)
        end
    else
        log("ERROR", "Unknown command: " .. command)
        commands.help()
        os.exit(1)
    end
end

-- Execute if HTTP libraries are available
if http and ltn12 then
    main()
else
    print("❌ Required Lua HTTP libraries not available")
    print("📋 Install with: luarocks install luasocket")
    print("🔄 Falling back to Go implementation...")
    
    local go_files = {
        check = "setup_yahoo_api.go", 
        refresh = "refresh_token.go",
        test = "setup_yahoo_api.go",
        sample = "setup_yahoo_api.go"
    }
    
    local command = arg[1] or "help"
    local go_file = go_files[command]
    
    if go_file then
        os.exit(os.execute("go run " .. go_file) and 0 or 1)
    else
        print("\nAvailable commands: check, refresh, test, sample, setup, help")
        os.exit(1)
    end
end