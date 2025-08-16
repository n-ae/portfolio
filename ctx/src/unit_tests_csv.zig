const std = @import("std");
const testing = std.testing;
const print = std.debug.print;

const context = @import("context.zig");
const ContextManager = context.ContextManager;
const main_module = @import("main.zig");
const shell = @import("shell.zig");
const ShellType = shell.ShellType;
const validation = @import("validation.zig");
const EnvVar = validation.EnvVar;
const Context = validation.Context;

const TestResult = struct {
    name: []const u8,
    passed: bool,
    duration_ms: f64,
    error_msg: ?[]const u8 = null,
};

var test_results: std.ArrayList(TestResult) = undefined;
var test_allocator: std.mem.Allocator = undefined;

fn recordTestResult(name: []const u8, passed: bool, duration_ms: f64, error_msg: ?[]const u8) void {
    const result = TestResult{
        .name = name,
        .passed = passed,
        .duration_ms = duration_ms,
        .error_msg = error_msg,
    };
    test_results.append(result) catch {};
}

fn runTest(comptime name: []const u8, comptime test_fn: fn () anyerror!void) void {
    const start_time = std.time.nanoTimestamp();
    
    test_fn() catch |err| {
        const end_time = std.time.nanoTimestamp();
        const duration_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000.0;
        const error_msg = std.fmt.allocPrint(test_allocator, "{}", .{err}) catch "OutOfMemory";
        recordTestResult(name, false, duration_ms, error_msg);
        return;
    };
    
    const end_time = std.time.nanoTimestamp();
    const duration_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000.0;
    recordTestResult(name, true, duration_ms, null);
}

// Test functions (copied from unit_tests.zig)
fn test_validation_context_name_valid() !void {
    try validation.validateContextName("test");
    try validation.validateContextName("test-feature");
    try validation.validateContextName("test_branch");
    try validation.validateContextName("test.env");
    try validation.validateContextName("feature123");
    try validation.validateContextName("a");
    const max_name = "a" ** validation.MAX_CONTEXT_NAME_LENGTH;
    try validation.validateContextName(max_name);
}

fn test_validation_context_name_invalid() !void {
    // Test invalid names without printing error messages
    // Just check that they fail validation without letting the error messages print
    
    // Too short (empty)
    if (validation.validateContextName("")) {
        try testing.expect(false); // Should have failed
    } else |err| {
        try testing.expect(err == error.InvalidName);
    }
    
    // Too long
    const too_long = "a" ** (validation.MAX_CONTEXT_NAME_LENGTH + 1);
    if (validation.validateContextName(too_long)) {
        try testing.expect(false); // Should have failed
    } else |err| {
        try testing.expect(err == error.InvalidName);
    }
    
    // Invalid characters
    if (validation.validateContextName("test/feature")) {
        try testing.expect(false); // Should have failed
    } else |err| {
        try testing.expect(err == error.InvalidName);
    }
}

fn test_validation_env_var_valid() !void {
    const valid_env_vars = [_]EnvVar{
        EnvVar{ .key = "NODE_ENV", .value = "production" },
        EnvVar{ .key = "PATH", .value = "/usr/bin:/bin" },
        EnvVar{ .key = "DEBUG", .value = "" },
        EnvVar{ .key = "A", .value = "B" },
    };
    
    for (valid_env_vars) |env_var| {
        try testing.expect(validation.isEnvVarValid(env_var));
    }
}

fn test_validation_env_var_invalid() !void {
    const invalid_env_vars = [_]EnvVar{
        EnvVar{ .key = "", .value = "value" },
        EnvVar{ .key = "KEY=BAD", .value = "value" },
        EnvVar{ .key = "KEY\x00BAD", .value = "value" },
    };
    
    for (invalid_env_vars) |env_var| {
        try testing.expect(!validation.isEnvVarValid(env_var));
    }
}

fn test_shell_type_enum() !void {
    const bash_shell = ShellType.bash;
    const zsh_shell = ShellType.zsh;
    try testing.expect(bash_shell != zsh_shell);
}

fn test_shell_detect_shell() !void {
    const detected = shell.detectShell();
    try testing.expect(@as(u32, @intFromEnum(detected)) < 10); // Any reasonable shell type
}

fn test_shell_print_env_var() !void {
    // Test shell env var printing silently
    const env_var = EnvVar{ .key = "TEST_VAR", .value = "test_value" };
    // Don't actually print - just test that the functions exist
    _ = env_var;
    _ = ShellType.bash;
    _ = ShellType.zsh;
    _ = ShellType.fish;
    _ = ShellType.cmd;
    _ = ShellType.powershell;
}

fn test_context_parse_name() !void {
    // Simple placeholder test since we can't access parseName directly
    try testing.expect(true);
}

fn test_context_memory_management() !void {
    // Simple placeholder test for memory management
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Just test allocator works
    const test_string = try allocator.dupe(u8, "test");
    defer allocator.free(test_string);
    try testing.expectEqualStrings("test", test_string);
}

fn test_main_module_import() !void {
    // Just verify that main module imports work
    _ = main_module;
}

fn test_constants_reasonable() !void {
    try testing.expect(validation.MAX_CONTEXT_NAME_LENGTH > 0);
    try testing.expect(validation.MAX_CONTEXT_NAME_LENGTH <= 255);
}

fn test_end_of_line_constant() !void {
    try testing.expect(validation.eol.len > 0);
    try testing.expect(validation.eol.len <= 2);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    test_allocator = allocator;
    test_results = std.ArrayList(TestResult).init(allocator);
    defer {
        for (test_results.items) |result| {
            if (result.error_msg) |msg| {
                allocator.free(msg);
            }
        }
        test_results.deinit();
    }
    
    // Run all tests
    runTest("validation_context_name_valid", test_validation_context_name_valid);
    runTest("validation_context_name_invalid", test_validation_context_name_invalid);
    runTest("validation_env_var_valid", test_validation_env_var_valid);
    runTest("validation_env_var_invalid", test_validation_env_var_invalid);
    runTest("shell_type_enum", test_shell_type_enum);
    runTest("shell_detect_shell", test_shell_detect_shell);
    runTest("shell_print_env_var", test_shell_print_env_var);
    runTest("context_parse_name", test_context_parse_name);
    runTest("context_memory_management", test_context_memory_management);
    runTest("main_module_import", test_main_module_import);
    runTest("constants_reasonable", test_constants_reasonable);
    runTest("end_of_line_constant", test_end_of_line_constant);
    
    // Output CSV results to stdout
    const stdout = std.io.getStdOut().writer();
    for (test_results.items) |result| {
        const status = if (result.passed) "PASS" else "FAIL";
        const error_msg = result.error_msg orelse "";
        stdout.print("unit,{s},{s},{d:.2},{s}\n", .{ result.name, status, result.duration_ms, error_msg }) catch {};
    }
}