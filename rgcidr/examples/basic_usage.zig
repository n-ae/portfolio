const std = @import("std");
const rgcidr = @import("rgcidr");
const print = std.debug.print;
const allocator = std.heap.page_allocator;

pub fn main() !void {
    print("=== rgcidr Library Usage Examples ===\n\n", .{});
    
    // Example 1: Basic IPv4 parsing and matching
    print("1. Basic IPv4 parsing and matching\n", .{});
    const ip = try rgcidr.parseIPv4("192.168.1.100");
    const pattern = try rgcidr.parsePattern("192.168.1.0/24", false);
    
    print("   IP: 192.168.1.100\n", .{});
    print("   Pattern: 192.168.1.0/24\n", .{});
    print("   Matches: {}\n\n", .{pattern.matchesIPv4(ip)});
    
    // Example 2: IPv6 parsing and matching  
    print("2. IPv6 parsing and matching\n", .{});
    const ipv6 = try rgcidr.parseIPv6("2001:db8::1");
    const ipv6_pattern = try rgcidr.parsePattern("2001:db8::/32", false);
    
    print("   IP: 2001:db8::1\n", .{});
    print("   Pattern: 2001:db8::/32\n", .{});
    print("   Matches: {}\n\n", .{ipv6_pattern.matchesIPv6(ipv6)});
    
    // Example 3: Multiple patterns
    print("3. Multiple patterns matching\n", .{});
    var patterns = try rgcidr.parseMultiplePatterns("192.168.0.0/16,10.0.0.0/8,172.16.0.0/12", false, allocator);
    defer patterns.deinit();
    
    const test_ips = [_][]const u8{ "192.168.1.1", "10.0.0.1", "172.16.1.1", "8.8.8.8" };
    
    for (test_ips) |ip_str| {
        const test_ip = try rgcidr.parseIPv4(ip_str);
        const matches = patterns.matchesIPv4(test_ip);
        print("   {s}: {}\n", .{ ip_str, matches });
    }
    print("\n", .{});
    
    // Example 4: Finding IPs in text
    print("4. Finding IPs in text\n", .{});
    const sample_text = "Server 192.168.1.10 and backup 10.0.0.5 are online";
    
    var found_ips = try rgcidr.findIPv4InLine(sample_text, allocator);
    defer found_ips.deinit(allocator);
    
    print("   Text: '{s}'\n", .{sample_text});
    print("   Found {} IPs:\n", .{found_ips.items.len});
    
    for (found_ips.items) |found_ip| {
        var buffer: [16]u8 = undefined;
        const formatted = try rgcidr.formatIPv4(found_ip, &buffer);
        print("     - {s}\n", .{formatted});
    }
    print("\n", .{});
    
    // Example 5: IP range matching
    print("5. IP range matching\n", .{});
    const range_pattern = try rgcidr.parsePattern("192.168.1.10-192.168.1.20", false);
    const test_range_ips = [_][]const u8{ "192.168.1.5", "192.168.1.15", "192.168.1.25" };
    
    for (test_range_ips) |ip_str| {
        const test_ip = try rgcidr.parseIPv4(ip_str);
        const matches = range_pattern.matchesIPv4(test_ip);
        print("   {s} in range 192.168.1.10-192.168.1.20: {}\n", .{ ip_str, matches });
    }
    print("\n", .{});
    
    // Example 6: Error handling
    print("6. Error handling\n", .{});
    if (rgcidr.parseIPv4("256.256.256.256")) |_| {
        print("   This shouldn't print\n", .{});
    } else |err| {
        print("   Invalid IP caught error: {}\n", .{err});
    }
    
    if (rgcidr.parsePattern("192.168.1.0/33", false)) |_| {
        print("   This shouldn't print\n", .{});
    } else |err| {
        print("   Invalid CIDR caught error: {}\n", .{err});
    }
    
    print("\n=== Examples Complete ===\n", .{});
}
