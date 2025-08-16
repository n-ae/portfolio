const std = @import("std");
const shell = @import("shell.zig");
const validation = @import("validation.zig");
const Context = validation.Context;
const eol = validation.eol;

/// Context Command Generator
/// Handles generation of shell commands for context restoration
pub const ContextCommands = struct {
    /// Generate shell commands to restore a context
    pub fn generateRestoreCommands(context: *const Context) void {
        std.debug.print("# Restoring context '{s}'..." ++ eol, .{context.name});

        // Change directory command
        generateDirectoryCommand(context.working_directory);

        // Git branch switching command
        if (context.git_branch) |branch| {
            generateGitCommand(branch);
        }

        // Environment variable commands
        generateEnvVarCommands(context.environment_vars);

        // Success message
        generateSuccessMessage(context);
    }

    /// Generate directory change command with validation
    fn generateDirectoryCommand(working_directory: []const u8) void {
        if (validateDirectory(working_directory)) {
            std.debug.print("cd \"{s}\"" ++ eol, .{working_directory});
        } else |err| {
            std.debug.print("# Warning: Could not access directory '{s}': {}" ++ eol, .{ working_directory, err });
            std.debug.print("# Staying in current directory" ++ eol, .{});
        }
    }

    /// Generate git branch switching command with validation
    fn generateGitCommand(branch: []const u8) void {
        if (validation.validateGitBranch(branch)) {
            std.debug.print("git switch \"{s}\"" ++ eol, .{branch});
        } else |err| {
            std.debug.print("# Warning: Git branch '{s}' not available: {}" ++ eol, .{ branch, err });
        }
    }

    /// Generate environment variable commands
    fn generateEnvVarCommands(env_vars: []const validation.EnvVar) void {
        const shell_type = shell.detectShell();
        
        for (env_vars) |env_var| {
            if (validation.isEnvVarValid(env_var)) {
                shell.printEnvVarCommand(env_var, shell_type);
            } else {
                std.debug.print("# Warning: Skipping invalid env var: {s}" ++ eol, .{env_var.key});
            }
        }
    }

    /// Generate success message with context details
    fn generateSuccessMessage(context: *const Context) void {
        std.debug.print("# ✅ Context '{s}' restored!" ++ eol, .{context.name});
        std.debug.print("# Directory: {s}" ++ eol, .{context.working_directory});
        
        if (context.git_branch) |branch| {
            std.debug.print("# Git branch: {s}" ++ eol, .{branch});
        }
    }

    /// Validate that a directory exists and is accessible
    fn validateDirectory(dir_path: []const u8) !void {
        // Check if directory exists and is accessible
        var dir = std.fs.cwd().openDir(dir_path, .{}) catch |err| switch (err) {
            error.FileNotFound => {
                std.debug.print("# Directory '{s}' doesn't exist, staying in current directory" ++ eol, .{dir_path});
                return error.DirectoryNotFound;
            },
            error.AccessDenied => {
                std.debug.print("# Access denied to '{s}'" ++ eol, .{dir_path});
                return error.AccessDenied;
            },
            else => return err,
        };
        defer dir.close();
    }
};