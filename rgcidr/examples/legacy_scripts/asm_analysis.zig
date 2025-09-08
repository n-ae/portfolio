const std = @import("std");
const rgcidr = @import("rgcidr");

/// Assembly analysis and profiling tool for hot path optimization
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    std.debug.print("=== Assembly Analysis & Hot Path Profiling ===\n\n", .{});
    
    // Create test data for hot path analysis
    var patterns = try rgcidr.parseMultiplePatterns("192.168.0.0/16", false, allocator);
    defer patterns.deinit();
    
    const test_ips = [_]rgcidr.IPv4{
        try rgcidr.parseIPv4("192.168.1.1"),
        try rgcidr.parseIPv4("10.0.0.1"),
        try rgcidr.parseIPv4("172.16.0.1"),
        try rgcidr.parseIPv4("203.0.113.1"),
    };
    
    // Profile different optimization levels
    std.debug.print("1. Hot Path Analysis:\n", .{});
    profileHotPaths(&patterns, &test_ips);
    
    std.debug.print("\n2. Memory Access Patterns:\n", .{});
    try analyzeMemoryPatterns(allocator, &patterns);
    
    std.debug.print("\n3. Branch Prediction Analysis:\n", .{});
    analyzeBranchPrediction(&patterns, &test_ips);
    
    std.debug.print("\n4. Cache Performance:\n", .{});
    try analyzeCachePerformance(allocator);
}

fn profileHotPaths(patterns: *rgcidr.MultiplePatterns, test_ips: []const rgcidr.IPv4) void {
    const iterations = 50_000_000;
    
    // Profile matchesIPv4 - most critical hot path
    const start = std.time.nanoTimestamp();
    var matches: u32 = 0;
    for (0..iterations) |_| {
        for (test_ips) |ip| {
            if (patterns.matchesIPv4(ip)) {
                matches += 1;
            }
        }
    }
    const end = std.time.nanoTimestamp();
    
    const total_ops = iterations * test_ips.len;
    const time_per_op = @as(f64, @floatFromInt(end - start)) / @as(f64, @floatFromInt(total_ops));
    
    std.debug.print("  matchesIPv4: {d} matches in {d} operations\n", .{matches, total_ops});
    std.debug.print("  Time per match: {d:.3}ns\n", .{time_per_op});
    std.debug.print("  Instructions per second: ~{d:.0}M\n", .{1000.0 / time_per_op});
}

fn analyzeMemoryPatterns(allocator: std.mem.Allocator, _: *rgcidr.MultiplePatterns) !void {
    // Analyze memory access patterns for large pattern sets
    var large_pattern_list = std.ArrayList(u8){};
    defer large_pattern_list.deinit(allocator);
    
    // Generate 10,000 patterns to test memory hierarchy effects
    for (0..10000) |i| {
        try large_pattern_list.writer(allocator).print("10.{d}.{d}.{d}/32 ", .{
            (i >> 16) & 0xFF,
            (i >> 8) & 0xFF,
            i & 0xFF
        });
    }
    
    const large_patterns_str = try large_pattern_list.toOwnedSlice(allocator);
    defer allocator.free(large_patterns_str);
    
    var large_patterns = try rgcidr.parseMultiplePatterns(large_patterns_str, false, allocator);
    defer large_patterns.deinit();
    
    // Test with different access patterns
    const test_ip = try rgcidr.parseIPv4("10.123.45.67");
    const iterations = 1_000_000;
    
    // Sequential access pattern
    const start_seq = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        _ = large_patterns.matchesIPv4(test_ip);
    }
    const end_seq = std.time.nanoTimestamp();
    
    const time_seq = @as(f64, @floatFromInt(end_seq - start_seq)) / 1_000_000.0;
    
    std.debug.print("  Large pattern set (10K patterns): {d:.3}ms\n", .{time_seq});
    std.debug.print("  Time per lookup: {d:.3}ns\n", .{time_seq * 1_000_000 / @as(f64, @floatFromInt(iterations))});
    std.debug.print("  Memory usage: ~{d}KB\n", .{large_patterns.ipv4_ranges.len * @sizeOf(rgcidr.IPv4Range) / 1024});
}

fn analyzeBranchPrediction(patterns: *rgcidr.MultiplePatterns, test_ips: []const rgcidr.IPv4) void {
    const iterations = 10_000_000;
    
    // Test predictable pattern (all matching)
    const matching_ips = [_]rgcidr.IPv4{
        0xC0A80101, // 192.168.1.1
        0xC0A80102, // 192.168.1.2  
        0xC0A80103, // 192.168.1.3
        0xC0A80104, // 192.168.1.4
    };
    
    // Predictable pattern
    var start = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        for (matching_ips) |ip| {
            _ = patterns.matchesIPv4(ip);
        }
    }
    var end = std.time.nanoTimestamp();
    const predictable_time = @as(f64, @floatFromInt(end - start)) / 1_000_000.0;
    
    // Unpredictable pattern (mixed matching/non-matching)
    start = std.time.nanoTimestamp();
    for (0..iterations) |_| {
        for (test_ips) |ip| {
            _ = patterns.matchesIPv4(ip);
        }
    }
    end = std.time.nanoTimestamp();
    const unpredictable_time = @as(f64, @floatFromInt(end - start)) / 1_000_000.0;
    
    std.debug.print("  Predictable branches: {d:.3}ms\n", .{predictable_time});
    std.debug.print("  Unpredictable branches: {d:.3}ms\n", .{unpredictable_time});
    std.debug.print("  Branch prediction penalty: {d:.2}x\n", .{unpredictable_time / predictable_time});
}

fn analyzeCachePerformance(allocator: std.mem.Allocator) !void {
    // Test cache performance with different data sizes
    const sizes = [_]usize{ 1, 10, 100, 1000, 10000 };
    
    std.debug.print("  Cache performance analysis:\n", .{});
    
    for (sizes) |size| {
        // Create pattern set of specific size
        var pattern_list = std.ArrayList(u8){};
        defer pattern_list.deinit(allocator);
        
        for (0..size) |i| {
            try pattern_list.writer(allocator).print("10.{d}.0.0/24 ", .{i % 256});
        }
        
        const patterns_str = try pattern_list.toOwnedSlice(allocator);
        defer allocator.free(patterns_str);
        
        var patterns = try rgcidr.parseMultiplePatterns(patterns_str, false, allocator);
        defer patterns.deinit();
        
        const test_ip = try rgcidr.parseIPv4("10.123.0.1");
        const iterations = 1_000_000;
        
        const start = std.time.nanoTimestamp();
        for (0..iterations) |_| {
            _ = patterns.matchesIPv4(test_ip);
        }
        const end = std.time.nanoTimestamp();
        
        const time = @as(f64, @floatFromInt(end - start)) / 1_000_000.0;
        const time_per_op = time * 1_000_000 / @as(f64, @floatFromInt(iterations));
        
        std.debug.print("    {d:>5} patterns: {d:>7.3}ms ({d:>6.1}ns/op)\n", .{size, time, time_per_op});
    }
}
