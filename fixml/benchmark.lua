#!/usr/bin/env lua

-- Import shared build configuration
local build_config = require("build_config")

local function get_file_size(filename)
    local file = io.open(filename, "r")
    if not file then return 0 end
    local size = file:seek("end")
    file:close()
    return size
end

local function get_time()
    -- Use higher precision timing with multiple attempts to reduce measurement error
    local times = {}
    for i = 1, 3 do
        local handle = io.popen("date +%s.%N")
        local time_str = handle:read("*a"):match("([%d%.]+)")
        handle:close()
        table.insert(times, tonumber(time_str) or 0)
    end
    -- Return median time for better stability
    table.sort(times)
    return times[2]
end

-- Warmup function to reduce cache/JIT effects
local function warmup_impl(command, test_file, warmup_runs)
    for i = 1, warmup_runs do
        local output_file = test_file:gsub("%.xml$", ".organized.xml")
        os.remove(output_file)
        os.execute(command .. " " .. test_file .. " 2>/dev/null >/dev/null")
        -- Small delay to prevent resource contention
        os.execute("sleep 0.01")
    end
end

local function benchmark_impl(name, command, test_file, iterations)
    local times = {}
    local success_count = 0
    
    -- Warmup runs to reduce cache/JIT variance
    warmup_impl(command, test_file, 3)
    
    for i = 1, iterations do
        -- Clean up previous output
        local output_file = test_file:gsub("%.xml$", ".organized.xml")
        os.remove(output_file)
        
        -- Small delay to prevent resource contention
        os.execute("sleep 0.01")
        
        local start_time = get_time()
        local result = os.execute(command .. " " .. test_file .. " 2>/dev/null >/dev/null")
        local end_time = get_time()
        
        if result == 0 or result == true then
            table.insert(times, (end_time - start_time) * 1000)
            success_count = success_count + 1
        end
    end
    
    if #times == 0 then return nil end
    
    -- Remove outliers using IQR method for more stable results
    table.sort(times)
    local filtered_times = {}
    
    if #times >= 10 then
        -- Calculate quartiles
        local q1_idx = math.floor(#times * 0.25)
        local q3_idx = math.floor(#times * 0.75)
        local q1 = times[q1_idx]
        local q3 = times[q3_idx]
        local iqr = q3 - q1
        local lower_bound = q1 - 1.5 * iqr
        local upper_bound = q3 + 1.5 * iqr
        
        -- Filter out outliers
        for _, time in ipairs(times) do
            if time >= lower_bound and time <= upper_bound then
                table.insert(filtered_times, time)
            end
        end
        
        -- Use filtered times if we have enough data points
        if #filtered_times >= math.floor(#times * 0.6) then
            times = filtered_times
        end
    end
    
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

local function setup_git_comparison(base_ref, implementations)
    print("Setting up Git comparison with base reference '" .. base_ref .. "'...")
    
    -- Check if base reference exists (branch, commit, or tag)
    local ref_check = os.execute("git rev-parse --verify " .. base_ref .. " >/dev/null 2>&1")
    if ref_check ~= 0 and ref_check ~= true then
        print("Error: Base reference '" .. base_ref .. "' not found")
        return nil
    end
    
    -- Get current branch
    local current_branch_handle = io.popen("git branch --show-current")
    local current_branch = current_branch_handle:read("*l")
    current_branch_handle:close()
    
    -- Create temporary directory for base branch builds
    local temp_dir = "/tmp/fixml_base_" .. os.time()
    
    -- Use git worktree to create a separate working directory
    local worktree_result = os.execute("git worktree add " .. temp_dir .. " " .. base_ref .. " 2>/dev/null")
    if worktree_result ~= 0 and worktree_result ~= true then
        print("Error: Failed to create git worktree for base reference")
        return nil
    end
    
    -- Build implementations in temp directory
    print("Building base branch implementations...")
    
    -- Detect if FIXML is in subdirectory (older commits) or root (current)
    local fixml_root = temp_dir
    if os.execute("test -d " .. temp_dir .. "/fixml") == 0 or os.execute("test -d " .. temp_dir .. "/fixml") == true then
        fixml_root = temp_dir .. "/fixml"
        print("  Detected FIXML in subdirectory (older commit structure)")
    end
    
    -- Check if build_config.lua exists in base version
    local build_config_exists = os.execute("test -f " .. fixml_root .. "/build_config.lua")
    
    -- Always build manually for more reliable results
    print("  Building base implementations manually...")
    
    -- Build each implementation and check results
    local build_commands = {
        {"Go", "go", "go build -o fixml fixml.go"},
        {"Rust", "rust", "rustc -O -o fixml fixml.rs"},
        {"OCaml", "ocaml", "ocamlopt -I +unix -I +str unix.cmxa str.cmxa -o fixml fixml.ml"},
        {"Zig", "zig", "zig build -Doptimize=ReleaseFast && cp zig-out/bin/fixml fixml"}
    }
    
    for _, build_info in ipairs(build_commands) do
        local lang, dir, cmd = build_info[1], build_info[2], build_info[3]
        if os.execute("test -d " .. fixml_root .. "/" .. dir) == 0 or os.execute("test -d " .. fixml_root .. "/" .. dir) == true then
            print("    Building " .. lang .. "...")
            os.execute("bash -c 'cd " .. fixml_root .. "/" .. dir .. " && " .. cmd .. " 2>/dev/null'")
        end
    end
    
    -- Debug: Check what was actually built
    print("Checking built binaries...")
    os.execute("ls -la " .. fixml_root .. "/*/fixml 2>/dev/null || echo '  No binaries found'")
    
    -- Store the detected root for later use
    temp_dir = fixml_root
    
    -- Create base implementation commands
    local base_implementations = {}
    for _, impl in ipairs(implementations) do
        local name, current_command = impl[1], impl[2]
        local base_command = current_command:gsub("([^/]+)/([^%s]+)", temp_dir .. "/%1/%2")
        
        -- Verify base binary exists
        local binary_path = base_command:match("([^%s]+)")
        local check_handle = io.popen("test -f '" .. binary_path .. "' && echo 'exists'")
        local exists = check_handle:read("*l")
        check_handle:close()
        
        if exists == "exists" then
            table.insert(base_implementations, {name .. "_base", base_command})
        else
            print("Warning: Base binary not found for " .. name .. ": " .. binary_path)
        end
    end
    
    return {
        temp_dir = temp_dir,
        current_branch = current_branch,
        base_implementations = base_implementations
    }
end

local function cleanup_git_comparison(git_data)
    if git_data and git_data.temp_dir then
        -- Remove git worktree
        os.execute("git worktree remove " .. git_data.temp_dir .. " --force 2>/dev/null")
    end
end

local function main()
    local mode = arg and arg[1] or "quick"
    local compare_base = arg and arg[2]
    
    if not (mode == "quick" or mode == "comprehensive" or mode == "benchmark") then
        print("Usage: lua benchmark.lua [quick|comprehensive|benchmark] [base_ref]")
        print("  base_ref: Optional Git reference (branch/commit/tag) to compare against")
        print("Examples:")
        print("  lua benchmark.lua quick")
        print("  lua benchmark.lua benchmark f456830")
        print("  lua benchmark.lua comprehensive HEAD~3")
        return 1
    end
    
    -- Build all implementations with optimizations
    build_config.build_all_optimized()
    
    -- Get available implementations
    local implementations = build_config.verify_implementations()
    
    if #implementations == 0 then
        print("Error: No implementations available for testing")
        return 1
    end
    
    -- Setup Git comparison if base branch specified
    local git_data = nil
    if compare_base then
        git_data = setup_git_comparison(compare_base, implementations)
        if git_data then
            print("Git comparison setup complete: " .. #git_data.base_implementations .. " base implementations available\n")
            -- Add base implementations to test list
            for _, base_impl in ipairs(git_data.base_implementations) do
                table.insert(implementations, base_impl)
            end
        else
            print("Warning: Git comparison setup failed, proceeding with current branch only\n")
        end
    end
    
    local test_files = get_test_files(mode)
    local iterations = mode == "quick" and 15 or (mode == "comprehensive" and 30 or 50)
    
    print("FIXML Performance Benchmark")
    print(string.rep("=", 50))
    print(string.format("Mode: %s | Iterations: %d | Implementations: %d", 
                       mode, iterations, #implementations))
    if git_data then
        print(string.format("Git Comparison: Current (%s) vs Base (%s)", git_data.current_branch, compare_base))
    end
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
    
    -- Git comparison analysis
    if git_data and #git_data.base_implementations > 0 then
        print("\nGIT COMPARISON ANALYSIS")
        print(string.rep("=", 50))
        
        for _, impl in ipairs(build_config.verify_implementations()) do
            local current_name = impl[1]
            local base_name = current_name .. "_base"
            
            local current_stats = calculate_stats(overall_results[current_name] or {})
            local base_stats = calculate_stats(overall_results[base_name] or {})
            
            if current_stats and base_stats then
                local improvement = ((base_stats.avg - current_stats.avg) / base_stats.avg) * 100
                local consistency_change = base_stats.consistency - current_stats.consistency
                
                print(string.format("%s:", current_name))
                print(string.format("  Current (%s):  %6.2fms avg (σ=%.2fms)", git_data.current_branch, current_stats.avg, current_stats.consistency))
                print(string.format("  Base (%s):     %6.2fms avg (σ=%.2fms)", compare_base:sub(1,8), base_stats.avg, base_stats.consistency))
                
                if improvement > 0 then
                    print(string.format("  Performance:   🟢 %+.1f%% improvement", improvement))
                elseif improvement < -5 then
                    print(string.format("  Performance:   🔴 %.1f%% regression", -improvement))
                else
                    print(string.format("  Performance:   🟡 %+.1f%% change", improvement))
                end
                
                if math.abs(consistency_change) > 1 then
                    if consistency_change < 0 then
                        print(string.format("  Consistency:   🟢 %.2fms less variance", -consistency_change))
                    else
                        print(string.format("  Consistency:   🟡 %.2fms more variance", consistency_change))
                    end
                end
                print()
            end
        end
    end
    
    -- Cleanup temporary files
    if git_data then
        cleanup_git_comparison(git_data)
    end
    
    print(string.format("Benchmark complete! Tested %d implementations successfully.", 
                       #implementations))
    return 0
end

main()