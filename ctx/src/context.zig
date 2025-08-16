const std = @import("std");
const json = std.json;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const fs = std.fs;
const process = std.process;
const build_options = @import("build_options");

const shell = @import("shell.zig");
const validation = @import("validation.zig");
const config = @import("config.zig");
const storage = @import("storage.zig");
const context_commands = @import("context_commands.zig");
const Context = validation.Context;
const EnvVar = validation.EnvVar;
const eol = validation.eol;

inline fn getEnv(key: []const u8) ?[:0]const u8 {
    return std.posix.getenv(key);
}

pub const ContextManager = struct {
    allocator: Allocator,
    storage: storage.Storage,
    original_cwd: []const u8,

    const Self = @This();

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

    pub fn deinit(self: *Self) void {
        self.storage.deinit();
        self.allocator.free(self.original_cwd);
    }

    pub fn saveContext(self: *Self, name: []const u8) !void {
        try validation.validateContextName(name);
        const context = try self.captureCurrentContext(name);
        defer context.deinit(self.allocator);
        try self.storage.saveContext(&context, name);
        std.debug.print("✅ Context '{s}' saved!" ++ eol, .{name});
    }

    fn captureCurrentContext(self: *Self, name: []const u8) !Context {
        return Context{
            .name = try self.allocator.dupe(u8, name),
            .timestamp = std.time.timestamp(),
            .git_branch = self.getCurrentGitBranch() catch |err| switch (err) {
                error.OutOfMemory => return err,
                else => null, // Git not available or not in repo - that's OK
            },
            .working_directory = try self.getCurrentWorkingDirectory(),
            .open_files = self.getOpenFiles() catch &[_][]const u8{}, // Fallback to empty
            .environment_vars = self.getRelevantEnvVars() catch &[_]EnvVar{}, // Fallback to empty
            .terminal_commands = self.getRecentCommands() catch &[_][]const u8{}, // Fallback to empty
        };
    }

    fn getCurrentWorkingDirectory(self: *Self) ![]const u8 {
        var buf: [std.fs.max_path_bytes]u8 = undefined;
        const cwd = try std.process.getCwd(&buf);
        return try self.allocator.dupe(u8, cwd);
    }

    pub fn restoreContext(self: *Self, name: []const u8) !void {
        // Validate context name
        if (name.len == 0) {
            std.debug.print("❌ Context name cannot be empty" ++ eol, .{});
            return error.InvalidName;
        }

        const context = self.storage.loadContext(name) catch |err| switch (err) {
            error.FileNotFound => return,
            else => {
                std.debug.print("❌ Failed to load context: {}" ++ eol, .{err});
                return err;
            },
        };
        defer context.deinit(self.allocator);

        // Validate context data
        if (!validation.isContextValid(&context)) {
            std.debug.print("❌ Context '{s}' contains invalid data" ++ eol, .{name});
            return error.InvalidContext;
        }

        // Generate shell commands for restoration
        context_commands.ContextCommands.generateRestoreCommands(&context);
    }


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

    pub fn parseName(self: *Self, args: []const [:0]const u8) ![]const u8 {
        _ = self;
        if (args.len < 3) {
            return error.MissingName;
        }
        return args[2];
    }

    /// Print user-friendly error message for parsing errors
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

