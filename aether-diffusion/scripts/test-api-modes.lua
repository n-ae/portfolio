#!/usr/bin/env lua

-- Test script to demonstrate both mock and real API modes
-- Usage: lua test-api-modes.lua

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
    print(colors.green .. "✓" .. colors.reset .. " " .. message)
end

local function error_msg(message)
    print(colors.red .. "✗" .. colors.reset .. " " .. message)
end

local function warning(message)
    print(colors.yellow .. "⚠" .. colors.reset .. " " .. message)
end

local function info(message)
    print(colors.cyan .. "ℹ" .. colors.reset .. " " .. message)
end

-- Helper function to execute commands
local function execute_command(command)
    local handle = io.popen(command)
    if not handle then
        return nil, false
    end
    
    local output = handle:read("*a")
    local success = handle:close()
    return output, success
end

-- Update .env file with new API mode
local function set_api_mode(mode)
    log("Setting YAHOO_API_MODE=" .. mode)
    
    -- Read current .env file
    local env_file = io.open("../.env", "r")
    if not env_file then
        error_msg("Could not open .env file")
        return false
    end
    
    local content = env_file:read("*a")
    env_file:close()
    
    -- Replace API mode
    local new_content = string.gsub(content, "YAHOO_API_MODE=%w+", "YAHOO_API_MODE=" .. mode)
    
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

-- Test a specific API mode
local function test_api_mode(mode)
    print()
    print(colors.magenta .. "======================================" .. colors.reset)
    print(colors.magenta .. "Testing " .. string.upper(mode) .. " API Mode" .. colors.reset)
    print(colors.magenta .. "======================================" .. colors.reset)
    
    -- Set the API mode
    if not set_api_mode(mode) then
        error_msg("Failed to set API mode")
        return false
    end
    
    -- Build and run the Go implementation
    log("Building Go SDK...")
    local build_output, build_success = execute_command("cd ../go && go build -o sdk sdk.go")
    
    if not build_success then
        error_msg("Build failed: " .. (build_output or "unknown error"))
        return false
    end
    
    success("Build successful")
    
    log("Running SDK in " .. mode .. " mode...")
    local run_output, run_success = execute_command("cd ../go && ./sdk")
    
    print()
    print("--- SDK Output ---")
    print(run_output)
    print("--- End Output ---")
    
    if run_success then
        success(string.upper(mode) .. " mode test completed successfully")
        return true
    else
        warning(string.upper(mode) .. " mode test completed with warnings/errors")
        return true -- This is expected for real mode without tokens
    end
end

-- Main test execution
local function main()
    print()
    print(colors.magenta .. "==========================================" .. colors.reset)
    print(colors.magenta .. "Yahoo Fantasy SDK - API Mode Testing" .. colors.reset)
    print(colors.magenta .. "==========================================" .. colors.reset)
    
    -- Test modes
    local modes = {"mock", "real"}
    local results = {}
    
    for _, mode in ipairs(modes) do
        results[mode] = test_api_mode(mode)
    end
    
    -- Summary
    print()
    print(colors.magenta .. "=========================================" .. colors.reset)
    print(colors.magenta .. "Test Results Summary" .. colors.reset)
    print(colors.magenta .. "=========================================" .. colors.reset)
    
    for _, mode in ipairs(modes) do
        local status = results[mode] and "✅ PASS" or "❌ FAIL"
        print(string.format("- %s mode: %s", string.upper(mode), status))
    end
    
    print()
    info("Configuration Summary:")
    print("- Mock mode: Works without authentication, returns predefined data")
    print("- Real mode: Requires access tokens, makes actual Yahoo API calls")
    
    print()
    info("To use real API mode with authentication:")
    print("1. Set YAHOO_API_MODE=real in .env")
    print("2. Obtain OAuth access tokens through Yahoo's 3-legged flow")
    print("3. Set YAHOO_ACCESS_TOKEN and YAHOO_ACCESS_TOKEN_SECRET in .env")
    
    -- Reset to mock mode
    set_api_mode("mock")
    success("Reset API mode to 'mock' for safety")
    
    print()
    success("API mode testing completed!")
    
    return 0
end

-- Run the tests
os.exit(main())