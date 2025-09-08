const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut();
    try stdout.writer().print("test\n", .{});
}
