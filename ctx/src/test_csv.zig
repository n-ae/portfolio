const std = @import("std");
const process = std.process;
const testing = std.testing;
const fs = std.fs;

const validation = @import("validation.zig");
const config = @import("config.zig");
const test_utils = @import("test_utils.zig");
const eol = validation.eol;

// Use the unified test utilities
const TestResult = test_utils.TestResult;
const ExpectationType = test_utils.ExpectationType;
const TestExpectation = test_utils.TestExpectation;

const TestCase = struct {
    name: []const u8,
    args: []const []const u8,
    expectation: TestExpectation,
    setup_fn: ?*const fn (*TestRunner) anyerror!void = null,

    fn execute(self: TestCase, runner: *TestRunner) !void {
        const start_time = std.time.milliTimestamp();

        if (self.setup_fn) |setup| {
            try setup(runner);
        }

        const result = try runner.runCommand(self.args);
        const end_time = std.time.milliTimestamp();
        const duration = @as(f64, @floatFromInt(end_time - start_time));

        const error_msg = try self.expectation.validate(result, runner.allocator);
        defer if (error_msg) |msg| runner.allocator.free(msg);

        const status = if (error_msg == null) "PASS" else "FAIL";

        const test_result = TestResult.init("blackbox", self.name, status, duration, if (error_msg) |msg| try runner.allocator.dupe(u8, msg) else null);
        try runner.csv_reporter.addResult(test_result);

        runner.cleanupResult(result);
    }
};

const OutputSelector = struct {
    fn selectOutput(result: std.process.Child.RunResult) []const u8 {
        return if (result.stdout.len > 0) result.stdout else result.stderr;
    }

    fn hasValidExitCode(result: std.process.Child.RunResult) bool {
        return result.term.Exited == 0;
    }

    fn formatError(allocator: std.mem.Allocator, result: std.process.Child.RunResult, error_type: []const u8) ![]const u8 {
        return switch (error_type[0]) {
            's' => std.fmt.allocPrint(allocator, "Expected success but got exit code {d}. Stderr: {s}", .{ result.term.Exited, result.stderr }),
            'f' => std.fmt.allocPrint(allocator, "Expected failure but command succeeded. Stdout: {s}", .{result.stdout}),
            'c' => std.fmt.allocPrint(allocator, "Command failed with exit code {d}. Stderr: {s}", .{ result.term.Exited, result.stderr }),
            else => std.fmt.allocPrint(allocator, "Unexpected error type: {s}", .{error_type}),
        };
    }
};

const TestRunner = struct {
    allocator: std.mem.Allocator,
    ctx_binary: []const u8,
    test_dir: []const u8,
    original_home: ?[]const u8,
    csv_reporter: *test_utils.CSVReporter,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, ctx_binary: []const u8, csv_reporter: *test_utils.CSVReporter) !Self {
        const test_dir = try allocator.dupe(u8, config.Config.TEST_DIR_PREFIX);

        const original_home = if (std.posix.getenv("HOME")) |home|
            try allocator.dupe(u8, home)
        else
            null;

        return Self{
            .allocator = allocator,
            .ctx_binary = try allocator.dupe(u8, ctx_binary),
            .test_dir = test_dir,
            .original_home = original_home,
            .csv_reporter = csv_reporter,
        };
    }

    pub fn deinit(self: *Self) void {
        self.cleanupTestDir() catch {};
        self.allocator.free(self.ctx_binary);
        self.allocator.free(self.test_dir);
        if (self.original_home) |home| self.allocator.free(home);
    }

    fn setupTestEnv(self: *Self) !void {
        fs.cwd().makeDir(self.test_dir) catch |err| switch (err) {
            error.PathAlreadyExists => {},
            else => return err,
        };
    }

    fn cleanupTestDir(self: *Self) !void {
        fs.cwd().deleteTree(self.test_dir) catch {};
    }

    fn runCommand(self: *Self, args: []const []const u8) !std.process.Child.RunResult {
        var full_args = std.ArrayList([]const u8).init(self.allocator);
        defer full_args.deinit();

        try full_args.append(self.ctx_binary);
        try full_args.appendSlice(args);

        var env_map = std.process.EnvMap.init(self.allocator);
        defer env_map.deinit();
        try env_map.put("HOME", self.test_dir);

        return try std.process.Child.run(.{
            .allocator = self.allocator,
            .argv = full_args.items,
            .env_map = &env_map,
            .max_output_bytes = config.Config.MAX_OUTPUT_SIZE,
        });
    }

    fn cleanupResult(self: *Self, result: std.process.Child.RunResult) void {
        self.allocator.free(result.stdout);
        self.allocator.free(result.stderr);
    }

    fn getBasicTestCases(self: *Self) []const TestCase {
        _ = self;
        return &[_]TestCase{
            TestCase{ .name = "help_shows_description", .args = &[_][]const u8{"--help"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Context Session Manager" } },
            TestCase{ .name = "help_h_shows_usage", .args = &[_][]const u8{"-h"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "USAGE:" } },
            TestCase{ .name = "version_shows_version_string", .args = &[_][]const u8{"version"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "ctx v" } },
            TestCase{ .name = "invalid_command_shows_error", .args = &[_][]const u8{"invalid"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Unknown command: 'invalid'" } },
            TestCase{ .name = "no_arguments_shows_help", .args = &[_][]const u8{}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Context Session Manager" } },
            TestCase{ .name = "list_empty_shows_message", .args = &[_][]const u8{"list"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "(none yet" } },
            TestCase{ .name = "save_valid_context_succeeds", .args = &[_][]const u8{ "save", "test-context" }, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Context 'test-context' saved!" } },
            TestCase{ .name = "save_with_slash_fails", .args = &[_][]const u8{ "save", "invalid/name" }, .expectation = TestExpectation{ .expectation_type = .failure } },
            TestCase{ .name = "save_with_empty_name_fails", .args = &[_][]const u8{ "save", "" }, .expectation = TestExpectation{ .expectation_type = .failure } },
            TestCase{ .name = "save_without_name_shows_error", .args = &[_][]const u8{"save"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Context name required for save command" } },
        };
    }

    pub fn runAllTests(self: *Self) !void {
        // Clean up any existing test environment first
        self.cleanupTestDir() catch {};
        try self.setupTestEnv();
        defer self.cleanupTestDir() catch {};

        // Run basic test cases
        const basic_tests = self.getBasicTestCases();
        for (basic_tests) |test_case| {
            try test_case.execute(self);
        }

        // Simple additional tests
        const additional_tests = [_]TestCase{
            TestCase{ .name = "save_with_long_name_fails", .args = &[_][]const u8{ "save", "a" ** 300 }, .expectation = TestExpectation{ .expectation_type = .failure } },
        };

        for (additional_tests) |test_case| {
            try test_case.execute(self);
        }
    }

    pub fn printCSVResults(self: *Self) void {
        self.csv_reporter.printHeader();
        self.csv_reporter.printResults();
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
        return;
    }

    const ctx_binary = args[1];

    fs.cwd().access(ctx_binary, .{}) catch |err| {
        std.debug.print("❌ Cannot access ctx binary at: {s}" ++ eol, .{ctx_binary});
        std.debug.print("Error: {}" ++ eol, .{err});
        return;
    };

    var csv_reporter = test_utils.CSVReporter.init(allocator);
    defer csv_reporter.deinit();

    var test_runner = try TestRunner.init(allocator, ctx_binary, &csv_reporter);
    defer test_runner.deinit();

    try test_runner.runAllTests();
    test_runner.printCSVResults();
}
