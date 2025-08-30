#!/usr/bin/env lua

-- Simplified Lua-only build system for Yahoo Fantasy Sports project
-- Single unified build system replacing Make and other build tools

local utils = require("scripts/utils")

-- Build configuration
local config = {
    project_name = "yahoo-fantasy-sports",
    version = "1.0.0",
    
    -- Build modes
    modes = {
        debug = {
            zig_flags = "",
            go_flags = ""
        },
        release = {
            zig_flags = "-O ReleaseFast",
            go_flags = '-ldflags="-s -w"'
        }
    },
    
    -- Component definitions (now using shared config and data)
    components = {
        zig = {
            {name = "sdk", source = "sdk.zig", output = "sdk", deps = {"../shared/errors.zig"}},
            {name = "webapi", source = "webapi.zig", output = "webapi", deps = {"../shared/errors.zig"}},
            {name = "webclient", source = "webclient.zig", output = "webclient", deps = {"../shared/errors.zig"}}
        },
        go = {
            {name = "webapi", sources = {"webapi.go", "sdk.go", "../shared/errors.go"}, output = "webapi"},
            {name = "webclient", sources = {"webclient.go", "../shared/errors.go"}, output = "webclient"}
        }
    },
    
    -- Directories
    dirs = {
        zig = "zig",
        go = "go", 
        scripts = "scripts",
        docs = "docs",
        build = "build",
        dist = "dist"
    }
}

-- Build state tracking
local build_state = {
    started_at = os.time(),
    components_built = {},
    errors = {},
    warnings = {}
}

-- Check for required dependencies
local function check_dependencies()
    utils.log("Checking build dependencies...")
    
    local deps = {
        {name = "zig", command = "zig version"},
        {name = "go", command = "go version"},  
        {name = "lua", command = "lua -v"},
        {name = "curl", command = "curl --version"}
    }
    
    local missing_deps = {}
    
    for _, dep in ipairs(deps) do
        local output, success = utils.execute(dep.command, true)
        if success and output and output ~= "" then
            utils.success(dep.name .. " found: " .. utils.trim(output:match("[^\n]*")))
        else
            table.insert(missing_deps, dep.name)
        end
    end
    
    if #missing_deps > 0 then
        utils.error("Missing dependencies: " .. table.concat(missing_deps, ", "))
        utils.info("Please install missing dependencies and try again")
        return false
    end
    
    utils.success("All dependencies found")
    return true
end

-- Create build directories
local function create_directories()
    utils.log("Creating build directories...")
    
    for dir_name, dir_path in pairs(config.dirs) do
        if not utils.mkdir(dir_path) then
            utils.error("Failed to create directory: " .. dir_path)
            return false
        end
    end
    
    utils.success("Build directories created")
    return true
end

-- Clean build artifacts
local function clean_build()
    utils.log("Cleaning previous build artifacts...")
    
    -- Remove build directories
    utils.rmdir(config.dirs.build)
    utils.rmdir(config.dirs.dist)
    
    -- Remove executables
    local executables = {
        "zig/sdk", "zig/webapi", "zig/webclient",
        "go/webapi", "go/webclient"
    }
    
    for _, exe in ipairs(executables) do
        if utils.file_exists(exe) then
            utils.execute(string.format('rm "%s"', exe))
        end
    end
    
    -- Clean temporary files
    utils.execute("rm -f /tmp/zig-*.log /tmp/go-*.log")
    
    utils.success("Build artifacts cleaned")
    return true
end

-- Build Zig components
local function build_zig_components(mode)
    utils.log("Building Zig components (" .. mode .. " mode)...")
    
    local flags = config.modes[mode].zig_flags
    local success_count = 0
    
    for _, component in ipairs(config.components.zig) do
        utils.log("Building Zig " .. component.name .. "...")
        
        local command = string.format("cd %s && zig build-exe %s %s", 
                                     config.dirs.zig, component.source, flags)
        
        local build_success = utils.execute(command)
        
        if build_success then
            utils.success("Built Zig " .. component.name)
            table.insert(build_state.components_built, "zig/" .. component.name)
            success_count = success_count + 1
        else
            local error_msg = "Failed to build Zig " .. component.name
            utils.error(error_msg)
            table.insert(build_state.errors, error_msg)
        end
    end
    
    local total_components = #config.components.zig
    utils.log(string.format("Zig build completed: %d/%d successful", success_count, total_components))
    
    return success_count == total_components
end

-- Build Go components
local function build_go_components(mode)
    utils.log("Building Go components (" .. mode .. " mode)...")
    
    local flags = config.modes[mode].go_flags
    local success_count = 0
    
    for _, component in ipairs(config.components.go) do
        utils.log("Building Go " .. component.name .. "...")
        
        local sources = table.concat(component.sources, " ")
        local command = string.format("cd %s && go build %s -o %s %s",
                                     config.dirs.go, flags, component.output, sources)
        
        local build_success = utils.execute(command)
        
        if build_success then
            utils.success("Built Go " .. component.name)
            table.insert(build_state.components_built, "go/" .. component.name)
            success_count = success_count + 1
        else
            local error_msg = "Failed to build Go " .. component.name
            utils.error(error_msg)
            table.insert(build_state.errors, error_msg)
        end
    end
    
    local total_components = #config.components.go
    utils.log(string.format("Go build completed: %d/%d successful", success_count, total_components))
    
    return success_count == total_components
end

-- Run tests
local function run_tests()
    utils.log("Running test suite...")
    
    -- Check if test runner exists
    local test_runner = config.dirs.scripts .. "/test-runner.lua"
    
    if not utils.file_exists(test_runner) then
        utils.warning("Test runner not found, skipping tests")
        return true
    end
    
    local command = string.format("cd %s && lua test-runner.lua", config.dirs.scripts)
    local test_success = utils.execute(command)
    
    if test_success then
        utils.success("All tests passed")
        return true
    else
        utils.error("Some tests failed")
        return false
    end
end

-- Generate build report
local function generate_build_report()
    utils.log("Generating build report...")
    
    local report_lines = {
        "# " .. config.project_name .. " - Build Report",
        "",
        "Generated: " .. os.date(),
        "Build mode: " .. (build_mode or "debug"),
        "Build duration: " .. (os.time() - build_state.started_at) .. " seconds",
        "",
        "## Components Built",
        ""
    }
    
    if #build_state.components_built > 0 then
        for _, component in ipairs(build_state.components_built) do
            table.insert(report_lines, "- ✓ " .. component)
        end
    else
        table.insert(report_lines, "- No components built successfully")
    end
    
    table.insert(report_lines, "")
    table.insert(report_lines, "## Build Status")
    table.insert(report_lines, "")
    table.insert(report_lines, "- Total components: " .. (#config.components.zig + #config.components.go))
    table.insert(report_lines, "- Successfully built: " .. #build_state.components_built)
    table.insert(report_lines, "- Build errors: " .. #build_state.errors)
    table.insert(report_lines, "- Build warnings: " .. #build_state.warnings)
    
    if #build_state.errors > 0 then
        table.insert(report_lines, "")
        table.insert(report_lines, "## Errors")
        table.insert(report_lines, "")
        for _, error in ipairs(build_state.errors) do
            table.insert(report_lines, "- " .. error)
        end
    end
    
    if #build_state.warnings > 0 then
        table.insert(report_lines, "")
        table.insert(report_lines, "## Warnings")
        table.insert(report_lines, "")
        for _, warning in ipairs(build_state.warnings) do
            table.insert(report_lines, "- " .. warning)
        end
    end
    
    local report_content = table.concat(report_lines, "\n")
    local report_path = "build-report.md"
    
    if utils.write_file(report_path, report_content) then
        utils.success("Build report generated: " .. report_path)
    else
        utils.error("Failed to generate build report")
    end
end

-- Build command handlers
local commands = {}

-- Build all components
function commands.build(mode)
    mode = mode or "debug"
    build_mode = mode
    
    utils.log("Starting build process...")
    utils.info("Project: " .. config.project_name .. " v" .. config.version)
    utils.info("Build mode: " .. mode)
    
    if not check_dependencies() then
        return false
    end
    
    if not create_directories() then
        return false
    end
    
    local zig_success = build_zig_components(mode)
    local go_success = build_go_components(mode) 
    
    generate_build_report()
    
    if zig_success and go_success then
        utils.success("Build completed successfully!")
        return true
    else
        utils.error("Build failed!")
        return false
    end
end

-- Clean build
function commands.clean()
    return clean_build()
end

-- Run tests
function commands.test()
    if not utils.file_exists("zig/webapi") or not utils.file_exists("go/webapi") then
        utils.warning("Components not built, building first...")
        if not commands.build("debug") then
            return false
        end
    end
    
    return run_tests()
end

-- Validate shared config and data files with schema validation
function commands.validate()
    utils.log("Validating shared configuration and data...")
    
    local config_file = "shared/config.json"
    local config_schema_file = "shared/config-schema.json"
    local data_file = "shared/mock-data.json"
    local data_schema_file = "shared/mock-data-schema.json"
    
    -- Check file existence
    local files_to_check = {
        {config_file, "Configuration file"},
        {config_schema_file, "Configuration schema"},
        {data_file, "Mock data file"},
        {data_schema_file, "Mock data schema"}
    }
    
    for _, file_info in ipairs(files_to_check) do
        local file_path, description = file_info[1], file_info[2]
        if not utils.file_exists(file_path) then
            utils.error(description .. " missing: " .. file_path)
            return false
        end
    end
    
    -- Read files
    local config_content = utils.read_file(config_file)
    local config_schema_content = utils.read_file(config_schema_file)
    local data_content = utils.read_file(data_file)
    local data_schema_content = utils.read_file(data_schema_file)
    
    if not config_content or not config_schema_content or not data_content or not data_schema_content then
        utils.error("Failed to read shared files")
        return false
    end
    
    -- Validate configuration against schema
    local config_valid, config_error = utils.validate_json_schema(config_content, config_schema_content)
    if not config_valid then
        utils.error("Configuration validation failed: " .. config_error)
        return false
    end
    utils.success("Configuration schema validation passed")
    
    -- Validate mock data against schema
    local data_valid, data_error = utils.validate_json_schema(data_content, data_schema_content)
    if not data_valid then
        utils.error("Mock data validation failed: " .. data_error)
        return false
    end
    utils.success("Mock data schema validation passed")
    
    utils.success("All shared files validated successfully")
    return true
end

-- Validate API contracts between implementations
function commands.validate_contracts()
    utils.log("Validating API contracts between implementations...")
    
    -- Start both implementations on different ports for testing
    local zig_port = 18081
    local go_port = 18082
    
    utils.log("Starting services for contract validation...")
    
    -- Build first if not already built
    if not utils.file_exists("zig/webapi") or not utils.file_exists("go/webapi") then
        utils.warning("Services not built, building first...")
        if not commands.build("debug") then
            return false
        end
    end
    
    -- Start services (simplified - in production would use proper process management)
    local zig_start_cmd = string.format("cd zig && ./webapi > /tmp/zig-contract-test.log 2>&1 &")
    local go_start_cmd = string.format("cd go && ./webapi > /tmp/go-contract-test.log 2>&1 &")
    
    utils.execute(zig_start_cmd)
    utils.execute(go_start_cmd)
    
    -- Wait for services to start
    utils.log("Waiting for services to start...")
    os.execute("sleep 3")
    
    -- Test endpoints
    local endpoints_to_test = {"/health", "/api/games"}
    local all_contracts_valid = true
    
    for _, endpoint in ipairs(endpoints_to_test) do
        utils.log("Testing contract for endpoint: " .. endpoint)
        
        local zig_response = utils.http_get(string.format("http://localhost:%d%s", zig_port, endpoint))
        local go_response = utils.http_get(string.format("http://localhost:%d%s", go_port, endpoint))
        
        local valid, error_msg = utils.validate_api_contract(endpoint, zig_response, go_response)
        
        if valid then
            utils.success("Contract validation passed for " .. endpoint)
        else
            utils.error("Contract validation failed for " .. endpoint .. ": " .. error_msg)
            all_contracts_valid = false
        end
    end
    
    -- Cleanup test processes
    utils.kill_process("webapi")
    
    if all_contracts_valid then
        utils.success("All API contracts validated successfully")
        return true
    else
        utils.error("API contract validation failed")
        return false
    end
end

-- Performance benchmarking
function commands.benchmark()
    utils.log("Running performance benchmarks...")
    
    -- Build optimized versions if needed
    if not utils.file_exists("zig/webapi") or not utils.file_exists("go/webapi") then
        utils.log("Building optimized versions for benchmarking...")
        if not commands.build("release") then
            return false
        end
    end
    
    -- Start services on different ports
    local zig_port = 19081
    local go_port = 19082
    
    utils.log("Starting services for benchmarking...")
    
    local zig_start_cmd = string.format("cd zig && ./webapi > /tmp/zig-benchmark.log 2>&1 &")
    local go_start_cmd = string.format("cd go && ./webapi > /tmp/go-benchmark.log 2>&1 &")
    
    utils.execute(zig_start_cmd)
    utils.execute(go_start_cmd)
    
    -- Wait for services to start
    utils.log("Waiting for services to start...")
    os.execute("sleep 3")
    
    -- Run performance comparison
    local endpoints = {"/health", "/api/games"}
    local results = utils.run_performance_comparison(zig_port, go_port, endpoints, 200)
    
    -- Generate benchmark report
    local report_lines = {
        "# Performance Benchmark Report",
        "",
        "Generated: " .. os.date(),
        "",
        "## Results Summary",
        ""
    }
    
    for endpoint, comparison in pairs(results.comparison) do
        local faster_impl = comparison.zig_faster and "Zig" or "Go"
        local slower_impl = comparison.zig_faster and "Go" or "Zig"
        
        table.insert(report_lines, string.format("### %s", endpoint))
        table.insert(report_lines, string.format("- **%s is %.2fx faster** than %s", 
                     faster_impl, comparison.performance_ratio, slower_impl))
        table.insert(report_lines, string.format("- Difference: %.2fms average response time", 
                     comparison.difference_ms))
        table.insert(report_lines, "")
    end
    
    table.insert(report_lines, "## Detailed Results")
    table.insert(report_lines, "")
    
    for endpoint, _ in pairs(results.zig) do
        local zig_stats = results.zig[endpoint]
        local go_stats = results.go[endpoint]
        
        table.insert(report_lines, string.format("### %s", endpoint))
        table.insert(report_lines, "")
        table.insert(report_lines, "| Implementation | Avg | Min | Max | Median | Success Rate |")
        table.insert(report_lines, "|---------------|-----|-----|-----|--------|--------------|")
        table.insert(report_lines, string.format("| Zig | %.3fs | %.3fs | %.3fs | %.3fs | %.1f%% |",
                     zig_stats.avg, zig_stats.min, zig_stats.max, zig_stats.median, 
                     zig_stats.success_rate * 100))
        table.insert(report_lines, string.format("| Go | %.3fs | %.3fs | %.3fs | %.3fs | %.1f%% |",
                     go_stats.avg, go_stats.min, go_stats.max, go_stats.median,
                     go_stats.success_rate * 100))
        table.insert(report_lines, "")
    end
    
    local report_content = table.concat(report_lines, "\n")
    local report_file = "benchmark-report.md"
    
    if utils.write_file(report_file, report_content) then
        utils.success("Benchmark report generated: " .. report_file)
    else
        utils.warning("Failed to generate benchmark report")
    end
    
    -- Cleanup
    utils.kill_process("webapi")
    
    utils.success("Performance benchmarking completed")
    return true
end

-- Generate documentation
function commands.docs()
    utils.log("Generating API documentation...")
    
    local config_path = "shared/config.json"
    local mock_data_path = "shared/mock-data.json"
    local output_path = "API-Documentation.md"
    
    local success, message = utils.generate_api_documentation(config_path, mock_data_path, output_path)
    
    if success then
        utils.success("API documentation generated: " .. output_path)
        return true
    else
        utils.error("Documentation generation failed: " .. message)
        return false
    end
end

-- Full CI pipeline
function commands.ci()
    utils.log("Running comprehensive CI pipeline...")
    
    local pipeline_steps = {
        {"Schema Validation", commands.validate},
        {"Clean Build", commands.clean}, 
        {"Release Build", function() return commands.build("release") end},
        {"Contract Validation", commands.validate_contracts},
        {"Integration Tests", commands.test},
        {"Performance Benchmarks", commands.benchmark},
        {"Documentation Generation", commands.docs}
    }
    
    for _, step in ipairs(pipeline_steps) do
        local step_name, step_function = step[1], step[2]
        
        utils.log("CI Pipeline Step: " .. step_name)
        
        if not step_function() then
            utils.error("CI Pipeline failed at step: " .. step_name)
            return false
        end
        
        utils.success("CI Pipeline step completed: " .. step_name)
    end
    
    utils.success("CI Pipeline completed successfully!")
    return true
end

-- Show help
function commands.help()
    print()
    print("Yahoo Fantasy Sports - Lua Build System")
    print("======================================")
    print()
    print("Usage: lua build.lua <command> [options]")
    print()
    print("Commands:")
    print("  build [mode]         - Build all components (mode: debug|release)")
    print("  clean                - Clean build artifacts")
    print("  validate             - Validate shared config and data with schemas")
    print("  validate_contracts   - Validate API contracts between implementations")
    print("  test                 - Run test suite")
    print("  benchmark            - Run performance benchmarks")
    print("  docs                 - Generate API documentation")
    print("  ci                   - Run comprehensive CI pipeline")
    print("  status               - Show project status")
    print("  help                 - Show this help message")
    print()
    print("Examples:")
    print("  lua build.lua build              # Build in debug mode")
    print("  lua build.lua build release      # Build in release mode") 
    print("  lua build.lua validate           # Validate schemas")
    print("  lua build.lua validate_contracts # Check API consistency")
    print("  lua build.lua benchmark          # Performance comparison")
    print("  lua build.lua ci                 # Full CI pipeline")
    print()
    print("CI Pipeline includes:")
    print("  1. Schema validation")
    print("  2. Clean build")
    print("  3. Release build")
    print("  4. Contract validation")
    print("  5. Integration tests")
    print("  6. Performance benchmarks")
    print("  7. Documentation generation")
    print()
    return true
end

-- Status command
function commands.status()
    utils.log("Project Status")
    print()
    
    -- Check if components exist
    local components_status = {
        {"zig/sdk", "Zig SDK"},
        {"zig/webapi", "Zig Web API"},
        {"zig/webclient", "Zig Web Client"},
        {"go/webapi", "Go Web API"}, 
        {"go/webclient", "Go Web Client"}
    }
    
    print("Components:")
    for _, component in ipairs(components_status) do
        local path, name = component[1], component[2]
        if utils.file_exists(path) then
            utils.success(name .. " - Built")
        else
            utils.error(name .. " - Not built")
        end
    end
    
    print()
    print("Dependencies:")
    check_dependencies()
    
    return true
end

-- Main entry point
local function main(args)
    local command = args[1] or "help"
    local options = {table.unpack(args, 2)}
    
    if commands[command] then
        local success = commands[command](table.unpack(options))
        return success and 0 or 1
    else
        utils.error("Unknown command: " .. command)
        commands.help()
        return 1
    end
end

-- Run if executed directly
if arg and arg[0] and arg[0]:match("build%.lua$") then
    os.exit(main(arg))
end

-- Export for require()
return {
    config = config,
    commands = commands,
    main = main
}