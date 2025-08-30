// Request logging middleware
//
// This middleware logs HTTP requests and responses with timing information
// and integrates with the structured logging system.

const std = @import("std");
const Context = @import("../router.zig").Context;
const Handler = @import("../router.zig").Handler;
const logging = @import("../../yahoo_fantasy/logging.zig");

pub fn requestLogger(ctx: *Context, next: Handler) !void {
    const start_time = std.time.milliTimestamp();
    
    // Generate request ID
    const request_id = try generateRequestId(ctx.allocator);
    defer ctx.allocator.free(request_id);
    
    // Store request ID in context for handlers to use
    ctx.user_data = @constCast(request_id.ptr);
    
    const method = @tagName(ctx.request.method);
    const path = ctx.request.target;
    const remote_addr = "unknown"; // HTTP server doesn't easily provide this in Zig
    
    // Log request start
    const request_context = logging.LogContext{}
        .with("request_id", request_id)
        .with("endpoint", path);
    
    logging.infoCtx(request_context, "Started {s} {s} from {s}", .{ method, path, remote_addr });
    
    // Execute next middleware/handler
    var had_error = false;
    next(ctx) catch |err| {
        had_error = true;
        
        const error_context = logging.LogContext{}
            .with("request_id", request_id)
            .with("endpoint", path);
        
        logging.errCtx(error_context, "Request handler error: {}", .{err});
        
        // Send generic error response if response hasn't been written yet
        ctx.internalServerError("An internal error occurred") catch {};
        
        return err;
    };
    
    const duration = std.time.milliTimestamp() - start_time;
    const status_code = @intFromEnum(ctx.response.status);
    
    // Log request completion
    const completion_context = logging.LogContext{}
        .with("request_id", request_id)
        .with("endpoint", path)
        .with("status_code", status_code)
        .with("duration_ms", @as(u64, @intCast(duration)));
    
    if (had_error or status_code >= 400) {
        logging.warnCtx(completion_context, "Completed {s} {s} - {d} ({d}ms)", .{ method, path, status_code, duration });
    } else {
        logging.infoCtx(completion_context, "Completed {s} {s} - {d} ({d}ms)", .{ method, path, status_code, duration });
    }
}

pub fn accessLogger(ctx: *Context, next: Handler) !void {
    const start_time = std.time.milliTimestamp();
    
    // Execute next middleware/handler
    try next(ctx);
    
    const duration = std.time.milliTimestamp() - start_time;
    const method = @tagName(ctx.request.method);
    const path = ctx.request.target;
    const status_code = @intFromEnum(ctx.response.status);
    const user_agent = ctx.request.headers.getFirstValue("User-Agent") orelse "-";
    
    // Common Log Format style logging
    const log_line = try std.fmt.allocPrint(
        ctx.allocator,
        "- - [{d}] \"{s} {s} HTTP/1.1\" {d} - \"{s}\" {d}ms",
        .{ std.time.timestamp(), method, path, status_code, user_agent, duration }
    );
    defer ctx.allocator.free(log_line);
    
    logging.info("{s}", .{log_line});
}

fn generateRequestId(allocator: std.mem.Allocator) ![]u8 {
    const timestamp = std.time.timestamp();
    var prng = std.Random.DefaultPrng.init(@intCast(timestamp));
    const random = prng.random();
    
    const random_bytes = random.int(u32);
    
    return std.fmt.allocPrint(allocator, "req-{x}-{x}", .{ timestamp, random_bytes });
}

test "request ID generation" {
    const allocator = std.testing.allocator;
    
    const id1 = try generateRequestId(allocator);
    defer allocator.free(id1);
    
    const id2 = try generateRequestId(allocator);
    defer allocator.free(id2);
    
    // Request IDs should be different
    try std.testing.expect(!std.mem.eql(u8, id1, id2));
    
    // Should start with "req-"
    try std.testing.expect(std.mem.startsWith(u8, id1, "req-"));
    try std.testing.expect(std.mem.startsWith(u8, id2, "req-"));
}