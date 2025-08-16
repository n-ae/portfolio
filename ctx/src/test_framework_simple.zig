const std = @import("std");

/// Simple CSV test result writer
pub fn writeCSVResult(
    writer: anytype,
    test_type: []const u8,
    test_name: []const u8, 
    status: []const u8,
    duration_ms: f64,
    error_msg: []const u8
) !void {
    try writer.print("{s},{s},{s},{d:.2},{s}\n", .{ test_type, test_name, status, duration_ms, error_msg });
}

/// Simple CSV header
pub fn writeCSVHeader(writer: anytype) !void {
    try writer.print("test_type,test_name,status,duration_ms,error_message\n", .{});
}

/// Simple timer wrapper for benchmarks
pub const SimpleTimer = struct {
    timer: std.time.Timer,

    pub fn start() SimpleTimer {
        return SimpleTimer{
            .timer = std.time.Timer.start() catch unreachable,
        };
    }

    pub fn elapsed_ms(self: *SimpleTimer) f64 {
        const ns = self.timer.read();
        return @as(f64, @floatFromInt(ns)) / 1_000_000.0;
    }
};