const std = @import("std");
const rgcidr = @import("rgcidr");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const line = "192.168.1.1 is a private IP";
    const pattern = "192.168.1.1";
    
    std.debug.print("Testing exact match:\n", .{});
    std.debug.print("Line: '{s}'\n", .{line});
    std.debug.print("Pattern: '{s}'\n", .{pattern});
    
    // Test pattern parsing
    var patterns = rgcidr.parseMultiplePatterns(pattern, false, allocator) catch |err| {
        std.debug.print("Pattern parse failed: {any}\n", .{err});
        return;
    };
    defer patterns.deinit();
    
    std.debug.print("Patterns parsed: {} IPv4 ranges, {} IPv6 ranges\n", .{patterns.ipv4_ranges.len, patterns.ipv6_ranges.len});
    
    // Test IPv4 extraction at line start
    var ips = findIPv4AtLineStart(line, allocator) catch |err| {
        std.debug.print("IP extraction failed: {any}\n", .{err});
        return;
    };
    defer ips.deinit(allocator);
    
    std.debug.print("Found {} IPs at line start\n", .{ips.items.len});
    for (ips.items) |ip| {
        std.debug.print("  IP: {d}.{d}.{d}.{d}\n", .{
            (ip >> 24) & 0xFF, (ip >> 16) & 0xFF, (ip >> 8) & 0xFF, ip & 0xFF
        });
        
        if (patterns.matchesIPv4(ip)) {
            std.debug.print("  -> MATCHES pattern\n", .{});
        } else {
            std.debug.print("  -> does not match pattern\n", .{});
        }
    }
}

/// Find IPv4 addresses only at the start of the line (for -x exact matching)
fn findIPv4AtLineStart(line: []const u8, allocator: std.mem.Allocator) !std.ArrayList(rgcidr.IPv4) {
    var ips = std.ArrayList(rgcidr.IPv4){};
    
    // Skip leading whitespace
    var i: usize = 0;
    while (i < line.len and (line[i] == ' ' or line[i] == '\t')) {
        i += 1;
    }
    
    if (i >= line.len) return ips;
    
    // Check if an IPv4 address starts at the beginning of the trimmed line
    if (i < line.len and std.ascii.isDigit(line[i])) {
        // Find the span that looks like an IP at the start
        var j = i;
        while (j < line.len and (std.ascii.isDigit(line[j]) or line[j] == '.')) {
            j += 1;
        }
        
        const potential_ip = line[i..j];
        std.debug.print("  Trying to parse potential IP: '{s}'\n", .{potential_ip});
        
        if (rgcidr.parseIPv4(potential_ip)) |ip| {
            try ips.append(allocator, ip);
            std.debug.print("  Successfully parsed as IP\n", .{});
        } else |err| {
            std.debug.print("  Failed to parse as IP: {any}\n", .{err});
        }
    }
    
    return ips;
}
