const std = @import("std");
const fs = std.fs;
const process = std.process;
const ArrayList = std.ArrayList;

/// Unified test result structure for CSV reporting
pub const TestResult = struct {
    test_type: []const u8,
    test_name: []const u8,
    status: []const u8,
    duration_ms: f64,
    error_message: ?[]const u8,

    pub fn init(test_type: []const u8, test_name: []const u8, status: []const u8, duration_ms: f64, error_message: ?[]const u8) TestResult {
        return TestResult{
            .test_type = test_type,
            .test_name = test_name,
            .status = status,
            .duration_ms = duration_ms,
            .error_message = error_message,
        };
    }
};

/// CSV Reporter for test results
pub const CSVReporter = struct {
    allocator: std.mem.Allocator,
    results: ArrayList(TestResult),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .allocator = allocator,
            .results = ArrayList(TestResult).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.results.deinit();
    }

    /// Add a test result to the collection
    pub fn addResult(self: *Self, result: TestResult) !void {
        try self.results.append(result);
    }

    /// Print CSV header to stdout
    pub fn printHeader(self: *Self) void {
        _ = self;
        const stdout = std.io.getStdOut().writer();
        stdout.print("test_type,test_name,status,duration_ms,error_message\n") catch {};
    }

    /// Print all results to stdout in CSV format
    pub fn printResults(self: *Self) void {
        const stdout = std.io.getStdOut().writer();
        
        for (self.results.items) |result| {
            const error_msg = result.error_message orelse "";
            stdout.print("{s},{s},{s},{d},{s}\n", .{
                result.test_type,
                result.test_name,
                result.status,
                result.duration_ms,
                error_msg,
            }) catch {};
        }
    }

    /// Save results to a CSV file
    pub fn saveToFile(self: *Self, file_path: []const u8) !void {
        const file = try fs.cwd().createFile(file_path, .{});
        defer file.close();

        const writer = file.writer();

        // Write header
        try writer.print("test_type,test_name,status,duration_ms,error_message\n");

        // Write results
        for (self.results.items) |result| {
            const error_msg = result.error_message orelse "";
            try writer.print("{s},{s},{s},{d},{s}\n", .{
                result.test_type,
                result.test_name,
                result.status,
                result.duration_ms,
                error_msg,
            });
        }
    }
};

/// Helper function to run a test and measure duration
pub fn runTimedTest(comptime test_name: []const u8, comptime test_func: fn () anyerror!void, test_type: []const u8, reporter: *CSVReporter) void {
    const start_time = std.time.milliTimestamp();
    
    const result = test_func() catch |err| {
        const end_time = std.time.milliTimestamp();
        const duration = @as(f64, @floatFromInt(end_time - start_time));
        
        const error_msg = std.fmt.allocPrint(reporter.allocator, "{}", .{err}) catch "allocation_error";
        defer if (!std.mem.eql(u8, error_msg, "allocation_error")) reporter.allocator.free(error_msg);
        
        const test_result = TestResult.init(test_type, test_name, "FAIL", duration, error_msg);
        reporter.addResult(test_result) catch {};
        return;
    };
    
    _ = result;
    const end_time = std.time.milliTimestamp();
    const duration = @as(f64, @floatFromInt(end_time - start_time));
    
    const test_result = TestResult.init(test_type, test_name, "PASS", duration, null);
    reporter.addResult(test_result) catch {};
}

/// Test expectation types for blackbox testing
pub const ExpectationType = enum {
    success,
    failure,
    output,
};

/// Test expectation structure for validating command results
pub const TestExpectation = struct {
    expectation_type: ExpectationType,
    expected_output: ?[]const u8 = null,

    pub fn validate(self: TestExpectation, result: process.Child.RunResult, allocator: std.mem.Allocator) !?[]const u8 {
        return switch (self.expectation_type) {
            .success => {
                if (result.term.Exited != 0) {
                    return try std.fmt.allocPrint(allocator, "Expected success but got exit code {}", .{result.term.Exited});
                }
                return null;
            },
            .failure => {
                if (result.term.Exited == 0) {
                    return try std.fmt.allocPrint(allocator, "Expected failure but command succeeded");
                }
                return null;
            },
            .output => {
                if (self.expected_output) |expected| {
                    if (!std.mem.containsAtLeast(u8, result.stdout, 1, expected)) {
                        return try std.fmt.allocPrint(allocator, "Expected output '{s}' not found in '{s}'", .{ expected, result.stdout });
                    }
                }
                return null;
            },
        };
    }
};