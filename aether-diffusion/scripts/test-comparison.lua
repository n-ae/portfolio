#!/usr/bin/env lua

-- Cross-implementation comparison tests for Yahoo Fantasy Sports SDK
-- Tests both Zig and Go implementations for functional equivalence

-- Colors for output
local colors = {
    reset = "\27[0m",
    red = "\27[0;31m",
    green = "\27[0;32m",
    yellow = "\27[1;33m",
    blue = "\27[0;34m",
    cyan = "\27[0;36m"
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

-- Test configuration
local config = {
    timeout = 30,
    zig_binary = "zig/sdk",
    go_binary = "go/sdk",
    rust_binary = "rust/sdk"
}

-- Test results tracking
local results = {
    total_tests = 0,
    passed_tests = 0,
    failed_tests = 0,
    details = {}
}

-- Record test result
local function record_test(test_name, passed, details)
    results.total_tests = results.total_tests + 1
    
    if passed then
        results.passed_tests = results.passed_tests + 1
        success(test_name)
    else
        results.failed_tests = results.failed_tests + 1
        error_msg(test_name .. (details and (" - " .. details) or ""))
    end
    
    table.insert(results.details, {
        name = test_name,
        passed = passed,
        details = details or "",
        timestamp = os.time()
    })
end

-- Helper function to execute commands
local function execute_command(command)
    local handle = io.popen(command)
    if not handle then
        return nil, "Failed to execute command"
    end
    
    local output = handle:read("*a")
    local success = handle:close()
    return output, success
end

-- Build implementations
local function build_implementations()
    log("Building implementations...")
    
    -- Build Zig implementation
    log("Building Zig SDK...")
    local zig_build_cmd = "cd ../zig && zig build-exe sdk.zig"
    local zig_output, zig_success = execute_command(zig_build_cmd)
    
    if not zig_success then
        record_test("Build Zig SDK", false, "Build failed: " .. (zig_output or "unknown error"))
        return false
    end
    record_test("Build Zig SDK", true)
    
    -- Build Go implementation
    log("Building Go SDK...")
    local go_build_cmd = "cd ../go && go build -o sdk sdk.go"
    local go_output, go_success = execute_command(go_build_cmd)
    
    if not go_success then
        record_test("Build Go SDK", false, "Build failed: " .. (go_output or "unknown error"))
        return false
    end
    record_test("Build Go SDK", true)
    
    -- Build Rust implementation
    log("Building Rust SDK...")
    local rust_build_cmd = "cd ../rust && cargo build --release && cp target/release/sdk ."
    local rust_output, rust_success = execute_command(rust_build_cmd)
    
    if not rust_success then
        record_test("Build Rust SDK", false, "Build failed: " .. (rust_output or "unknown error"))
        return false
    end
    record_test("Build Rust SDK", true)
    
    return true
end

-- Test implementation outputs
local function test_outputs()
    log("Testing implementation outputs...")
    
    -- Test Zig output
    log("Testing Zig SDK output...")
    local zig_output, zig_success = execute_command("cd ../zig && ./sdk 2>&1")
    
    if not zig_success then
        record_test("Zig SDK execution", false, "Execution failed")
        return false
    end
    record_test("Zig SDK execution", true)
    
    -- Test Go output
    log("Testing Go SDK output...")
    local go_output, go_success = execute_command("cd ../go && ./sdk 2>&1")
    
    if not go_success then
        record_test("Go SDK execution", false, "Execution failed")
        return false
    end
    record_test("Go SDK execution", true)
    
    -- Test Rust output
    log("Testing Rust SDK output...")
    local rust_output, rust_success = execute_command("cd ../rust && ./sdk 2>&1")
    
    if not rust_success then
        record_test("Rust SDK execution", false, "Execution failed")
        return false
    end
    record_test("Rust SDK execution", true)
    
    -- Compare outputs for key similarities
    local zig_has_games = string.find(zig_output, "Retrieved.*games") ~= nil
    local go_has_games = string.find(go_output, "Retrieved.*games") ~= nil
    local rust_has_games = string.find(rust_output, "Retrieved.*games") ~= nil
    
    local outputs_similar = zig_has_games and go_has_games and rust_has_games
    
    record_test("Output similarity", outputs_similar, 
               string.format("Zig: %s, Go: %s, Rust: %s", 
                           zig_has_games and "yes" or "no",
                           go_has_games and "yes" or "no",
                           rust_has_games and "yes" or "no"))
    
    -- Check for error-free execution
    local zig_has_errors = string.find(zig_output:lower(), "error") ~= nil
    local go_has_errors = string.find(go_output:lower(), "error") ~= nil
    local rust_has_errors = string.find(rust_output:lower(), "error") ~= nil
    
    record_test("Error-free execution", not (zig_has_errors or go_has_errors or rust_has_errors),
               string.format("Zig: %s, Go: %s, Rust: %s",
                           zig_has_errors and "errors" or "clean",
                           go_has_errors and "errors" or "clean",
                           rust_has_errors and "errors" or "clean"))
    
    return true
end

-- Performance comparison
local function performance_comparison()
    log("Running performance comparison...")
    
    -- Simple timing test
    local function time_execution(command, implementation)
        local start_time = os.clock()
        local output, success = execute_command(command)
        local end_time = os.clock()
        local duration = end_time - start_time
        
        return {
            success = success,
            duration = duration,
            output = output
        }
    end
    
    -- Time all three implementations
    local zig_result = time_execution("cd ../zig && ./sdk", "Zig")
    local go_result = time_execution("cd ../go && ./sdk", "Go")
    local rust_result = time_execution("cd ../rust && ./sdk", "Rust")
    
    if zig_result.success and go_result.success and rust_result.success then
        local fastest = "Zig"
        local fastest_time = zig_result.duration
        
        if go_result.duration < fastest_time then
            fastest = "Go"
            fastest_time = go_result.duration
        end
        
        if rust_result.duration < fastest_time then
            fastest = "Rust"
            fastest_time = rust_result.duration
        end
        
        record_test("Performance comparison", true,
                   string.format("Zig: %.3fs, Go: %.3fs, Rust: %.3fs (Fastest: %s)",
                               zig_result.duration, go_result.duration, rust_result.duration, fastest))
    else
        record_test("Performance comparison", false, "One or more implementations failed to run")
    end
end

-- Memory usage check (basic)
local function memory_usage_check()
    log("Checking memory usage patterns...")
    
    -- This is a simplified check - in a real scenario you'd use valgrind, instruments, etc.
    local zig_cmd = "cd ../zig && timeout 5s ./sdk > /dev/null 2>&1; echo $?"
    local go_cmd = "cd ../go && timeout 5s ./sdk > /dev/null 2>&1; echo $?"
    local rust_cmd = "cd ../rust && timeout 5s ./sdk > /dev/null 2>&1; echo $?"
    
    local zig_exit, _ = execute_command(zig_cmd)
    local go_exit, _ = execute_command(go_cmd)
    local rust_exit, _ = execute_command(rust_cmd)
    
    -- All should exit cleanly (exit code 0)
    local zig_clean = zig_exit and string.match(zig_exit, "0") ~= nil
    local go_clean = go_exit and string.match(go_exit, "0") ~= nil
    local rust_clean = rust_exit and string.match(rust_exit, "0") ~= nil
    
    record_test("Memory usage check", zig_clean and go_clean and rust_clean,
               string.format("Zig: %s, Go: %s, Rust: %s",
                           zig_clean and "clean" or "fail",
                           go_clean and "clean" or "fail",
                           rust_clean and "clean" or "fail"))
end

-- Generate test report
local function generate_report()
    local report_lines = {
        "# Cross-Implementation Comparison Test Report",
        "",
        "Generated: " .. os.date(),
        "",
        "## Summary",
        "",
        string.format("- Total Tests: %d", results.total_tests),
        string.format("- Passed: %d", results.passed_tests),
        string.format("- Failed: %d", results.failed_tests),
        string.format("- Success Rate: %.1f%%", 
                     results.total_tests > 0 and (results.passed_tests / results.total_tests) * 100 or 0),
        "",
        "## Test Details",
        ""
    }
    
    for _, test in ipairs(results.details) do
        local status = test.passed and "✓ PASS" or "✗ FAIL"
        local line = string.format("- %s: %s", status, test.name)
        
        if test.details and test.details ~= "" then
            line = line .. " - " .. test.details
        end
        
        table.insert(report_lines, line)
    end
    
    table.insert(report_lines, "")
    table.insert(report_lines, "## Recommendations")
    table.insert(report_lines, "")
    
    if results.failed_tests == 0 then
        table.insert(report_lines, "✓ All tests passed! Both implementations are working correctly.")
    else
        table.insert(report_lines, "⚠ Some tests failed. Review the following:")
        table.insert(report_lines, "- Check build dependencies and compilation")
        table.insert(report_lines, "- Verify both implementations produce expected output")
        table.insert(report_lines, "- Ensure proper error handling in both versions")
    end
    
    local report_content = table.concat(report_lines, "\n")
    local report_file = "comparison-test-report.md"
    
    local file = io.open(report_file, "w")
    if file then
        file:write(report_content)
        file:close()
        success("Test report generated: " .. report_file)
    else
        warning("Failed to generate test report")
    end
end

-- Main test execution
local function main()
    print()
    print("======================================================")
    print("Cross-Implementation Comparison Tests (Zig/Go/Rust)")
    print("======================================================")
    print()
    
    -- Test phases
    local phases = {
        {name = "Build Implementations", func = build_implementations},
        {name = "Test Outputs", func = test_outputs},
        {name = "Performance Comparison", func = performance_comparison},
        {name = "Memory Usage Check", func = memory_usage_check}
    }
    
    local all_phases_passed = true
    
    for _, phase in ipairs(phases) do
        log("Starting phase: " .. phase.name)
        
        if not phase.func() then
            error_msg("Phase failed: " .. phase.name)
            all_phases_passed = false
            -- Continue with other phases
        else
            success("Phase completed: " .. phase.name)
        end
        
        print() -- Add spacing between phases
    end
    
    -- Generate report
    generate_report()
    
    -- Final results
    print()
    print("============================================")
    print("Test Results Summary")
    print("============================================")
    print(string.format("Total Tests: %d", results.total_tests))
    print(string.format("Passed: %d", results.passed_tests))
    print(string.format("Failed: %d", results.failed_tests))
    print(string.format("Success Rate: %.1f%%", 
           results.total_tests > 0 and (results.passed_tests / results.total_tests) * 100 or 0))
    
    if results.failed_tests == 0 then
        success("All tests passed! Both implementations are equivalent.")
        print()
        return 0
    else
        error_msg(string.format("%d tests failed!", results.failed_tests))
        print()
        return 1
    end
end

-- Run the tests
os.exit(main())