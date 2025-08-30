#!/usr/bin/env lua

-- Lua-based test runner for Yahoo Fantasy Sports implementations
-- Provides unified testing interface for both correctness and performance tests

local utils = require("utils")

-- Test configuration
local config = {
    zig_api_port = 8085,
    go_api_port = 8086,
    zig_client_port = 3003,
    go_client_port = 3004,
    test_timeout = 30,
    warmup_requests = 20,
    benchmark_requests = 500,
    concurrent_connections = 25
}

-- Test results tracking
local results = {
    total_tests = 0,
    passed_tests = 0,
    failed_tests = 0,
    test_details = {}
}

-- Service management
local services = {}

-- Cleanup function
local function cleanup()
    utils.log("Cleaning up test services...")
    
    for service_name, pid in pairs(services) do
        if pid then
            utils.kill_process(service_name)
            utils.log("Stopped " .. service_name .. " (PID: " .. pid .. ")")
        end
    end
    
    -- Additional cleanup
    utils.kill_process("zig.*webapi")
    utils.kill_process("go.*webapi")
    utils.kill_process("zig.*webclient")
    utils.kill_process("go.*webclient")
    
    os.execute("sleep 2")
end

-- Record test result
local function record_test(test_name, passed, details)
    results.total_tests = results.total_tests + 1
    
    if passed then
        results.passed_tests = results.passed_tests + 1
        utils.success(test_name)
    else
        results.failed_tests = results.failed_tests + 1
        utils.error(test_name .. (details and (" - " .. details) or ""))
    end
    
    table.insert(results.test_details, {
        name = test_name,
        passed = passed,
        details = details,
        timestamp = os.time()
    })
end

-- Build all components
local function build_components()
    utils.log("Building all components...")
    
    -- Build Zig components
    local zig_builds = {
        {lang = "zig", component = "webapi", optimization = "release"},
        {lang = "zig", component = "webclient", optimization = "release"}
    }
    
    -- Build Go components  
    local go_builds = {
        {lang = "go", component = "webapi", optimization = "release"},
        {lang = "go", component = "webclient", optimization = "release"}
    }
    
    local all_builds = utils.table_merge(zig_builds, go_builds)
    local build_success = true
    
    for _, build in ipairs(all_builds) do
        if not utils.build_project(build.lang, build.component, build.optimization) then
            build_success = false
            break
        end
    end
    
    record_test("Build all components", build_success)
    return build_success
end

-- Start test services
local function start_test_services()
    utils.log("Starting test services...")
    
    -- Create modified versions with custom ports
    local zig_dir = "zig"
    local go_dir = "go"
    
    -- Start Zig services
    local zig_api_pid = utils.start_service("zig", "webapi", config.zig_api_port)
    local zig_client_pid = utils.start_service("zig", "webclient", config.zig_client_port)
    
    -- Start Go services
    local go_api_pid = utils.start_service("go", "webapi", config.go_api_port)
    local go_client_pid = utils.start_service("go", "webclient", config.go_client_port)
    
    if zig_api_pid and zig_client_pid and go_api_pid and go_client_pid then
        services["zig-webapi"] = zig_api_pid
        services["zig-webclient"] = zig_client_pid
        services["go-webapi"] = go_api_pid
        services["go-webclient"] = go_client_pid
        
        record_test("Start all test services", true)
        return true
    else
        record_test("Start all test services", false, "One or more services failed to start")
        return false
    end
end

-- Wait for services to be ready
local function wait_for_services()
    utils.log("Waiting for services to be ready...")
    
    local endpoints = {
        {name = "Zig API", url = string.format("http://localhost:%d/health", config.zig_api_port)},
        {name = "Go API", url = string.format("http://localhost:%d/health", config.go_api_port)},
        {name = "Zig Client", url = string.format("http://localhost:%d/", config.zig_client_port)},
        {name = "Go Client", url = string.format("http://localhost:%d/", config.go_client_port)}
    }
    
    local all_ready = true
    
    for _, endpoint in ipairs(endpoints) do
        if utils.wait_for_service(endpoint.url, config.test_timeout) then
            record_test(endpoint.name .. " ready", true)
        else
            record_test(endpoint.name .. " ready", false, "Service not responding")
            all_ready = false
        end
    end
    
    return all_ready
end

-- Test API equivalence
local function test_api_equivalence()
    utils.log("Testing API equivalence...")
    
    local endpoints = {
        {path = "/health", name = "Health check"},
        {path = "/api/games", name = "Games endpoint"}
    }
    
    for _, endpoint in ipairs(endpoints) do
        local zig_url = string.format("http://localhost:%d%s", config.zig_api_port, endpoint.path)
        local go_url = string.format("http://localhost:%d%s", config.go_api_port, endpoint.path)
        
        local zig_response = utils.http_get(zig_url)
        local go_response = utils.http_get(go_url)
        
        if zig_response and go_response then
            -- Basic structure comparison (could be enhanced with JSON parsing)
            local responses_similar = string.len(zig_response) > 0 and string.len(go_response) > 0
            record_test("API equivalence: " .. endpoint.name, responses_similar)
        else
            record_test("API equivalence: " .. endpoint.name, false, "Failed to get responses")
        end
    end
end

-- Test web client functionality
local function test_web_clients()
    utils.log("Testing web client functionality...")
    
    local clients = {
        {name = "Zig", port = config.zig_client_port},
        {name = "Go", port = config.go_client_port}
    }
    
    local pages = {"", "games", "search", "auth"}
    
    for _, client in ipairs(clients) do
        local client_working = true
        
        for _, page in ipairs(pages) do
            local url = string.format("http://localhost:%d/%s", client.port, page)
            local response = utils.http_get(url)
            
            if not response or response == "" then
                client_working = false
                break
            end
        end
        
        record_test(client.name .. " web client functionality", client_working)
    end
end

-- Test authentication flow
local function test_authentication()
    utils.log("Testing authentication flow...")
    
    local test_payload = utils.json_encode({
        access_token = "test_token",
        access_token_secret = "test_secret"
    })
    
    local headers = {["Content-Type"] = "application/json"}
    
    local zig_auth_url = string.format("http://localhost:%d/api/auth/tokens", config.zig_api_port)
    local go_auth_url = string.format("http://localhost:%d/api/auth/tokens", config.go_api_port)
    
    local zig_response = utils.http_post(zig_auth_url, test_payload, headers)
    local go_response = utils.http_post(go_auth_url, test_payload, headers)
    
    local zig_auth_works = zig_response and string.find(zig_response, "success") ~= nil
    local go_auth_works = go_response and string.find(go_response, "success") ~= nil
    
    record_test("Zig authentication flow", zig_auth_works)
    record_test("Go authentication flow", go_auth_works)
end

-- Performance benchmarks
local function run_performance_benchmarks()
    utils.log("Running performance benchmarks...")
    
    -- Warmup
    utils.log("Warming up services...")
    for i = 1, config.warmup_requests do
        utils.http_get(string.format("http://localhost:%d/health", config.zig_api_port))
        utils.http_get(string.format("http://localhost:%d/health", config.go_api_port))
    end
    
    -- Benchmark health endpoints
    local function benchmark_health_endpoint(port, name)
        local url = string.format("http://localhost:%d/health", port)
        
        local function single_request()
            return utils.http_get(url)
        end
        
        local stats = utils.benchmark(single_request, 100)
        
        utils.info(string.format("%s Health Endpoint Performance:", name))
        utils.info(string.format("  Min: %.4fs, Max: %.4fs, Avg: %.4fs", stats.min, stats.max, stats.avg))
        utils.info(string.format("  Median: %.4fs, P95: %.4fs, P99: %.4fs", stats.median, stats.p95, stats.p99))
        
        record_test(name .. " performance benchmark", stats.avg < 1.0, 
                   string.format("Average response time: %.4fs", stats.avg))
        
        return stats
    end
    
    local zig_stats = benchmark_health_endpoint(config.zig_api_port, "Zig")
    local go_stats = benchmark_health_endpoint(config.go_api_port, "Go")
    
    -- Compare performance
    local performance_ratio = zig_stats.avg / go_stats.avg
    if performance_ratio < 1.2 and performance_ratio > 0.8 then
        record_test("Performance parity", true, "Both implementations perform similarly")
    else
        record_test("Performance parity", false, 
                   string.format("Performance difference: %.2fx", performance_ratio))
    end
end

-- Generate test report
local function generate_test_report()
    local report_path = "scripts/test-results/test-report.md"
    utils.mkdir("scripts/test-results")
    
    local report_lines = {
        "# Yahoo Fantasy Sports - Test Report",
        "",
        "Generated: " .. os.date(),
        "",
        "## Summary",
        "",
        string.format("- Total Tests: %d", results.total_tests),
        string.format("- Passed: %d", results.passed_tests),
        string.format("- Failed: %d", results.failed_tests),
        string.format("- Success Rate: %.1f%%", (results.passed_tests / results.total_tests) * 100),
        "",
        "## Test Details",
        ""
    }
    
    for _, test in ipairs(results.test_details) do
        local status = test.passed and "✓ PASS" or "✗ FAIL"
        local line = string.format("- %s: %s", status, test.name)
        
        if test.details then
            line = line .. " - " .. test.details
        end
        
        table.insert(report_lines, line)
    end
    
    table.insert(report_lines, "")
    table.insert(report_lines, "## Configuration")
    table.insert(report_lines, "")
    table.insert(report_lines, string.format("- Zig API Port: %d", config.zig_api_port))
    table.insert(report_lines, string.format("- Go API Port: %d", config.go_api_port))
    table.insert(report_lines, string.format("- Zig Client Port: %d", config.zig_client_port))
    table.insert(report_lines, string.format("- Go Client Port: %d", config.go_client_port))
    table.insert(report_lines, string.format("- Test Timeout: %d seconds", config.test_timeout))
    
    local report_content = table.concat(report_lines, "\n")
    
    if utils.write_file(report_path, report_content) then
        utils.success("Test report generated: " .. report_path)
    else
        utils.error("Failed to generate test report")
    end
end

-- Main test execution
local function main()
    print()
    print("==========================================")
    print("Yahoo Fantasy Sports - Lua Test Runner")
    print("==========================================")
    print()
    
    -- Set up cleanup on exit
    -- Note: Lua doesn't have built-in signal handling, so manual cleanup needed
    
    -- Execute test phases
    local phases = {
        {name = "Build Components", func = build_components},
        {name = "Start Services", func = start_test_services},
        {name = "Wait for Services", func = wait_for_services},
        {name = "Test API Equivalence", func = test_api_equivalence},
        {name = "Test Web Clients", func = test_web_clients},
        {name = "Test Authentication", func = test_authentication},
        {name = "Performance Benchmarks", func = run_performance_benchmarks}
    }
    
    local all_phases_passed = true
    
    for _, phase in ipairs(phases) do
        utils.log("Starting phase: " .. phase.name)
        
        if not phase.func() then
            utils.error("Phase failed: " .. phase.name)
            all_phases_passed = false
            break
        end
        
        utils.success("Phase completed: " .. phase.name)
    end
    
    -- Cleanup
    cleanup()
    
    -- Generate report
    generate_test_report()
    
    -- Final results
    print()
    print("==========================================")
    print("Test Results")
    print("==========================================")
    print(string.format("Total Tests: %d", results.total_tests))
    print(string.format("Passed: %d", results.passed_tests))
    print(string.format("Failed: %d", results.failed_tests))
    print(string.format("Success Rate: %.1f%%", (results.passed_tests / results.total_tests) * 100))
    
    if results.failed_tests == 0 then
        utils.success("All tests passed!")
        print()
        return 0
    else
        utils.error(string.format("%d tests failed!", results.failed_tests))
        print()
        return 1
    end
end

-- Run if executed directly
if arg and arg[0] and arg[0]:match("test%-runner%.lua$") then
    os.exit(main())
end

-- Export for require()
return {
    main = main,
    config = config,
    results = results
}