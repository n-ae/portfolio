const std = @import("std");
const json = std.json;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const fs = std.fs;
const process = std.process;
const build_options = @import("build_options");

const clap = @import("clap");

// OS-specific end-of-line character
const eol = switch (@import("builtin").os.tag) {
    .windows => "\r\n",
    else => "\n",
};

const SubCommand = enum {
    save,
    restore,
    list,
    delete,
};

const EnvVar = struct {
    key: []const u8,
    value: []const u8,
};

const Context = struct {
    name: []const u8,
    timestamp: i64,
    git_branch: ?[]const u8,
    working_directory: []const u8,
    open_files: [][]const u8,
    environment_vars: []EnvVar,
    terminal_commands: [][]const u8,

    pub fn deinit(self: *const Context, allocator: Allocator) void {
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

inline fn getEnv(key: []const u8) ?[:0]const u8 {
    return std.posix.getenv(key);
}

fn debugLine(comptime s: []const u8) void {
    std.debug.print(s ++ eol, .{});
}

const ContextManager = struct {
    allocator: Allocator,
    contexts_dir: []const u8,

    const Self = @This();

    pub fn init(allocator: Allocator) !Self {
        const home_dir = getEnv("HOME") orelse "/tmp";
        const contexts_dir = try std.fmt.allocPrint(allocator, "{s}/.{s}", .{ home_dir, build_options.package.name });

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

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.contexts_dir);
    }

    pub fn saveContext(self: *Self, name: []const u8) !void {
        const context = Context{
            .name = name,
            .timestamp = std.time.timestamp(),
            .git_branch = try self.getCurrentGitBranch(),
            .working_directory = blk: {
                var buf: [std.fs.max_path_bytes]u8 = undefined;
                const cwd = try std.process.getCwd(&buf);
                break :blk try self.allocator.dupe(u8, cwd);
            },
            .open_files = try self.getOpenFiles(),
            .environment_vars = try self.getRelevantEnvVars(),
            .terminal_commands = try self.getRecentCommands(),
        };

        const context_file = try std.fmt.allocPrint(self.allocator, "{s}/{s}.json", .{ self.contexts_dir, name });
        defer self.allocator.free(context_file);

        const file = try fs.cwd().createFile(context_file, .{});
        defer file.close();

        try json.stringify(context, .{}, file.writer());
        context.deinit(self.allocator);
        std.debug.print("✅ Context '{s}' saved!" ++ eol, .{name});
    }

    pub fn restoreContext(self: *Self, name: []const u8) !void {
        const context_file = try std.fmt.allocPrint(self.allocator, "{s}/{s}.json", .{ self.contexts_dir, name });
        defer self.allocator.free(context_file);

        const file = fs.cwd().openFile(context_file, .{}) catch |err| switch (err) {
            error.FileNotFound => {
                std.debug.print("❌ Context '{s}' not found" ++ eol, .{name});
                return;
            },
            else => return err,
        };
        defer file.close();

        const content = try file.readToEndAlloc(self.allocator, 1024 * 1024);
        defer self.allocator.free(content);

        const parsed = try json.parseFromSlice(Context, self.allocator, content, .{});
        defer parsed.deinit();
        const context = parsed.value;

        // Change to saved directory
        try std.posix.chdir(context.working_directory);

        // Switch git branch if different
        if (context.git_branch) |branch| {
            try self.switchGitBranch(branch);
        }

        // TODO: Restore open files, environment vars, etc.
        std.debug.print("🔄 Context '{s}' restored! (Directory: {s})" ++ eol, .{ name, context.working_directory });

        if (context.git_branch) |branch| {
            std.debug.print("📂 Git branch: {s}" ++ eol, .{branch});
        }
    }

    pub fn listContexts(self: *Self) !void {
        var dir = fs.cwd().openDir(self.contexts_dir, .{}) catch |err| switch (err) {
            error.FileNotFound => {
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
            std.debug.print("  (none yet - use '{s}' to create one)", .{saveHelp});
        }
    }

    pub fn deleteContext(self: *Self, name: []const u8) !void {
        const context_file = try std.fmt.allocPrint(self.allocator, "{s}/{s}.json", .{ self.contexts_dir, name });
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

    fn switchGitBranch(self: *Self, branch: []const u8) !void {
        var child = std.process.Child.init(&[_][]const u8{ "git", "checkout", branch }, self.allocator);
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Pipe;

        try child.spawn();
        _ = try child.wait();
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

    pub fn parseName(self: *Self, args: []const [:0]const u8) ![]const u8 {
        _ = self;
        if (args.len < 3) {
            std.debug.print("❌ Context name required. Usage: {s}", .{saveHelp});
            return error.MissingName;
        }
        return args[2];
    }
};

const saveHelp = std.fmt.comptimePrint(
    \\{s} save <name>
, .{build_options.package.name});

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const params = comptime clap.parseParamsComptime(
        \\-h, --help             Display this help and exit.
        \\-v, --version          Show version info.
        \\<command>
        \\
    );

    const parsers = comptime .{
        .command = clap.parsers.enumeration(SubCommand),
    };

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, parsers, .{
        .diagnostic = &diag,
        .allocator = allocator,
        .terminating_positional = 0,
    }) catch |err| {
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help != 0) {
        std.debug.print(
            \\{0s} - Context Session Manager
            \\USAGE:
            \\  {1s}      Save current context
            \\  {0s} restore <name>   Restore a saved context
            \\  {0s} list             List all saved contexts
            \\  {0s} delete <name>    Delete a context
            \\
            \\EXAMPLES:
            \\  {0s} save feature-auth
            \\  {0s} restore bugfix-payment
            \\  {0s} list
            \\
        , .{ build_options.package.name, saveHelp });
        return;
    }

    if (res.args.version != 0) {
        std.debug.print(build_options.package.name ++ "-v" ++ build_options.package.version ++ eol, .{});
        return;
    }

    if (res.positionals.len == 0 or res.positionals[0] == null) {
        debugLine("❌ No command specified. Use --help for usage.");
        return;
    }

    var ctx_manager = try ContextManager.init(allocator);
    defer ctx_manager.deinit();

    const subcommand = res.positionals[0].?;

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    switch (subcommand) {
        .save => {
            const name = try ctx_manager.parseName(args);
            try ctx_manager.saveContext(name);
        },
        .restore => {
            const name = try ctx_manager.parseName(args);
            try ctx_manager.restoreContext(name);
        },
        .list => {
            try ctx_manager.listContexts();
        },
        .delete => {
            const name = try ctx_manager.parseName(args);
            try ctx_manager.deleteContext(name);
        },
    }
}
