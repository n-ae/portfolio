const std = @import("std");

pub fn main() !void {
    const stdout_file = std.process.getStdOut();
    try stdout_file.writer().print("test\n", .{});
}
