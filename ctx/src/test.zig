const std = @import("std");
const process = std.process;
const testing = std.testing;
const fs = std.fs;

const validation = @import("validation.zig");
const eol = validation.eol;

const TestResult = struct {
    name: []const u8,
    passed: bool,
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

    fn validate(self: TestExpectation, result: std.process.Child.RunResult, allocator: std.mem.Allocator) !?[]const u8 {
        return switch (self.expectation_type) {
            .success => {
                if (!OutputSelector.hasValidExitCode(result)) {
                    return try OutputSelector.formatError(allocator, result, "success");
                }
                return null;
            },
            .failure => {
                if (OutputSelector.hasValidExitCode(result)) {
                    return try OutputSelector.formatError(allocator, result, "failure");
                }
                return null;
            },
            .output => {
                if (!OutputSelector.hasValidExitCode(result)) {
                    return try OutputSelector.formatError(allocator, result, "command");
                }
                const output = OutputSelector.selectOutput(result);
                if (self.expected_output) |expected| {
                    if (!std.mem.containsAtLeast(u8, output, 1, expected)) {
                        return try std.fmt.allocPrint(allocator, "Expected output to contain '{s}' but got stdout: '{s}' stderr: '{s}'", .{ expected, result.stdout, result.stderr });
                    }
                }
                return null;
            },
        };
    }
};

const TestCase = struct {
    name: []const u8,
    args: []const []const u8,
    expectation: TestExpectation,
    setup_fn: ?*const fn (*TestRunner) anyerror!void = null,

    fn execute(self: TestCase, runner: *TestRunner) !void {
        if (self.setup_fn) |setup| {
            try setup(runner);
        }
        const result = try runner.runCommand(self.args);
        try runner.expectResult(result, self.expectation, self.name);
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
    results: std.ArrayList(TestResult),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, ctx_binary: []const u8) !Self {
        // Create temporary test directory
        const test_dir = try allocator.dupe(u8, "/tmp/ctx_test");

        // Store original HOME
        const original_home = if (std.posix.getenv("HOME")) |home|
            try allocator.dupe(u8, home)
        else
            null;

        return Self{
            .allocator = allocator,
            .ctx_binary = try allocator.dupe(u8, ctx_binary),
            .test_dir = test_dir,
            .original_home = original_home,
            .results = std.ArrayList(TestResult).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        // Cleanup test directory
        self.cleanupTestDir() catch {};

        self.allocator.free(self.ctx_binary);
        self.allocator.free(self.test_dir);
        if (self.original_home) |home| self.allocator.free(home);

        for (self.results.items) |result| {
            if (result.error_msg) |msg| self.allocator.free(msg);
        }
        self.results.deinit();
    }

    fn setupTestEnv(self: *Self) !void {
        // Create test directory
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

        // Create environment with test HOME
        var env_map = std.process.EnvMap.init(self.allocator);
        defer env_map.deinit();
        try env_map.put("HOME", self.test_dir);

        return try std.process.Child.run(.{
            .allocator = self.allocator,
            .argv = full_args.items,
            .env_map = &env_map,
            .max_output_bytes = 1024 * 1024,
        });
    }

    fn cleanupResult(self: *Self, result: std.process.Child.RunResult) void {
        self.allocator.free(result.stdout);
        self.allocator.free(result.stderr);
    }

    fn recordTestResult(self: *Self, test_name: []const u8, passed: bool, error_msg: ?[]const u8) !void {
        try self.results.append(TestResult{ .name = test_name, .passed = passed, .error_msg = error_msg });
    }

    fn expectResult(self: *Self, result: std.process.Child.RunResult, expectation: TestExpectation, test_name: []const u8) !void {
        defer self.cleanupResult(result);

        const error_msg = try expectation.validate(result, self.allocator);
        const passed = error_msg == null;
        try self.recordTestResult(test_name, passed, error_msg);
    }

    fn expectSuccess(self: *Self, result: std.process.Child.RunResult, test_name: []const u8) !void {
        try self.expectResult(result, TestExpectation{ .expectation_type = .success }, test_name);
    }

    fn expectFailure(self: *Self, result: std.process.Child.RunResult, test_name: []const u8) !void {
        try self.expectResult(result, TestExpectation{ .expectation_type = .failure }, test_name);
    }

    fn expectOutput(self: *Self, result: std.process.Child.RunResult, expected: []const u8, test_name: []const u8) !void {
        try self.expectResult(result, TestExpectation{ .expectation_type = .output, .expected_output = expected }, test_name);
    }

    fn getBasicTestCases(self: *Self) []const TestCase {
        _ = self;
        return &[_]TestCase{
            TestCase{ .name = "help shows description", .args = &[_][]const u8{"--help"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Context Session Manager" } },
            TestCase{ .name = "help -h shows usage", .args = &[_][]const u8{"-h"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "USAGE:" } },
            TestCase{ .name = "version shows version string", .args = &[_][]const u8{"version"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "ctx v" } },
            TestCase{ .name = "invalid command shows error", .args = &[_][]const u8{"invalid"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Unknown command: 'invalid'" } },
            TestCase{ .name = "no arguments shows help", .args = &[_][]const u8{}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Context Session Manager" } },
            TestCase{ .name = "save valid context succeeds", .args = &[_][]const u8{ "save", "test-context" }, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Context 'test-context' saved!" } },
            TestCase{ .name = "save with slash fails", .args = &[_][]const u8{ "save", "invalid/name" }, .expectation = TestExpectation{ .expectation_type = .failure } },
            TestCase{ .name = "save with empty name fails", .args = &[_][]const u8{ "save", "" }, .expectation = TestExpectation{ .expectation_type = .failure } },
            TestCase{ .name = "save without name shows error", .args = &[_][]const u8{"save"}, .expectation = TestExpectation{ .expectation_type = .output, .expected_output = "Context name required for save command" } },
        };
    }

    // Test Cases
    pub fn runAllTests(self: *Self) !void {
        try self.setupTestEnv();
        defer self.cleanupTestDir() catch {};

        std.debug.print("🧪 Running blackbox tests for ctx..." ++ eol, .{});
        std.debug.print("Test binary: {s}" ++ eol, .{self.ctx_binary});
        std.debug.print("Test environment: {s}" ++ eol, .{self.test_dir});
        std.debug.print("" ++ eol, .{});

        // Run basic test cases
        const basic_tests = self.getBasicTestCases();
        for (basic_tests) |test_case| {
            try test_case.execute(self);
        }

        // Advanced tests with custom logic
        try self.testSaveInvalidNames();
        try self.testListEmpty();
        try self.testListWithContexts();
        try self.testRestoreValidContext();
        try self.testRestoreNonexistent();
        try self.testRestoreMissingName();
        try self.testDeleteValidContext();
        try self.testDeleteNonexistent();
        try self.testDeleteMissingName();
        try self.testFullWorkflow();
        try self.testMultipleContexts();
    }

    fn testSaveInvalidNames(self: *Self) !void {
        const result1 = try self.runCommand(&[_][]const u8{ "save", "invalid/name" });
        try self.expectFailure(result1, "save with slash fails");

        const result2 = try self.runCommand(&[_][]const u8{ "save", "" });
        try self.expectFailure(result2, "save with empty name fails");

        // Test very long name
        const long_name = "a" ** 300; // Exceeds MAX_CONTEXT_NAME_LENGTH
        const result3 = try self.runCommand(&[_][]const u8{ "save", long_name });
        try self.expectFailure(result3, "save with long name fails");
    }

    fn testListEmpty(self: *Self) !void {
        // Clean slate
        try self.cleanupTestDir();
        try self.setupTestEnv();

        const result = try self.runCommand(&[_][]const u8{"list"});
        try self.expectOutput(result, "(none yet", "list empty shows message");
    }

    fn testListWithContexts(self: *Self) !void {
        // First save a context
        const save_result = try self.runCommand(&[_][]const u8{ "save", "list-test" });
        self.allocator.free(save_result.stdout);
        self.allocator.free(save_result.stderr);

        const result = try self.runCommand(&[_][]const u8{"list"});
        try self.expectOutput(result, "list-test", "list shows saved context");
    }

    fn testRestoreValidContext(self: *Self) !void {
        // First save a context
        const save_result = try self.runCommand(&[_][]const u8{ "save", "restore-test" });
        self.allocator.free(save_result.stdout);
        self.allocator.free(save_result.stderr);

        const result = try self.runCommand(&[_][]const u8{ "restore", "restore-test" });
        try self.expectOutput(result, "Context 'restore-test' restored!", "restore valid context succeeds");
    }

    fn testRestoreNonexistent(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{ "restore", "nonexistent" });
        try self.expectOutput(result, "Context 'nonexistent' not found", "restore nonexistent shows error");
    }

    fn testRestoreMissingName(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{"restore"});
        try self.expectOutput(result, "Context name required for restore command", "restore without name shows error");
    }

    fn testDeleteValidContext(self: *Self) !void {
        // First save a context
        const save_result = try self.runCommand(&[_][]const u8{ "save", "delete-test" });
        self.allocator.free(save_result.stdout);
        self.allocator.free(save_result.stderr);

        const result = try self.runCommand(&[_][]const u8{ "delete", "delete-test" });
        try self.expectOutput(result, "Context 'delete-test' deleted", "delete valid context succeeds");
    }

    fn testDeleteNonexistent(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{ "delete", "nonexistent" });
        try self.expectOutput(result, "Context 'nonexistent' not found", "delete nonexistent shows error");
    }

    fn testDeleteMissingName(self: *Self) !void {
        const result = try self.runCommand(&[_][]const u8{"delete"});
        try self.expectOutput(result, "Context name required for delete command", "delete without name shows error");
    }

    fn testFullWorkflow(self: *Self) !void {
        // Clean slate
        try self.cleanupTestDir();
        try self.setupTestEnv();

        // Save -> List -> Restore -> Delete -> List
        const save_result = try self.runCommand(&[_][]const u8{ "save", "workflow-test" });
        try self.expectOutput(save_result, "Context 'workflow-test' saved!", "workflow: save succeeds");

        const list_result1 = try self.runCommand(&[_][]const u8{"list"});
        try self.expectOutput(list_result1, "workflow-test", "workflow: list shows context");

        const restore_result = try self.runCommand(&[_][]const u8{ "restore", "workflow-test" });
        try self.expectOutput(restore_result, "Context 'workflow-test' restored!", "workflow: restore succeeds");

        const delete_result = try self.runCommand(&[_][]const u8{ "delete", "workflow-test" });
        try self.expectOutput(delete_result, "Context 'workflow-test' deleted", "workflow: delete succeeds");

        const list_result2 = try self.runCommand(&[_][]const u8{"list"});
        try self.expectOutput(list_result2, "(none yet", "workflow: list empty after delete");
    }

    fn testMultipleContexts(self: *Self) !void {
        // Clean slate
        try self.cleanupTestDir();
        try self.setupTestEnv();

        // Save multiple contexts
        const contexts = [_][]const u8{ "ctx1", "ctx2", "ctx3" };

        for (contexts) |ctx_name| {
            const result = try self.runCommand(&[_][]const u8{ "save", ctx_name });
            self.allocator.free(result.stdout);
            self.allocator.free(result.stderr);
        }

        // List should show all
        const list_result = try self.runCommand(&[_][]const u8{"list"});
        defer {
            self.allocator.free(list_result.stdout);
            self.allocator.free(list_result.stderr);
        }

        const output = OutputSelector.selectOutput(list_result);
        var all_found = true;
        for (contexts) |ctx_name| {
            if (!std.mem.containsAtLeast(u8, output, 1, ctx_name)) {
                all_found = false;
                break;
            }
        }

        if (all_found) {
            try self.results.append(TestResult{ .name = "multiple contexts: all visible in list", .passed = true });
        } else {
            const error_msg = try std.fmt.allocPrint(self.allocator, "Not all contexts found in list output stdout: '{s}' stderr: '{s}'", .{ list_result.stdout, list_result.stderr });
            try self.results.append(TestResult{ .name = "multiple contexts: all visible in list", .passed = false, .error_msg = error_msg });
        }
    }

    pub fn printResults(self: *Self) void {
        var passed: u32 = 0;
        var failed: u32 = 0;

        std.debug.print("" ++ eol, .{});
        std.debug.print("📊 Test Results:" ++ eol, .{});
        std.debug.print("═══════════════" ++ eol, .{});

        for (self.results.items) |result| {
            if (result.passed) {
                std.debug.print("✅ {s}" ++ eol, .{result.name});
                passed += 1;
            } else {
                std.debug.print("❌ {s}" ++ eol, .{result.name});
                if (result.error_msg) |msg| {
                    std.debug.print("   {s}" ++ eol, .{msg});
                }
                failed += 1;
            }
        }

        std.debug.print("" ++ eol, .{});
        std.debug.print("📈 Summary: {d} passed, {d} failed, {d} total" ++ eol, .{ passed, failed, passed + failed });

        if (failed == 0) {
            std.debug.print("🎉 All tests passed!" ++ eol, .{});
        } else {
            std.debug.print("💥 {d} tests failed!" ++ eol, .{failed});
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
    test_runner.printResults();
}
