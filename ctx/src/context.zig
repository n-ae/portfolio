const std = @import("std");
const json = std.json;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const fs = std.fs;
const process = std.process;
const build_options = @import("build_options");

const validation = @import("validation.zig");
const shell = @import("shell.zig");

const Context = validation.Context;
const EnvVar = validation.EnvVar;
const eol = validation.eol;
const MAX_FILE_SIZE = 1024 * 1024;

inline fn getEnv(key: []const u8) ?[:0]const u8 {
    return std.posix.getenv(key);
}

pub const ContextManager = struct {
    allocator: Allocator,
    contexts_dir: []const u8,
    original_cwd: []const u8,

    const Self = @This();

    fn getContextFilePath(self: *Self, name: []const u8) ![]const u8 {
        return try std.fmt.allocPrint(self.allocator, "{s}/{s}.json", .{ self.contexts_dir, name });
    }

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

    pub fn init(allocator: Allocator) !Self {
        const home_dir = getEnv("HOME") orelse "/tmp";
        const contexts_dir = try std.fmt.allocPrint(allocator, "{s}/.{s}", .{ home_dir, build_options.package.name });

        // Store current working directory
        var buf: [std.fs.max_path_bytes]u8 = undefined;
        const original_cwd = try std.process.getCwd(&buf);
        const owned_cwd = try allocator.dupe(u8, original_cwd);

        // Ensure contexts directory exists
        fs.cwd().makeDir(contexts_dir) catch |err| switch (err) {
            error.PathAlreadyExists => {},
            else => return err,
        };

        return Self{
            .allocator = allocator,
            .contexts_dir = contexts_dir,
            .original_cwd = owned_cwd,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.contexts_dir);
        self.allocator.free(self.original_cwd);
    }

    pub fn saveContext(self: *Self, name: []const u8) !void {
        try validation.validateContextName(name);
        const context = try self.captureCurrentContext(name);
        defer context.deinit(self.allocator);
        try self.writeContextToFile(&context, name);
        std.debug.print("✅ Context '{s}' saved!" ++ eol, .{name});
    }

    fn captureCurrentContext(self: *Self, name: []const u8) !Context {
        return Context{
            .name = name,
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

    fn writeContextToFile(self: *Self, context: *const Context, name: []const u8) !void {
        const temp_file = try std.fmt.allocPrint(self.allocator, "{s}/.{s}.tmp", .{ self.contexts_dir, name });
        defer self.allocator.free(temp_file);
        
        const final_file = try self.getContextFilePath(name);
        defer self.allocator.free(final_file);

        try self.writeToTempFile(context, temp_file);
        try self.atomicRename(temp_file, final_file);
    }

    fn writeToTempFile(self: *Self, context: *const Context, temp_file: []const u8) !void {
        _ = self;
        const file = fs.cwd().createFile(temp_file, .{}) catch |err| {
            std.debug.print("❌ Failed to create context file: {}" ++ eol, .{err});
            return err;
        };
        defer file.close();

        json.stringify(context, .{ .whitespace = .indent_2 }, file.writer()) catch |err| {
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

    pub fn restoreContext(self: *Self, name: []const u8) !void {
        // Validate context name
        if (name.len == 0) {
            std.debug.print("❌ Context name cannot be empty" ++ eol, .{});
            return error.InvalidName;
        }

        const file = self.openContextFile(name) catch return;
        defer file.close();

        const content = file.readToEndAlloc(self.allocator, MAX_FILE_SIZE) catch |err| {
            std.debug.print("❌ Failed to read context file: {}" ++ eol, .{err});
            return err;
        };
        defer self.allocator.free(content);

        const parsed = json.parseFromSlice(Context, self.allocator, content, .{}) catch |err| {
            std.debug.print("❌ Invalid context file format: {}" ++ eol, .{err});
            return err;
        };
        defer parsed.deinit();
        const context = parsed.value;

        // Validate context data
        if (!validation.isContextValid(&context)) {
            std.debug.print("❌ Context '{s}' contains invalid data" ++ eol, .{name});
            return error.InvalidContext;
        }

        std.debug.print("# Restoring context '{s}'..." ++ eol, .{name});

        // Change directory - create if it doesn't exist
        if (self.ensureDirectoryExists(context.working_directory)) {
            std.debug.print("cd \"{s}\"" ++ eol, .{context.working_directory});
        } else |err| {
            std.debug.print("# Warning: Could not access directory '{s}': {}" ++ eol, .{ context.working_directory, err });
            std.debug.print("# Staying in current directory" ++ eol, .{});
        }

        // Switch git branch if available and valid
        if (context.git_branch) |branch| {
            if (validation.validateGitBranch(branch)) {
                std.debug.print("git switch \"{s}\"" ++ eol, .{branch});
            } else |err| {
                std.debug.print("# Warning: Git branch '{s}' not available: {}" ++ eol, .{ branch, err });
            }
        }

        // Restore environment vars with validation
        const shell_type = shell.detectShell();
        for (context.environment_vars) |env_var| {
            if (validation.isEnvVarValid(env_var)) {
                shell.printEnvVarCommand(env_var, shell_type);
            } else {
                std.debug.print("# Warning: Skipping invalid env var: {s}" ++ eol, .{env_var.key});
            }
        }

        std.debug.print("# ✅ Context '{s}' restored!" ++ eol, .{name});
        std.debug.print("# Directory: {s}" ++ eol, .{context.working_directory});
        if (context.git_branch) |branch| {
            std.debug.print("# Git branch: {s}" ++ eol, .{branch});
        }
    }

    fn ensureDirectoryExists(self: *Self, dir_path: []const u8) !void {
        _ = self;
        
        // Check if directory exists and is accessible
        var dir = fs.cwd().openDir(dir_path, .{}) catch |err| switch (err) {
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
        dir.close();
    }

    pub fn listContexts(self: *Self) !void {
        var dir = fs.cwd().openDir(self.contexts_dir, .{}) catch |err| switch (err) {
            error.FileNotFound => {
                const saveHelp = build_options.package.name ++ " save <name>";
                std.debug.print("No contexts saved yet. Use '{s}' to create one.", .{saveHelp});
                return;
            },
            else => return err,
        };
        defer dir.close();

        var iterator = dir.iterate();
        var found_any = false;

        std.debug.print("📋 Saved contexts:" ++ eol, .{});
        while (try iterator.next()) |entry| {
            if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".json")) {
                found_any = true;
                const name = entry.name[0 .. entry.name.len - 5]; // Remove .json

                // Try to read timestamp for better display
                const context_file = try std.fmt.allocPrint(self.allocator, "{s}/{s}", .{ self.contexts_dir, entry.name });
                defer self.allocator.free(context_file);

                if (fs.cwd().openFile(context_file, .{})) |file| {
                    defer file.close();
                    const content = file.readToEndAlloc(self.allocator, 1024) catch continue;
                    defer self.allocator.free(content);

                    if (json.parseFromSlice(Context, self.allocator, content, .{})) |parsed| {
                        defer parsed.deinit();
                        const context = parsed.value;
                        const time_ago = std.time.timestamp() - context.timestamp;
                        std.debug.print("  • {s} (saved {d}s ago)" ++ eol, .{ name, time_ago });
                    } else |_| {
                        std.debug.print("  • {s}" ++ eol, .{name});
                    }
                } else |_| {
                    std.debug.print("  • {s}" ++ eol, .{name});
                }
            }
        }

        if (!found_any) {
            const saveHelp = build_options.package.name ++ " save <name>";
            std.debug.print("  (none yet - use '{s}' to create one)", .{saveHelp});
        }
    }

    pub fn deleteContext(self: *Self, name: []const u8) !void {
        const context_file = try self.getContextFilePath(name);
        defer self.allocator.free(context_file);

        fs.cwd().deleteFile(context_file) catch |err| switch (err) {
            error.FileNotFound => {
                std.debug.print("❌ Context '{s}' not found" ++ eol, .{name});
                return;
            },
            else => return err,
        };

        std.debug.print("🗑️  Context '{s}' deleted" ++ eol, .{name});
    }

    fn getCurrentGitBranch(self: *Self) !?[]const u8 {
        var child = std.process.Child.init(&[_][]const u8{ "git", "branch", "--show-current" }, self.allocator);
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;

        try child.spawn();
        const stdout = try child.stdout.?.readToEndAlloc(self.allocator, 1024);
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
        const dev_vars = [_][]const u8{ "NODE_ENV", "PYTHONPATH", "GOPATH", "RUST_LOG", "DEBUG" };

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

    pub fn parseName(self: *Self, args: []const [:0]const u8, command: []const u8) ![]const u8 {
        _ = self;
        if (args.len < 3) {
            std.debug.print("❌ Context name required for {s} command" ++ eol, .{command});
            std.debug.print("Usage: {s} {s} <name>" ++ eol, .{ build_options.package.name, command });
            return error.MissingName;
        }
        return args[2];
    }
};