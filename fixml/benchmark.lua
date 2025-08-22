#!/usr/bin/env lua

local function get_file_size(filename)
    local file = io.open(filename, "r")
    if not file then return 0 end
    local size = file:seek("end")
    file:close()
    return size
end

local function get_time()
    local handle = io.popen("date +%s.%N")
    local time_str = handle:read("*a"):match("([%d%.]+)")
    handle:close()
    return tonumber(time_str)
end

local function benchmark_impl(name, command, test_file, iterations)
    local times = {}
    local success_count = 0
    
    for i = 1, iterations do
        -- Clean up previous output
        local output_file = test_file:gsub("%.xml$", ".organized.xml")
        os.remove(output_file)
        
        local start_time = get_time()
        local result = os.execute(command .. " " .. test_file .. " 2>/dev/null")
        local end_time = get_time()
        
        if result == 0 or result == true then
            table.insert(times, (end_time - start_time) * 1000) -- ms
            success_count = success_count + 1
        end
    end
    
    if #times == 0 then
        return nil
    end
    
    -- Calculate statistics
    local sum = 0
    for _, time in ipairs(times) do
        sum = sum + time
    end
    local mean = sum / #times
    
    local min_time = math.min(table.unpack(times))
    local max_time = math.max(table.unpack(times))
    
    -- Calculate standard deviation
    local variance_sum = 0
    for _, time in ipairs(times) do
        variance_sum = variance_sum + (time - mean) ^ 2
    end
    local stddev = #times > 1 and math.sqrt(variance_sum / (#times - 1)) or 0
    
    return {
        mean = mean,
        min = min_time,
        max = max_time,
        stddev = stddev,
        success_rate = (success_count / iterations) * 100
    }
end

local function get_test_files(mode)
    if mode == "quick" then
        return {
            "tests/samples/sample.xml"
        }
    else -- comprehensive
        return {
            "tests/samples/sample.xml",
            "tests/samples/medium-test.xml", 
            "tests/samples/large-test.xml"
        }
    end
end

local function file_exists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function main()
    local mode = arg and arg[1] or "quick"
    
    if mode ~= "quick" and mode ~= "comprehensive" then
        print("Usage: lua benchmark.lua [quick|comprehensive]")
        return 1
    end
    
    local implementations = {
        {"Go", "go/fixml"},
        {"Rust", "rust/fixml"},
        {"Lua", "lua lua/fixml.lua"},
        {"OCaml", "ocaml/fixml"},
        {"Zig", "zig/fixml"}
    }
    
    local test_files = get_test_files(mode)
    local iterations = mode == "quick" and 5 or 10
    
    print("=== FIXML Benchmark (" .. mode .. " mode) ===")
    print("Iterations: " .. iterations .. ", Languages: " .. #implementations)
    print("")
    
    local overall_results = {}
    for _, impl in ipairs(implementations) do
        overall_results[impl[1]] = {}
    end
    
    for _, test_file in ipairs(test_files) do
        if not file_exists(test_file) then
            goto continue
        end
        
        local file_size = get_file_size(test_file) / 1024
        print(string.format("%s (%.1f KB)", test_file, file_size))
        print(string.rep("-", 30))
        
        local file_results = {}
        
        for _, impl in ipairs(implementations) do
            local name, command = impl[1], impl[2]
            io.write(string.format("%-8s... ", name))
            io.flush()
            
            local result = benchmark_impl(name, command, test_file, iterations)
            
            if result then
                print(string.format("%6.1fms", result.mean))
                table.insert(file_results, {name, result.mean})
                table.insert(overall_results[name], result.mean)
            else
                print("FAILED")
            end
        end
        
        -- Show rankings for this file
        if #file_results > 0 then
            table.sort(file_results, function(a, b) return a[2] < b[2] end)
            
            print("\nRankings:")
            for rank, result in ipairs(file_results) do
                local name, time_ms = result[1], result[2]
                local speedup = file_results[1][2] / time_ms
                print(string.format("  %d. %-8s %6.1fms (%4.1fx)", rank, name, time_ms, speedup))
            end
            print("")
        end
        
        ::continue::
    end
    
    -- Overall summary for comprehensive mode
    if mode == "comprehensive" and #test_files > 1 then
        print("=== Overall Performance ===")
        
        local summary = {}
        for name, times in pairs(overall_results) do
            if #times > 0 then
                local sum = 0
                for _, time in ipairs(times) do
                    sum = sum + time
                end
                table.insert(summary, {name, sum / #times})
            end
        end
        
        table.sort(summary, function(a, b) return a[2] < b[2] end)
        
        for rank, result in ipairs(summary) do
            local name, avg_time = result[1], result[2]
            local speedup = summary[1][2] / avg_time
            print(string.format("%d. %-8s %6.1fms avg (%4.1fx)", rank, name, avg_time, speedup))
        end
    end
    
    return 0
end

main()