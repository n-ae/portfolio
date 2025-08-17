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

    // Testing infrastructure - Enhanced with CSV support
    
    // Unit tests with CSV support capability  
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/unit_tests_enhanced.zig"),
        .target = target,
        .optimize = optimize,
    });
    unit_tests.root_module.addImport("build_options", options.createModule());
    unit_tests.root_module.addImport("clap", clap.module("clap"));

    const exe_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const blackbox_exe = b.addExecutable(.{
        .name = "ctx-test",
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });
    blackbox_exe.root_module.addImport("build_options", options.createModule());
    b.installArtifact(blackbox_exe);

    // Core test steps
    const test_step = b.step("test", "Run all tests (unit + integration)");
    test_step.dependOn(&b.addRunArtifact(unit_tests).step);
    test_step.dependOn(&b.addRunArtifact(exe_tests).step);

    const blackbox_cmd = b.addRunArtifact(blackbox_exe);
    blackbox_cmd.addArg("./zig-out/bin/ctx");
    blackbox_cmd.step.dependOn(b.getInstallStep());

    const blackbox_step = b.step("test-blackbox", "Run blackbox tests");
    blackbox_step.dependOn(&blackbox_cmd.step);


    const test_runner = b.addExecutable(.{
        .name = "ctx-test-runner",
        .root_source_file = b.path("src/test_runner.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_runner.root_module.addImport("build_options", options.createModule());
    test_runner.root_module.addImport("clap", clap.module("clap"));
    b.installArtifact(test_runner);

    const test_unit_step = b.step("test-unit", "Run unit tests only");
    test_unit_step.dependOn(&b.addRunArtifact(unit_tests).step);

    const test_integration_step = b.step("test-integration", "Run integration tests only");
    test_integration_step.dependOn(&b.addRunArtifact(exe_tests).step);

    // Consolidated test runner steps
    const run_unit_csv_cmd = b.addRunArtifact(test_runner);
    run_unit_csv_cmd.addArgs(&[_][]const u8{ "--type", "unit", "--format", "csv" });
    run_unit_csv_cmd.step.dependOn(b.getInstallStep());
    const test_unit_csv_step = b.step("test-unit-csv", "Run unit tests with CSV output");
    test_unit_csv_step.dependOn(&run_unit_csv_cmd.step);

    const run_performance_cmd = b.addRunArtifact(test_runner);
    run_performance_cmd.addArgs(&[_][]const u8{ "--type", "performance" });
    run_performance_cmd.step.dependOn(b.getInstallStep());
    const performance_step = b.step("test-performance", "Run performance benchmarks");
    performance_step.dependOn(&run_performance_cmd.step);

    const run_performance_csv_cmd = b.addRunArtifact(test_runner);
    run_performance_csv_cmd.addArgs(&[_][]const u8{ "--type", "performance", "--format", "csv" });
    run_performance_csv_cmd.step.dependOn(b.getInstallStep());
    const performance_csv_step = b.step("test-performance-csv", "Run performance benchmarks with CSV output");
    performance_csv_step.dependOn(&run_performance_csv_cmd.step);

}
