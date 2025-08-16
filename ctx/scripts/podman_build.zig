const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

const Config = struct {
    image_name: []const u8 = "ctx-cli",
    registry: []const u8 = "localhost",
    tag: []const u8 = "latest",
    target: []const u8 = "runtime",
    no_cache: bool = false,
    push: bool = false,
    platform: ?[]const u8 = null,
    containerfile: []const u8 = "Containerfile",
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
        \\Usage: zig run podman_build.zig -- [OPTIONS] [TARGET]
        \\
        \\Build ctx CLI container images using Podman
        \\
        \\TARGETS:
        \\    runtime         Build production runtime image (default)
        \\    builder         Build builder image with Zig and source code  
        \\    all             Build all images
        \\
        \\OPTIONS:
        \\    -h, --help          Show this help message
        \\    -t, --tag TAG       Tag for the image (default: latest)
        \\    -r, --registry REG  Registry prefix (default: localhost)
        \\    --no-cache          Build without cache
        \\    --push              Push images to registry after build
        \\    --platform PLAT     Target specific platform (linux/amd64, windows/amd64, darwin/amd64, etc.)
        \\    -f, --file FILE     Use specific Containerfile (default: Containerfile)
        \\
        \\EXAMPLES:
        \\    zig run podman_build.zig                                    # Build runtime image
        \\    zig run podman_build.zig -- builder                        # Build builder image
        \\    zig run podman_build.zig -- --tag v1.0.0 all              # Build all images with tag v1.0.0
        \\    zig run podman_build.zig -- --platform linux/amd64 builder  # Build for specific platform
        \\
    , .{});
}

fn checkPodman(allocator: std.mem.Allocator) !bool {
    // Check if podman is installed
    const version_result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "podman", "--version" },
    }) catch {
        logError("Podman is not installed or not in PATH", .{});
        logInfo("Install Podman: https://podman.io/getting-started/installation", .{});
        return false;
    };
    defer allocator.free(version_result.stdout);
    defer allocator.free(version_result.stderr);

    if (version_result.term.Exited != 0) {
        return false;
    }

    logInfo("Using Podman version: {s}", .{std.mem.trim(u8, version_result.stdout, " \n\r\t")});

    // Check if podman machine is running (for macOS/Windows)
    const ping_result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "podman", "system", "connection", "list" },
    }) catch {
        logError("Failed to check Podman connections", .{});
        return false;
    };
    defer allocator.free(ping_result.stdout);
    defer allocator.free(ping_result.stderr);

    if (ping_result.term.Exited != 0) {
        logError("Podman is not running properly", .{});
        logInfo("On macOS/Windows, try: podman machine init && podman machine start", .{});
        return false;
    }

    return true;
}

fn buildImage(allocator: std.mem.Allocator, config: Config) !bool {
    const image_tag = try std.fmt.allocPrint(allocator, "{s}/{s}:{s}-{s}", .{ config.registry, config.image_name, config.target, config.tag });
    defer allocator.free(image_tag);

    logInfo("Building {s} image: {s}", .{ config.target, image_tag });
    if (config.platform) |platform| {
        logInfo("Target platform: {s}", .{platform});
    }

    var build_args = ArrayList([]const u8).init(allocator);
    defer build_args.deinit();

    try build_args.appendSlice(&[_][]const u8{ "podman", "build" });

    if (config.no_cache) {
        try build_args.append("--no-cache");
    }

    if (config.platform) |platform| {
        try build_args.appendSlice(&[_][]const u8{ "--platform", platform });
    }

    try build_args.appendSlice(&[_][]const u8{ "--target", config.target });
    try build_args.appendSlice(&[_][]const u8{ "-f", config.containerfile });
    try build_args.appendSlice(&[_][]const u8{ "-t", image_tag });
    try build_args.append(".");

    const joined_cmd = try std.mem.join(allocator, " ", build_args.items);
    defer allocator.free(joined_cmd);
    logInfo("Executing: {s}", .{joined_cmd});

    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = build_args.items,
    }) catch |err| {
        logError("Failed to execute podman build: {}", .{err});
        return false;
    };
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    if (result.term.Exited == 0) {
        logSuccess("Successfully built {s} image", .{config.target});

        // Show image info
        const images_result = std.process.Child.run(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "podman", "images", image_tag, "--format", "table {{.Repository}} {{.Tag}} {{.Size}} {{.Created}}" },
        }) catch {
            logError("Failed to show image info", .{});
            return true; // Build succeeded, just info failed
        };
        defer allocator.free(images_result.stdout);
        defer allocator.free(images_result.stderr);

        print("{s}", .{images_result.stdout});

        // Push if requested
        if (config.push) {
            logInfo("Pushing {s} to registry...", .{image_tag});
            const push_result = std.process.Child.run(.{
                .allocator = allocator,
                .argv = &[_][]const u8{ "podman", "push", image_tag },
            }) catch {
                logError("Failed to push {s}", .{image_tag});
                return false;
            };
            defer allocator.free(push_result.stdout);
            defer allocator.free(push_result.stderr);

            if (push_result.term.Exited == 0) {
                logSuccess("Successfully pushed {s}", .{image_tag});
            } else {
                logError("Failed to push {s}", .{image_tag});
                return false;
            }
        }
        return true;
    } else {
        logError("Failed to build {s} image", .{config.target});
        if (result.stderr.len > 0) {
            print("Error output: {s}\n", .{result.stderr});
        }
        return false;
    }
}

fn buildAll(allocator: std.mem.Allocator, config: Config) !bool {
    logInfo("Building all ctx CLI images...", .{});

    const targets: []const []const u8 = &[_][]const u8{ "runtime", "builder" };
    var failed = ArrayList([]const u8).init(allocator);
    defer failed.deinit();

    for (targets) |target| {
        var target_config = config;
        target_config.target = target;

        if (!try buildImage(allocator, target_config)) {
            try failed.append(target);
        }
    }

    if (failed.items.len == 0) {
        logSuccess("Successfully built all images", .{});

        // Show available images
        logInfo("Available images:", .{});
        const image_pattern = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ config.registry, config.image_name });
        defer allocator.free(image_pattern);

        const list_result = std.process.Child.run(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "podman", "images", image_pattern, "--format", "table {{.Repository}} {{.Tag}} {{.Size}} {{.Created}}" },
        }) catch {
            logError("Failed to list images", .{});
            return true; // Build succeeded, just listing failed
        };
        defer allocator.free(list_result.stdout);
        defer allocator.free(list_result.stderr);

        print("{s}", .{list_result.stdout});
        return true;
    } else {
        logError("Failed to build images: {s}", .{try std.mem.join(allocator, ", ", failed.items)});
        return false;
    }
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
        } else if (std.mem.eql(u8, arg, "--no-cache")) {
            config.no_cache = true;
        } else if (std.mem.eql(u8, arg, "--push")) {
            config.push = true;
        } else if (std.mem.eql(u8, arg, "--platform")) {
            if (i + 1 >= args.len) {
                logError("--platform requires a value", .{});
                return error.InvalidArgs;
            }
            i += 1;
            config.platform = args[i];
        } else if (std.mem.eql(u8, arg, "-f") or std.mem.eql(u8, arg, "--file")) {
            if (i + 1 >= args.len) {
                logError("--file requires a value", .{});
                return error.InvalidArgs;
            }
            i += 1;
            config.containerfile = args[i];
        } else if (std.mem.eql(u8, arg, "runtime") or std.mem.eql(u8, arg, "builder") or std.mem.eql(u8, arg, "all")) {
            config.target = arg;
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

    // Check prerequisites
    if (!try checkPodman(allocator)) {
        std.process.exit(1);
    }

    // Ensure we're in the project root
    const containerfile = std.fs.cwd().openFile("Containerfile", .{}) catch {
        logError("Containerfile not found. Run this script from the project root.", .{});
        std.process.exit(1);
    };
    containerfile.close();

    logInfo("Building ctx CLI containers with target: {s}", .{config.target});
    logInfo("Registry: {s}", .{config.registry});
    logInfo("Tag: {s}", .{config.tag});

    // Build images
    const success = if (std.mem.eql(u8, config.target, "all"))
        try buildAll(allocator, config)
    else
        try buildImage(allocator, config);

    if (success) {
        logSuccess("Container build process completed!", .{});
    } else {
        std.process.exit(1);
    }
}
