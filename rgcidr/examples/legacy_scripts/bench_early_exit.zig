const std = @import("std");
const rgcidr = @import("rgcidr");

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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    std.debug.print("=== Early Termination Performance Benchmark ===\n\n", .{});
    
    // Create test patterns (looking for private networks)
    var patterns = try rgcidr.parseMultiplePatterns("192.168.0.0/16 10.0.0.0/8 172.16.0.0/12", false, allocator);
    defer patterns.deinit();
    
    // Generate test data with early matches (private IPs at beginning of lines)
    const line_count = 100_000;
    var early_match_data = std.ArrayList(u8){};
    defer early_match_data.deinit(allocator);
    
    var prng = std.Random.DefaultPrng.init(12345);
    const rand = prng.random();
    
    for (0..line_count) |i| {
        if (i % 3 == 0) {
            // 1/3 of lines start with matching private IP
            try early_match_data.writer(allocator).print("192.168.{d}.{d} some log entry here\n", .{
                rand.int(u8), rand.int(u8)
            });
        } else {
            // 2/3 of lines have no matching IPs or public IPs
            try early_match_data.writer(allocator).print("8.8.{d}.{d} public IP followed by more text and data\n", .{
                rand.int(u8), rand.int(u8)
            });
        }
    }
    
    const early_match_content = try early_match_data.toOwnedSlice(allocator);
    defer allocator.free(early_match_content);
    
    // Generate test data with late matches (matching IPs at end of lines) 
    var late_match_data = std.ArrayList(u8){};
    defer late_match_data.deinit(allocator);
    
    for (0..line_count) |i| {
        if (i % 3 == 0) {
            // 1/3 of lines end with matching private IP
            try late_match_data.writer(allocator).print("some long log entry here with IP at end: 10.0.{d}.{d}\n", .{
                rand.int(u8), rand.int(u8)
            });
        } else {
            // 2/3 of lines with public IPs
            try late_match_data.writer(allocator).print("public IP at end of line: 8.8.{d}.{d}\n", .{
                rand.int(u8), rand.int(u8)
            });
        }
    }
    
    const late_match_content = try late_match_data.toOwnedSlice(allocator);
    defer allocator.free(late_match_content);
    
    // Benchmark early termination vs full scan
    var scanner = rgcidr.IpScanner.init(allocator);
    defer scanner.deinit();
    
    std.debug.print("Testing with {d} lines...\n\n", .{line_count});
    
    // Test 1: Early matches with early termination
    {
        const timer = Timer.init();
        var match_count: u32 = 0;
        var lines = std.mem.splitSequence(u8, early_match_content, "\n");
        
        while (lines.next()) |line| {
            if (line.len == 0) continue;
            if (try scanner.scanIPv4WithEarlyExit(line, patterns)) |_| {
                match_count += 1;
            }
        }
        
        const time = timer.elapsed();
        std.debug.print("Early Match + Early Exit: {d:.3}ms ({d} matches, {d:.3}ns per line)\n", 
                      .{time, match_count, (time * 1_000_000) / @as(f64, @floatFromInt(line_count))});
    }
    
    // Test 2: Early matches with full scan
    {
        const timer = Timer.init();
        var match_count: u32 = 0;
        var lines = std.mem.splitSequence(u8, early_match_content, "\n");
        
        while (lines.next()) |line| {
            if (line.len == 0) continue;
            const ips = try scanner.scanIPv4(line);
            for (ips) |ip| {
                if (patterns.matchesIPv4(ip)) {
                    match_count += 1;
                    break; // Still break after first match for fair comparison
                }
            }
        }
        
        const time = timer.elapsed();
        std.debug.print("Early Match + Full Scan:  {d:.3}ms ({d} matches, {d:.3}ns per line)\n", 
                      .{time, match_count, (time * 1_000_000) / @as(f64, @floatFromInt(line_count))});
    }
    
    // Test 3: Late matches with early termination
    {
        const timer = Timer.init();
        var match_count: u32 = 0;
        var lines = std.mem.splitSequence(u8, late_match_content, "\n");
        
        while (lines.next()) |line| {
            if (line.len == 0) continue;
            if (try scanner.scanIPv4WithEarlyExit(line, patterns)) |_| {
                match_count += 1;
            }
        }
        
        const time = timer.elapsed();
        std.debug.print("Late Match + Early Exit:  {d:.3}ms ({d} matches, {d:.3}ns per line)\n", 
                      .{time, match_count, (time * 1_000_000) / @as(f64, @floatFromInt(line_count))});
    }
    
    // Test 4: Late matches with full scan
    {
        const timer = Timer.init();
        var match_count: u32 = 0;
        var lines = std.mem.splitSequence(u8, late_match_content, "\n");
        
        while (lines.next()) |line| {
            if (line.len == 0) continue;
            const ips = try scanner.scanIPv4(line);
            for (ips) |ip| {
                if (patterns.matchesIPv4(ip)) {
                    match_count += 1;
                    break; // Still break after first match for fair comparison
                }
            }
        }
        
        const time = timer.elapsed();
        std.debug.print("Late Match + Full Scan:   {d:.3}ms ({d} matches, {d:.3}ns per line)\n", 
                      .{time, match_count, (time * 1_000_000) / @as(f64, @floatFromInt(line_count))});
    }
    
    std.debug.print("\n=== Results Summary ===\n", .{});
    std.debug.print("Early termination should show better performance when matches appear early in lines.\n", .{});
    std.debug.print("The lookup table optimizations improve character validation performance.\n", .{});
}
