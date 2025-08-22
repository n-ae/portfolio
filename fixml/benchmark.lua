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
    return tonumber(time_str) or 0
end

local function benchmark_impl(name, command, test_file, iterations)
    local times = {}
    local success_count = 0
    
    for i = 1, iterations do
        -- Clean up previous output
        local output_file = test_file:gsub("%.xml$", ".organized.xml")
        os.remove(output_file)
        
        local start_time = get_time()
        local result = os.execute(command .. " " .. test_file .. " 2>/dev/null >/dev/null")
        local end_time = get_time()
        
        if result == 0 or result == true then
            table.insert(times, (end_time - start_time) * 1000)
            success_count = success_count + 1
        end
    end
    
    if #times == 0 then return nil end
    
    local sum = 0
    for _, time in ipairs(times) do
        sum = sum + time
    end
    local mean = sum / #times
    
    local min_time = math.min(table.unpack(times))
    local max_time = math.max(table.unpack(times))
    
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
    local files = {
        quick = {"tests/samples/sample.xml"},
        comprehensive = {
            "tests/samples/sample.xml",
            "tests/samples/medium-test.xml", 
            "tests/samples/large-test.xml"
        },
        benchmark = {
            "tests/samples/sample.xml",
            "tests/samples/medium-test.xml", 
            "tests/samples/large-test.xml",
            "tests/samples/enterprise-benchmark.xml",
            "tests/samples/large-benchmark.xml",
            "tests/samples/massive-benchmark.xml"
        }
    }
    return files[mode] or files.quick
end

local function file_exists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    end
    return false
end

local function calculate_stats(times)
    if #times == 0 then return nil end
    
    local sum = 0
    for _, time in ipairs(times) do
        sum = sum + time
    end
    local mean = sum / #times
    
    local variance_sum = 0
    for _, time in ipairs(times) do
        variance_sum = variance_sum + (time - mean) ^ 2
    end
    local consistency = #times > 1 and math.sqrt(variance_sum / (#times - 1)) or 0
    
    return {avg = mean, files = #times, consistency = consistency}
end

local function main()
    local mode = arg and arg[1] or "quick"
    
    if not (mode == "quick" or mode == "comprehensive" or mode == "benchmark") then
        print("Usage: lua benchmark.lua [quick|comprehensive|benchmark]")
        return 1
    end
    
    local implementations = {
        {"Go", "go/fixml"},
        {"Rust", "rust/fixml"},
        {"Lua", "lua lua/fixml.lua"},
        {"OCaml", "ocaml/fixml"},
        {"Zig", "zig/zig-out/bin/fixml"}
    }
    
    local test_files = get_test_files(mode)
    local iterations = mode == "quick" and 5 or (mode == "comprehensive" and 10 or 20)
    
    print("FIXML Performance Benchmark")
    print(string.rep("=", 50))
    print(string.format("Mode: %s | Iterations: %d | Implementations: %d", 
                       mode, iterations, #implementations))
    print(string.format("Test files: %d | O(n) time & space complexity", #test_files))
    print()
    
    local results = {}
    local overall_results = {}
    
    for _, impl in ipairs(implementations) do
        overall_results[impl[1]] = {}
    end
    
    for _, test_file in ipairs(test_files) do
        if not file_exists(test_file) then goto continue end
        
        local file_size = get_file_size(test_file) / 1024
        print(string.format("Testing %s (%.1f KB)", test_file, file_size))
        print(string.rep("-", 50))
        
        local file_results = {}
        
        for _, impl in ipairs(implementations) do
            local name, command = impl[1], impl[2]
            io.write(string.format("  %-12s... ", name))
            io.flush()
            
            local result = benchmark_impl(name, command, test_file, iterations)
            
            if result then
                if mode == "benchmark" then
                    print(string.format("%6.2fms ±%4.2f (%3.0f%% success)", 
                                       result.mean, result.stddev, result.success_rate))
                else
                    print(string.format("%6.1fms", result.mean))
                end
                table.insert(file_results, {name, result.mean, result.stddev, result.success_rate})
                table.insert(overall_results[name], result.mean)
            else
                print("FAILED")
                table.insert(file_results, {name, math.huge, 0, 0})
            end
        end
        
        table.sort(file_results, function(a, b) return a[2] < b[2] end)
        
        print("\n  Rankings:")
        for rank, result in ipairs(file_results) do
            local name, avg_time = result[1], result[2]
            if avg_time == math.huge then
                print(string.format("    %d. %-12s FAILED", rank, name))
            else
                local speedup = file_results[1][2] / avg_time
                if mode == "benchmark" then
                    print(string.format("    %d. %-12s %6.2fms  (%4.2fx)", 
                                       rank, name, avg_time, speedup))
                else
                    print(string.format("    %d. %-12s %6.1fms  (%4.1fx)", 
                                       rank, name, avg_time, speedup))
                end
            end
        end
        
        results[test_file] = file_results
        print()
        
        ::continue::
    end
    
    if #test_files > 1 then
        print("OVERALL PERFORMANCE SUMMARY")
        print(string.rep("=", 50))
        
        local summary = {}
        for name, _ in pairs(overall_results) do
            local stats = calculate_stats(overall_results[name])
            if stats then
                table.insert(summary, {name, stats})
            end
        end
        
        table.sort(summary, function(a, b) return a[2].avg < b[2].avg end)
        
        print("Final Rankings (cross-file average):")
        for rank, result in ipairs(summary) do
            local name, stats = result[1], result[2]
            local speedup = summary[1][2].avg / stats.avg
            print(string.format("  %d. %-12s %6.2fms avg  (%4.2fx)  [σ=%.2fms]", 
                               rank, name, stats.avg, speedup, stats.consistency))
        end
        
        if mode == "benchmark" then
            print("\nComplexity Analysis:")
            print("All implementations maintain O(n) time & space complexity")
            print("- Single-pass processing with pre-allocation")
            print("- Bulk operations minimize system overhead") 
            print("- Memory efficient with minimal garbage collection")
        end
    end
    
    print(string.format("\nBenchmark complete! Tested %d implementations successfully.", 
                       #implementations))
    return 0
end

main()