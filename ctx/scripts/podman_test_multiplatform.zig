const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const Config = struct {
    image_name: []const u8 = "ctx-cli",
    registry: []const u8 = "localhost",
    tag: []const u8 = "latest",
    test_type: []const u8 = "all",
    platform: ?[]const u8 = null,
    multiplatform: bool = false,
    platforms: []const []const u8 = &[_][]const u8{ "linux/amd64", "windows/amd64", "darwin/amd64" },
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

fn logWarning(comptime message: []const u8, args: anytype) void {
    print(Color.YELLOW ++ "[WARNING]" ++ Color.NC ++ " " ++ message ++ "\n", args);
}

fn showUsage() void {
    print(
        \\Usage: zig run podman_test_multiplatform.zig -- [OPTIONS] [TEST_TYPE]
        \\
        \\Run ctx CLI tests across multiple platforms using containers
        \\
        \\TEST TYPES:
        \\    unit        Run unit tests only
        \\    blackbox    Run blackbox/integration tests only
        \\    csv         Run CSV output tests
        \\    all         Run all tests (default)
        \\    interactive Run interactive testing session
        \\
        \\OPTIONS:
        \\    -h, --help              Show this help message
        \\    -t, --tag TAG           Use specific image tag (default: latest)
        \\    -r, --registry REG      Use specific registry (default: localhost)
        \\    --platform PLATFORM     Test specific platform only (linux/amd64, windows/amd64, darwin/amd64)
        \\    --multiplatform         Test all supported platforms
        \\    --platforms P1,P2,P3    Test specific comma-separated platforms
        \\    -v, --verbose           Verbose output
        \\    -k, --keep              Keep containers after tests (for debugging)
        \\    --no-cleanup            Don't cleanup containers before running
        \\    --shell SHELL           Test with specific shell (bash, zsh, fish)
        \\    --mount-source          Mount source code for development testing
        \\
        \\EXAMPLES:
        \\    zig run podman_test_multiplatform.zig                                   # Run all tests on default platform
        \\    zig run podman_test_multiplatform.zig -- --multiplatform blackbox      # Run blackbox tests on all platforms
        \\    zig run podman_test_multiplatform.zig -- --platform linux/amd64 unit  # Run unit tests on Linux
        \\    zig run podman_test_multiplatform.zig -- --platform windows/amd64 all # Run all tests on Windows
        \\    zig run podman_test_multiplatform.zig -- --platforms linux/amd64,windows/amd64 csv # CSV tests on specific platforms
        \\
    , .{});
}

fn getPlatformShell(platform: []const u8) []const u8 {
    if (std.mem.startsWith(u8, platform, "windows")) {
        return "powershell";
    } else if (std.mem.startsWith(u8, platform, "darwin")) {
        return "bash"; // macOS-like environment uses bash
    } else {
        return "sh"; // Linux uses sh
    }
}

fn getPlatformImageTag(allocator: std.mem.Allocator, config: Config, platform: []const u8) ![]const u8 {
    // Normalize platform name for image tag
    const normalized_platform = if (std.mem.eql(u8, platform, "linux/amd64"))
        "linux"
    else if (std.mem.eql(u8, platform, "windows/amd64"))
        "windows"
    else if (std.mem.eql(u8, platform, "darwin/amd64"))
        "macos"
    else
        platform;

    return try std.fmt.allocPrint(allocator, "{s}/{s}:blackbox-testing-{s}-{s}", .{ config.registry, config.image_name, normalized_platform, config.tag });
}

fn cleanupContainers(allocator: std.mem.Allocator, config: Config) !void {
    if (config.no_cleanup) {
        logInfo("Skipping cleanup (--no-cleanup specified)", .{});
        return;
    }

    logInfo("Cleaning up multiplatform test containers...", .{});

    // Get containers matching pattern
    const list_result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "podman", "ps", "-a", "--filter", "name=ctx-test-multiplatform", "--format", "{{.Names}}" },
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

fn runTestOnPlatform(allocator: std.mem.Allocator, config: Config, platform: []const u8, test_command: []const u8) !bool {
    const container_name = try std.fmt.allocPrint(allocator, "ctx-test-multiplatform-{s}-{s}-{d}", .{ std.mem.replace(u8, platform, "/", "-", allocator), config.test_type, std.time.timestamp() });
    defer allocator.free(container_name);

    const image = try getPlatformImageTag(allocator, config, platform);
    defer allocator.free(image);

    logInfo("Testing platform: {s}", .{platform});
    logInfo("Creating test container: {s}", .{container_name});
    logInfo("Using image: {s}", .{image});

    var podman_args = ArrayList([]const u8).init(allocator);
    defer podman_args.deinit();

    try podman_args.appendSlice(&[_][]const u8{ "podman", "run", "--name", container_name, "--rm" });

    // Add platform specification
    try podman_args.appendSlice(&[_][]const u8{ "--platform", platform });

    // Add interactive flags if needed
    if (std.mem.eql(u8, config.test_type, "interactive")) {
        try podman_args.append("-it");
    }

    // Set working directory based on platform
    const workdir = if (std.mem.startsWith(u8, platform, "windows")) "C:/build" else "/build";
    try podman_args.appendSlice(&[_][]const u8{ "--workdir", workdir });

    // Mount source code if requested (for development)
    if (config.mount_source) {
        const project_root = try std.fs.cwd().realpathAlloc(allocator, ".");
        defer allocator.free(project_root);
        const volume_mount = if (std.mem.startsWith(u8, platform, "windows"))
            try std.fmt.allocPrint(allocator, "{s}:C:/build:Z", .{project_root})
        else
            try std.fmt.allocPrint(allocator, "{s}:/build:Z", .{project_root});
        defer allocator.free(volume_mount);

        try podman_args.appendSlice(&[_][]const u8{ "--volume", volume_mount });
        logInfo("Mounting source code from: {s}", .{project_root});
    }

    // Set platform environment variables
    const platform_env = try std.fmt.allocPrint(allocator, "TARGET_PLATFORM={s}", .{platform});
    defer allocator.free(platform_env);
    try podman_args.appendSlice(&[_][]const u8{ "--env", platform_env });

    // Set shell if specified or use platform default
    const shell = if (config.shell_type) |shell_type| shell_type else getPlatformShell(platform);
    const shell_env = try std.fmt.allocPrint(allocator, "SHELL={s}", .{shell});
    defer allocator.free(shell_env);
    try podman_args.appendSlice(&[_][]const u8{ "--env", shell_env });
    logInfo("Using shell: {s}", .{shell});

    // Add image and command
    try podman_args.append(image);

    // Use platform-appropriate shell for command execution
    if (std.mem.startsWith(u8, platform, "windows")) {
        try podman_args.appendSlice(&[_][]const u8{ "powershell", "-Command", test_command });
    } else {
        try podman_args.appendSlice(&[_][]const u8{ "sh", "-c", test_command });
    }

    if (config.verbose) {
        const cmd_str = try std.mem.join(allocator, " ", podman_args.items);
        defer allocator.free(cmd_str);
        logInfo("Command: {s}", .{cmd_str});
    }

    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = podman_args.items,
    }) catch |err| {
        logError("Failed to execute podman run on {s}: {}", .{ platform, err });
        return false;
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (result.stdout.len > 0) {
        print("=== {s} OUTPUT ===\n{s}\n", .{ platform, result.stdout });
    }
    if (result.stderr.len > 0) {
        print("=== {s} STDERR ===\n{s}\n", .{ platform, result.stderr });
    }

    const success = result.term.Exited == 0;
    if (success) {
        logSuccess("Tests passed on {s}", .{platform});
    } else {
        logError("Tests failed on {s}", .{platform});
    }

    return success;
}

fn runMultiplatformTests(allocator: std.mem.Allocator, config: Config) !bool {
    logInfo("Running multiplatform tests...", .{});

    const test_command = switch (std.hash_map.hashString(config.test_type)) {
        std.hash_map.hashString("unit") =>
        \\echo '🧪 Running unit tests...' && zig build test && echo '✅ Unit tests completed!'
        ,
        std.hash_map.hashString("blackbox") =>
        \\echo '🎯 Running blackbox tests...' && zig build test-blackbox && echo '✅ Blackbox tests completed!'
        ,
        std.hash_map.hashString("csv") =>
        \\echo '📊 Running CSV tests...' && zig build test-csv && echo '✅ CSV tests completed!'
        ,
        else =>
        \\echo '🧪 Running comprehensive test suite...' && zig build test && zig build test-blackbox && echo '✅ All tests completed!'
        ,
    };

    var failed_platforms = ArrayList([]const u8).init(allocator);
    defer failed_platforms.deinit();

    const platforms_to_test = if (config.platform) |single_platform|
        &[_][]const u8{single_platform}
    else
        config.platforms;

    for (platforms_to_test) |platform| {
        logInfo("======================================", .{});
        logInfo("Testing platform: {s}", .{platform});
        logInfo("======================================", .{});

        if (!try runTestOnPlatform(allocator, config, platform, test_command)) {
            try failed_platforms.append(platform);
        }
    }

    print("\n");
    logInfo("=======================================", .{});
    logInfo("MULTIPLATFORM TEST SUMMARY", .{});
    logInfo("=======================================", .{});

    if (failed_platforms.items.len == 0) {
        logSuccess("All platforms passed! 🎉", .{});
        for (platforms_to_test) |platform| {
            logSuccess("✅ {s}", .{platform});
        }
        return true;
    } else {
        logError("Some platforms failed:", .{});
        for (platforms_to_test) |platform| {
            var found = false;
            for (failed_platforms.items) |failed_platform| {
                if (std.mem.eql(u8, platform, failed_platform)) {
                    found = true;
                    break;
                }
            }
            if (found) {
                logError("❌ {s}", .{platform});
            } else {
                logSuccess("✅ {s}", .{platform});
            }
        }
        return false;
    }
}

fn parsePlatforms(allocator: std.mem.Allocator, platform_str: []const u8) ![][]const u8 {
    var platforms = ArrayList([]const u8).init(allocator);
    defer platforms.deinit();

    var iter = std.mem.split(u8, platform_str, ",");
    while (iter.next()) |platform| {
        const trimmed = std.mem.trim(u8, platform, " \t");
        if (trimmed.len > 0) {
            try platforms.append(try allocator.dupe(u8, trimmed));
        }
    }

    return try platforms.toOwnedSlice();
}

fn parseArgs(allocator: std.mem.Allocator, args: [][:0]u8) !Config {
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
        } else if (std.mem.eql(u8, arg, "--platform")) {
            if (i + 1 >= args.len) {
                logError("--platform requires a value", .{});
                return error.InvalidArgs;
            }
            i += 1;
            config.platform = args[i];
        } else if (std.mem.eql(u8, arg, "--multiplatform")) {
            config.multiplatform = true;
        } else if (std.mem.eql(u8, arg, "--platforms")) {
            if (i + 1 >= args.len) {
                logError("--platforms requires a value", .{});
                return error.InvalidArgs;
            }
            i += 1;
            config.platforms = try parsePlatforms(allocator, args[i]);
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

    const config = parseArgs(allocator, args) catch {
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

    logInfo("Running multiplatform ctx CLI tests", .{});
    logInfo("Registry: {s}", .{config.registry});
    logInfo("Tag: {s}", .{config.tag});
    logInfo("Test type: {s}", .{config.test_type});

    if (config.platform) |platform| {
        logInfo("Target platform: {s}", .{platform});
    } else {
        logInfo("Target platforms: {s}", .{try std.mem.join(allocator, ", ", config.platforms)});
    }

    // Cleanup unless disabled
    if (!config.keep) {
        try cleanupContainers(allocator, config);
    }

    // Run multiplatform tests
    const success = try runMultiplatformTests(allocator, config);

    if (!success) {
        std.process.exit(1);
    }
}

