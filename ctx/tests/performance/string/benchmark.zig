const std = @import("std");

// Simulate build options
const build_options = struct {
    pub const package = struct {
        pub const name = "ctx";
        pub const version = "0.1.0";
    };
};

const eol = "\n";

// Redirect stdout to /dev/null to isolate timing from I/O
var dev_null: ?std.fs.File = null;

fn setupDevNull() !void {
    dev_null = try std.fs.openFileAbsolute("/dev/null", .{ .mode = .write_only });
}

fn method1_format_string() void {
    if (dev_null) |file| {
        file.writer().print("{s}-v{s}" ++ eol, .{ build_options.package.name, build_options.package.version }) catch {};
    }
}

fn method2_string_concat() void {
    if (dev_null) |file| {
        file.writer().print(build_options.package.name ++ "-v" ++ build_options.package.version ++ eol, .{}) catch {};
    }
}

fn benchmark(comptime func: fn() void, comptime name: []const u8, iterations: u32) !void {
    const start = std.time.nanoTimestamp();
    
    for (0..iterations) |_| {
        func();
    }
    
    const end = std.time.nanoTimestamp();
    const duration = end - start;
    const avg_ns = @as(f64, @floatFromInt(duration)) / @as(f64, @floatFromInt(iterations));
    
    std.debug.print("{s}: {d} iterations, {d}ns total, {d:.2}ns average\n", .{ name, iterations, duration, avg_ns });
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    try setupDevNull();
    defer if (dev_null) |file| file.close();
    
    const iterations: u32 = 1_000_000;
    
    std.debug.print("Benchmarking string formatting approaches ({d} iterations each):\n", .{iterations});
    
    try benchmark(method1_format_string, "Method 1 (Format String)", iterations);
    try benchmark(method2_string_concat, "Method 2 (String Concat)", iterations);
    
    // Also test without I/O for pure string operation timing
    std.debug.print("\nTesting pure string operations (no I/O):\n", .{});
    
    const start1 = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        const result = std.fmt.allocPrint(allocator, "{s}-v{s}" ++ eol, .{ build_options.package.name, build_options.package.version }) catch unreachable;
        allocator.free(result);
    }
    const end1 = std.time.nanoTimestamp();
    
    const start2 = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        _ = build_options.package.name ++ "-v" ++ build_options.package.version ++ eol;
    }
    const end2 = std.time.nanoTimestamp();
    
    const duration1 = end1 - start1;
    const duration2 = end2 - start2;
    
    std.debug.print("Format string (with allocation): {d}ns total, {d:.2}ns average\n", .{ duration1, @as(f64, @floatFromInt(duration1)) / @as(f64, @floatFromInt(iterations)) });
    std.debug.print("String concatenation: {d}ns total, {d:.2}ns average\n", .{ duration2, @as(f64, @floatFromInt(duration2)) / @as(f64, @floatFromInt(iterations)) });
    
    if (duration2 > 0) {
        const speedup = @as(f64, @floatFromInt(duration1)) / @as(f64, @floatFromInt(duration2));
        std.debug.print("String concatenation is {d:.2}x faster\n", .{speedup});
    } else {
        std.debug.print("String concatenation completed in effectively 0ns (compile-time optimized away)\n", .{});
    }
}