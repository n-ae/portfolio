// Simple HTTP router with middleware support
//
// This module provides a clean, maintainable routing system
// with middleware chain support for the web API server.

const std = @import("std");
const http = std.http;
const logging = @import("../yahoo_fantasy/logging.zig");

pub const Context = struct {
    allocator: std.mem.Allocator,
    request: *http.Server.Request,
    response: *http.Server.Response,
    params: std.StringHashMap([]const u8),
    query: std.StringHashMap([]const u8),
    body: ?[]const u8,
    user_data: ?*anyopaque = null,
    
    const Self = @This();
    
    pub fn init(allocator: std.mem.Allocator, request: *http.Server.Request, response: *http.Server.Response) Self {
        return Self{
            .allocator = allocator,
            .request = request,
            .response = response,
            .params = std.StringHashMap([]const u8).init(allocator),
            .query = std.StringHashMap([]const u8).init(allocator),
            .body = null,
        };
    }
    
    pub fn deinit(self: *Self) void {
        self.params.deinit();
        self.query.deinit();
        if (self.body) |body| {
            self.allocator.free(body);
        }
    }
    
    pub fn json(self: *Self, data: anytype) !void {
        const json_string = try std.json.stringify(data, .{}, self.allocator);
        defer self.allocator.free(json_string);
        
        try self.response.headers.append("Content-Type", "application/json");
        try self.response.headers.append("Content-Length", try std.fmt.allocPrint(self.allocator, "{d}", .{json_string.len}));
        
        try self.response.writeAll(json_string);
    }
    
    pub fn text(self: *Self, content: []const u8) !void {
        try self.response.headers.append("Content-Type", "text/plain");
        try self.response.headers.append("Content-Length", try std.fmt.allocPrint(self.allocator, "{d}", .{content.len}));
        
        try self.response.writeAll(content);
    }
    
    pub fn html(self: *Self, content: []const u8) !void {
        try self.response.headers.append("Content-Type", "text/html");
        try self.response.headers.append("Content-Length", try std.fmt.allocPrint(self.allocator, "{d}", .{content.len}));
        
        try self.response.writeAll(content);
    }
    
    pub fn status(self: *Self, code: u16) *Self {
        self.response.status = @enumFromInt(code);
        return self;
    }
    
    pub fn notFound(self: *Self) !void {
        self.status(404);
        try self.json(.{ .error = "Not Found", .message = "The requested resource was not found" });
    }
    
    pub fn badRequest(self: *Self, message: []const u8) !void {
        self.status(400);
        try self.json(.{ .error = "Bad Request", .message = message });
    }
    
    pub fn unauthorized(self: *Self) !void {
        self.status(401);
        try self.json(.{ .error = "Unauthorized", .message = "Authentication required" });
    }
    
    pub fn internalServerError(self: *Self, message: []const u8) !void {
        self.status(500);
        try self.json(.{ .error = "Internal Server Error", .message = message });
    }
    
    pub fn getParam(self: *Self, key: []const u8) ?[]const u8 {
        return self.params.get(key);
    }
    
    pub fn getQuery(self: *Self, key: []const u8) ?[]const u8 {
        return self.query.get(key);
    }
    
    pub fn readBody(self: *Self) !?[]const u8 {
        if (self.body != null) {
            return self.body;
        }
        
        const body = self.request.reader().readAllAlloc(self.allocator, 1024 * 1024) catch |err| switch (err) {
            error.StreamTooLong => return error.PayloadTooLarge,
            else => return err,
        };
        
        self.body = body;
        return body;
    }
};

pub const Handler = *const fn(*Context) anyerror!void;
pub const Middleware = *const fn(*Context, Handler) anyerror!void;

pub const Route = struct {
    method: []const u8,
    path: []const u8,
    handler: Handler,
    middlewares: []const Middleware,
    
    pub fn matches(self: Route, method: []const u8, path: []const u8) bool {
        return std.mem.eql(u8, self.method, method) and pathMatches(self.path, path);
    }
    
    pub fn extractParams(self: Route, path: []const u8, params: *std.StringHashMap([]const u8)) !void {
        var route_parts = std.mem.split(u8, self.path, "/");
        var path_parts = std.mem.split(u8, path, "/");
        
        while (route_parts.next()) |route_part| {
            const path_part = path_parts.next() orelse break;
            
            if (std.mem.startsWith(u8, route_part, "{") and std.mem.endsWith(u8, route_part, "}")) {
                const param_name = route_part[1..route_part.len-1];
                try params.put(param_name, path_part);
            }
        }
    }
};

pub const Router = struct {
    allocator: std.mem.Allocator,
    routes: std.ArrayList(Route),
    global_middlewares: std.ArrayList(Middleware),
    
    const Self = @This();
    
    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .routes = std.ArrayList(Route).init(allocator),
            .global_middlewares = std.ArrayList(Middleware).init(allocator),
        };
    }
    
    pub fn deinit(self: *Self) void {
        self.routes.deinit();
        self.global_middlewares.deinit();
    }
    
    pub fn use(self: *Self, middleware: Middleware) !void {
        try self.global_middlewares.append(middleware);
    }
    
    pub fn get(self: *Self, path: []const u8, handler: Handler) !void {
        try self.addRoute("GET", path, handler, &[_]Middleware{});
    }
    
    pub fn post(self: *Self, path: []const u8, handler: Handler) !void {
        try self.addRoute("POST", path, handler, &[_]Middleware{});
    }
    
    pub fn put(self: *Self, path: []const u8, handler: Handler) !void {
        try self.addRoute("PUT", path, handler, &[_]Middleware{});
    }
    
    pub fn delete(self: *Self, path: []const u8, handler: Handler) !void {
        try self.addRoute("DELETE", path, handler, &[_]Middleware{});
    }
    
    pub fn getWithMiddleware(self: *Self, path: []const u8, handler: Handler, middlewares: []const Middleware) !void {
        try self.addRoute("GET", path, handler, middlewares);
    }
    
    pub fn postWithMiddleware(self: *Self, path: []const u8, handler: Handler, middlewares: []const Middleware) !void {
        try self.addRoute("POST", path, handler, middlewares);
    }
    
    fn addRoute(self: *Self, method: []const u8, path: []const u8, handler: Handler, middlewares: []const Middleware) !void {
        try self.routes.append(Route{
            .method = method,
            .path = path,
            .handler = handler,
            .middlewares = middlewares,
        });
    }
    
    pub fn dispatch(self: *Self, ctx: *Context) !void {
        const method = @tagName(ctx.request.method);
        const path = ctx.request.target;
        
        // Parse query parameters
        try self.parseQuery(path, &ctx.query);
        
        for (self.routes.items) |route| {
            if (route.matches(method, path)) {
                // Extract route parameters
                try route.extractParams(path, &ctx.params);
                
                // Build middleware chain: global + route-specific + handler
                var all_middlewares = std.ArrayList(Middleware).init(self.allocator);
                defer all_middlewares.deinit();
                
                try all_middlewares.appendSlice(self.global_middlewares.items);
                try all_middlewares.appendSlice(route.middlewares);
                
                // Execute middleware chain
                try self.executeMiddlewareChain(ctx, all_middlewares.items, route.handler);
                return;
            }
        }
        
        // No route found
        try ctx.notFound();
    }
    
    fn executeMiddlewareChain(self: *Self, ctx: *Context, middlewares: []const Middleware, handler: Handler) !void {
        if (middlewares.len == 0) {
            return handler(ctx);
        }
        
        const current_middleware = middlewares[0];
        const remaining_middlewares = middlewares[1..];
        
        const next_handler = struct {
            router: *Self,
            context: *Context,
            remaining: []const Middleware,
            final_handler: Handler,
            
            fn call(self_inner: @This()) !void {
                return self_inner.router.executeMiddlewareChain(
                    self_inner.context,
                    self_inner.remaining,
                    self_inner.final_handler,
                );
            }
        }{ .router = self, .context = ctx, .remaining = remaining_middlewares, .final_handler = handler };
        
        return current_middleware(ctx, next_handler.call);
    }
    
    fn parseQuery(self: *Self, path: []const u8, query_map: *std.StringHashMap([]const u8)) !void {
        _ = self;
        
        const query_start = std.mem.indexOf(u8, path, "?") orelse return;
        const query_string = path[query_start + 1..];
        
        var pairs = std.mem.split(u8, query_string, "&");
        while (pairs.next()) |pair| {
            if (std.mem.indexOf(u8, pair, "=")) |eq_pos| {
                const key = pair[0..eq_pos];
                const value = pair[eq_pos + 1..];
                try query_map.put(key, value);
            }
        }
    }
};

fn pathMatches(route_path: []const u8, request_path: []const u8) bool {
    // Remove query string from request path
    const path_end = std.mem.indexOf(u8, request_path, "?") orelse request_path.len;
    const clean_path = request_path[0..path_end];
    
    var route_parts = std.mem.split(u8, route_path, "/");
    var path_parts = std.mem.split(u8, clean_path, "/");
    
    while (route_parts.next()) |route_part| {
        const path_part = path_parts.next() orelse return false;
        
        // Parameter placeholder (e.g., {id})
        if (std.mem.startsWith(u8, route_part, "{") and std.mem.endsWith(u8, route_part, "}")) {
            continue;
        }
        
        // Exact match required
        if (!std.mem.eql(u8, route_part, path_part)) {
            return false;
        }
    }
    
    // Make sure there are no extra path parts
    return path_parts.next() == null;
}

test "path matching" {
    try std.testing.expect(pathMatches("/api/users", "/api/users"));
    try std.testing.expect(pathMatches("/api/users/{id}", "/api/users/123"));
    try std.testing.expect(pathMatches("/api/users", "/api/users?page=1"));
    try std.testing.expect(!pathMatches("/api/users", "/api/users/123"));
    try std.testing.expect(!pathMatches("/api/users/{id}", "/api/users"));
}

test "route parameter extraction" {
    const allocator = std.testing.allocator;
    var params = std.StringHashMap([]const u8).init(allocator);
    defer params.deinit();
    
    const route = Route{
        .method = "GET",
        .path = "/api/users/{id}/posts/{post_id}",
        .handler = undefined,
        .middlewares = &[_]Middleware{},
    };
    
    try route.extractParams("/api/users/123/posts/456", &params);
    
    try std.testing.expectEqualStrings("123", params.get("id").?);
    try std.testing.expectEqualStrings("456", params.get("post_id").?);
}