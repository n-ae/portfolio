const std = @import("std");
const config = @import("config.zig");

// Constants for validation limits
pub const MAX_CONTEXT_NAME_LENGTH = 255;
pub const MIN_CONTEXT_NAME_LENGTH = 1;
pub const MAX_ENV_KEY_LENGTH = config.Validation.MAX_ENV_KEY_LENGTH;
pub const MAX_ENV_VALUE_LENGTH = 4096;
pub const MAX_BRANCH_NAME_LENGTH = 255;

// OS-specific end-of-line character
pub const eol = switch (@import("builtin").os.tag) {
    .windows => "\r\n",
    else => "\n",
};

pub const EnvVar = struct {
    key: []const u8,
    value: []const u8,
};

pub const Context = struct {
    name: []const u8,
    timestamp: i64,
    git_branch: ?[]const u8,
    working_directory: []const u8,
    open_files: [][]const u8,
    environment_vars: []EnvVar,
    terminal_commands: [][]const u8,

    pub fn deinit(self: *const Context, allocator: std.mem.Allocator) void {
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

pub fn validateContextName(name: []const u8) !void {
    if (name.len < MIN_CONTEXT_NAME_LENGTH or name.len > MAX_CONTEXT_NAME_LENGTH) {
        std.debug.print("❌ Context name must be {d}-{d} characters" ++ eol, .{ MIN_CONTEXT_NAME_LENGTH, MAX_CONTEXT_NAME_LENGTH });
        return error.InvalidName;
    }

    for (name) |c| {
        if (!std.ascii.isAlphanumeric(c) and c != '-' and c != '_' and c != '.') {
            std.debug.print("❌ Context name can only contain alphanumeric, '-', '_', '.' characters" ++ eol, .{});
            return error.InvalidName;
        }
    }
}

pub fn isContextValid(context: *const Context) bool {
    // Basic validation
    if (context.name.len < MIN_CONTEXT_NAME_LENGTH or context.name.len > MAX_CONTEXT_NAME_LENGTH) return false;
    if (context.working_directory.len == 0) return false;
    if (context.timestamp < 0) return false;

    // Validate each component
    for (context.environment_vars) |env_var| {
        if (env_var.key.len == 0 or env_var.key.len > MAX_ENV_KEY_LENGTH) return false;
        if (env_var.value.len > MAX_ENV_VALUE_LENGTH) return false;
    }

    return true;
}

pub fn isEnvVarValid(env_var: EnvVar) bool {
    // Basic validation
    if (env_var.key.len == 0 or env_var.key.len > MAX_ENV_KEY_LENGTH) return false;
    if (env_var.value.len > MAX_ENV_VALUE_LENGTH) return false;

    // Key should not contain null bytes, '=' characters, or spaces
    for (env_var.key) |c| {
        if (c == 0 or c == '=' or c == ' ') return false;
    }

    // Value should not contain null bytes
    for (env_var.value) |c| {
        if (c == 0) return false;
    }

    return true;
}

pub fn validateGitBranch(branch: []const u8) !void {
    // Basic branch name validation - just ensure it's not empty and reasonable length
    if (branch.len == 0 or branch.len > MAX_BRANCH_NAME_LENGTH) return error.InvalidBranch;

    // For resilience, we don't validate git repository state here
    // The git checkout command will fail gracefully if there are issues
    // This keeps the restore operation more resilient
}
