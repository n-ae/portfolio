const std = @import("std");

const context = @import("context.zig");
const shell = @import("shell.zig");
const storage = @import("storage.zig");
pub const OutputFormat = enum { standard, csv };

const BenchmarkResult = struct {
    name: []const u8,
    duration_ns: u64,
    iterations: u32,
};
const validation = @import("validation.zig");

// Import modules to benchmark
/// Performance benchmark runner with configurable iterations
pub const BenchmarkRunner = struct {
    allocator: std.mem.Allocator,
    iterations: u32,
    warmup_iterations: u32,

    pub fn init(allocator: std.mem.Allocator) BenchmarkRunner {
        return BenchmarkRunner{
            .allocator = allocator,
            .iterations = 1000,
            .warmup_iterations = 100,
        };
    }

    pub fn setIterations(self: *BenchmarkRunner, iterations: u32) void {
        self.iterations = iterations;
    }

    pub fn setWarmupIterations(self: *BenchmarkRunner, warmup: u32) void {
        self.warmup_iterations = warmup;
    }

    /// Run a benchmark function multiple times and return average duration
    pub fn benchmark(self: *BenchmarkRunner, comptime name: []const u8, benchmark_func: fn () void) BenchmarkResult {
        // Warmup runs
        var i: u32 = 0;
        while (i < self.warmup_iterations) : (i += 1) {
            benchmark_func();
        }

        // Actual benchmark runs
        var timer = std.time.Timer.start() catch unreachable;

        i = 0;
        while (i < self.iterations) : (i += 1) {
            benchmark_func();
        }

        const total_duration_ns = timer.read();
        const avg_duration_ns = total_duration_ns / self.iterations;

        return BenchmarkResult{
            .name = name,
            .duration_ns = avg_duration_ns,
            .iterations = self.iterations,
        };
    }
};

// String operation benchmarks
fn benchmarkStringConcatenation() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const str1 = "Hello";
    const str2 = "World";
    const result = std.fmt.allocPrint(allocator, "{s} {s}", .{ str1, str2 }) catch return;
    defer allocator.free(result);
}

fn benchmarkStringAllocation() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const str = allocator.dupe(u8, "Test string for allocation benchmark") catch return;
    defer allocator.free(str);
}

fn benchmarkStringComparison() void {
    const str1 = "test-context-name";
    const str2 = "test-context-name";
    _ = std.mem.eql(u8, str1, str2);
}

// Context operation benchmarks
fn benchmarkContextNameValidation() void {
    _ = validation.validateContextName("test-context-name") catch {};
}

fn benchmarkShellDetection() void {
    _ = shell.detectShell();
}

fn benchmarkEnvironmentVarParsing() void {
    const test_env_var = validation.EnvVar{ .key = "TEST_VAR", .value = "test_value" };
    _ = validation.isEnvVarValid(test_env_var);
}

// File I/O benchmarks (using temporary files)
fn benchmarkFileWrite() void {
    const test_data = "Test data for file write benchmark";

    const tmp_file = std.fs.cwd().createFile("bench_temp.txt", .{}) catch return;
    defer {
        tmp_file.close();
        std.fs.cwd().deleteFile("bench_temp.txt") catch {};
    }

    _ = tmp_file.writeAll(test_data) catch {};
}

fn benchmarkFileRead() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create a temporary file first
    const tmp_file = std.fs.cwd().createFile("bench_temp_read.txt", .{}) catch return;
    defer std.fs.cwd().deleteFile("bench_temp_read.txt") catch {};

    const test_data = "Test data for file read benchmark";
    _ = tmp_file.writeAll(test_data) catch return;
    tmp_file.close();

    // Now benchmark reading
    const read_file = std.fs.cwd().openFile("bench_temp_read.txt", .{}) catch return;
    defer read_file.close();

    const content = read_file.readToEndAlloc(allocator, 1024) catch return;
    defer allocator.free(content);
}

/// Run all performance benchmarks
pub fn runPerformanceBenchmarks(allocator: std.mem.Allocator, output_format: OutputFormat, output_file: ?[]const u8) !void {
    var benchmark_runner = BenchmarkRunner.init(allocator);
    benchmark_runner.setIterations(1000);
    benchmark_runner.setWarmupIterations(100);

    var results = std.ArrayList(BenchmarkResult).init(allocator);
    defer results.deinit();

    // String operation benchmarks
    try results.append(benchmark_runner.benchmark("string_concatenation", benchmarkStringConcatenation));
    try results.append(benchmark_runner.benchmark("string_allocation", benchmarkStringAllocation));
    try results.append(benchmark_runner.benchmark("string_comparison", benchmarkStringComparison));

    // Context operation benchmarks
    try results.append(benchmark_runner.benchmark("context_name_validation", benchmarkContextNameValidation));
    try results.append(benchmark_runner.benchmark("shell_detection", benchmarkShellDetection));
    try results.append(benchmark_runner.benchmark("env_var_parsing", benchmarkEnvironmentVarParsing));

    // File I/O benchmarks
    try results.append(benchmark_runner.benchmark("file_write", benchmarkFileWrite));
    try results.append(benchmark_runner.benchmark("file_read", benchmarkFileRead));

    // Output results
    try outputResults(results.items, output_format, output_file);
}

/// Simple output function for benchmark results
fn outputResults(results: []const BenchmarkResult, format: OutputFormat, output_file: ?[]const u8) !void {
    const writer = if (output_file) |file_path| blk: {
        const file = try std.fs.cwd().createFile(file_path, .{});
        break :blk file.writer();
    } else std.io.getStdOut().writer();

    switch (format) {
        .csv => {
            try writer.print("test_name,duration_ns,iterations\n", .{});
            for (results) |result| {
                try writer.print("{s},{d},{d}\n", .{ result.name, result.duration_ns, result.iterations });
            }
        },
        .standard => {
            try writer.print("Performance Benchmark Results:\n", .{});
            try writer.print("============================\n", .{});
            for (results) |result| {
                try writer.print("{s}: {d}ns avg ({d} iterations)\n", .{ result.name, result.duration_ns, result.iterations });
            }
        },
    }
}

/// Main function for running performance tests as standalone executable
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var output_format = OutputFormat.standard;
    var output_file: ?[]const u8 = null;

    // Parse command line arguments
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        if (std.mem.eql(u8, args[i], "--csv")) {
            output_format = .csv;
        // Removed json support for simplicity
        } else if (std.mem.eql(u8, args[i], "--output") and i + 1 < args.len) {
            i += 1;
            output_file = args[i];
        } else if (std.mem.eql(u8, args[i], "--help")) {
            std.debug.print(
                \\Usage: ctx-performance [OPTIONS]
                \\
                \\Options:
                \\  --csv           Output results in CSV format
                \\  --json          Output results in JSON format
                \\  --output FILE   Write results to file instead of stdout
                \\  --help          Show this help message
                \\
                \\Examples:
                \\  ctx-performance                    # Standard output
                \\  ctx-performance --csv              # CSV output to stdout
                \\  ctx-performance --csv --output results.csv  # CSV output to file
                \\
            , .{});
            return;
        }
    }

    try runPerformanceBenchmarks(allocator, output_format, output_file);
}

