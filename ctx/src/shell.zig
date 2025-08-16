const std = @import("std");

const validation = @import("validation.zig");
const eol = validation.eol;
const EnvVar = validation.EnvVar;

pub const ShellType = enum {
    bash,
    zsh,
    fish,
    cmd,
    powershell,
    unknown,
};

inline fn getEnv(key: []const u8) ?[:0]const u8 {
    return std.posix.getenv(key);
}

pub fn detectShell() ShellType {
    // Check SHELL environment variable first (Unix-like systems)
    if (getEnv("SHELL")) |shell_path| {
        if (std.mem.endsWith(u8, shell_path, "/bash")) return .bash;
        if (std.mem.endsWith(u8, shell_path, "/zsh")) return .zsh;
        if (std.mem.endsWith(u8, shell_path, "/fish")) return .fish;
    }

    // Check for Windows shells
    if (getEnv("PSModulePath")) |_| return .powershell;
    if (getEnv("COMSPEC")) |comspec| {
        if (std.mem.endsWith(u8, comspec, "cmd.exe")) return .cmd;
    }

    // Platform-specific defaults
    return switch (@import("builtin").os.tag) {
        .windows => .cmd,
        .macos => .zsh, // macOS default since Catalina
        else => .bash, // Most Linux distributions
    };
}

pub fn printEnvVarCommand(env_var: EnvVar, shell_type: ShellType) void {
    switch (shell_type) {
        .bash, .zsh, .fish => {
            std.debug.print("export {s}=\"{s}\"" ++ eol, .{ env_var.key, env_var.value });
        },
        .cmd => {
            std.debug.print("set {s}={s}" ++ eol, .{ env_var.key, env_var.value });
        },
        .powershell => {
            std.debug.print("$env:{s}=\"{s}\"" ++ eol, .{ env_var.key, env_var.value });
        },
        .unknown => {
            // Skip env vars for unknown shells
        },
    }
}

pub fn printDirectoryChangeCommand(directory: []const u8, shell_type: ShellType) void {
    switch (shell_type) {
        .bash, .zsh => {
            std.debug.print("pushd \"{s}\"" ++ eol, .{directory});
        },
        .cmd => {
            std.debug.print("pushd \"{s}\"" ++ eol, .{directory});
        },
        .powershell => {
            std.debug.print("Push-Location \"{s}\"" ++ eol, .{directory});
        },
        .fish => {
            std.debug.print("pushd \"{s}\"" ++ eol, .{directory});
        },
        .unknown => {
            // Fallback to simple cd
            std.debug.print("cd \"{s}\"" ++ eol, .{directory});
        },
    }
}

