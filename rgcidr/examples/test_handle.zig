const std = @import("std");

pub fn main() !void {
    const stdout = std.fs.File{ .handle = 1 };
    try stdout.writeAll("test\n");
}
