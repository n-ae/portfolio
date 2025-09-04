const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const final_optimize = if (optimize == .Debug) .ReleaseFast else optimize;

    const exe = b.addExecutable(.{
        .name = "fixml",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = final_optimize,
        }),
    });

    b.installArtifact(exe);
}