const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    // Import the rgcidr module from parent directory
    const rgcidr_mod = b.addModule("rgcidr", .{
        .root_source_file = b.path("../src/root.zig"),
        .target = target,
    });
    
    // Basic usage example
    const basic_exe = b.addExecutable(.{
        .name = "basic_usage",
        .root_module = b.createModule(.{
            .root_source_file = b.path("basic_usage.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "rgcidr", .module = rgcidr_mod },
            },
        }),
    });
    b.installArtifact(basic_exe);
    
    // Advanced usage example
    const advanced_exe = b.addExecutable(.{
        .name = "advanced_usage",
        .root_module = b.createModule(.{
            .root_source_file = b.path("advanced_usage.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "rgcidr", .module = rgcidr_mod },
            },
        }),
    });
    b.installArtifact(advanced_exe);
    
    // Run steps for easy execution
    const run_basic = b.step("run-basic", "Run basic usage example");
    const run_basic_cmd = b.addRunArtifact(basic_exe);
    run_basic.dependOn(&run_basic_cmd.step);
    
    const run_advanced = b.step("run-advanced", "Run advanced usage example");
    const run_advanced_cmd = b.addRunArtifact(advanced_exe);
    run_advanced.dependOn(&run_advanced_cmd.step);
    
    // Run all examples
    const run_all = b.step("run-all", "Run all examples");
    run_all.dependOn(&run_basic_cmd.step);
    run_all.dependOn(&run_advanced_cmd.step);
}
