const std = @import("std");

pub fn main() !void {
    const stdout_file = std.fs.getStdOut();
    try stdout_file.writer().print("test\n", .{});
}
