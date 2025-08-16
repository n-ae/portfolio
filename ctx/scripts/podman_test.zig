const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const Config = struct {
    image_name: []const u8 = "ctx-cli",
    registry: []const u8 = "localhost",
    tag: []const u8 = "latest",
    test_type: []const u8 = "all",
    verbose: bool = false,
    keep: bool = false,
    no_cleanup: bool = false,
    shell_type: ?[]const u8 = null,
    mount_source: bool = false,
    help: bool = false,
};

const Color = struct {
    const RED = "\x1b[0;31m";
    const GREEN = "\x1b[0;32m";
    const YELLOW = "\x1b[1;33m";
    const BLUE = "\x1b[0;34m";
    const NC = "\x1b[0m";
};

fn logInfo(comptime message: []const u8, args: anytype) void {
    print(Color.BLUE ++ "[INFO]" ++ Color.NC ++ " " ++ message ++ "\n", args);
}

fn logSuccess(comptime message: []const u8, args: anytype) void {
    print(Color.GREEN ++ "[SUCCESS]" ++ Color.NC ++ " " ++ message ++ "\n", args);
}

fn logError(comptime message: []const u8, args: anytype) void {
    print(Color.RED ++ "[ERROR]" ++ Color.NC ++ " " ++ message ++ "\n", args);
}

fn showUsage() void {
    print(
        \\Usage: zig run podman_test.zig -- [OPTIONS] [TEST_TYPE]
        \\
        \\Run ctx CLI tests in isolated Podman containers
        \\
        \\TEST TYPES:
        \\    unit        Run unit tests only
        \\    blackbox    Run blackbox/integration tests only
        \\    csv         Run CSV output tests
        \\    all         Run all tests (default)
        \\    interactive Run interactive testing session
        \\
        \\OPTIONS:
        \\    -h, --help          Show this help message
        \\    -t, --tag TAG       Use specific image tag (default: latest)
        \\    -r, --registry REG  Use specific registry (default: localhost)
        \\    -v, --verbose       Verbose output
        \\    -k, --keep          Keep containers after tests (for debugging)
        \\    --no-cleanup        Don't cleanup containers before running
        \\    --shell SHELL       Test with specific shell (bash, zsh, fish)
        \\    --mount-source      Mount source code for development testing
        \\
        \\EXAMPLES:
        \\    zig run podman_test.zig                          # Run all tests
        \\    zig run podman_test.zig -- unit                 # Run unit tests only
        \\    zig run podman_test.zig -- --verbose csv        # Run CSV tests with verbose output
        \\    zig run podman_test.zig -- --keep interactive   # Interactive session, keep container
        \\
    , .{});
}

fn cleanupContainers(allocator: std.mem.Allocator, config: Config) !void {
    if (config.no_cleanup) {
        logInfo("Skipping cleanup (--no-cleanup specified)", .{});
        return;
    }

    logInfo("Cleaning up test containers...", .{});

    // Get containers matching pattern
    const list_result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "podman", "ps", "-a", "--filter", "name=ctx-test", "--format", "{{.Names}}" },
    }) catch {
        logInfo("No containers to cleanup", .{});
        return;
    };
    defer allocator.free(list_result.stdout);
    defer allocator.free(list_result.stderr);

    if (list_result.stdout.len == 0 or std.mem.trim(u8, list_result.stdout, " \n\r\t").len == 0) {
        return;
    }

    const container_names = std.mem.trim(u8, list_result.stdout, " \n\r\t");
    
    // Stop containers
    const stop_cmd = try std.fmt.allocPrint(allocator, "echo '{s}' | xargs -r podman stop", .{container_names});
    defer allocator.free(stop_cmd);
    _ = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "sh", "-c", stop_cmd },
    }) catch {};

    // Remove containers
    const rm_cmd = try std.fmt.allocPrint(allocator, "echo '{s}' | xargs -r podman rm", .{container_names});
    defer allocator.free(rm_cmd);
    _ = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "sh", "-c", rm_cmd },
    }) catch {};

    logInfo("Cleaned up containers: {s}", .{container_names});
}

fn runTestInContainer(allocator: std.mem.Allocator, config: Config, test_command: []const u8) !bool {
    const container_name = try std.fmt.allocPrint(allocator, "ctx-test-{s}-{d}", .{ config.test_type, std.time.timestamp() });
    defer allocator.free(container_name);

    const image = try std.fmt.allocPrint(allocator, "{s}/{s}:builder-{s}", .{ config.registry, config.image_name, config.tag });
    defer allocator.free(image);

    logInfo("Creating test container: {s}", .{container_name});
    logInfo("Using image: {s}", .{image});

    var podman_args = ArrayList([]const u8).init(allocator);
    defer podman_args.deinit();

    try podman_args.appendSlice(&[_][]const u8{ "podman", "run", "--name", container_name, "--rm" });

    // Add interactive flags if needed
    if (std.mem.eql(u8, config.test_type, "interactive")) {
        try podman_args.append("-it");
    }

    // Set working directory to builder project location
    try podman_args.appendSlice(&[_][]const u8{ "--workdir", "/build" });
    
    // Mount source code if requested (for development)
    if (config.mount_source) {
        const project_root = try std.fs.cwd().realpathAlloc(allocator, ".");
        defer allocator.free(project_root);
        const volume_mount = try std.fmt.allocPrint(allocator, "{s}:/build:Z", .{project_root});
        defer allocator.free(volume_mount);

        try podman_args.appendSlice(&[_][]const u8{ "--volume", volume_mount });
        logInfo("Mounting source code from: {s}", .{project_root});
    }

    // Set shell if specified
    if (config.shell_type) |shell| {
        const shell_env = try std.fmt.allocPrint(allocator, "SHELL=/bin/{s}", .{shell});
        defer allocator.free(shell_env);
        try podman_args.appendSlice(&[_][]const u8{ "--env", shell_env });
        logInfo("Using shell: {s}", .{shell});
    }

    // Add image and command
    try podman_args.append(image);
    try podman_args.appendSlice(&[_][]const u8{ "sh", "-c", test_command });

    if (config.verbose) {
        const cmd_str = try std.mem.join(allocator, " ", podman_args.items);
        defer allocator.free(cmd_str);
        logInfo("Command: {s}", .{cmd_str});
    }

    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = podman_args.items,
    }) catch |err| {
        logError("Failed to execute podman run: {}", .{err});
        return false;
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (result.stdout.len > 0) {
        print("{s}", .{result.stdout});
    }
    if (result.stderr.len > 0) {
        print("STDERR: {s}", .{result.stderr});
    }

    return result.term.Exited == 0;
}

fn runUnitTests(allocator: std.mem.Allocator, config: Config) !bool {
    logInfo("Running unit tests in container...", .{});

    const test_command =
        \\set -e
        \\echo '🧪 Running unit tests...'
        \\zig build test
        \\echo '📊 Running CSV unit tests...'
        \\./zig-out/bin/ctx-unit-csv
        \\echo '✅ Unit tests completed successfully!'
    ;

    if (try runTestInContainer(allocator, config, test_command)) {
        logSuccess("Unit tests passed!", .{});
        return true;
    } else {
        logError("Unit tests failed!", .{});
        return false;
    }
}

fn runBlackboxTests(allocator: std.mem.Allocator, config: Config) !bool {
    logInfo("Running blackbox tests in container...", .{});

    const test_command =
        \\set -e
        \\echo '🎯 Running blackbox tests...'
        \\zig build test-blackbox
        \\echo '📊 Running CSV blackbox tests...'
        \\./zig-out/bin/ctx-test-csv ./zig-out/bin/ctx
        \\echo '✅ Blackbox tests completed successfully!'
    ;

    if (try runTestInContainer(allocator, config, test_command)) {
        logSuccess("Blackbox tests passed!", .{});
        return true;
    } else {
        logError("Blackbox tests failed!", .{});
        return false;
    }
}

fn runCsvTests(allocator: std.mem.Allocator, config: Config) !bool {
    logInfo("Running CSV tests in container...", .{});

    const test_command =
        \\set -e
        \\echo '📊 Running CSV test suite...'
        \\zig build test-csv
        \\echo '💾 Testing CSV file output...'
        \\./zig-out/bin/csv-runner --output-file /tmp/test-results.csv
        \\echo '📄 CSV Results:'
        \\cat /tmp/test-results.csv
        \\echo '✅ CSV tests completed successfully!'
    ;

    if (try runTestInContainer(allocator, config, test_command)) {
        logSuccess("CSV tests passed!", .{});
        return true;
    } else {
        logError("CSV tests failed!", .{});
        return false;
    }
}

fn runAllTests(allocator: std.mem.Allocator, config: Config) !bool {
    logInfo("Running comprehensive test suite in container...", .{});

    var failed_tests = ArrayList([]const u8).init(allocator);
    defer failed_tests.deinit();

    var unit_config = config;
    unit_config.test_type = "unit";
    if (!try runUnitTests(allocator, unit_config)) {
        try failed_tests.append("unit");
    }

    var blackbox_config = config;
    blackbox_config.test_type = "blackbox";
    if (!try runBlackboxTests(allocator, blackbox_config)) {
        try failed_tests.append("blackbox");
    }

    var csv_config = config;
    csv_config.test_type = "csv";
    if (!try runCsvTests(allocator, csv_config)) {
        try failed_tests.append("csv");
    }

    if (failed_tests.items.len == 0) {
        logSuccess("All tests passed! 🎉", .{});
        return true;
    } else {
        const failed_str = try std.mem.join(allocator, ", ", failed_tests.items);
        defer allocator.free(failed_str);
        logError("Failed tests: {s}", .{failed_str});
        return false;
    }
}

fn runInteractive(allocator: std.mem.Allocator, config: Config) !bool {
    logInfo("Starting interactive testing session...", .{});

    logInfo("Available commands:", .{});
    logInfo("  - zig build test        # Run all tests", .{});
    logInfo("  - zig build test-csv    # Run CSV tests", .{});
    logInfo("  - ctx --help           # Test CLI", .{});
    logInfo("  - exit                 # Exit container", .{});

    return try runTestInContainer(allocator, config, "sh");
}

fn parseArgs(args: [][:0]u8) !Config {
    var config = Config{};
    var i: usize = 1; // Skip program name

    while (i < args.len) {
        const arg = args[i];

        if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
            config.help = true;
            return config;
        } else if (std.mem.eql(u8, arg, "-t") or std.mem.eql(u8, arg, "--tag")) {
            if (i + 1 >= args.len) {
                logError("--tag requires a value", .{});
                return error.InvalidArgs;
            }
            i += 1;
            config.tag = args[i];
        } else if (std.mem.eql(u8, arg, "-r") or std.mem.eql(u8, arg, "--registry")) {
            if (i + 1 >= args.len) {
                logError("--registry requires a value", .{});
                return error.InvalidArgs;
            }
            i += 1;
            config.registry = args[i];
        } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--verbose")) {
            config.verbose = true;
        } else if (std.mem.eql(u8, arg, "-k") or std.mem.eql(u8, arg, "--keep")) {
            config.keep = true;
        } else if (std.mem.eql(u8, arg, "--no-cleanup")) {
            config.no_cleanup = true;
        } else if (std.mem.eql(u8, arg, "--shell")) {
            if (i + 1 >= args.len) {
                logError("--shell requires a value", .{});
                return error.InvalidArgs;
            }
            i += 1;
            config.shell_type = args[i];
        } else if (std.mem.eql(u8, arg, "--mount-source")) {
            config.mount_source = true;
        } else if (std.mem.eql(u8, arg, "unit") or std.mem.eql(u8, arg, "blackbox") or std.mem.eql(u8, arg, "csv") or std.mem.eql(u8, arg, "all") or std.mem.eql(u8, arg, "interactive")) {
            config.test_type = arg;
        } else {
            logError("Unknown option: {s}", .{arg});
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

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const config = parseArgs(args) catch {
        showUsage();
        return;
    };

    if (config.help) {
        showUsage();
        return;
    }

    // Check if podman is available
    const podman_check = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "podman", "--version" },
    }) catch {
        logError("Podman is not installed or not in PATH", .{});
        std.process.exit(1);
    };
    defer allocator.free(podman_check.stdout);
    defer allocator.free(podman_check.stderr);

    if (podman_check.term.Exited != 0) {
        logError("Podman is not working correctly", .{});
        std.process.exit(1);
    }

    logInfo("Running ctx CLI tests with type: {s}", .{config.test_type});
    logInfo("Registry: {s}", .{config.registry});
    logInfo("Tag: {s}", .{config.tag});

    // Cleanup unless disabled
    if (!config.keep) {
        try cleanupContainers(allocator, config);
    }

    // Run tests based on type
    const success = if (std.mem.eql(u8, config.test_type, "unit"))
        try runUnitTests(allocator, config)
    else if (std.mem.eql(u8, config.test_type, "blackbox"))
        try runBlackboxTests(allocator, config)
    else if (std.mem.eql(u8, config.test_type, "csv"))
        try runCsvTests(allocator, config)
    else if (std.mem.eql(u8, config.test_type, "all"))
        try runAllTests(allocator, config)
    else if (std.mem.eql(u8, config.test_type, "interactive"))
        try runInteractive(allocator, config)
    else {
        logError("Invalid test type: {s}", .{config.test_type});
        showUsage();
        std.process.exit(1);
    };

    if (!success) {
        std.process.exit(1);
    }
}