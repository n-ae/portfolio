const std = @import("std");
const rgcidr = @import("rgcidr");
const print = std.debug.print;

// Performance profiling utilities
const Timer = struct {
    start: i128,
    
    fn init() Timer {
        return Timer{ .start = std.time.nanoTimestamp() };
    }
    
    fn elapsed(self: Timer) f64 {
        const end = std.time.nanoTimestamp();
        return @as(f64, @floatFromInt(end - self.start)) / 1_000_000.0; // Convert to milliseconds
    }
};

// Test data generation
fn generateIPv4TestData(allocator: std.mem.Allocator, count: usize) ![]u8 {
    var result = std.ArrayList(u8){};
    defer result.deinit(allocator);
    
    const seed: u64 = 12345;
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();
    
    for (0..count) |_| {
        const ip = rand.int(u32);
        const a = (ip >> 24) & 0xFF;
        const b = (ip >> 16) & 0xFF;
        const c = (ip >> 8) & 0xFF;
        const d = ip & 0xFF;
        
        const writer = result.writer(allocator);
        try writer.print("{d}.{d}.{d}.{d} test line {d}\n", .{a, b, c, d, ip});
    }
    
    return result.toOwnedSlice(allocator);
}

fn generateIPv6TestData(allocator: std.mem.Allocator, count: usize) ![]u8 {
    var result = std.ArrayList(u8){};
    defer result.deinit(allocator);
    
    const seed: u64 = 67890;
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();
    
    for (0..count) |_| {
        const a = rand.int(u16);
        const b = rand.int(u16);
        const c = rand.int(u16);
        const d = rand.int(u16);
        
        const writer = result.writer(allocator);
        try writer.print("2001:db8:{x:04}:{x:04}::1 test line\n", .{a, b, c, d});
    }
    
    return result.toOwnedSlice(allocator);
}

// Benchmark functions
fn benchmarkIPv4Parsing(_: std.mem.Allocator, iterations: usize) !f64 {
    const test_ips = [_][]const u8{
        "192.168.1.1",
        "10.0.0.1", 
        "172.16.0.1",
        "255.255.255.255",
        "0.0.0.0",
        "127.0.0.1",
        "203.0.113.1",
    };
    
    const timer = Timer.init();
    
    for (0..iterations) |_| {
        for (test_ips) |ip_str| {
            _ = try rgcidr.parseIPv4(ip_str);
        }
    }
    
    return timer.elapsed();
}

fn benchmarkIPv6Parsing(_: std.mem.Allocator, iterations: usize) !f64 {
    const test_ips = [_][]const u8{
        "2001:db8::1",
        "2001:db8:85a3::8a2e:370:7334",
        "::1",
        "::",
        "fe80::1",
        "2001:db8::192.168.1.1",
    };
    
    const timer = Timer.init();
    
    for (0..iterations) |_| {
        for (test_ips) |ip_str| {
            _ = try rgcidr.parseIPv6(ip_str);
        }
    }
    
    return timer.elapsed();
}

fn benchmarkPatternMatching(allocator: std.mem.Allocator, pattern_count: usize, test_count: usize) !f64 {
    // Create test patterns
    var pattern_strings = std.ArrayList([]const u8){};
    defer pattern_strings.deinit(allocator);
    
    for (0..pattern_count) |i| {
        const pattern = try std.fmt.allocPrint(allocator, "10.{d}.0.0/16", .{i % 255});
        try pattern_strings.append(allocator, pattern);
    }
    defer {
        for (pattern_strings.items) |pattern| {
            allocator.free(pattern);
        }
    }
    
    // Join patterns for parsing
    const joined = try std.mem.join(allocator, " ", pattern_strings.items);
    defer allocator.free(joined);
    
    var patterns = try rgcidr.parseMultiplePatterns(joined, false, allocator);
    defer patterns.deinit();
    
    // Generate test IPs
    var test_ips = std.ArrayList(rgcidr.IPv4){};
    defer test_ips.deinit(allocator);
    
    const seed: u64 = 54321;
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();
    
    for (0..test_count) |_| {
        const ip = rand.int(u32);
        try test_ips.append(allocator, ip);
    }
    
    const timer = Timer.init();
    
    // Benchmark pattern matching
    for (test_ips.items) |ip| {
        _ = patterns.matchesIPv4(ip);
    }
    
    return timer.elapsed();
}

fn benchmarkIPExtraction(allocator: std.mem.Allocator, line_count: usize) !f64 {
    const test_data = try generateIPv4TestData(allocator, line_count);
    defer allocator.free(test_data);
    
    var lines = std.mem.splitSequence(u8, test_data, "\n");
    
    const timer = Timer.init();
    
    while (lines.next()) |line| {
        if (line.len == 0) continue;
        
        var ips = try rgcidr.findIPv4InLine(line, allocator);
        ips.deinit(allocator);
    }
    
    return timer.elapsed();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    print("=== rgcidr Performance Profiling ===\n\n", .{});
    
    // IPv4 Parsing Benchmark
    {
        const iterations = 100_000;
        const time = try benchmarkIPv4Parsing(allocator, iterations);
        print("IPv4 Parsing: {d:.3}ms for {d} iterations ({d:.3}ns per parse)\n", 
              .{time, iterations * 7, (time * 1_000_000) / @as(f64, @floatFromInt(iterations * 7))});
    }
    
    // IPv6 Parsing Benchmark  
    {
        const iterations = 100_000;
        const time = try benchmarkIPv6Parsing(allocator, iterations);
        print("IPv6 Parsing: {d:.3}ms for {d} iterations ({d:.3}ns per parse)\n",
              .{time, iterations * 6, (time * 1_000_000) / @as(f64, @floatFromInt(iterations * 6))});
    }
    
    // Pattern Matching Benchmark
    {
        const pattern_count = 1000;
        const test_count = 10_000;
        const time = try benchmarkPatternMatching(allocator, pattern_count, test_count);
        print("Pattern Matching: {d:.3}ms for {d} patterns x {d} tests ({d:.3}ns per match)\n",
              .{time, pattern_count, test_count, (time * 1_000_000) / @as(f64, @floatFromInt(test_count))});
    }
    
    // IP Extraction Benchmark
    {
        const line_count = 50_000;
        const time = try benchmarkIPExtraction(allocator, line_count);
        print("IP Extraction: {d:.3}ms for {d} lines ({d:.3}ns per line)\n",
              .{time, line_count, (time * 1_000_000) / @as(f64, @floatFromInt(line_count))});
    }
    
    print("\n=== Hot Path Analysis ===\n", .{});
    print("Key optimization targets:\n", .{});
    print("1. IP parsing functions (parseIPv4/parseIPv6)\n", .{});
    print("2. Pattern matching binary search\n", .{});
    print("3. IP extraction hint detection\n", .{});
    print("4. Memory allocation/deallocation patterns\n", .{});
}
