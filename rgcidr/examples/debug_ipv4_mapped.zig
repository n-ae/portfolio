const std = @import("std");
const rgcidr = @import("src/root.zig");

pub fn main() !void {
    const test_addresses = [_][]const u8{
        "::ffff:192.168.1.1",
        "::FFFF:192.168.1.1",
        "0:0:0:0:0:ffff:192.168.1.1",
    };
    
    for (test_addresses) |addr| {
        std.debug.print("Testing: '{s}'\n", .{addr});
        const result = rgcidr.parseIPv6(addr);
        if (result) |ipv6| {
            std.debug.print("  ✓ Parsed: 0x{x}\n", .{ipv6});
        } else |err| {
            std.debug.print("  ✗ Failed: {}\n", .{err});
        }
    }
}
