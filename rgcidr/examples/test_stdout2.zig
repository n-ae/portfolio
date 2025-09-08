const std = @import("std");

pub fn main() !void {
    const stdout_file = std.io.getStdOut();
    _ = stdout_file;
}
