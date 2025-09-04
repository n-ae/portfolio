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

/// Enhanced shell detection with robust environment variable checking
/// Handles edge cases like shell symlinks, nested shells, and multiple shell indicators
pub fn detectShell() ShellType {
    // Priority 1: Check current shell context (most reliable)
    if (getEnv("ZSH_VERSION")) |_| return .zsh;
    if (getEnv("BASH_VERSION")) |_| return .bash;
    if (getEnv("FISH_VERSION")) |_| return .fish;

    // Priority 2: Check SHELL environment variable with enhanced parsing
    if (getEnv("SHELL")) |shell_path| {
        // Handle both absolute paths and symlinks
        if (std.mem.containsAtLeast(u8, shell_path, 1, "bash")) return .bash;
        if (std.mem.containsAtLeast(u8, shell_path, 1, "zsh")) return .zsh;
        if (std.mem.containsAtLeast(u8, shell_path, 1, "fish")) return .fish;
        // Handle common shell symlinks and alternatives
        if (std.mem.containsAtLeast(u8, shell_path, 1, "sh") and
            !std.mem.containsAtLeast(u8, shell_path, 1, "fish"))
        {
            // Could be dash, ash, or other sh-compatible - treat as bash for commands
            return .bash;
        }
    }

    // Priority 3: Check for Windows shells with multiple indicators
    if (getEnv("PSModulePath")) |_| {
        // Confirm PowerShell by checking multiple indicators
        if (getEnv("POWERSHELL_DISTRIBUTION_CHANNEL")) |_| return .powershell;
        if (getEnv("PSVersionTable")) |_| return .powershell;
        return .powershell; // PSModulePath is strong indicator
    }

    if (getEnv("COMSPEC")) |comspec| {
        if (std.mem.containsAtLeast(u8, comspec, 1, "cmd.exe")) return .cmd;
        if (std.mem.containsAtLeast(u8, comspec, 1, "powershell")) return .powershell;
    }

    // Priority 4: Check session-specific indicators
    if (getEnv("ZSH_NAME")) |_| return .zsh;
    if (getEnv("BASH")) |_| return .bash;

    // Priority 5: Platform-specific intelligent defaults
    return switch (@import("builtin").os.tag) {
        .windows => blk: {
            // Windows 10+ often has PowerShell as default
            if (getEnv("OS")) |os| {
                if (std.mem.containsAtLeast(u8, os, 1, "Windows_NT")) {
                    // Check if this is a modern Windows version
                    if (getEnv("PROCESSOR_ARCHITECTURE")) |_| return .powershell;
                }
            }
            break :blk .cmd;
        },
        .macos => blk: {
            // macOS Catalina+ defaults to zsh, but check for older versions
            if (getEnv("TERM_PROGRAM")) |term| {
                if (std.mem.containsAtLeast(u8, term, 1, "Apple_Terminal")) return .zsh;
                if (std.mem.containsAtLeast(u8, term, 1, "iTerm")) return .zsh;
            }
            break :blk .zsh;
        },
        else => blk: {
            // Linux/Unix: intelligent detection based on distribution hints
            if (getEnv("DESKTOP_SESSION")) |session| {
                if (std.mem.containsAtLeast(u8, session, 1, "ubuntu")) return .bash;
                if (std.mem.containsAtLeast(u8, session, 1, "fedora")) return .bash;
            }
            break :blk .bash;
        },
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

pub fn formatEnvVarCommand(allocator: std.mem.Allocator, env_var: EnvVar, shell_type: ShellType) ![]const u8 {
    return switch (shell_type) {
        .bash, .zsh, .fish => std.fmt.allocPrint(allocator, "export {s}=\"{s}\"", .{ env_var.key, env_var.value }),
        .cmd => std.fmt.allocPrint(allocator, "set {s}={s}", .{ env_var.key, env_var.value }),
        .powershell => std.fmt.allocPrint(allocator, "$env:{s}=\"{s}\"", .{ env_var.key, env_var.value }),
        .unknown => std.fmt.allocPrint(allocator, "# Unknown shell - skipping {s}", .{env_var.key}),
    };
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
