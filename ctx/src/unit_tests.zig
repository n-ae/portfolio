const std = @import("std");
const testing = std.testing;

// Import modules directly since they're in the same directory
const validation = @import("validation.zig");
const shell = @import("shell.zig");
const context = @import("context.zig");
const main = @import("main.zig");

const EnvVar = validation.EnvVar;
const Context = validation.Context;
const ShellType = shell.ShellType;
const ContextManager = context.ContextManager;

// ===== VALIDATION TESTS =====

test "validation: context name validation - valid names" {
    try validation.validateContextName("test");
    try validation.validateContextName("test-feature");
    try validation.validateContextName("test_branch");
    try validation.validateContextName("test.env");
    try validation.validateContextName("feature123");
    try validation.validateContextName("a"); // Minimum length
    
    // Maximum length test
    const max_name = "a" ** validation.MAX_CONTEXT_NAME_LENGTH;
    try validation.validateContextName(max_name);
}

test "validation: context name validation - invalid names" {
    // Too short (empty)
    try testing.expectError(error.InvalidName, validation.validateContextName(""));
    
    // Too long
    const too_long = "a" ** (validation.MAX_CONTEXT_NAME_LENGTH + 1);
    try testing.expectError(error.InvalidName, validation.validateContextName(too_long));
    
    // Invalid characters
    try testing.expectError(error.InvalidName, validation.validateContextName("test/feature"));
    try testing.expectError(error.InvalidName, validation.validateContextName("test feature"));
    try testing.expectError(error.InvalidName, validation.validateContextName("test@feature"));
}

test "validation: environment variable validation - valid env vars" {
    const valid_env_vars = [_]EnvVar{
        EnvVar{ .key = "NODE_ENV", .value = "production" },
        EnvVar{ .key = "PATH", .value = "/usr/bin:/bin" },
        EnvVar{ .key = "DEBUG", .value = "" }, // Empty value is valid
        EnvVar{ .key = "A", .value = "B" }, // Minimum key length
    };
    
    for (valid_env_vars) |env_var| {
        try testing.expect(validation.isEnvVarValid(env_var));
    }
}

test "validation: environment variable validation - invalid env vars" {
    const invalid_env_vars = [_]EnvVar{
        EnvVar{ .key = "", .value = "value" }, // Empty key
        EnvVar{ .key = "KEY=BAD", .value = "value" }, // Key with '='
        EnvVar{ .key = "KEY\x00BAD", .value = "value" }, // Key with null byte
        EnvVar{ .key = "KEY", .value = "val\x00ue" }, // Value with null byte
    };
    
    for (invalid_env_vars) |env_var| {
        try testing.expect(!validation.isEnvVarValid(env_var));
    }
}

// ===== SHELL TESTS =====

test "shell: ShellType enum completeness" {
    // Ensure all shell types are defined
    const shells = [_]ShellType{ .bash, .zsh, .fish, .cmd, .powershell, .unknown };
    try testing.expect(shells.len == 6);
}

test "shell: detectShell returns valid shell type" {
    const detected_shell = shell.detectShell();
    
    // Should return one of the known shell types
    const valid_shells = [_]ShellType{ .bash, .zsh, .fish, .cmd, .powershell, .unknown };
    var found = false;
    for (valid_shells) |valid_shell| {
        if (detected_shell == valid_shell) {
            found = true;
            break;
        }
    }
    try testing.expect(found);
}

test "shell: printEnvVarCommand formatting" {
    // We can't easily test output in unit tests, but we can test that the function doesn't crash
    const test_env_var = EnvVar{ .key = "TEST_VAR", .value = "test_value" };
    
    const shell_types = [_]ShellType{ .bash, .zsh, .fish, .cmd, .powershell, .unknown };
    
    for (shell_types) |shell_type| {
        // These should not crash
        shell.printEnvVarCommand(test_env_var, shell_type);
    }
}

// ===== CONTEXT TESTS =====

test "context: parseName function validation" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    // Create a mock ContextManager for testing parseName
    var ctx_manager = ContextManager{
        .allocator = allocator,
        .contexts_dir = "/tmp/test",
        .original_cwd = "/tmp",
    };
    
    // Test valid args
    const valid_args = [_][:0]const u8{ "ctx", "save", "test-context" };
    const result = ctx_manager.parseName(&valid_args, "save");
    try testing.expectEqualStrings("test-context", result catch unreachable);
    
    // Test insufficient args
    const insufficient_args = [_][:0]const u8{ "ctx", "save" };
    try testing.expectError(error.MissingName, ctx_manager.parseName(&insufficient_args, "save"));
}

test "context: Context struct memory management" {
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    // Create a context with allocated memory
    const branch = try allocator.dupe(u8, "test-branch");
    const working_dir = try allocator.dupe(u8, "/test/directory");
    
    const open_files = try allocator.alloc([]const u8, 1);
    open_files[0] = try allocator.dupe(u8, "file1.txt");
    
    const env_vars = try allocator.alloc(EnvVar, 1);
    env_vars[0] = EnvVar{
        .key = try allocator.dupe(u8, "NODE_ENV"),
        .value = try allocator.dupe(u8, "test"),
    };
    
    const commands = try allocator.alloc([]const u8, 1);
    commands[0] = try allocator.dupe(u8, "npm test");
    
    const test_context = Context{
        .name = "test-context",
        .timestamp = std.time.timestamp(),
        .git_branch = branch,
        .working_directory = working_dir,
        .open_files = open_files,
        .environment_vars = env_vars,
        .terminal_commands = commands,
    };
    
    // Test that deinit doesn't crash
    test_context.deinit(allocator);
}

// ===== MAIN TESTS =====

test "main: module imports successfully" {
    // Test that main module can be imported without errors
    _ = main;
    // This test mainly ensures compilation succeeds
}

// ===== INTEGRATION TESTS =====

test "unit tests: all modules importable" {
    // Basic smoke test that all modules are importable
    _ = validation;
    _ = shell; 
    _ = context;
    _ = main;
}

test "unit tests: constants are reasonable" {
    // Verify our constants make sense
    try testing.expect(validation.MIN_CONTEXT_NAME_LENGTH > 0);
    try testing.expect(validation.MAX_CONTEXT_NAME_LENGTH > validation.MIN_CONTEXT_NAME_LENGTH);
    try testing.expect(validation.MAX_ENV_KEY_LENGTH > 0);
    try testing.expect(validation.MAX_ENV_VALUE_LENGTH > 0);
}

test "unit tests: end-of-line constant" {
    // Test that eol is defined and reasonable
    const validation_eol = validation.eol;
    const is_windows = std.mem.eql(u8, validation_eol, "\r\n");
    const is_unix = std.mem.eql(u8, validation_eol, "\n");
    try testing.expect(is_windows or is_unix);
}