const std = @import("std");
const testing = std.testing;

/// Test output format options
pub const OutputFormat = enum {
    standard,
    csv,
    json,
};

/// Test result for a single test
pub const TestResult = struct {
    name: []const u8,
    passed: bool,
    duration_ms: f64,
    error_message: ?[]const u8 = null,

    pub fn deinit(self: *TestResult, allocator: std.mem.Allocator) void {
        if (self.error_message) |msg| {
            allocator.free(msg);
        }
    }
};

/// Test suite results aggregation
pub const TestSuiteResult = struct {
    suite_name: []const u8,
    tests: std.ArrayList(TestResult),
    total_duration_ms: f64 = 0,

    pub fn init(allocator: std.mem.Allocator, suite_name: []const u8) TestSuiteResult {
        return TestSuiteResult{
            .suite_name = suite_name,
            .tests = std.ArrayList(TestResult).init(allocator),
        };
    }

    pub fn deinit(self: *TestSuiteResult) void {
        for (self.tests.items) |*test_result| {
            test_result.deinit(self.tests.allocator);
        }
        self.tests.deinit();
    }

    pub fn addTest(self: *TestSuiteResult, result: TestResult) !void {
        self.total_duration_ms += result.duration_ms;
        try self.tests.append(result);
    }

    pub fn getPassedCount(self: *const TestSuiteResult) u32 {
        var count: u32 = 0;
        for (self.tests.items) |result| {
            if (result.passed) count += 1;
        }
        return count;
    }

    pub fn getFailedCount(self: *const TestSuiteResult) u32 {
        var count: u32 = 0;
        for (self.tests.items) |result| {
            if (!result.passed) count += 1;
        }
        return count;
    }
};

/// Unified test runner that supports multiple output formats
pub const TestRunner = struct {
    allocator: std.mem.Allocator,
    output_format: OutputFormat,
    output_file: ?[]const u8 = null,

    pub fn init(allocator: std.mem.Allocator, format: OutputFormat) TestRunner {
        return TestRunner{
            .allocator = allocator,
            .output_format = format,
        };
    }

    pub fn setOutputFile(self: *TestRunner, file_path: []const u8) void {
        self.output_file = file_path;
    }

    /// Run a single test function and measure timing
    pub fn runTest(self: *TestRunner, comptime test_name: []const u8, test_func: fn () anyerror!void) TestResult {
        var timer = std.time.Timer.start() catch unreachable;
        
        test_func() catch |err| {
            const duration_ns = timer.read();
            const duration_ms = @as(f64, @floatFromInt(duration_ns)) / 1_000_000.0;
            
            const error_msg = std.fmt.allocPrint(self.allocator, "Test failed with error: {}", .{err}) catch "Unknown error";
            return TestResult{
                .name = test_name,
                .passed = false,
                .duration_ms = duration_ms,
                .error_message = error_msg,
            };
        };

        const duration_ns = timer.read();
        const duration_ms = @as(f64, @floatFromInt(duration_ns)) / 1_000_000.0;
        
        return TestResult{
            .name = test_name,
            .passed = true,
            .duration_ms = duration_ms,
        };
    }

    /// Output test results in the specified format
    pub fn outputResults(self: *TestRunner, suite_result: *const TestSuiteResult) !void {
        switch (self.output_format) {
            .standard => try self.outputStandard(suite_result),
            .csv => try self.outputCSV(suite_result),
            .json => try self.outputJSON(suite_result),
        }
    }

    fn outputStandard(self: *TestRunner, suite_result: *const TestSuiteResult) !void {
        _ = self;
        const stdout = std.io.getStdOut().writer();
        
        try stdout.print("\n=== {s} Test Results ===\n", .{suite_result.suite_name});
        
        for (suite_result.tests.items) |result| {
            const status = if (result.passed) "✅ PASS" else "❌ FAIL";
            try stdout.print("{s} {s} ({d:.2}ms)\n", .{ status, result.name, result.duration_ms });
            
            if (result.error_message) |msg| {
                try stdout.print("    Error: {s}\n", .{msg});
            }
        }
        
        const passed = suite_result.getPassedCount();
        const failed = suite_result.getFailedCount();
        const total = passed + failed;
        
        try stdout.print("\nSummary: {d}/{d} passed, {d} failed ({d:.2}ms total)\n", 
            .{ passed, total, failed, suite_result.total_duration_ms });
    }

    fn outputCSV(self: *TestRunner, suite_result: *const TestSuiteResult) !void {
        const output_writer = if (self.output_file) |file_path| blk: {
            const file = try std.fs.cwd().createFile(file_path, .{});
            break :blk file.writer();
        } else std.io.getStdOut().writer();

        // CSV Header
        try output_writer.print("test_type,test_name,status,duration_ms,error_message\n", .{});
        
        for (suite_result.tests.items) |result| {
            const status = if (result.passed) "PASS" else "FAIL";
            const error_msg = result.error_message orelse "";
            
            // Escape commas and quotes in error messages
            const escaped_error = try self.escapeCSVField(error_msg);
            defer if (escaped_error.len != error_msg.len) self.allocator.free(escaped_error);
            
            try output_writer.print("{s},{s},{s},{d:.2},{s}\n", 
                .{ suite_result.suite_name, result.name, status, result.duration_ms, escaped_error });
        }
    }

    fn outputJSON(self: *TestRunner, suite_result: *const TestSuiteResult) !void {
        const output_writer = if (self.output_file) |file_path| blk: {
            const file = try std.fs.cwd().createFile(file_path, .{});
            break :blk file.writer();
        } else std.io.getStdOut().writer();

        try output_writer.print("{\n");
        try output_writer.print("  \"suite_name\": \"{s}\",\n", .{suite_result.suite_name});
        try output_writer.print("  \"total_duration_ms\": {d:.2},\n", .{suite_result.total_duration_ms});
        try output_writer.print("  \"passed\": {d},\n", .{suite_result.getPassedCount()});
        try output_writer.print("  \"failed\": {d},\n", .{suite_result.getFailedCount()});
        try output_writer.print("  \"tests\": [\n");
        
        for (suite_result.tests.items, 0..) |result, i| {
            try output_writer.print("    {\n");
            try output_writer.print("      \"name\": \"{s}\",\n", .{result.name});
            try output_writer.print("      \"passed\": {s},\n", .{if (result.passed) "true" else "false"});
            try output_writer.print("      \"duration_ms\": {d:.2}", .{result.duration_ms});
            
            if (result.error_message) |msg| {
                const escaped_msg = try self.escapeJSONString(msg);
                defer self.allocator.free(escaped_msg);
                try output_writer.print(",\n      \"error_message\": \"{s}\"", .{escaped_msg});
            }
            
            try output_writer.print("\n    }");
            if (i < suite_result.tests.items.len - 1) {
                try output_writer.print(",");
            }
            try output_writer.print("\n");
        }
        
        try output_writer.print("  ]\n");
        try output_writer.print("}\n");
    }

    fn escapeCSVField(self: *TestRunner, field: []const u8) ![]const u8 {
        if (std.mem.indexOf(u8, field, ",") == null and 
           std.mem.indexOf(u8, field, "\"") == null and
           std.mem.indexOf(u8, field, "\n") == null) {
            return field; // No escaping needed
        }
        
        // Need to escape - wrap in quotes and escape internal quotes
        var escaped = std.ArrayList(u8).init(self.allocator);
        try escaped.append('"');
        
        for (field) |c| {
            if (c == '"') {
                try escaped.appendSlice("\"\""); // Escape quote with double quote
            } else {
                try escaped.append(c);
            }
        }
        
        try escaped.append('"');
        return escaped.toOwnedSlice();
    }

    fn escapeJSONString(self: *TestRunner, str: []const u8) ![]const u8 {
        var escaped = std.ArrayList(u8).init(self.allocator);
        
        for (str) |c| {
            switch (c) {
                '"' => try escaped.appendSlice("\\\""),
                '\\' => try escaped.appendSlice("\\\\"),
                '\n' => try escaped.appendSlice("\\n"),
                '\r' => try escaped.appendSlice("\\r"),
                '\t' => try escaped.appendSlice("\\t"),
                else => try escaped.append(c),
            }
        }
        
        return escaped.toOwnedSlice();
    }
};

/// Convenience macro for defining test functions that work with the framework
pub fn runTestSuite(
    comptime suite_name: []const u8,
    comptime test_functions: anytype,
    allocator: std.mem.Allocator,
    output_format: OutputFormat,
    output_file: ?[]const u8,
) !void {
    var runner = TestRunner.init(allocator, output_format);
    if (output_file) |file| {
        runner.setOutputFile(file);
    }

    var suite_result = TestSuiteResult.init(allocator, suite_name);
    defer suite_result.deinit();

    // Run each test function
    inline for (test_functions) |test_info| {
        const result = runner.runTest(test_info.name, test_info.func);
        try suite_result.addTest(result);
    }

    try runner.outputResults(&suite_result);
}