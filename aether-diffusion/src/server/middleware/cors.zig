// CORS middleware
//
// This middleware handles Cross-Origin Resource Sharing (CORS)
// headers for web API requests.

const std = @import("std");
const Context = @import("../router.zig").Context;
const Handler = @import("../router.zig").Handler;

pub const CorsConfig = struct {
    allowed_origins: []const []const u8 = &[_][]const u8{"*"},
    allowed_methods: []const u8 = "GET,POST,PUT,DELETE,OPTIONS",
    allowed_headers: []const u8 = "Content-Type,Authorization,X-Requested-With",
    max_age: u32 = 86400, // 24 hours
    allow_credentials: bool = false,
};

pub fn cors(config: CorsConfig) fn(*Context, Handler) anyerror!void {
    return struct {
        fn middleware(ctx: *Context, next: Handler) !void {
            // Get the origin from the request
            const origin = ctx.request.headers.getFirstValue("Origin");
            
            // Check if origin is allowed
            var origin_allowed = false;
            if (origin) |req_origin| {
                for (config.allowed_origins) |allowed| {
                    if (std.mem.eql(u8, allowed, "*") or std.mem.eql(u8, allowed, req_origin)) {
                        origin_allowed = true;
                        break;
                    }
                }
            } else {
                // No origin header means same-origin request
                origin_allowed = true;
            }
            
            if (origin_allowed) {
                // Set CORS headers
                if (origin) |req_origin| {
                    if (std.mem.eql(u8, config.allowed_origins[0], "*")) {
                        try ctx.response.headers.append("Access-Control-Allow-Origin", "*");
                    } else {
                        try ctx.response.headers.append("Access-Control-Allow-Origin", req_origin);
                    }
                }
                
                try ctx.response.headers.append("Access-Control-Allow-Methods", config.allowed_methods);
                try ctx.response.headers.append("Access-Control-Allow-Headers", config.allowed_headers);
                
                if (config.allow_credentials) {
                    try ctx.response.headers.append("Access-Control-Allow-Credentials", "true");
                }
                
                const max_age_str = try std.fmt.allocPrint(ctx.allocator, "{d}", .{config.max_age});
                defer ctx.allocator.free(max_age_str);
                try ctx.response.headers.append("Access-Control-Max-Age", max_age_str);
            }
            
            // Handle preflight OPTIONS request
            if (ctx.request.method == .OPTIONS) {
                ctx.status(200);
                try ctx.text("");
                return;
            }
            
            // Continue to next middleware/handler
            try next(ctx);
        }
    }.middleware;
}

// Default CORS middleware with permissive settings for development
pub fn defaultCors(ctx: *Context, next: Handler) !void {
    const default_config = CorsConfig{};
    const middleware_fn = cors(default_config);
    try middleware_fn(ctx, next);
}

// Strict CORS middleware for production
pub fn strictCors(allowed_origins: []const []const u8) fn(*Context, Handler) anyerror!void {
    const strict_config = CorsConfig{
        .allowed_origins = allowed_origins,
        .allowed_methods = "GET,POST,PUT,DELETE",
        .allowed_headers = "Content-Type,Authorization",
        .allow_credentials = true,
    };
    return cors(strict_config);
}

test "cors middleware allows all origins by default" {
    // This would need a proper test setup with mock Context
    // For now, just verify the configuration
    const config = CorsConfig{};
    try std.testing.expectEqualStrings("*", config.allowed_origins[0]);
    try std.testing.expect(!config.allow_credentials);
}