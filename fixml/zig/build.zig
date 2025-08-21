const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    // Target configurations for cross-compilation
    const targets = [_]std.Target.Query{
        .{ .cpu_arch = .aarch64, .os_tag = .macos },   // Apple Silicon
        .{ .cpu_arch = .x86_64, .os_tag = .linux },   // Linux AMD64
        .{ .cpu_arch = .x86_64, .os_tag = .windows }, // Windows AMD64
    };

    const target_names = [_][]const u8{ "aarch64-macos", "x86_64-linux", "x86_64-windows" };

    // Create executables for each target
    for (targets, target_names) |target_query, target_name| {
        const resolved_target = b.resolveTargetQuery(target_query);
        
        const exe = b.addExecutable(.{
            .name = b.fmt("fixml-{s}", .{target_name}),
            .root_source_file = b.path("src/main.zig"),
            .target = resolved_target,
            .optimize = optimize,
            .strip = optimize != .Debug,
        });

        const install_exe = b.addInstallArtifact(exe, .{});
        
        // Create a step for each target
        const target_step = b.step(
            b.fmt("build-{s}", .{target_name}), 
            b.fmt("Build for {s}", .{target_name})
        );
        target_step.dependOn(&install_exe.step);
    }

    // Default build step builds for current host
    const default_target = b.standardTargetOptions(.{});
    const exe = b.addExecutable(.{
        .name = "fixml",
        .root_source_file = b.path("src/main.zig"),
        .target = default_target,
        .optimize = optimize,
        .strip = optimize != .Debug,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Add a step to build all targets
    const build_all_step = b.step("build-all", "Build for all targets");
    for (target_names) |target_name| {
        const target_step_name = b.fmt("build-{s}", .{target_name});
        if (b.top_level_steps.get(target_step_name)) |target_step| {
            build_all_step.dependOn(&target_step.step);
        }
    }
}