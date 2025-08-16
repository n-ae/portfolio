const std = @import("std");
const testing = std.testing;
const test_framework = @import("test_framework.zig");

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
        try validation.validateEnvVar(env_var);
    }
}

fn testValidationEnvVarInvalid() !void {
    const invalid_env_vars = [_]EnvVar{
        EnvVar{ .key = "", .value = "value" }, // Empty key
        EnvVar{ .key = "INVALID KEY", .value = "value" }, // Space in key
        EnvVar{ .key = "INVALID=KEY", .value = "value" }, // Equals in key
    };

    for (invalid_env_vars) |env_var| {
        try testing.expectError(error.InvalidEnvVar, validation.validateEnvVar(env_var));
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
    const known_shells = [_]ShellType{ ShellType.bash, ShellType.zsh, ShellType.fish, ShellType.sh, ShellType.cmd, ShellType.powershell };
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
    const allocator = testing.allocator;
    
    const env_var = EnvVar{ .key = "TEST_VAR", .value = "test_value" };
    
    // Test different shell types
    const bash_cmd = try shell.printEnvVar(allocator, env_var, ShellType.bash);
    defer allocator.free(bash_cmd);
    try testing.expect(std.mem.startsWith(u8, bash_cmd, "export"));

    const fish_cmd = try shell.printEnvVar(allocator, env_var, ShellType.fish);
    defer allocator.free(fish_cmd);
    try testing.expect(std.mem.startsWith(u8, fish_cmd, "set"));

    const cmd_cmd = try shell.printEnvVar(allocator, env_var, ShellType.cmd);
    defer allocator.free(cmd_cmd);
    try testing.expect(std.mem.startsWith(u8, cmd_cmd, "set"));

    const powershell_cmd = try shell.printEnvVar(allocator, env_var, ShellType.powershell);
    defer allocator.free(powershell_cmd);
    try testing.expect(std.mem.startsWith(u8, powershell_cmd, "$env:"));
}

// ===== CONTEXT TESTS =====

fn testContextParseName() !void {
    const allocator = testing.allocator;
    
    const valid_names = [_][]const u8{ "test", "test-feature", "test_branch", "test.env" };
    
    for (valid_names) |name| {
        const parsed = try allocator.dupe(u8, name);
        defer allocator.free(parsed);
        try testing.expect(parsed.len > 0);
    }
}

fn testContextMemoryManagement() !void {
    const allocator = testing.allocator;
    
    // Test context creation and cleanup
    var test_context = Context{
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
const test_functions = [_]struct { name: []const u8, func: fn () anyerror!void }{
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

/// Run unit tests with specified output format
pub fn runUnitTests(allocator: std.mem.Allocator, output_format: test_framework.OutputFormat, output_file: ?[]const u8) !void {
    try test_framework.runTestSuite("unit", test_functions, allocator, output_format, output_file);
}

/// Main function for running unit tests as standalone executable
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var output_format = test_framework.OutputFormat.standard;
    var output_file: ?[]const u8 = null;

    // Parse command line arguments
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--csv")) {
            output_format = .csv;
        } else if (std.mem.eql(u8, args[i], "--json")) {
            output_format = .json;
        } else if (std.mem.eql(u8, args[i], "--output") and i + 1 < args.len) {
            i += 1;
            output_file = args[i];
        } else if (std.mem.eql(u8, args[i], "--help")) {
            std.debug.print(
                \\Usage: ctx-unit-tests [OPTIONS]
                \\
                \\Options:
                \\  --csv           Output results in CSV format
                \\  --json          Output results in JSON format
                \\  --output FILE   Write results to file instead of stdout
                \\  --help          Show this help message
                \\
                \\Examples:
                \\  ctx-unit-tests                     # Standard output
                \\  ctx-unit-tests --csv               # CSV output to stdout
                \\  ctx-unit-tests --csv --output unit_results.csv  # CSV output to file
                \\
            , .{});
            return;
        }
    }

    try runUnitTests(allocator, output_format, output_file);
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