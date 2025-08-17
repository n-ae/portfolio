const std = @import("std");
const ArrayList = std.ArrayList;

// Import all test modules
const unit_tests = @import("unit_tests_enhanced.zig");
const performance_tests = @import("performance_tests.zig");

const TestType = enum {
    unit,
    performance,
    all,
};

const OutputFormat = enum {
    standard,
    csv,
};

const Config = struct {
    test_type: TestType = .all,
    output_format: OutputFormat = .standard,
    output_file: ?[]const u8 = null,
    help: bool = false,
};

fn showUsage() void {
    std.debug.print(
        \\Usage: ctx-test-runner [OPTIONS]
        \\
        \\Run different types of tests with configurable output formats.
        \\
        \\Options:
        \\  --type TYPE         Test type: unit, performance, all (default: all)
        \\  --format FORMAT     Output format: standard, csv (default: standard)  
        \\  --output FILE       Write results to file instead of stdout
        \\  --help              Show this help message
        \\
        \\Examples:
        \\  ctx-test-runner                              # Run all tests, standard output
        \\  ctx-test-runner --type unit --format csv     # Unit tests with CSV output
        \\  ctx-test-runner --type performance --format csv --output perf.csv  # Performance tests to file
        \\
    , .{});
}

fn parseArgs(allocator: std.mem.Allocator) !Config {
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    
    var config = Config{};
    var i: usize = 1; // Skip program name
    
    while (i < args.len) {
        const arg = args[i];
        
        if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            config.help = true;
            return config;
        } else if (std.mem.eql(u8, arg, "--type")) {
            if (i + 1 >= args.len) {
                std.debug.print("Error: --type requires a value\n", .{});
                return error.InvalidArgs;
            }
            i += 1;
            const type_str = args[i];
            if (std.mem.eql(u8, type_str, "unit")) {
                config.test_type = .unit;
            } else if (std.mem.eql(u8, type_str, "performance")) {
                config.test_type = .performance;
            } else if (std.mem.eql(u8, type_str, "all")) {
                config.test_type = .all;
            } else {
                std.debug.print("Error: Invalid test type '{s}'. Use: unit, performance, all\n", .{type_str});
                return error.InvalidArgs;
            }
        } else if (std.mem.eql(u8, arg, "--format")) {
            if (i + 1 >= args.len) {
                std.debug.print("Error: --format requires a value\n", .{});
                return error.InvalidArgs;
            }
            i += 1;
            const format_str = args[i];
            if (std.mem.eql(u8, format_str, "standard")) {
                config.output_format = .standard;
            } else if (std.mem.eql(u8, format_str, "csv")) {
                config.output_format = .csv;
            } else {
                std.debug.print("Error: Invalid output format '{s}'. Use: standard, csv\n", .{format_str});
                return error.InvalidArgs;
            }
        } else if (std.mem.eql(u8, arg, "--output")) {
            if (i + 1 >= args.len) {
                std.debug.print("Error: --output requires a value\n", .{});
                return error.InvalidArgs;
            }
            i += 1;
            config.output_file = args[i];
        } else {
            std.debug.print("Error: Unknown option '{s}'\n", .{arg});
            return error.InvalidArgs;
        }
        
        i += 1;
    }
    
    return config;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const config = parseArgs(allocator) catch {
        showUsage();
        std.process.exit(1);
    };
    
    if (config.help) {
        showUsage();
        return;
    }
    
    // Set global allocator for unit tests
    unit_tests.g_allocator = allocator;
    
    switch (config.test_type) {
        .unit => {
            std.debug.print("Running unit tests...\n", .{});
            try runUnitTests(allocator, config);
        },
        .performance => {
            std.debug.print("Running performance tests...\n", .{});
            try runPerformanceTests(allocator, config);
        },
        .all => {
            std.debug.print("Running all tests...\n", .{});
            try runUnitTests(allocator, config);
            try runPerformanceTests(allocator, config);
        },
    }
}

fn runUnitTests(allocator: std.mem.Allocator, config: Config) !void {
    var results = ArrayList(unit_tests.TestResult).init(allocator);
    defer results.deinit();
    
    // Run all unit tests and collect results
    for (unit_tests.test_functions) |test_def| {
        const result = unit_tests.runTestWithTiming(test_def.name, test_def.func);
        try results.append(result);
    }
    
    // Output results in requested format
    try outputUnitTestResults(results.items, config);
}

fn runPerformanceTests(allocator: std.mem.Allocator, config: Config) !void {
    const perf_format: performance_tests.OutputFormat = switch (config.output_format) {
        .standard => .standard,
        .csv => .csv,
    };
    
    try performance_tests.runPerformanceBenchmarks(allocator, perf_format, config.output_file);
}

fn outputUnitTestResults(results: []const unit_tests.TestResult, config: Config) !void {
    const writer = if (config.output_file) |file_path| blk: {
        const file = try std.fs.cwd().createFile(file_path, .{});
        break :blk file.writer();
    } else std.io.getStdOut().writer();
    
    switch (config.output_format) {
        .csv => {
            try writer.print("test_type,test_name,status,duration_ms,error_message\n", .{});
            for (results) |result| {
                try writer.print("{s},{s},{s},{d:.2},{s}\n", .{
                    result.test_type,
                    result.test_name,
                    result.status,
                    result.duration_ms,
                    result.error_message,
                });
            }
        },
        .standard => {
            try writer.print("Unit Test Results:\n", .{});
            try writer.print("==================\n", .{});
            for (results) |result| {
                const status_symbol = if (std.mem.eql(u8, result.status, "PASS")) "✅" else "❌";
                try writer.print("{s} {s}: {s} ({d:.2}ms)\n", .{ 
                    status_symbol, 
                    result.test_name, 
                    result.status, 
                    result.duration_ms 
                });
                if (result.error_message.len > 0) {
                    try writer.print("   Error: {s}\n", .{result.error_message});
                }
            }
        },
    }
}