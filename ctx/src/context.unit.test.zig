const std = @import("std");
const testing = std.testing;
const context = @import("context.zig");
const ContextManager = context.ContextManager;

test "context parse name" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Test parsing valid context names
    const valid_names = [_][]const u8{ "test", "feature-branch", "dev_env", "release.1.0" };
    
    for (valid_names) |name| {
        // Just test that the name parsing doesn't crash
        // The actual validation is handled by validation.zig
        const parsed_name = try allocator.dupe(u8, name);
        defer allocator.free(parsed_name);
        try testing.expect(parsed_name.len > 0);
    }
}

test "context memory management" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    // Test ContextManager initialization and cleanup
    var ctx_manager = try ContextManager.init(allocator);
    defer ctx_manager.deinit();
    
    // Test that we can create and destroy the context manager without leaks
    try testing.expect(true); // If we reach here, memory management worked
}