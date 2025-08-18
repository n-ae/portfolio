const std = @import("std");
const json = std.json;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const fs = std.fs;
const process = std.process;
const build_options = @import("build_options");

const config = @import("config.zig");
const shell = @import("shell.zig");
const storage = @import("storage.zig");
const validation = @import("validation.zig");
const Context = validation.Context;
const EnvVar = validation.EnvVar;
const eol = validation.eol;

inline fn getEnv(key: []const u8) ?[:0]const u8 {
    return std.posix.getenv(key);
}

/// Manages context saving, restoration, and persistence operations
/// Handles the complete lifecycle of development context snapshots
pub const ContextManager = struct {
    allocator: Allocator,
    storage: storage.Storage,
    original_cwd: []const u8,

    const Self = @This();

    /// Initialize a new ContextManager with storage in the user's home directory
    /// Returns error if home directory cannot be accessed or storage initialization fails
    pub fn init(allocator: Allocator) !Self {
        const home_dir = getEnv("HOME") orelse config.Config.FALLBACK_HOME_DIR;

        // Store current working directory
        var buf: [std.fs.max_path_bytes]u8 = undefined;
        const original_cwd = try std.process.getCwd(&buf);
        const owned_cwd = try allocator.dupe(u8, original_cwd);

        // Initialize storage
        const ctx_storage = try storage.Storage.init(allocator, home_dir);

        return Self{
            .allocator = allocator,
            .storage = ctx_storage,
            .original_cwd = owned_cwd,
        };
    }

    /// Clean up allocated resources including storage and working directory string
    pub fn deinit(self: *Self) void {
        self.storage.deinit();
        self.allocator.free(self.original_cwd);
    }

    /// Capture and save the current development context with the given name
    /// Includes working directory, git branch, environment variables, and placeholder for editor state
    /// Returns error if context name is invalid or storage operation fails
    pub fn saveContext(self: *Self, name: []const u8) !void {
        try validation.validateContextName(name);
        const context = try self.captureCurrentContext(name);
        defer context.deinit(self.allocator);
        try self.storage.saveContext(&context, name);
        std.debug.print("✅ Context '{s}' saved!" ++ eol, .{name});
    }

    fn captureCurrentContext(self: *Self, name: []const u8) !Context {
        const context_name = try self.allocator.dupe(u8, name);
        const working_dir = try self.getCurrentWorkingDirectory();
        const git_branch = try self.captureGitBranch();
        const env_vars = try self.captureEnvironmentVars();
        const open_files = try self.captureOpenFiles();
        const recent_commands = try self.captureRecentCommands();

        return Context{
            .name = context_name,
            .timestamp = std.time.timestamp(),
            .git_branch = git_branch,
            .working_directory = working_dir,
            .open_files = open_files,
            .environment_vars = env_vars,
            .terminal_commands = recent_commands,
        };
    }

    fn captureGitBranch(self: *Self) !?[]const u8 {
        return self.getCurrentGitBranch() catch |err| switch (err) {
            error.OutOfMemory => return err,
            else => null, // Git not available or not in repo - that's OK
        };
    }

    fn captureEnvironmentVars(self: *Self) ![]EnvVar {
        return self.getRelevantEnvVars() catch &[_]EnvVar{}; // Fallback to empty
    }

    fn captureOpenFiles(self: *Self) ![][]const u8 {
        return self.getOpenFiles() catch &[_][]const u8{}; // Fallback to empty
    }

    fn captureRecentCommands(self: *Self) ![][]const u8 {
        return self.getRecentCommands() catch &[_][]const u8{}; // Fallback to empty
    }

    fn getCurrentWorkingDirectory(self: *Self) ![]const u8 {
        var buf: [std.fs.max_path_bytes]u8 = undefined;
        const cwd = try std.process.getCwd(&buf);
        return try self.allocator.dupe(u8, cwd);
    }

    /// Load and display shell commands to restore a previously saved context
    /// Generates platform-appropriate commands for directory change, git branch switch, and environment setup
    /// Prints user-friendly error if context does not exist
    pub fn restoreContext(self: *Self, name: []const u8) !void {
        const context = self.storage.loadContext(name) catch |err| switch (err) {
            error.FileNotFound => {
                std.debug.print("❌ Context '{s}' not found" ++ eol, .{name});
                return;
            },
            else => return err,
        };
        defer context.deinit(self.allocator);

        const restore_commands = try generateRestoreCommands(self.allocator, &context);
        defer {
            self.allocator.free(restore_commands.header);
            self.allocator.free(restore_commands.footer);
            for (restore_commands.commands) |cmd| {
                self.allocator.free(cmd.command);
            }
            self.allocator.free(restore_commands.commands);
        }
        printRestoreCommands(restore_commands);
    }

    /// Display all saved contexts with timestamps showing when they were created
    /// Shows helpful message with save command example if no contexts exist
    pub fn listContexts(self: *Self) !void {
        const contexts = self.storage.listContexts() catch |err| switch (err) {
            else => return err,
        };
        defer storage.freeContextInfoList(self.allocator, contexts);

        std.debug.print("📋 Saved contexts:" ++ eol, .{});
        if (contexts.len == 0) {
            const saveHelp = build_options.package.name ++ " save <name>";
            std.debug.print("  (none yet - use '{s}' to create one)", .{saveHelp});
            return;
        }

        for (contexts) |context| {
            if (context.timestamp) |timestamp| {
                const time_ago = std.time.timestamp() - timestamp;
                std.debug.print("  • {s} (saved {d}s ago)" ++ eol, .{ context.name, time_ago });
            } else {
                std.debug.print("  • {s}" ++ eol, .{context.name});
            }
        }
    }

    /// Permanently delete a saved context by name
    /// Shows user-friendly error message if context does not exist
    pub fn deleteContext(self: *Self, name: []const u8) !void {
        const deleted = try self.storage.deleteContext(name);
        if (!deleted) {
            std.debug.print("❌ Context '{s}' not found" ++ eol, .{name});
            return;
        }

        std.debug.print("🗑️  Context '{s}' deleted" ++ eol, .{name});
    }

    fn getCurrentGitBranch(self: *Self) !?[]const u8 {
        var child = std.process.Child.init(&[_][]const u8{ "git", "branch", "--show-current" }, self.allocator);
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;

        try child.spawn();
        const stdout = try child.stdout.?.readToEndAlloc(self.allocator, config.Config.MAX_GIT_OUTPUT_SIZE);
        defer self.allocator.free(stdout);
        _ = try child.wait();

        if (stdout.len == 0) return null;

        // Trim OS-specific newline and duplicate the result to return owned memory
        const trimmed = if (std.mem.endsWith(u8, stdout, eol))
            stdout[0 .. stdout.len - eol.len]
        else
            stdout;

        return try self.allocator.dupe(u8, trimmed);
    }

    fn getOpenFiles(self: *Self) ![][]const u8 {
        // Placeholder - would integrate with editors like VS Code, Neovim
        var files = ArrayList([]const u8).init(self.allocator);
        // For now, just return empty array
        return files.toOwnedSlice();
    }

    fn getRelevantEnvVars(self: *Self) ![]EnvVar {
        var env_vars = ArrayList(EnvVar).init(self.allocator);

        // Save common dev environment variables
        const dev_vars = config.Config.DEV_ENV_VARS;

        for (dev_vars) |var_name| {
            if (getEnv(var_name)) |value| {
                try env_vars.append(EnvVar{
                    .key = try self.allocator.dupe(u8, var_name),
                    .value = try self.allocator.dupe(u8, value),
                });
            }
        }

        return env_vars.toOwnedSlice();
    }

    fn getRecentCommands(self: *Self) ![][]const u8 {
        // Placeholder - would read from shell history
        var commands = ArrayList([]const u8).init(self.allocator);
        return commands.toOwnedSlice();
    }

    /// Extract context name from command line arguments
    /// Returns error if required name argument is missing
    pub fn parseName(self: *Self, args: []const [:0]const u8) ![]const u8 {
        _ = self;
        if (args.len < 3) {
            return error.MissingName;
        }
        return args[2];
    }

    /// Display user-friendly error messages for command parsing failures
    /// Provides usage examples and specific guidance based on error type
    pub fn printParseError(command: []const u8, err: anyerror) void {
        switch (err) {
            error.MissingName => {
                std.debug.print("❌ Context name required for {s} command" ++ eol, .{command});
                std.debug.print("Usage: {s} {s} <name>" ++ eol, .{ build_options.package.name, command });
            },
            else => {
                std.debug.print("❌ Error parsing {s} command: {}" ++ eol, .{ command, err });
            },
        }
    }
};

const RestoreCommand = struct {
    command: []const u8,
    is_warning: bool = false,
};

const RestoreCommands = struct {
    header: []const u8,
    commands: []RestoreCommand,
    footer: []const u8,
};

/// Generate platform-appropriate shell commands to restore a saved development context
/// Returns structured commands for directory change, git branch switch, and environment variables
/// Validates each component and provides warnings for unavailable resources
fn generateRestoreCommands(allocator: std.mem.Allocator, context: *const Context) !RestoreCommands {
    var commands = std.ArrayList(RestoreCommand).init(allocator);

    // Change directory command
    if (validateDirectory(context.working_directory)) {
        const cd_cmd = try std.fmt.allocPrint(allocator, "cd \"{s}\"", .{context.working_directory});
        try commands.append(.{ .command = cd_cmd });
    } else |err| {
        const warning = try std.fmt.allocPrint(allocator, "# Warning: Could not access directory '{s}': {}", .{ context.working_directory, err });
        try commands.append(.{ .command = warning, .is_warning = true });
        try commands.append(.{ .command = "# Staying in current directory", .is_warning = true });
    }

    // Git branch switching command
    if (context.git_branch) |branch| {
        if (validation.validateGitBranch(branch)) {
            const git_cmd = try std.fmt.allocPrint(allocator, "git switch \"{s}\"", .{branch});
            try commands.append(.{ .command = git_cmd });
        } else |err| {
            const warning = try std.fmt.allocPrint(allocator, "# Warning: Git branch '{s}' not available: {}", .{ branch, err });
            try commands.append(.{ .command = warning, .is_warning = true });
        }
    }

    // Environment variable commands
    const shell_type = shell.detectShell();
    for (context.environment_vars) |env_var| {
        if (validation.isEnvVarValid(env_var)) {
            const env_cmd = shell.formatEnvVarCommand(allocator, env_var, shell_type) catch continue;
            try commands.append(.{ .command = env_cmd });
        } else {
            const warning = try std.fmt.allocPrint(allocator, "# Warning: Skipping invalid env var: {s}", .{env_var.key});
            try commands.append(.{ .command = warning, .is_warning = true });
        }
    }

    const header = try std.fmt.allocPrint(allocator, "# Restoring context '{s}'...", .{context.name});

    const git_info = if (context.git_branch) |branch|
        try std.fmt.allocPrint(allocator, "# Git branch: {s}", .{branch})
    else
        try allocator.dupe(u8, "");
    defer allocator.free(git_info);

    const footer = try std.fmt.allocPrint(allocator, "# ✅ Context '{s}' restored!\n# Directory: {s}\n{s}", .{ context.name, context.working_directory, git_info });

    return RestoreCommands{
        .header = header,
        .commands = try commands.toOwnedSlice(),
        .footer = footer,
    };
}

/// Output restore commands to stdout with proper formatting
/// Displays header, individual commands, and summary footer
fn printRestoreCommands(restore_commands: RestoreCommands) void {
    std.debug.print("{s}" ++ eol, .{restore_commands.header});

    for (restore_commands.commands) |cmd| {
        std.debug.print("{s}" ++ eol, .{cmd.command});
    }

    std.debug.print("{s}" ++ eol, .{restore_commands.footer});
}

/// Check if a directory exists and can be accessed by the current user
/// Returns specific errors for file not found or permission denied cases
fn validateDirectory(dir_path: []const u8) !void {
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
