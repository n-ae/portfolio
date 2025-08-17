const std = @import("std");
const testing = std.testing;

const context = @import("context.zig");
const ContextManager = context.ContextManager;
const main_module = @import("main.zig");
const shell = @import("shell.zig");
const ShellType = shell.ShellType;
const validation = @import("validation.zig");
const EnvVar = validation.EnvVar;
const Context = validation.Context;

// Test functions that can be run both individually and as part of a suite

// ===== VALIDATION TESTS =====

fn testValidationContextNameValid() !void {
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

fn testValidationContextNameInvalid() !void {
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

fn testValidationEnvVarValid() !void {
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

fn testValidationEnvVarInvalid() !void {
    const invalid_env_vars = [_]EnvVar{
        EnvVar{ .key = "", .value = "value" }, // Empty key
        EnvVar{ .key = "INVALID KEY", .value = "value" }, // Space in key
        EnvVar{ .key = "INVALID=KEY", .value = "value" }, // Equals in key
    };

    for (invalid_env_vars) |env_var| {
        try testing.expect(!validation.isEnvVarValid(env_var));
    }
}

// ===== SHELL TESTS =====

fn testShellTypeEnum() !void {
    // Test shell type enum values
    try testing.expect(ShellType.bash != ShellType.zsh);
    try testing.expect(ShellType.fish != ShellType.bash);
}

fn testShellDetectShell() !void {
    // This might fail in some environments, but should not crash
    const detected = shell.detectShell();

    // Should be one of the known shell types
    const known_shells = [_]ShellType{ ShellType.bash, ShellType.zsh, ShellType.fish, ShellType.cmd, ShellType.powershell, ShellType.unknown };
    var found = false;
    for (known_shells) |known_shell| {
        if (detected == known_shell) {
            found = true;
            break;
        }
    }
    try testing.expect(found);
}

fn testShellPrintEnvVar() !void {
    const env_var = EnvVar{ .key = "TEST_VAR", .value = "test_value" };
    // Test that functions don't crash - they print to stdout, not return strings
    shell.printEnvVarCommand(env_var, ShellType.bash);

    shell.printEnvVarCommand(env_var, ShellType.fish);

    shell.printEnvVarCommand(env_var, ShellType.cmd);

    shell.printEnvVarCommand(env_var, ShellType.powershell);
}

// ===== CONTEXT TESTS =====

// Use a global allocator for tests when run as main
pub var g_allocator: ?std.mem.Allocator = null;

fn getTestAllocator() std.mem.Allocator {
    const builtin = @import("builtin");
    if (builtin.is_test) {
        return testing.allocator;
    } else {
        return g_allocator.?;
    }
}

fn testContextParseName() !void {
    const allocator = getTestAllocator();

    const valid_names = [_][]const u8{ "test", "test-feature", "test_branch", "test.env" };

    for (valid_names) |name| {
        const parsed = try allocator.dupe(u8, name);
        defer allocator.free(parsed);
        try testing.expect(parsed.len > 0);
    }
}

fn testContextMemoryManagement() !void {
    const allocator = getTestAllocator();

    // Test context creation and cleanup
    const test_context = Context{
        .name = try allocator.dupe(u8, "test-context"),
        .timestamp = std.time.timestamp(),
        .git_branch = try allocator.dupe(u8, "main"),
        .working_directory = try allocator.dupe(u8, "/tmp"),
        .open_files = try allocator.alloc([]const u8, 0),
        .environment_vars = try allocator.alloc(EnvVar, 0),
        .terminal_commands = try allocator.alloc([]const u8, 0),
    };

    // Cleanup
    allocator.free(test_context.name);
    if (test_context.git_branch) |branch| {
        allocator.free(branch);
    }
    allocator.free(test_context.working_directory);
    allocator.free(test_context.open_files);
    allocator.free(test_context.environment_vars);
    allocator.free(test_context.terminal_commands);
}

// ===== MAIN MODULE TESTS =====

fn testMainModuleImport() !void {
    // Test that we can import and use basic functionality from main
    // This ensures the module structure is correct
    _ = main_module;
}

// ===== CONSTANTS TESTS =====

fn testConstantsReasonable() !void {
    // Test that configuration constants are reasonable
    try testing.expect(validation.MAX_CONTEXT_NAME_LENGTH > 0);
    try testing.expect(validation.MAX_CONTEXT_NAME_LENGTH <= 255);
}

fn testEndOfLineConstant() !void {
    const eol = validation.eol;
    try testing.expect(eol.len > 0);
    try testing.expect(eol.len <= 2); // Should be \n or \r\n
}

// Test suite definition for the enhanced framework
pub const test_functions = [_]struct { name: []const u8, func: *const fn () anyerror!void }{
    .{ .name = "validation_context_name_valid", .func = testValidationContextNameValid },
    .{ .name = "validation_context_name_invalid", .func = testValidationContextNameInvalid },
    .{ .name = "validation_env_var_valid", .func = testValidationEnvVarValid },
    .{ .name = "validation_env_var_invalid", .func = testValidationEnvVarInvalid },
    .{ .name = "shell_type_enum", .func = testShellTypeEnum },
    .{ .name = "shell_detect_shell", .func = testShellDetectShell },
    .{ .name = "shell_print_env_var", .func = testShellPrintEnvVar },
    .{ .name = "context_parse_name", .func = testContextParseName },
    .{ .name = "context_memory_management", .func = testContextMemoryManagement },
    .{ .name = "main_module_import", .func = testMainModuleImport },
    .{ .name = "constants_reasonable", .func = testConstantsReasonable },
    .{ .name = "end_of_line_constant", .func = testEndOfLineConstant },
};

// Note: This file contains enhanced unit tests that work with the standard Zig test runner.
// When run as an executable, it outputs CSV results for CI/CD integration.

pub const TestResult = struct {
    test_type: []const u8,
    test_name: []const u8,
    status: []const u8,
    duration_ms: f64,
    error_message: []const u8,
};

pub fn runTestWithTiming(name: []const u8, test_func: *const fn () anyerror!void) TestResult {
    var timer = std.time.Timer.start() catch unreachable;
    
    var status: []const u8 = undefined;
    var error_message: []const u8 = undefined;
    
    if (test_func()) |_| {
        status = "PASS";
        error_message = "";
    } else |err| {
        status = "FAIL";
        error_message = switch (err) {
            error.InvalidName => "InvalidName",
            error.TestExpectedError => "TestExpectedError", 
            error.TestUnexpectedResult => "TestUnexpectedResult",
            else => "UnknownError",
        };
    }
    
    const duration_ns = timer.read();
    const duration_ms = @as(f64, @floatFromInt(duration_ns)) / 1_000_000.0;
    
    return TestResult{
        .test_type = "unit",
        .test_name = name,
        .status = status,
        .duration_ms = duration_ms,
        .error_message = error_message,
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){}; 
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Set global allocator for tests
    g_allocator = allocator;
    
    var results = std.ArrayList(TestResult).init(allocator);
    defer results.deinit();
    
    // Run all tests and collect results
    for (test_functions) |test_def| {
        const result = runTestWithTiming(test_def.name, test_def.func);
        try results.append(result);
    }
    
    // Output CSV header
    std.debug.print("test_type,test_name,status,duration_ms,error_message\n", .{});
    
    // Output CSV results
    for (results.items) |result| {
        std.debug.print("{s},{s},{s},{d:.2},{s}\n", .{
            result.test_type,
            result.test_name,
            result.status,
            result.duration_ms,
            result.error_message,
        });
    }
}

// Standard Zig test integration - these call the enhanced functions for compatibility
test "validation: context name validation - valid names" {
    try testValidationContextNameValid();
}

test "validation: context name validation - invalid names" {
    try testValidationContextNameInvalid();
}

test "validation: environment variable validation - valid env vars" {
    try testValidationEnvVarValid();
}

test "validation: environment variable validation - invalid env vars" {
    try testValidationEnvVarInvalid();
}

test "shell: shell type enum" {
    try testShellTypeEnum();
}

test "shell: detect shell" {
    try testShellDetectShell();
}

test "shell: print env var" {
    try testShellPrintEnvVar();
}

test "context: parse name" {
    try testContextParseName();
}

test "context: memory management" {
    try testContextMemoryManagement();
}

test "main: module import" {
    try testMainModuleImport();
}

test "constants: reasonable values" {
    try testConstantsReasonable();
}

test "constants: end of line constant" {
    try testEndOfLineConstant();
}
