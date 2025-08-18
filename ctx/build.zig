const std = @import("std");

const zon_package: struct {
    name: enum { ctx },
    version: []const u8,
    fingerprint: u64,
    minimum_zig_version: []const u8,
    dependencies: struct {
        clap: struct {
            url: []const u8,
            hash: []const u8,
        },
    },
    paths: []const []const u8,
} = @import("build.zig.zon");

const PackageInfo = struct {
    name: []const u8,
    version: []const u8,
};

const package = PackageInfo{ .name = @tagName(zon_package.name), .version = zon_package.version };

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create build options to pass package info to the executable
    const options = b.addOptions();
    options.addOption(comptime PackageInfo, "package", package);

    // Main executable module
    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = package.name,
        .root_module = exe_mod,
    });

    const clap = b.dependency("clap", .{});
    exe.root_module.addImport("clap", clap.module("clap"));
    exe.root_module.addImport("build_options", options.createModule());

    b.installArtifact(exe);

    // Run step for the executable
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Testing infrastructure
    
    // Unified test runner - single executable for all test types
    const test_runner = b.addExecutable(.{
        .name = "test",
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_runner.root_module.addImport("build_options", options.createModule());
    test_runner.root_module.addImport("clap", clap.module("clap"));
    b.installArtifact(test_runner);

    // Single unified test step - runs all tests by default, accepts args for test runner
    const test_cmd = b.addRunArtifact(test_runner);
    test_cmd.step.dependOn(b.getInstallStep());

    // Forward arguments to test runner (default: all tests)
    if (b.args) |args| {
        test_cmd.addArgs(args);
    } else {
        test_cmd.addArgs(&[_][]const u8{ "--type", "all" });
    }

    const test_step = b.step("test", "Run all tests (unit + integration + performance + blackbox). Use -- to pass options to test runner");
    test_step.dependOn(&test_cmd.step);
}
