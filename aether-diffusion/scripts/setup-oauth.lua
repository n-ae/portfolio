#!/usr/bin/env lua

-- OAuth Setup Script for Yahoo Fantasy API
-- Based on patterns from user's NBA Fantasy project

-- Colors for output
local colors = {
    reset = "\27[0m",
    red = "\27[0;31m",
    green = "\27[0;32m",
    yellow = "\27[1;33m",
    blue = "\27[0;34m",
    cyan = "\27[0;36m",
    magenta = "\27[0;35m"
}

-- Logging functions
local function log(message)
    print(colors.blue .. "[" .. os.date("%H:%M:%S") .. "]" .. colors.reset .. " " .. message)
end

local function success(message)
    print(colors.green .. "✅ " .. colors.reset .. message)
end

local function error_msg(message)
    print(colors.red .. "❌ " .. colors.reset .. message)
end

local function warning(message)
    print(colors.yellow .. "⚠️  " .. colors.reset .. message)
end

local function info(message)
    print(colors.cyan .. "ℹ️  " .. colors.reset .. message)
end

local function step(message)
    print(colors.magenta .. "🔹 " .. colors.reset .. message)
end

-- Helper function to execute commands
local function execute_command(command)
    local handle = io.popen(command)
    if not handle then
        return nil, false
    end
    
    local output = handle:read("*a")
    local success_flag = handle:close()
    return output, success_flag
end

-- Check if command exists
local function command_exists(command)
    local output, success_flag = execute_command("which " .. command .. " >/dev/null 2>&1")
    return success_flag
end

-- Read user input
local function read_input(prompt)
    io.write(prompt .. ": ")
    return io.read()
end

-- Update .env file with ngrok URL
local function update_env_with_ngrok_url(ngrok_url)
    log("Updating .env file with ngrok URL...")
    
    -- Read current .env file
    local env_file = io.open("../.env", "r")
    if not env_file then
        error_msg("Could not open .env file")
        return false
    end
    
    local content = env_file:read("*a")
    env_file:close()
    
    -- Replace OAuth token URL
    local new_content = string.gsub(content, 
        "YAHOO_OAUTH_TOKEN_URL=https://[^%s]*", 
        "YAHOO_OAUTH_TOKEN_URL=" .. ngrok_url .. "/oauth/callback")
    
    -- Write back to file
    env_file = io.open("../.env", "w")
    if not env_file then
        error_msg("Could not write to .env file")
        return false
    end
    
    env_file:write(new_content)
    env_file:close()
    
    return true
end

-- Main setup process
local function main()
    print()
    print(colors.magenta .. "============================================" .. colors.reset)
    print(colors.magenta .. "Yahoo Fantasy API OAuth Setup" .. colors.reset)
    print(colors.magenta .. "Based on NBA Fantasy project patterns" .. colors.reset)
    print(colors.magenta .. "============================================" .. colors.reset)
    print()
    
    -- Step 1: Check prerequisites
    step("Step 1: Checking prerequisites...")
    
    -- Check for Go
    if not command_exists("go") then
        error_msg("Go is not installed. Please install Go first.")
        return 1
    end
    success("Go is installed")
    
    -- Check for ngrok
    if not command_exists("ngrok") then
        error_msg("ngrok is not installed.")
        print("Please install ngrok from: https://ngrok.com/download")
        print("  macOS: brew install ngrok/ngrok/ngrok")
        print("  Or download from: https://ngrok.com/download")
        return 1
    end
    success("ngrok is installed")
    
    print()
    
    -- Step 2: Check environment variables
    step("Step 2: Checking environment configuration...")
    
    local env_file = io.open("../.env", "r")
    if not env_file then
        error_msg(".env file not found")
        return 1
    end
    
    local env_content = env_file:read("*a")
    env_file:close()
    
    local has_consumer_key = string.find(env_content, "YAHOO_CONSUMER_KEY=dj0y") ~= nil
    local has_consumer_secret = string.find(env_content, "YAHOO_CONSUMER_SECRET=%w") ~= nil
    
    if not has_consumer_key then
        error_msg("YAHOO_CONSUMER_KEY is missing or invalid in .env")
        print("Please set your Yahoo consumer key in .env file")
        return 1
    end
    success("Consumer key found")
    
    if not has_consumer_secret then
        error_msg("YAHOO_CONSUMER_SECRET is missing or invalid in .env")
        print("Please set your Yahoo consumer secret in .env file")
        return 1
    end
    success("Consumer secret found")
    
    print()
    
    -- Step 3: Start ngrok
    step("Step 3: Setting up ngrok tunnel...")
    
    info("Starting ngrok in background...")
    info("This will expose localhost:8080 to the internet via HTTPS")
    
    -- Start ngrok in background
    local ngrok_command = "ngrok http 8080 > /dev/null 2>&1 &"
    execute_command(ngrok_command)
    
    -- Wait for ngrok to start
    print("Waiting for ngrok to start...")
    for i = 1, 10 do
        io.write(".")
        os.execute("sleep 1")
        
        -- Check if ngrok API is responding
        local output, success_flag = execute_command("curl -s http://localhost:4040/api/tunnels 2>/dev/null")
        if success_flag and output and string.find(output, "https://") then
            break
        end
        
        if i == 10 then
            error_msg("ngrok failed to start after 10 seconds")
            print("Please start ngrok manually: ngrok http 8080")
            return 1
        end
    end
    print()
    
    -- Get ngrok URL
    local output, success_flag = execute_command("curl -s http://localhost:4040/api/tunnels")
    if not success_flag then
        error_msg("Could not get ngrok tunnel information")
        print("Please check that ngrok is running: ngrok http 8080")
        return 1
    end
    
    -- Extract HTTPS URL (simple pattern matching)
    local ngrok_url = string.match(output, '"public_url":"(https://[^"]*)"')
    if not ngrok_url then
        error_msg("Could not extract ngrok HTTPS URL")
        print("Please check ngrok status at: http://localhost:4040")
        return 1
    end
    
    success("ngrok tunnel created: " .. ngrok_url)
    
    print()
    
    -- Step 4: Update configuration
    step("Step 4: Updating configuration...")
    
    if not update_env_with_ngrok_url(ngrok_url) then
        error_msg("Failed to update .env file")
        return 1
    end
    
    success("Updated .env with ngrok URL")
    
    print()
    
    -- Step 5: Yahoo Developer Configuration
    step("Step 5: Yahoo Developer App Configuration")
    
    print("⚠️  IMPORTANT: Configure your Yahoo Developer App")
    print()
    print("1. Go to: https://developer.yahoo.com/apps")
    print("2. Select your Yahoo Fantasy app")
    print("3. Add this callback URL to 'Redirect URIs':")
    print("   " .. colors.green .. ngrok_url .. "/oauth/callback" .. colors.reset)
    print("4. Save the changes")
    print()
    
    -- Wait for user confirmation
    local confirmation = read_input("Have you added the callback URL to your Yahoo app? (y/N)")
    if string.lower(confirmation) ~= "y" then
        warning("Please complete the Yahoo Developer App configuration first")
        return 1
    end
    
    print()
    
    -- Step 6: Start OAuth server
    step("Step 6: Starting OAuth server...")
    
    -- Update oauth_server.go with the correct callback URL
    log("Updating oauth_server.go with ngrok URL...")
    
    local oauth_file = io.open("../go/oauth_server.go", "r")
    if not oauth_file then
        error_msg("oauth_server.go not found")
        return 1
    end
    
    local oauth_content = oauth_file:read("*a")
    oauth_file:close()
    
    -- Replace callback URL in the Go code
    local updated_content = string.gsub(oauth_content,
        'callbackURL := "https://[^"]*"',
        'callbackURL := "' .. ngrok_url .. '/oauth/callback"')
    
    oauth_file = io.open("../go/oauth_server.go", "w")
    oauth_file:write(updated_content)
    oauth_file:close()
    
    success("Updated oauth_server.go with ngrok URL")
    
    print()
    print(colors.magenta .. "🚀 Ready to start OAuth flow!" .. colors.reset)
    print()
    print("Next steps:")
    print("1. cd ../go")
    print("2. go run oauth_server.go")
    print("3. Follow the authorization URL in your browser")
    print("4. Complete the OAuth flow")
    print()
    print("Your access tokens will be automatically saved to .env")
    print()
    
    success("OAuth setup completed!")
    
    return 0
end

-- Cleanup function
local function cleanup()
    print()
    info("Cleaning up...")
    
    -- Stop ngrok
    execute_command("pkill -f ngrok")
    
    print("Setup script finished")
end

-- Handle script termination
local function signal_handler()
    cleanup()
    os.exit(0)
end

-- Set up signal handling (Unix-like systems)
if package.config:sub(1,1) == '/' then
    -- Unix-like system
    os.execute("trap 'lua -e \"cleanup()\"' INT TERM")
end

-- Run the setup
local exit_code = main()

if exit_code == 0 then
    success("Setup completed successfully!")
    print()
    print("🎯 Next: Run 'cd ../go && go run oauth_server.go' to get access tokens")
else
    error_msg("Setup failed with exit code " .. exit_code)
end

os.exit(exit_code)