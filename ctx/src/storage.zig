const std = @import("std");
const json = std.json;
const fs = std.fs;
const Allocator = std.mem.Allocator;
const build_options = @import("build_options");

const config = @import("config.zig");
const validation = @import("validation.zig");
const Context = validation.Context;
const eol = validation.eol;

/// Storage format version for compatibility tracking
pub const STORAGE_VERSION = "1.0";

/// Versioned context structure for JSON storage
const VersionedContext = struct {
    // Metadata
    version: []const u8 = STORAGE_VERSION,
    created_with: []const u8,

    // Context data (flattened from Context struct)
    name: []const u8,
    timestamp: i64,
    git_branch: ?[]const u8,
    working_directory: []const u8,
    open_files: [][]const u8,
    environment_vars: []validation.EnvVar,
    terminal_commands: [][]const u8,

    /// Create from standard Context
    pub fn fromContext(allocator: Allocator, context: *const Context) !VersionedContext {
        const version_str = build_options.package.name ++ " v" ++ build_options.package.version;

        return VersionedContext{
            .version = try allocator.dupe(u8, STORAGE_VERSION),
            .created_with = try allocator.dupe(u8, version_str),
            .name = try allocator.dupe(u8, context.name),
            .timestamp = context.timestamp,
            .git_branch = if (context.git_branch) |branch| try allocator.dupe(u8, branch) else null,
            .working_directory = try allocator.dupe(u8, context.working_directory),
            .open_files = try duplicateStringSlice(allocator, context.open_files),
            .environment_vars = try duplicateEnvVars(allocator, context.environment_vars),
            .terminal_commands = try duplicateStringSlice(allocator, context.terminal_commands),
        };
    }

    /// Convert to standard Context
    pub fn toContext(self: *const VersionedContext, allocator: Allocator) !Context {
        return Context{
            .name = try allocator.dupe(u8, self.name),
            .timestamp = self.timestamp,
            .git_branch = if (self.git_branch) |branch| try allocator.dupe(u8, branch) else null,
            .working_directory = try allocator.dupe(u8, self.working_directory),
            .open_files = try duplicateStringSlice(allocator, self.open_files),
            .environment_vars = try duplicateEnvVars(allocator, self.environment_vars),
            .terminal_commands = try duplicateStringSlice(allocator, self.terminal_commands),
        };
    }

    /// Clean up allocated memory
    pub fn deinit(self: *const VersionedContext, allocator: Allocator) void {
        allocator.free(self.version);
        allocator.free(self.created_with);
        allocator.free(self.name);
        if (self.git_branch) |branch| {
            allocator.free(branch);
        }
        allocator.free(self.working_directory);

        for (self.open_files) |file| {
            allocator.free(file);
        }
        allocator.free(self.open_files);

        for (self.environment_vars) |env_var| {
            allocator.free(env_var.key);
            allocator.free(env_var.value);
        }
        allocator.free(self.environment_vars);

        for (self.terminal_commands) |cmd| {
            allocator.free(cmd);
        }
        allocator.free(self.terminal_commands);
    }
};

/// Helper function to duplicate string slice
fn duplicateStringSlice(allocator: Allocator, source: [][]const u8) ![][]const u8 {
    const result = try allocator.alloc([]const u8, source.len);
    for (source, 0..) |str, i| {
        result[i] = try allocator.dupe(u8, str);
    }
    return result;
}

/// Helper function to duplicate environment variables
fn duplicateEnvVars(allocator: Allocator, source: []validation.EnvVar) ![]validation.EnvVar {
    const result = try allocator.alloc(validation.EnvVar, source.len);
    for (source, 0..) |env_var, i| {
        result[i] = validation.EnvVar{
            .key = try allocator.dupe(u8, env_var.key),
            .value = try allocator.dupe(u8, env_var.value),
        };
    }
    return result;
}

/// Storage interface for context data persistence
pub const Storage = struct {
    allocator: Allocator,
    contexts_dir: []const u8,

    const Self = @This();

    /// Initialize storage with contexts directory
    pub fn init(allocator: Allocator, home_dir: []const u8) !Self {
        const contexts_dir = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ home_dir, config.Config.CONTEXTS_DIR_NAME });

        // Ensure contexts directory exists
        fs.cwd().makeDir(contexts_dir) catch |err| switch (err) {
            error.PathAlreadyExists => {},
            else => return err,
        };

        return Self{
            .allocator = allocator,
            .contexts_dir = contexts_dir,
        };
    }

    /// Clean up allocated resources
    pub fn deinit(self: *Self) void {
        self.allocator.free(self.contexts_dir);
    }

    /// Get the full file path for a context
    fn getContextFilePath(self: *Self, name: []const u8) ![]const u8 {
        return try std.fmt.allocPrint(self.allocator, "{s}/{s}{s}", .{ self.contexts_dir, name, config.Config.CONTEXT_FILE_EXTENSION });
    }

    /// Save a context to storage
    pub fn saveContext(self: *Self, context: *const Context, name: []const u8) !void {
        const temp_file = try std.fmt.allocPrint(self.allocator, "{s}/.{s}.tmp", .{ self.contexts_dir, name });
        defer self.allocator.free(temp_file);

        const final_file = try self.getContextFilePath(name);
        defer self.allocator.free(final_file);

        try self.writeToTempFile(context, temp_file);
        try self.atomicRename(temp_file, final_file);
    }

    /// Load a context from storage
    pub fn loadContext(self: *Self, name: []const u8) !Context {
        const file = try self.openContextFile(name);
        defer file.close();

        const content = try file.readToEndAlloc(self.allocator, config.Config.MAX_FILE_SIZE);
        defer self.allocator.free(content);

        const parsed = try json.parseFromSlice(VersionedContext, self.allocator, content, .{ .allocate = .alloc_always });
        defer parsed.deinit();

        const versioned_context = parsed.value;
        const context = try versioned_context.toContext(self.allocator);

        return context;
    }

    /// Delete a context from storage
    pub fn deleteContext(self: *Self, name: []const u8) !bool {
        const context_file = try self.getContextFilePath(name);
        defer self.allocator.free(context_file);

        fs.cwd().deleteFile(context_file) catch |err| switch (err) {
            error.FileNotFound => return false,
            else => return err,
        };

        return true;
    }

    /// List all available contexts
    pub fn listContexts(self: *Self) ![]ContextInfo {
        var contexts = std.ArrayList(ContextInfo).init(self.allocator);
        defer contexts.deinit();

        var dir = fs.cwd().openDir(self.contexts_dir, .{ .iterate = true }) catch |err| switch (err) {
            error.FileNotFound => return try contexts.toOwnedSlice(),
            else => return err,
        };
        defer dir.close();

        var iterator = dir.iterate();
        while (try iterator.next()) |entry| {
            if (entry.kind == .file and std.mem.endsWith(u8, entry.name, config.Config.CONTEXT_FILE_EXTENSION)) {
                const name = entry.name[0 .. entry.name.len - config.Config.CONTEXT_FILE_EXTENSION.len];

                // Try to read timestamp for better display
                const timestamp = self.getContextTimestamp(entry.name) catch null;

                try contexts.append(ContextInfo{
                    .name = try self.allocator.dupe(u8, name),
                    .timestamp = timestamp,
                });
            }
        }

        return try contexts.toOwnedSlice();
    }

    /// Check if a context exists
    pub fn contextExists(self: *Self, name: []const u8) bool {
        const context_file = self.getContextFilePath(name) catch return false;
        defer self.allocator.free(context_file);

        fs.cwd().access(context_file, .{}) catch return false;
        return true;
    }

    // Private helper methods

    fn openContextFile(self: *Self, name: []const u8) !fs.File {
        const context_file = try self.getContextFilePath(name);
        defer self.allocator.free(context_file);

        return fs.cwd().openFile(context_file, .{}) catch |err| switch (err) {
            error.FileNotFound => {
                std.debug.print("❌ Context '{s}' not found" ++ eol, .{name});
                return error.FileNotFound;
            },
            else => {
                std.debug.print("❌ Failed to open context file: {}" ++ eol, .{err});
                return err;
            },
        };
    }

    fn writeToTempFile(self: *Self, context: *const Context, temp_file: []const u8) !void {
        const versioned_context = try VersionedContext.fromContext(self.allocator, context);
        defer versioned_context.deinit(self.allocator);

        const file = fs.cwd().createFile(temp_file, .{}) catch |err| {
            std.debug.print("❌ Failed to create context file: {}" ++ eol, .{err});
            return err;
        };
        defer file.close();

        json.stringify(versioned_context, .{ .whitespace = .indent_2 }, file.writer()) catch |err| {
            std.debug.print("❌ Failed to write context data: {}" ++ eol, .{err});
            fs.cwd().deleteFile(temp_file) catch {}; // Clean up temp file
            return err;
        };
    }

    fn atomicRename(self: *Self, temp_file: []const u8, final_file: []const u8) !void {
        _ = self;

        fs.cwd().rename(temp_file, final_file) catch |err| {
            std.debug.print("❌ Failed to finalize context save: {}" ++ eol, .{err});
            fs.cwd().deleteFile(temp_file) catch {}; // Clean up temp file
            return err;
        };
    }

    /// Duplicate a string slice with owned memory
    fn duplicateStringSlice(self: *Self, source: [][]const u8) ![][]const u8 {
        const result = try self.allocator.alloc([]const u8, source.len);
        for (source, 0..) |str, i| {
            result[i] = try self.allocator.dupe(u8, str);
        }
        return result;
    }

    /// Duplicate environment variables with owned memory
    fn duplicateEnvVars(self: *Self, source: []validation.EnvVar) ![]validation.EnvVar {
        const result = try self.allocator.alloc(validation.EnvVar, source.len);
        for (source, 0..) |env_var, i| {
            result[i] = validation.EnvVar{
                .key = try self.allocator.dupe(u8, env_var.key),
                .value = try self.allocator.dupe(u8, env_var.value),
            };
        }
        return result;
    }

    fn getContextTimestamp(self: *Self, filename: []const u8) !?i64 {
        const context_file = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ self.contexts_dir, filename });
        defer self.allocator.free(context_file);

        const file = fs.cwd().openFile(context_file, .{}) catch return null;
        defer file.close();

        const content = file.readToEndAlloc(self.allocator, config.Config.MAX_PREVIEW_SIZE) catch return null;
        defer self.allocator.free(content);

        const parsed = json.parseFromSlice(VersionedContext, self.allocator, content, .{}) catch return null;
        defer parsed.deinit();

        return parsed.value.timestamp;
    }
};

/// Information about a stored context
pub const ContextInfo = struct {
    name: []const u8,
    timestamp: ?i64,

    pub fn deinit(self: *ContextInfo, allocator: Allocator) void {
        allocator.free(self.name);
    }
};

/// Free a list of ContextInfo structs
pub fn freeContextInfoList(allocator: Allocator, contexts: []ContextInfo) void {
    for (contexts) |*context| {
        context.deinit(allocator);
    }
    allocator.free(contexts);
}

