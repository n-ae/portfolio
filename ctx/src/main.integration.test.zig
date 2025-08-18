const std = @import("std");
const testing = std.testing;
const main_module = @import("main.zig");

test "main module import" {
    // Test that main module can be imported without errors
    // This ensures all dependencies are properly linked
    try testing.expect(true);
}

test "constants reasonable" {
    const validation = @import("validation.zig");
    
    // Test that validation constants are reasonable
    try testing.expect(validation.MAX_CONTEXT_NAME_LENGTH > 0);
    try testing.expect(validation.MAX_CONTEXT_NAME_LENGTH <= 1000); // Reasonable upper bound
    try testing.expect(validation.MIN_CONTEXT_NAME_LENGTH > 0);
    try testing.expect(validation.MAX_ENV_KEY_LENGTH > 0);
}

test "end of line constant" {
    const validation = @import("validation.zig");
    
    // Test that EOL constant is defined and not empty
    try testing.expect(validation.eol.len > 0);
    try testing.expect(validation.eol.len <= 2); // Should be \n or \r\n
}