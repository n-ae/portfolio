-- General scripting utilities for Yahoo Fantasy Sports project
-- Lua-based cross-platform utility functions and helpers

local utils = {}

-- ANSI color codes for terminal output
local colors = {
    reset = "\27[0m",
    red = "\27[0;31m",
    green = "\27[0;32m",
    yellow = "\27[1;33m",
    blue = "\27[0;34m",
    purple = "\27[0;35m",
    cyan = "\27[0;36m",
    white = "\27[1;37m"
}

-- Logging functions with colors
function utils.log(message)
    print(colors.blue .. "[" .. os.date("%H:%M:%S") .. "]" .. colors.reset .. " " .. message)
end

function utils.success(message)
    print(colors.green .. "✓" .. colors.reset .. " " .. message)
end

function utils.error(message)
    print(colors.red .. "✗" .. colors.reset .. " " .. message)
end

function utils.warning(message)
    print(colors.yellow .. "⚠" .. colors.reset .. " " .. message)
end

function utils.info(message)
    print(colors.cyan .. "ℹ" .. colors.reset .. " " .. message)
end

-- File system utilities
function utils.file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

function utils.read_file(path)
    local file = io.open(path, "r")
    if not file then
        return nil, "Cannot open file: " .. path
    end
    
    local content = file:read("*a")
    file:close()
    return content
end

function utils.write_file(path, content)
    local file = io.open(path, "w")
    if not file then
        return false, "Cannot create file: " .. path
    end
    
    file:write(content)
    file:close()
    return true
end

function utils.append_file(path, content)
    local file = io.open(path, "a")
    if not file then
        return false, "Cannot open file for append: " .. path
    end
    
    file:write(content)
    file:close()
    return true
end

-- Directory utilities
function utils.mkdir(path)
    local command = string.format('mkdir -p "%s"', path)
    return os.execute(command) == 0
end

function utils.rmdir(path)
    local command = string.format('rm -rf "%s"', path)
    return os.execute(command) == 0
end

-- Process utilities
function utils.execute(command, capture_output)
    if capture_output then
        local handle = io.popen(command)
        if not handle then
            return nil, "Failed to execute command"
        end
        
        local output = handle:read("*a")
        local success = handle:close()
        return output, success
    else
        return os.execute(command) == 0
    end
end

function utils.kill_process(pattern)
    local command = string.format('pkill -f "%s"', pattern)
    return os.execute(command) == 0
end

-- HTTP utilities
function utils.http_get(url)
    local command = string.format('curl -s "%s"', url)
    return utils.execute(command, true)
end

function utils.http_post(url, data, headers)
    local command = string.format('curl -s -X POST -d "%s"', url, data or "")
    
    if headers then
        for header, value in pairs(headers) do
            command = command .. string.format(' -H "%s: %s"', header, value)
        end
    end
    
    command = command .. string.format(' "%s"', url)
    return utils.execute(command, true)
end

function utils.wait_for_service(url, timeout)
    timeout = timeout or 30
    local count = 0
    
    while count < timeout do
        local output = utils.http_get(url)
        if output and output ~= "" then
            return true
        end
        os.execute("sleep 1")
        count = count + 1
    end
    
    return false
end

-- JSON utilities (basic implementation)
function utils.json_encode(obj)
    if type(obj) == "string" then
        return '"' .. obj:gsub('"', '\\"') .. '"'
    elseif type(obj) == "number" then
        return tostring(obj)
    elseif type(obj) == "boolean" then
        return tostring(obj)
    elseif type(obj) == "table" then
        local parts = {}
        local is_array = true
        local max_index = 0
        
        -- Check if it's an array
        for k, v in pairs(obj) do
            if type(k) ~= "number" then
                is_array = false
                break
            end
            max_index = math.max(max_index, k)
        end
        
        if is_array then
            for i = 1, max_index do
                parts[i] = utils.json_encode(obj[i])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            for k, v in pairs(obj) do
                table.insert(parts, utils.json_encode(k) .. ":" .. utils.json_encode(v))
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    else
        return "null"
    end
end

-- String utilities
function utils.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function utils.split(s, delimiter)
    delimiter = delimiter or "%s"
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    
    for match in s:gmatch(pattern) do
        table.insert(result, match)
    end
    
    return result
end

function utils.starts_with(s, prefix)
    return s:sub(1, #prefix) == prefix
end

function utils.ends_with(s, suffix)
    return s:sub(-#suffix) == suffix
end

-- Table utilities
function utils.table_merge(t1, t2)
    local result = {}
    
    for k, v in pairs(t1) do
        result[k] = v
    end
    
    for k, v in pairs(t2) do
        result[k] = v
    end
    
    return result
end

function utils.table_keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

function utils.table_values(t)
    local values = {}
    for _, v in pairs(t) do
        table.insert(values, v)
    end
    return values
end

-- Configuration management
utils.config = {}

function utils.load_config(path)
    local content, err = utils.read_file(path)
    if not content then
        return nil, err
    end
    
    -- Simple key=value config parser
    local config = {}
    for line in content:gmatch("[^\r\n]+") do
        line = utils.trim(line)
        if line ~= "" and not utils.starts_with(line, "#") then
            local key, value = line:match("([^=]+)=(.+)")
            if key and value then
                config[utils.trim(key)] = utils.trim(value)
            end
        end
    end
    
    return config
end

function utils.save_config(path, config)
    local lines = {}
    table.insert(lines, "# Configuration file generated by utils.lua")
    table.insert(lines, "# Generated at: " .. os.date())
    table.insert(lines, "")
    
    for key, value in pairs(config) do
        table.insert(lines, key .. "=" .. tostring(value))
    end
    
    return utils.write_file(path, table.concat(lines, "\n") .. "\n")
end

-- Test utilities
function utils.assert_equals(actual, expected, message)
    if actual == expected then
        utils.success(message or ("Assertion passed: " .. tostring(actual)))
        return true
    else
        utils.error((message or "Assertion failed") .. 
                   string.format(": expected %s, got %s", tostring(expected), tostring(actual)))
        return false
    end
end

function utils.assert_true(condition, message)
    return utils.assert_equals(condition, true, message)
end

function utils.assert_false(condition, message)
    return utils.assert_equals(condition, false, message)
end

-- Performance monitoring
function utils.time_function(func, ...)
    local start_time = os.clock()
    local results = {func(...)}
    local end_time = os.clock()
    local duration = end_time - start_time
    
    return duration, table.unpack(results)
end

function utils.benchmark(func, iterations, ...)
    iterations = iterations or 1000
    local times = {}
    
    utils.log(string.format("Running benchmark with %d iterations...", iterations))
    
    for i = 1, iterations do
        local duration = utils.time_function(func, ...)
        table.insert(times, duration)
    end
    
    -- Calculate statistics
    table.sort(times)
    local total = 0
    for _, time in ipairs(times) do
        total = total + time
    end
    
    local stats = {
        min = times[1],
        max = times[#times],
        avg = total / #times,
        median = times[math.ceil(#times / 2)],
        p95 = times[math.ceil(#times * 0.95)],
        p99 = times[math.ceil(#times * 0.99)]
    }
    
    return stats
end

-- Project-specific utilities
function utils.build_project(language, component, optimization)
    optimization = optimization or "debug"
    
    local commands = {
        zig = {
            sdk = string.format("zig build-exe sdk.zig %s", 
                  optimization == "release" and "-O ReleaseFast" or ""),
            webapi = string.format("zig build-exe webapi.zig %s", 
                     optimization == "release" and "-O ReleaseFast" or ""),
            webclient = string.format("zig build-exe webclient.zig %s", 
                        optimization == "release" and "-O ReleaseFast" or "")
        },
        go = {
            sdk = "go build sdk.go",
            webapi = string.format("go build %s -o webapi webapi.go sdk.go",
                     optimization == "release" and '-ldflags="-s -w"' or ""),
            webclient = string.format("go build %s -o webclient webclient.go",
                        optimization == "release" and '-ldflags="-s -w"' or "")
        }
    }
    
    local command = commands[language] and commands[language][component]
    if not command then
        return false, "Unsupported language/component: " .. language .. "/" .. component
    end
    
    utils.log(string.format("Building %s %s (%s)...", language, component, optimization))
    
    local success = utils.execute(command)
    if success then
        utils.success(string.format("Built %s %s", language, component))
    else
        utils.error(string.format("Failed to build %s %s", language, component))
    end
    
    return success
end

function utils.start_service(language, component, port)
    local executables = {
        zig = {
            sdk = "./sdk",
            webapi = "./webapi",
            webclient = "./webclient"
        },
        go = {
            sdk = "./sdk",
            webapi = "./webapi",
            webclient = "./webclient"
        }
    }
    
    local executable = executables[language] and executables[language][component]
    if not executable then
        return nil, "Unsupported service: " .. language .. "/" .. component
    end
    
    -- Start service in background
    local log_file = string.format("/tmp/%s-%s.log", language, component)
    local command = string.format("cd %s && %s > %s 2>&1 &", language, executable, log_file)
    
    utils.log(string.format("Starting %s %s service...", language, component))
    
    if utils.execute(command) then
        -- Get the PID (simplified approach)
        local pid_output = utils.execute("echo $!", true)
        local pid = pid_output and tonumber(utils.trim(pid_output))
        
        utils.success(string.format("Started %s %s (PID: %s)", language, component, pid or "unknown"))
        return pid
    else
        utils.error(string.format("Failed to start %s %s", language, component))
        return nil
    end
end

-- JSON Schema validation (basic implementation)
function utils.validate_json_schema(json_data, schema_data)
    -- Basic validation - in production would use a proper JSON schema validator
    local json_obj = utils.json_decode(json_data)
    local schema_obj = utils.json_decode(schema_data)
    
    if not json_obj or not schema_obj then
        return false, "Invalid JSON format"
    end
    
    -- Basic type checking
    if schema_obj.type and type(json_obj) ~= schema_obj.type then
        return false, "Type mismatch: expected " .. schema_obj.type .. ", got " .. type(json_obj)
    end
    
    -- Check required fields for objects
    if schema_obj.required and type(json_obj) == "table" then
        for _, field in ipairs(schema_obj.required) do
            if json_obj[field] == nil then
                return false, "Missing required field: " .. field
            end
        end
    end
    
    return true, "Validation passed"
end

-- Basic JSON decoder (simplified implementation)
function utils.json_decode(json_string)
    -- This is a very basic implementation
    -- In production, use a proper JSON library like lua-cjson or dkjson
    local success, result = pcall(function()
        return load("return " .. json_string:gsub("null", "nil"):gsub("true", "true"):gsub("false", "false"))()
    end)
    
    if success then
        return result
    else
        return nil
    end
end

-- Contract validation utilities
function utils.validate_api_contract(endpoint, zig_response, go_response)
    -- Normalize JSON responses for comparison
    local zig_normalized = utils.normalize_json_response(zig_response)
    local go_normalized = utils.normalize_json_response(go_response)
    
    if not zig_normalized or not go_normalized then
        return false, "Invalid JSON in responses"
    end
    
    -- Compare structure
    local match = utils.deep_compare(zig_normalized, go_normalized)
    
    if match then
        return true, "API contracts match"
    else
        return false, "API contracts differ for endpoint: " .. endpoint
    end
end

function utils.normalize_json_response(response_string)
    -- Remove timestamps and other dynamic fields for comparison
    if not response_string or response_string == "" then
        return nil
    end
    
    local normalized = response_string:gsub('"timestamp":%d+', '"timestamp":0')
    return utils.json_decode(normalized)
end

function utils.deep_compare(obj1, obj2)
    if type(obj1) ~= type(obj2) then
        return false
    end
    
    if type(obj1) ~= "table" then
        return obj1 == obj2
    end
    
    -- Compare tables recursively
    for k, v in pairs(obj1) do
        if not utils.deep_compare(v, obj2[k]) then
            return false
        end
    end
    
    for k, v in pairs(obj2) do
        if obj1[k] == nil then
            return false
        end
    end
    
    return true
end

-- Performance monitoring utilities
function utils.run_performance_comparison(zig_port, go_port, endpoints, iterations)
    iterations = iterations or 100
    local results = {
        zig = {},
        go = {},
        comparison = {}
    }
    
    utils.log("Running performance comparison...")
    
    for _, endpoint in ipairs(endpoints) do
        utils.log("Testing endpoint: " .. endpoint)
        
        -- Benchmark Zig implementation
        local zig_url = string.format("http://localhost:%d%s", zig_port, endpoint)
        local zig_stats = utils.benchmark_endpoint(zig_url, iterations)
        results.zig[endpoint] = zig_stats
        
        -- Benchmark Go implementation
        local go_url = string.format("http://localhost:%d%s", go_port, endpoint)
        local go_stats = utils.benchmark_endpoint(go_url, iterations)
        results.go[endpoint] = go_stats
        
        -- Calculate comparison
        local ratio = go_stats.avg / zig_stats.avg
        results.comparison[endpoint] = {
            zig_faster = ratio > 1,
            performance_ratio = ratio,
            difference_ms = math.abs(go_stats.avg - zig_stats.avg) * 1000
        }
        
        utils.info(string.format("%s - Zig: %.3fs, Go: %.3fs, Ratio: %.2fx", 
                   endpoint, zig_stats.avg, go_stats.avg, ratio))
    end
    
    return results
end

function utils.benchmark_endpoint(url, iterations)
    local times = {}
    local success_count = 0
    
    for i = 1, iterations do
        local start_time = os.clock()
        local response = utils.http_get(url)
        local end_time = os.clock()
        
        if response and response ~= "" then
            table.insert(times, end_time - start_time)
            success_count = success_count + 1
        end
    end
    
    if #times == 0 then
        return {avg = 0, min = 0, max = 0, success_rate = 0}
    end
    
    table.sort(times)
    local total = 0
    for _, time in ipairs(times) do
        total = total + time
    end
    
    return {
        avg = total / #times,
        min = times[1],
        max = times[#times],
        median = times[math.ceil(#times / 2)],
        success_rate = success_count / iterations,
        total_requests = iterations
    }
end

-- Documentation generation
function utils.generate_api_documentation(config_path, mock_data_path, output_path)
    local config_content = utils.read_file(config_path)
    local mock_data_content = utils.read_file(mock_data_path)
    
    if not config_content or not mock_data_content then
        return false, "Failed to read input files"
    end
    
    local doc_lines = {
        "# Yahoo Fantasy Sports API Documentation",
        "",
        "Auto-generated from shared configuration and mock data.",
        "",
        "## Configuration",
        "",
        "```json",
        config_content,
        "```",
        "",
        "## API Endpoints",
        "",
        "### Health Check",
        "- **GET** `/health`",
        "- Returns service health status",
        "",
        "### Games",
        "- **GET** `/api/games`",
        "- Returns list of available fantasy games",
        "",
        "### Leagues", 
        "- **GET** `/api/leagues/{game_key}`",
        "- Returns leagues for specified game",
        "",
        "### Teams",
        "- **GET** `/api/teams/{league_key}`", 
        "- Returns teams in specified league",
        "",
        "### Players",
        "- **GET** `/api/players/search?game={game_key}&q={query}`",
        "- Search players by name",
        "",
        "### Roster",
        "- **GET** `/api/roster/{team_key}`",
        "- Returns team roster",
        "",
        "### Authentication",
        "- **POST** `/api/auth/tokens`",
        "- Set OAuth tokens for API access",
        "",
        "## Error Codes",
        ""
    }
    
    -- Add error codes from config
    local config_obj = utils.json_decode(config_content)
    if config_obj and config_obj.error_codes then
        for error_name, error_info in pairs(config_obj.error_codes) do
            table.insert(doc_lines, string.format("- **%s** (%d): %s", 
                         error_name, error_info.code, error_info.message))
        end
    end
    
    table.insert(doc_lines, "")
    table.insert(doc_lines, "## Sample Data Structure")
    table.insert(doc_lines, "")
    table.insert(doc_lines, "```json")
    table.insert(doc_lines, mock_data_content)
    table.insert(doc_lines, "```")
    
    local doc_content = table.concat(doc_lines, "\n")
    
    if utils.write_file(output_path, doc_content) then
        return true, "Documentation generated successfully"
    else
        return false, "Failed to write documentation"
    end
end

-- Export the utils module
return utils