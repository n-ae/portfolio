const std = @import("std");
const rgcidr = @import("rgcidr");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    print("=== rgcidr Advanced Usage Examples ===\n\n");
    
    // Example 1: Bulk IP processing
    try bulkIpProcessingExample(allocator);
    
    // Example 2: Log file analysis
    try logFileAnalysisExample(allocator);
    
    // Example 3: Network security filtering
    try securityFilteringExample(allocator);
    
    // Example 4: IPv6 with embedded IPv4
    try ipv6EmbeddedExample(allocator);
    
    print("=== Advanced Examples Complete ===\n");
}

fn bulkIpProcessingExample(allocator: std.mem.Allocator) !void {
    print("1. Bulk IP processing with performance focus\n");
    
    // Create a corporate network pattern (RFC 1918 private networks)
    var corporate_patterns = try rgcidr.parseMultiplePatterns(
        "192.168.0.0/16 10.0.0.0/8 172.16.0.0/12", 
        false, 
        allocator
    );
    defer corporate_patterns.deinit();
    
    // Simulate processing a large batch of IPs
    const sample_ips = [_][]const u8{
        "192.168.1.100",    // Corporate
        "10.0.50.25",       // Corporate  
        "172.16.200.1",     // Corporate
        "8.8.8.8",          // External (Google DNS)
        "1.1.1.1",          // External (Cloudflare DNS)  
        "203.0.113.45",     // External (TEST-NET-3)
        "172.15.1.1",       // External (just outside 172.16.0.0/12)
    };
    
    var internal_count: u32 = 0;
    var external_count: u32 = 0;
    
    // Process IPs efficiently
    for (sample_ips) |ip_str| {
        if (rgcidr.parseIPv4(ip_str)) |ip| {
            if (corporate_patterns.matchesIPv4(ip)) {
                internal_count += 1;
                print("   Internal: {s}\n", .{ip_str});
            } else {
                external_count += 1;
                print("   External: {s}\n", .{ip_str});
            }
        } else |err| {
            print("   Error parsing {s}: {}\n", .{ ip_str, err });
        }
    }
    
    print("   Summary: {} internal, {} external\n\n", .{ internal_count, external_count });
}

fn logFileAnalysisExample(allocator: std.mem.Allocator) !void {
    print("2. Log file analysis simulation\n");
    
    // Simulate log entries from different sources
    const log_entries = [_][]const u8{
        "2024-01-15 10:30:45 INFO [192.168.1.15] User login successful",
        "2024-01-15 10:31:02 WARN [203.0.113.25] Failed login attempt from external IP",
        "2024-01-15 10:31:15 INFO [10.0.5.100] Database connection established", 
        "2024-01-15 10:31:30 ERROR [198.51.100.5] Suspicious activity detected",
        "2024-01-15 10:31:45 INFO [172.16.50.10] File upload completed",
        "2024-01-15 10:32:00 INFO [2001:db8::1] IPv6 client connected",
    };
    
    // Define suspicious network ranges (example: known bad actor networks)
    var threat_patterns = try rgcidr.parseMultiplePatterns(
        "198.51.100.0/24 203.0.113.0/24", 
        false, 
        allocator
    );
    defer threat_patterns.deinit();
    
    print("   Analyzing log entries for threats:\n");
    
    for (log_entries) |entry| {
        // Extract IPv4 addresses from log line
        var found_ipv4 = try rgcidr.findIPv4InLine(entry, allocator);
        defer found_ipv4.deinit(allocator);
        
        // Extract IPv6 addresses from log line  
        var found_ipv6 = try rgcidr.findIPv6InLine(entry, allocator);
        defer found_ipv6.deinit(allocator);
        
        var threat_detected = false;
        
        // Check IPv4 addresses against threat patterns
        for (found_ipv4.items) |ip| {
            if (threat_patterns.matchesIPv4(ip)) {
                threat_detected = true;
                break;
            }
        }
        
        // Format output
        const status = if (threat_detected) "🚨 THREAT" else "✅ Safe";
        const ip_count = found_ipv4.items.len + found_ipv6.items.len;
        print("   {s} ({} IPs): {s}\n", .{ status, ip_count, entry });
    }
    
    print("\n");
}

fn securityFilteringExample(allocator: std.mem.Allocator) !void {
    print("3. Network security filtering\n");
    
    // Define different security zones
    var dmz_patterns = try rgcidr.parseMultiplePatterns("203.0.113.0/24", false, allocator);
    defer dmz_patterns.deinit();
    
    var internal_patterns = try rgcidr.parseMultiplePatterns("192.168.0.0/16 10.0.0.0/8", false, allocator);  
    defer internal_patterns.deinit();
    
    var mgmt_patterns = try rgcidr.parseMultiplePatterns("10.255.255.0/24", false, allocator);
    defer mgmt_patterns.deinit();
    
    const network_traffic = [_]struct { src: []const u8, dst: []const u8, action: []const u8 }{
        .{ .src = "192.168.1.100", .dst = "203.0.113.5", .action = "HTTP_GET" },
        .{ .src = "203.0.113.5", .dst = "192.168.1.100", .action = "HTTP_RESP" },
        .{ .src = "10.255.255.10", .dst = "192.168.1.15", .action = "SSH" },
        .{ .src = "8.8.8.8", .dst = "192.168.1.50", .action = "DNS_RESP" },
        .{ .src = "192.168.1.200", .dst = "10.255.255.10", .action = "SNMP" },
    };
    
    print("   Network traffic analysis:\n");
    
    for (network_traffic) |traffic| {
        const src_ip = rgcidr.parseIPv4(traffic.src) catch continue;
        const dst_ip = rgcidr.parseIPv4(traffic.dst) catch continue;
        
        // Classify source and destination
        const src_zone = classifyIpZone(src_ip, &internal_patterns, &dmz_patterns, &mgmt_patterns);
        const dst_zone = classifyIpZone(dst_ip, &internal_patterns, &dmz_patterns, &mgmt_patterns);
        
        // Determine if traffic should be allowed based on zones
        const allowed = isTrafficAllowed(src_zone, dst_zone, traffic.action);
        const status = if (allowed) "✅ ALLOW" else "🚫 BLOCK";
        
        print("   {s} {s}→{s} ({s}→{s}) {s}\n", .{ 
            status, traffic.src, traffic.dst, src_zone, dst_zone, traffic.action 
        });
    }
    
    print("\n");
}

const SecurityZone = enum { internal, dmz, management, external };

fn classifyIpZone(ip: rgcidr.IPv4, internal: *rgcidr.MultiplePatterns, dmz: *rgcidr.MultiplePatterns, mgmt: *rgcidr.MultiplePatterns) []const u8 {
    if (mgmt.matchesIPv4(ip)) return "MGMT";
    if (internal.matchesIPv4(ip)) return "INT";
    if (dmz.matchesIPv4(ip)) return "DMZ";
    return "EXT";
}

fn isTrafficAllowed(src_zone: []const u8, dst_zone: []const u8, action: []const u8) bool {
    // Simple security policy rules
    _ = action; // For this example, we don't check action type
    
    // Management can access anywhere
    if (std.mem.eql(u8, src_zone, "MGMT")) return true;
    
    // Internal can access DMZ and external
    if (std.mem.eql(u8, src_zone, "INT") and 
       (std.mem.eql(u8, dst_zone, "DMZ") or std.mem.eql(u8, dst_zone, "EXT"))) return true;
    
    // DMZ can respond to internal
    if (std.mem.eql(u8, src_zone, "DMZ") and std.mem.eql(u8, dst_zone, "INT")) return true;
    
    // External can access DMZ
    if (std.mem.eql(u8, src_zone, "EXT") and std.mem.eql(u8, dst_zone, "DMZ")) return true;
    
    // Block everything else
    return false;
}

fn ipv6EmbeddedExample(allocator: std.mem.Allocator) !void {
    print("4. IPv6 with embedded IPv4 addresses\n");
    
    // IPv4-mapped IPv6 addresses (::ffff:x.x.x.x)
    const ipv6_addresses = [_][]const u8{
        "::ffff:192.168.1.1",       // IPv4-mapped
        "::ffff:10.0.0.1",          // IPv4-mapped  
        "2001:db8::192.168.1.1",    // IPv6 with embedded IPv4
        "2001:db8::1",              // Pure IPv6
        "::1",                      // IPv6 loopback
    };
    
    // Create IPv6 patterns
    var ipv6_patterns = try rgcidr.parseMultiplePatterns("::ffff:0:0/96 2001:db8::/32", false, allocator);
    defer ipv6_patterns.deinit();
    
    print("   IPv6 address classification:\n");
    
    for (ipv6_addresses) |addr_str| {
        if (rgcidr.parseIPv6(addr_str)) |ipv6| {
            const matches = ipv6_patterns.matchesIPv6(ipv6);
            
            // Check if it's IPv4-mapped (starts with ::ffff:)
            const is_ipv4_mapped = (ipv6 & 0xffffffff00000000000000000000000000) == 0x00000000000000000000ffff00000000;
            
            var type_info: []const u8 = "Pure IPv6";
            if (is_ipv4_mapped) {
                type_info = "IPv4-mapped";
            } else if (std.mem.indexOf(u8, addr_str, ".") != null) {
                type_info = "Embedded IPv4";
            }
            
            const status = if (matches) "Match" else "No match";
            print("   {s}: {s} ({s})\n", .{ addr_str, status, type_info });
        } else |err| {
            print("   {s}: Parse error - {}\n", .{ addr_str, err });
        }
    }
    
    print("\n");
}
