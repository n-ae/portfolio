const std = @import("std");
const rgcidr = @import("rgcidr");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Example 1: Parse and match individual patterns
    std.debug.print("=== Individual Pattern Matching ===\n", .{});
    
    // Parse a CIDR pattern
    const cidr_pattern = try rgcidr.parsePattern("192.168.0.0/16", false);
    const ip = try rgcidr.parseIPv4("192.168.1.100");
    const matches = cidr_pattern.matchesIPv4(ip);
    std.debug.print("IP 192.168.1.100 matches 192.168.0.0/16: {}\n", .{matches});
    
    // Parse IPv6 pattern
    const ipv6_pattern = try rgcidr.parsePattern("2001:db8::/32", false);
    const ipv6 = try rgcidr.parseIPv6("2001:db8::1");
    const ipv6_matches = ipv6_pattern.matchesIPv6(ipv6);
    std.debug.print("IP 2001:db8::1 matches 2001:db8::/32: {}\n", .{ipv6_matches});

    // Example 2: Multiple patterns for efficient matching
    std.debug.print("\n=== Multiple Pattern Matching ===\n", .{});
    
    var patterns = try rgcidr.parseMultiplePatterns("10.0.0.0/8,192.168.0.0/16 172.16.0.0/12", false, allocator);
    defer patterns.deinit();
    
    const test_ips = [_][]const u8{"10.1.1.1", "192.168.50.1", "172.16.100.1", "8.8.8.8"};
    for (test_ips) |test_ip_str| {
        const test_ip = try rgcidr.parseIPv4(test_ip_str);
        const private_match = patterns.matchesIPv4(test_ip);
        std.debug.print("IP {s} is private: {}\n", .{test_ip_str, private_match});
    }

    // Example 3: Scanning lines for IP addresses
    std.debug.print("\n=== Line Scanning ===\n", .{});
    
    var scanner = rgcidr.IpScanner.init(allocator);
    defer scanner.deinit();
    
    const log_line = "2024-01-01 12:00:00 Server 192.168.1.50 received connection from 2001:db8::dead:beef";
    const found_ipv4s = try scanner.scanIPv4(log_line);
    const found_ipv6s = try scanner.scanIPv6(log_line);
    
    std.debug.print("Found {} IPv4 addresses: ", .{found_ipv4s.len});
    for (found_ipv4s) |found_ip| {
        var buf: [16]u8 = undefined;
        const formatted = try rgcidr.formatIPv4(found_ip, &buf);
        std.debug.print("{s} ", .{formatted});
    }
    
    std.debug.print("\nFound {} IPv6 addresses\n", .{found_ipv6s.len});

    // Example 4: Convenience functions
    std.debug.print("\n=== Convenience Functions ===\n", .{});
    
    var line_ipv4s = try rgcidr.findIPv4InLine("Error from 10.0.0.1 and 172.16.5.10", allocator);
    defer line_ipv4s.deinit(allocator);
    
    std.debug.print("Convenience scan found {} IPv4 addresses\n", .{line_ipv4s.items.len});
    
    std.debug.print("\nAPI demonstration complete!\n", .{});
}
