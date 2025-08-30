#!/usr/bin/env lua

-- Cross-implementation integration tests
-- Ensures both Zig and Go implementations behave identically

local utils = require("utils")

-- Test configuration
local test_config = {
    zig_port = 17081,
    go_port = 17082,
    test_timeout = 30,
    endpoints_to_test = {
        {path = "/health", method = "GET", description = "Health check"},
        {path = "/api/games", method = "GET", description = "Games list"},
        {path = "/api/auth/tokens", method = "POST", description = "Token authentication",
         body = '{"access_token":"test_token","access_token_secret":"test_secret"}',
         headers = {["Content-Type"] = "application/json"}}
    }
}

-- Test results
local test_results = {
    total_tests = 0,
    passed_tests = 0,
    failed_tests = 0,
    test_details = {}
}

-- Record test result
local function record_test_result(test_name, passed, details)
    test_results.total_tests = test_results.total_tests + 1
    
    if passed then
        test_results.passed_tests = test_results.passed_tests + 1
        utils.success(test_name)
    else
        test_results.failed_tests = test_results.failed_tests + 1
        utils.error(test_name .. (details and (" - " .. details) or ""))
    end
    
    table.insert(test_results.test_details, {
        name = test_name,
        passed = passed,
        details = details or "",
        timestamp = os.time()
    })
end

-- Test API response equivalence
local function test_response_equivalence(endpoint_info)
    local path = endpoint_info.path
    local method = endpoint_info.method
    local description = endpoint_info.description
    
    utils.log("Testing response equivalence: " .. description)
    
    -- Build URLs
    local zig_url = string.format("http://localhost:%d%s", test_config.zig_port, path)
    local go_url = string.format("http://localhost:%d%s", test_config.go_port, path)
    
    -- Make requests
    local zig_response, go_response
    
    if method == "GET" then
        zig_response = utils.http_get(zig_url)
        go_response = utils.http_get(go_url)
    elseif method == "POST" then
        zig_response = utils.http_post(zig_url, endpoint_info.body, endpoint_info.headers)
        go_response = utils.http_post(go_url, endpoint_info.body, endpoint_info.headers)
    end
    
    -- Validate responses
    if not zig_response or not go_response then
        record_test_result("Response equivalence: " .. description, false, "Failed to get responses")
        return false
    end
    
    -- Compare responses using contract validation
    local valid, error_msg = utils.validate_api_contract(path, zig_response, go_response)
    
    record_test_result("Response equivalence: " .. description, valid, error_msg)
    return valid
end

-- Test response time consistency
local function test_response_times()
    utils.log("Testing response time consistency...")
    
    local health_endpoint = "/health"
    local iterations = 50
    
    -- Collect response times
    local zig_times = {}
    local go_times = {}
    
    for i = 1, iterations do
        -- Test Zig implementation
        local zig_start = os.clock()
        utils.http_get(string.format("http://localhost:%d%s", test_config.zig_port, health_endpoint))
        local zig_duration = os.clock() - zig_start
        table.insert(zig_times, zig_duration)
        
        -- Test Go implementation
        local go_start = os.clock()
        utils.http_get(string.format("http://localhost:%d%s", test_config.go_port, health_endpoint))
        local go_duration = os.clock() - go_start
        table.insert(go_times, go_duration)
    end
    
    -- Calculate statistics
    local function calculate_stats(times)
        table.sort(times)
        local total = 0
        for _, time in ipairs(times) do
            total = total + time
        end
        return {
            avg = total / #times,
            min = times[1],
            max = times[#times],
            median = times[math.ceil(#times / 2)]
        }
    end
    
    local zig_stats = calculate_stats(zig_times)
    local go_stats = calculate_stats(go_times)
    
    -- Compare performance (allowing reasonable variance)
    local avg_ratio = go_stats.avg / zig_stats.avg
    local performance_similar = avg_ratio > 0.5 and avg_ratio < 2.0  -- Within 2x of each other
    
    local details = string.format("Zig avg: %.3fs, Go avg: %.3fs, ratio: %.2fx", 
                                  zig_stats.avg, go_stats.avg, avg_ratio)
    
    record_test_result("Response time consistency", performance_similar, details)
    return performance_similar
end

-- Test error handling consistency
local function test_error_handling()
    utils.log("Testing error handling consistency...")
    
    -- Test authentication error (no tokens set)
    local auth_path = "/api/games"  -- Requires auth
    
    local zig_response = utils.http_get(string.format("http://localhost:%d%s", test_config.zig_port, auth_path))
    local go_response = utils.http_get(string.format("http://localhost:%d%s", test_config.go_port, auth_path))
    
    -- Both should return error responses
    if not zig_response or not go_response then
        record_test_result("Error handling consistency", false, "Failed to get error responses")
        return false
    end
    
    -- Check if both contain error indicators
    local zig_has_error = string.find(zig_response:lower(), "error") or string.find(zig_response, "401")
    local go_has_error = string.find(go_response:lower(), "error") or string.find(go_response, "401")
    
    local consistent_errors = zig_has_error and go_has_error
    
    record_test_result("Error handling consistency", consistent_errors, 
                       string.format("Zig error: %s, Go error: %s", 
                                   zig_has_error and "yes" or "no", 
                                   go_has_error and "yes" or "no"))
    
    return consistent_errors
end

-- Test configuration loading
local function test_configuration_loading()
    utils.log("Testing configuration loading...")
    
    -- Both implementations should load the same configuration
    local config_file = "shared/config.json"
    
    if not utils.file_exists(config_file) then
        record_test_result("Configuration loading", false, "Config file missing")
        return false
    end
    
    -- Test that both services respond to health check (indicating they loaded config successfully)
    local zig_health = utils.http_get(string.format("http://localhost:%d/health", test_config.zig_port))
    local go_health = utils.http_get(string.format("http://localhost:%d/health", test_config.go_port))
    
    local both_healthy = zig_health and go_health and 
                         string.find(zig_health, "healthy") and 
                         string.find(go_health, "healthy")
    
    record_test_result("Configuration loading", both_healthy, 
                       both_healthy and "Both services healthy" or "One or both services unhealthy")
    
    return both_healthy
end

-- Generate integration test report
local function generate_integration_report()
    local report_lines = {
        "# Cross-Implementation Integration Test Report",
        "",
        "Generated: " .. os.date(),
        "",
        "## Summary",
        "",
        string.format("- Total Tests: %d", test_results.total_tests),
        string.format("- Passed: %d", test_results.passed_tests),
        string.format("- Failed: %d", test_results.failed_tests),
        string.format("- Success Rate: %.1f%%", 
                     test_results.total_tests > 0 and (test_results.passed_tests / test_results.total_tests) * 100 or 0),
        "",
        "## Test Results",
        ""
    }
    
    for _, test in ipairs(test_results.test_details) do
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
    
    if test_results.failed_tests == 0 then
        table.insert(report_lines, "All integration tests passed! Both implementations are consistent.")
    else
        table.insert(report_lines, "Some tests failed. Review the following:")
        table.insert(report_lines, "- Check API response structures for consistency")
        table.insert(report_lines, "- Verify error handling implementations")
        table.insert(report_lines, "- Ensure both implementations use identical configuration")
    end
    
    local report_content = table.concat(report_lines, "\n")
    local report_file = "integration-test-report.md"
    
    if utils.write_file(report_file, report_content) then
        utils.success("Integration test report generated: " .. report_file)
    else
        utils.warning("Failed to generate integration test report")
    end
end

-- Main integration test function
local function run_integration_tests()
    print()
    print("=================================================")
    print("Cross-Implementation Integration Tests")
    print("=================================================")
    print()
    
    -- Test 1: Configuration loading
    test_configuration_loading()
    
    -- Test 2: Response equivalence for each endpoint
    for _, endpoint in ipairs(test_config.endpoints_to_test) do
        test_response_equivalence(endpoint)
    end
    
    -- Test 3: Response time consistency
    test_response_times()
    
    -- Test 4: Error handling consistency
    test_error_handling()
    
    -- Generate report
    generate_integration_report()
    
    -- Print results
    print()
    print("=================================================")
    print("Integration Test Results")
    print("=================================================")
    print(string.format("Total Tests: %d", test_results.total_tests))
    print(string.format("Passed: %d", test_results.passed_tests))
    print(string.format("Failed: %d", test_results.failed_tests))
    print(string.format("Success Rate: %.1f%%", 
           test_results.total_tests > 0 and (test_results.passed_tests / test_results.total_tests) * 100 or 0))
    
    if test_results.failed_tests == 0 then
        utils.success("All integration tests passed!")
        print()
        return true
    else
        utils.error(string.format("%d integration tests failed!", test_results.failed_tests))
        print()
        return false
    end
end

-- Export for require() or run directly
if arg and arg[0] and arg[0]:match("integration%-tests%.lua$") then
    -- Script executed directly
    os.exit(run_integration_tests() and 0 or 1)
else
    -- Required as module
    return {
        run = run_integration_tests,
        config = test_config,
        results = test_results
    }
end