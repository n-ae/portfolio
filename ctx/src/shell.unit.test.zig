const std = @import("std");
const testing = std.testing;
const shell = @import("shell.zig");
const ShellType = shell.ShellType;

test "shell type enum" {
    const bash_shell = ShellType.bash;
    const zsh_shell = ShellType.zsh;
    
    try testing.expect(bash_shell != zsh_shell);
    try testing.expect(@intFromEnum(bash_shell) != @intFromEnum(zsh_shell));
}

test "shell detect shell" {
    // Test shell detection (no parameters - uses environment)
    const result = shell.detectShell();
    // Just test that it returns a valid shell type
    try testing.expect(@intFromEnum(result) >= 0 and @intFromEnum(result) <= @intFromEnum(ShellType.powershell));
}

test "shell format env var command" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const validation = @import("validation.zig");
    const EnvVar = validation.EnvVar;
    
    // Test different shell types generate correct export commands
    const test_env_var = EnvVar{ .key = "TEST_VAR", .value = "test_value" };
    
    const bash_cmd = try shell.formatEnvVarCommand(allocator, test_env_var, ShellType.bash);
    defer allocator.free(bash_cmd);
    try testing.expect(std.mem.indexOf(u8, bash_cmd, "export") != null);
    try testing.expect(std.mem.indexOf(u8, bash_cmd, "TEST_VAR") != null);
    
    const cmd_cmd = try shell.formatEnvVarCommand(allocator, test_env_var, ShellType.cmd);
    defer allocator.free(cmd_cmd);
    try testing.expect(std.mem.indexOf(u8, cmd_cmd, "set") != null);
    
    const powershell_cmd = try shell.formatEnvVarCommand(allocator, test_env_var, ShellType.powershell);
    defer allocator.free(powershell_cmd);
    try testing.expect(std.mem.indexOf(u8, powershell_cmd, "$env:") != null);
}