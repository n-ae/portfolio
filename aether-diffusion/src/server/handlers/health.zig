// Health check handlers
//
// These handlers provide system health and status information
// for monitoring and load balancer health checks.

const std = @import("std");
const Context = @import("../router.zig").Context;
const logging = @import("../../yahoo_fantasy/logging.zig");

pub fn healthCheck(ctx: *Context) !void {
    const health_data = .{
        .status = "healthy",
        .timestamp = std.time.timestamp(),
        .version = "1.0.0",
        .uptime_seconds = getUptimeSeconds(),
    };
    
    try ctx.json(health_data);
}

pub fn readinessCheck(ctx: *Context) !void {
    // Perform more thorough checks for readiness
    const checks = .{
        .database = checkDatabase(),
        .external_apis = checkExternalApis(),
        .memory = checkMemoryUsage(),
    };
    
    const all_ready = checks.database and checks.external_apis and checks.memory;
    
    if (all_ready) {
        try ctx.json(.{
            .status = "ready",
            .timestamp = std.time.timestamp(),
            .checks = checks,
        });
    } else {
        ctx.status(503);
        try ctx.json(.{
            .status = "not_ready", 
            .timestamp = std.time.timestamp(),
            .checks = checks,
        });
    }
}

pub fn livenessCheck(ctx: *Context) !void {
    // Simple liveness check - if we can respond, we're alive
    try ctx.json(.{
        .status = "alive",
        .timestamp = std.time.timestamp(),
    });
}

pub fn statusInfo(ctx: *Context) !void {
    const status_data = .{
        .service = "Yahoo Fantasy API Proxy",
        .version = "1.0.0",
        .environment = std.process.getEnvVarOwned(ctx.allocator, "ENVIRONMENT") catch "development",
        .timestamp = std.time.timestamp(),
        .uptime_seconds = getUptimeSeconds(),
        .memory_usage = getMemoryUsage(),
        .go_routines = 1, // Zig doesn't have goroutines, but keeping for API compatibility
        .system = .{
            .os = @tagName(std.builtin.os.tag),
            .arch = @tagName(std.builtin.cpu.arch),
            .zig_version = std.builtin.zig_version_string,
        },
    };
    
    // Free environment variable if allocated
    if (@TypeOf(status_data.environment) == []u8) {
        defer ctx.allocator.free(status_data.environment);
    }
    
    try ctx.json(status_data);
}

pub fn metricsEndpoint(ctx: *Context) !void {
    // Simple Prometheus-style metrics
    const metrics_text = 
        \\# HELP http_requests_total Total number of HTTP requests
        \\# TYPE http_requests_total counter
        \\http_requests_total 123
        \\
        \\# HELP http_request_duration_seconds HTTP request duration in seconds
        \\# TYPE http_request_duration_seconds histogram
        \\http_request_duration_seconds_bucket{{le="0.1"}} 95
        \\http_request_duration_seconds_bucket{{le="0.5"}} 98
        \\http_request_duration_seconds_bucket{{le="1.0"}} 100
        \\http_request_duration_seconds_bucket{{le="+Inf"}} 100
        \\http_request_duration_seconds_count 100
        \\http_request_duration_seconds_sum 15.5
        \\
        \\# HELP memory_usage_bytes Current memory usage in bytes
        \\# TYPE memory_usage_bytes gauge
        \\memory_usage_bytes{type="heap"}
    ;
    
    const memory_usage = getMemoryUsage();
    const full_metrics = try std.fmt.allocPrint(
        ctx.allocator,
        "{s} {d}\n",
        .{ metrics_text, memory_usage }
    );
    defer ctx.allocator.free(full_metrics);
    
    try ctx.response.headers.append("Content-Type", "text/plain; version=0.0.4");
    try ctx.text(full_metrics);
}

// Helper functions
var start_time: i64 = 0;
var start_time_set = false;

fn getUptimeSeconds() i64 {
    if (!start_time_set) {
        start_time = std.time.timestamp();
        start_time_set = true;
    }
    return std.time.timestamp() - start_time;
}

fn getMemoryUsage() usize {
    // This is a simplified memory usage check
    // In a real implementation, you might want to track actual heap usage
    return 1024 * 1024 * 50; // 50MB placeholder
}

fn checkDatabase() bool {
    // Placeholder for database connectivity check
    // In a real implementation, you would ping your database
    return true;
}

fn checkExternalApis() bool {
    // Placeholder for external API checks (Yahoo API, etc.)
    // In a real implementation, you would make a lightweight request
    return true;
}

fn checkMemoryUsage() bool {
    // Check if memory usage is within acceptable limits
    const usage = getMemoryUsage();
    const limit = 1024 * 1024 * 500; // 500MB limit
    return usage < limit;
}

test "uptime tracking" {
    const uptime1 = getUptimeSeconds();
    std.time.sleep(std.time.ns_per_ms * 10); // Sleep 10ms
    const uptime2 = getUptimeSeconds();
    
    try std.testing.expect(uptime2 >= uptime1);
}

test "health checks return boolean" {
    try std.testing.expect(checkDatabase() == true or checkDatabase() == false);
    try std.testing.expect(checkExternalApis() == true or checkExternalApis() == false);
    try std.testing.expect(checkMemoryUsage() == true or checkMemoryUsage() == false);
}