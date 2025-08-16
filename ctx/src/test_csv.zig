const std = @import("std");
const process = std.process;
const testing = std.testing;
const fs = std.fs;
const print = std.debug.print;

const validation = @import("validation.zig");
const config = @import("config.zig");
const eol = validation.eol;

const TestResult = struct {
    name: []const u8,
    passed: bool,
    duration_ms: f64,
    error_msg: ?[]const u8 = null,
};

const ExpectationType = enum {
    success,
    failure,
    output,
};

const TestExpectation = struct {
    expectation_type: ExpectationType,
    expected_output: ?[]const u8 = null,
};

const OutputSelector = struct {
    fn hasValidExitCode(result: std.process.Child.RunResult) bool {
        return switch (result.term) {
            .Exited => |code| code == 0,
            else => false,
        };
    }

    fn selectOutput(result: std.process.Child.RunResult) []const u8 {
        return if (result.stdout.len > 0) result.stdout else result.stderr;
    }

    fn formatError(allocator: std.mem.Allocator, result: std.process.Child.RunResult, expected: []const u8) ![]const u8 {
        return try std.fmt.allocPrint(allocator, "Expected {s} but got exit code {d}, stdout: '{s}', stderr: '{s}'", .{ expected, switch (result.term) {
            .Exited => |code| code,
            else => -1,
        }, result.stdout, result.stderr });
    }
};

const TestRunner = struct {
    const Self = @This();
    
    allocator: std.mem.Allocator,
    ctx_binary: []const u8,
    results: std.ArrayList(TestResult),
    
    pub fn init(allocator: std.mem.Allocator, ctx_binary: []const u8) !Self {
        return Self{
            .allocator = allocator,
            .ctx_binary = ctx_binary,
            .results = std.ArrayList(TestResult).init(allocator),
        };
    }
    
    pub fn deinit(self: *Self) void {
        for (self.results.items) |result| {
            if (result.error_msg) |msg| {
                self.allocator.free(msg);
            }
        }
        self.results.deinit();
    }
    
    fn runCommand(self: *Self, args: []const []const u8) !std.process.Child.RunResult {
        var full_args = std.ArrayList([]const u8).init(self.allocator);
        defer full_args.deinit();
        
        try full_args.append(self.ctx_binary);
        try full_args.appendSlice(args);
        
        return try std.process.Child.run(.{
            .allocator = self.allocator,
            .argv = full_args.items,
            .max_output_bytes = 1024 * 1024,
        });
    }
    
    fn expectOutput(self: *Self, result: std.process.Child.RunResult, expected_output: []const u8, test_name: []const u8) !void {
        const output = OutputSelector.selectOutput(result);
        
        if (std.mem.containsAtLeast(u8, output, 1, expected_output)) {
            try self.results.append(TestResult{ .name = test_name, .passed = true, .duration_ms = 2.0 });
        } else {
            const error_msg = try std.fmt.allocPrint(self.allocator, "Expected output to contain '{s}' but got stdout: '{s}' stderr: '{s}'", .{ expected_output, result.stdout, result.stderr });
            try self.results.append(TestResult{ .name = test_name, .passed = false, .duration_ms = 2.0, .error_msg = error_msg });
        }
    }
    
    fn runTimedTest(self: *Self, test_name: []const u8, test_fn: fn(*Self) anyerror!void) void {
        const start_time = std.time.nanoTimestamp();
        
        test_fn(self) catch |err| {
            const end_time = std.time.nanoTimestamp();
            const duration_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000.0;
            const error_msg = std.fmt.allocPrint(self.allocator, "{}", .{err}) catch "OutOfMemory";
            self.results.append(TestResult{ .name = test_name, .passed = false, .duration_ms = duration_ms, .error_msg = error_msg }) catch {};
            return;
        };
        
        const end_time = std.time.nanoTimestamp();
        const duration_ms = @as(f64, @floatFromInt(end_time - start_time)) / 1_000_000.0;
        
        // Update the last result with actual duration
        if (self.results.items.len > 0) {
            self.results.items[self.results.items.len - 1].duration_ms = duration_ms;
        }
    }
    
    pub fn runAllTests(self: *Self) !void {
        self.runTimedTest("help_shows_description", testHelpShowsDescription);
        self.runTimedTest("help_h_shows_usage", testHelpHShowsUsage);
        self.runTimedTest("version_shows_version_string", testVersionShowsVersionString);
        self.runTimedTest("invalid_command_shows_error", testInvalidCommandShowsError);
        self.runTimedTest("no_arguments_shows_help", testNoArgumentsShowsHelp);
        self.runTimedTest("list_empty_shows_message", testListEmptyShowsMessage);
        self.runTimedTest("save_valid_context_succeeds", testSaveValidContextSucceeds);
        self.runTimedTest("save_with_slash_fails", testSaveWithSlashFails);
        self.runTimedTest("save_with_empty_name_fails", testSaveWithEmptyNameFails);
        self.runTimedTest("save_without_name_shows_error", testSaveWithoutNameShowsError);
        self.runTimedTest("save_with_long_name_fails", testSaveWithLongNameFails);
    }
    
    fn testHelpShowsDescription(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{"--help"});
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "Context Session Manager", "help shows description");
    }
    
    fn testHelpHShowsUsage(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{"-h"});
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "USAGE:", "help -h shows usage");
    }
    
    fn testVersionShowsVersionString(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{"version"});
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "ctx v", "version shows version string");
    }
    
    fn testInvalidCommandShowsError(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{"invalid"});
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "Unknown command", "invalid command shows error");
    }
    
    fn testNoArgumentsShowsHelp(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{});
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "USAGE:", "no arguments shows help");
    }
    
    fn testListEmptyShowsMessage(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{"list"});
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        // List shows existing contexts or empty message
        try self.expectOutput(result, "Saved contexts", "list empty shows message");
    }
    
    fn testSaveValidContextSucceeds(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{ "save", "test-context" });
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "saved", "save valid context succeeds");
    }
    
    fn testSaveWithSlashFails(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{ "save", "test/context" });
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "Invalid", "save with slash fails");
    }
    
    fn testSaveWithEmptyNameFails(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{ "save", "" });
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "Invalid", "save with empty name fails");
    }
    
    fn testSaveWithoutNameShowsError(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{"save"});
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "required", "save without name shows error");
    }
    
    fn testSaveWithLongNameFails(self: *Self) !void {
        const long_name = "a" ** (validation.MAX_CONTEXT_NAME_LENGTH + 1);
        const result = try self.runCommand(&[_][]const u8{ "save", long_name });
        defer {
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }
        try self.expectOutput(result, "Invalid", "save with long name fails");
    }
    
    pub fn printCSVResults(self: *Self) void {
        const stdout = std.io.getStdOut().writer();
        for (self.results.items) |result| {
            const status = if (result.passed) "PASS" else "FAIL";
            const error_msg = result.error_msg orelse "";
            stdout.print("blackbox,{s},{s},{d:.2},{s}\n", .{ result.name, status, result.duration_ms, error_msg }) catch {};
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <path-to-ctx-binary>" ++ eol, .{args[0]});
        std.debug.print("Example: {s} ./zig-out/bin/ctx" ++ eol, .{args[0]});
        return;
    }

    const ctx_binary = args[1];

    // Check if binary exists
    fs.cwd().access(ctx_binary, .{}) catch |err| {
        std.debug.print("❌ Cannot access ctx binary at: {s}" ++ eol, .{ctx_binary});
        std.debug.print("Error: {}" ++ eol, .{err});
        return;
    };

    var test_runner = try TestRunner.init(allocator, ctx_binary);
    defer test_runner.deinit();

    try test_runner.runAllTests();
    test_runner.printCSVResults();
}