const std = @import("std");
const ArrayList = std.ArrayList;

// Import all test modules
const performance_tests = @import(".performance.test.zig");

const TestType = enum {
    unit,
    integration,
    performance,
    blackbox,
    container,
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
        \\  --type TYPE         Test type: unit, integration, performance, blackbox, container, all (default: all)
        \\  --format FORMAT     Output format: standard, csv (default: standard)  
        \\  --output FILE       Write results to file instead of stdout
        \\  --help              Show this help message
        \\
        \\Examples:
        \\  ctx-test-runner                              # Run all tests, standard output
        \\  ctx-test-runner --type unit --format csv     # Unit tests with CSV output
        \\  ctx-test-runner --type integration           # Integration tests only
        \\  ctx-test-runner --type blackbox             # Blackbox tests only
        \\  ctx-test-runner --type container            # Container tests only
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
            } else if (std.mem.eql(u8, type_str, "integration")) {
                config.test_type = .integration;
            } else if (std.mem.eql(u8, type_str, "performance")) {
                config.test_type = .performance;
            } else if (std.mem.eql(u8, type_str, "blackbox")) {
                config.test_type = .blackbox;
            } else if (std.mem.eql(u8, type_str, "container")) {
                config.test_type = .container;
            } else if (std.mem.eql(u8, type_str, "all")) {
                config.test_type = .all;
            } else {
                std.debug.print("Error: Invalid test type '{s}'. Use: unit, integration, performance, blackbox, container, all\n", .{type_str});
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

    // No global allocator needed for standard Zig tests

    switch (config.test_type) {
        .unit => {
            std.debug.print("Running unit tests...\n", .{});
            try runUnitTests(allocator, config);
        },
        .integration => {
            std.debug.print("Running integration tests...\n", .{});
            try runIntegrationTests(allocator, config);
        },
        .performance => {
            std.debug.print("Running performance tests...\n", .{});
            try runPerformanceTests(allocator, config);
        },
        .blackbox => {
            std.debug.print("Running blackbox tests...\n", .{});
            try runBlackboxTests(allocator, config);
        },
        .container => {
            std.debug.print("Running container tests...\n", .{});
            try runContainerTests(allocator, config);
        },
        .all => {
            std.debug.print("Running all tests...\n", .{});
            try runUnitTests(allocator, config);
            try runIntegrationTests(allocator, config);
            try runPerformanceTests(allocator, config);
            try runBlackboxTests(allocator, config);
            try runContainerTests(allocator, config);
        },
    }
}

fn runUnitTests(allocator: std.mem.Allocator, config: Config) !void {
    // Find all *.unit.test.zig files recursively
    const test_files = try findTestFiles(allocator, ".", "*.unit.test.zig");
    defer {
        for (test_files) |file| {
            allocator.free(file);
        }
        allocator.free(test_files);
    }

    for (test_files) |test_file| {
        const result = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "zig", "test", test_file },
        });
        defer allocator.free(result.stdout);
        defer allocator.free(result.stderr);

        if (config.output_format == .standard) {
            if (result.stdout.len > 0) {
                std.debug.print("Unit test output ({s}):\n{s}\n", .{ test_file, result.stdout });
            }
            if (result.stderr.len > 0) {
                std.debug.print("Unit test errors ({s}):\n{s}\n", .{ test_file, result.stderr });
            }
        }

        if (result.term.Exited != 0) {
            std.debug.print("Unit tests failed in {s} with exit code: {d}\n", .{ test_file, result.term.Exited });
            return error.TestsFailed;
        }
    }
}

fn runPerformanceTests(allocator: std.mem.Allocator, config: Config) !void {
    const perf_format: performance_tests.OutputFormat = switch (config.output_format) {
        .standard => .standard,
        .csv => .csv,
    };

    try performance_tests.runPerformanceBenchmarks(allocator, perf_format, config.output_file);
}

fn runIntegrationTests(allocator: std.mem.Allocator, config: Config) !void {
    // Find all *.integration.test.zig files recursively
    const test_files = try findTestFiles(allocator, ".", "*.integration.test.zig");
    defer {
        for (test_files) |file| {
            allocator.free(file);
        }
        allocator.free(test_files);
    }

    for (test_files) |test_file| {
        const result = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "zig", "test", test_file },
        });
        defer allocator.free(result.stdout);
        defer allocator.free(result.stderr);

        if (config.output_format == .standard) {
            if (result.stdout.len > 0) {
                std.debug.print("Integration test output ({s}):\n{s}\n", .{ test_file, result.stdout });
            }
            if (result.stderr.len > 0) {
                std.debug.print("Integration test errors ({s}):\n{s}\n", .{ test_file, result.stderr });
            }
        }

        if (result.term.Exited != 0) {
            std.debug.print("Integration tests failed in {s} with exit code: {d}\n", .{ test_file, result.term.Exited });
            return error.TestsFailed;
        }
    }
}

fn runBlackboxTests(allocator: std.mem.Allocator, config: Config) !void {
    // Find all *.blackbox.test.zig files recursively and run them with zig test
    const test_files = try findTestFiles(allocator, ".", "*.blackbox.test.zig");
    defer {
        for (test_files) |file| {
            allocator.free(file);
        }
        allocator.free(test_files);
    }

    for (test_files) |test_file| {
        // Run blackbox tests by executing the zig file directly (it contains main function)
        const result = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "zig", "run", test_file, "--", "./zig-out/bin/ctx" },
        });
        defer allocator.free(result.stdout);
        defer allocator.free(result.stderr);

        if (config.output_format == .standard) {
            if (result.stdout.len > 0) {
                std.debug.print("Blackbox test output ({s}):\n{s}\n", .{ test_file, result.stdout });
            }
            if (result.stderr.len > 0) {
                std.debug.print("Blackbox test errors ({s}):\n{s}\n", .{ test_file, result.stderr });
            }
        }

        if (result.term.Exited != 0) {
            std.debug.print("Blackbox tests failed in {s} with exit code: {d}\n", .{ test_file, result.term.Exited });
            return error.TestsFailed;
        }
    }
}

fn runContainerTests(allocator: std.mem.Allocator, config: Config) !void {
    // Check if Podman is available
    const podman_check = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "podman", "--version" },
    }) catch {
        std.debug.print("Podman not available - skipping container tests\n", .{});
        return;
    };
    defer allocator.free(podman_check.stdout);
    defer allocator.free(podman_check.stderr);

    if (podman_check.term.Exited != 0) {
        std.debug.print("Podman not available - skipping container tests\n", .{});
        return;
    }

    // Use existing Podman test infrastructure
    std.debug.print("Running container tests using Podman infrastructure...\n", .{});

    // First check if we have any custom *.container.test.zig files
    const test_files = try findTestFiles(allocator, ".", "*.container.test.zig");
    defer {
        for (test_files) |file| {
            allocator.free(file);
        }
        allocator.free(test_files);
    }

    // Run custom container test files if they exist
    for (test_files) |test_file| {
        const result = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "zig", "run", test_file },
        });
        defer allocator.free(result.stdout);
        defer allocator.free(result.stderr);

        if (config.output_format == .standard) {
            if (result.stdout.len > 0) {
                std.debug.print("Container test output ({s}):\n{s}\n", .{ test_file, result.stdout });
            }
            if (result.stderr.len > 0) {
                std.debug.print("Container test errors ({s}):\n{s}\n", .{ test_file, result.stderr });
            }
        }

        if (result.term.Exited != 0) {
            std.debug.print("Container tests failed in {s} with exit code: {d}\n", .{ test_file, result.term.Exited });
            return error.TestsFailed;
        }
    }

    // Run a simpler container test that works with available binaries
    std.debug.print("Running simplified container tests with available binaries...\n", .{});

    const container_test_cmd =
        \\set -e
        \\echo '🐳 Testing ctx CLI in container environment...'
        \\echo '📦 Available binaries:'
        \\ls -la zig-out/bin/
        \\echo '🧪 Testing basic functionality:'
        \\./zig-out/bin/ctx version
        \\./zig-out/bin/ctx --help | head -5
        \\echo '🎯 Running blackbox tests:'
        \\./zig-out/bin/ctx-test ./zig-out/bin/ctx
        \\echo '✅ Container tests completed successfully!'
    ;

    const container_name = try std.fmt.allocPrint(allocator, "ctx-test-unified-{d}", .{std.time.timestamp()});
    defer allocator.free(container_name);

    const image = "localhost/ctx-cli:builder-latest";

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "podman", "run", "--name", container_name, "--rm", "--workdir", "/build", image, "sh", "-c", container_test_cmd },
    });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (config.output_format == .standard) {
        if (result.stdout.len > 0) {
            std.debug.print("Container test output:\n{s}\n", .{result.stdout});
        }
        if (result.stderr.len > 0) {
            std.debug.print("Container test errors:\n{s}\n", .{result.stderr});
        }
    }

    if (result.term.Exited != 0) {
        std.debug.print("Container tests failed with exit code: {d}\n", .{result.term.Exited});
        return error.TestsFailed;
    }
}

fn findTestFiles(allocator: std.mem.Allocator, dir_path: []const u8, pattern: []const u8) ![][]u8 {
    var files = ArrayList([]u8).init(allocator);
    defer files.deinit();

    // For simplicity, we'll use a basic approach to find files
    // In a real implementation, we might want to use a more sophisticated file walker
    var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch |err| switch (err) {
        error.FileNotFound => return try allocator.alloc([]u8, 0),
        else => return err,
    };
    defer dir.close();

    var iterator = dir.iterate();
    while (try iterator.next()) |entry| {
        if (entry.kind == .file) {
            // Check if file matches pattern
            if (matchesPattern(entry.name, pattern)) {
                const full_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir_path, entry.name });
                try files.append(full_path);
            }
        } else if (entry.kind == .directory) {
            // Skip common directories that shouldn't contain tests
            if (std.mem.eql(u8, entry.name, ".git") or
                std.mem.eql(u8, entry.name, "zig-out") or
                std.mem.eql(u8, entry.name, ".zig-cache"))
            {
                continue;
            }

            // Recursively search subdirectories
            const sub_dir_path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ dir_path, entry.name });
            defer allocator.free(sub_dir_path);

            const sub_files = try findTestFiles(allocator, sub_dir_path, pattern);
            defer {
                for (sub_files) |sub_file| {
                    allocator.free(sub_file);
                }
                allocator.free(sub_files);
            }

            for (sub_files) |sub_file| {
                try files.append(try allocator.dupe(u8, sub_file));
            }
        }
    }

    return try files.toOwnedSlice();
}

fn matchesPattern(filename: []const u8, pattern: []const u8) bool {
    // Simple pattern matching for *.extension.zig
    if (std.mem.startsWith(u8, pattern, "*.") and std.mem.endsWith(u8, pattern, ".zig")) {
        const middle_part = pattern[2 .. pattern.len - 4]; // Remove "*." and ".zig"
        const expected_suffix = std.fmt.allocPrint(std.heap.page_allocator, ".{s}.zig", .{middle_part}) catch return false;
        defer std.heap.page_allocator.free(expected_suffix);
        return std.mem.endsWith(u8, filename, expected_suffix);
    }
    return false;
}
