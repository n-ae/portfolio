const std = @import("std");
const process = std.process;
const fs = std.fs;

const TestResult = struct {
    test_type: []const u8,
    test_name: []const u8,
    status: []const u8,
    duration_ms: f64,
    error_message: ?[]const u8,
};

const TestSummary = struct {
    total_tests: u32 = 0,
    passed_tests: u32 = 0,
    failed_tests: u32 = 0,
    total_duration_ms: f64 = 0.0,
    unit_tests: u32 = 0,
    blackbox_tests: u32 = 0,
};

fn parseCSVLine(allocator: std.mem.Allocator, line: []const u8) !?TestResult {
    if (line.len == 0 or std.mem.startsWith(u8, line, "test_type,")) {
        return null; // Skip empty lines and header
    }
    
    var fields = std.ArrayList([]const u8).init(allocator);
    defer fields.deinit();
    
    var in_quotes = false;
    var field_start: usize = 0;
    var i: usize = 0;
    
    while (i < line.len) {
        if (line[i] == '"') {
            in_quotes = !in_quotes;
        } else if (line[i] == ',' and !in_quotes) {
            const field = std.mem.trim(u8, line[field_start..i], " \"");
            try fields.append(try allocator.dupe(u8, field));
            field_start = i + 1;
        }
        i += 1;
    }
    
    // Add the last field
    const field = std.mem.trim(u8, line[field_start..], " \"");
    try fields.append(try allocator.dupe(u8, field));
    
    if (fields.items.len < 4) {
        return null; // Invalid CSV line
    }
    
    const duration = std.fmt.parseFloat(f64, fields.items[3]) catch 0.0;
    const error_message = if (fields.items.len > 4 and fields.items[4].len > 0)
        try allocator.dupe(u8, fields.items[4])
    else
        null;
    
    return TestResult{
        .test_type = try allocator.dupe(u8, fields.items[0]),
        .test_name = try allocator.dupe(u8, fields.items[1]),
        .status = try allocator.dupe(u8, fields.items[2]),
        .duration_ms = duration,
        .error_message = error_message,
    };
}

fn runCommand(allocator: std.mem.Allocator, argv: []const []const u8) ![]const u8 {
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
        .max_output_bytes = 1024 * 1024,
    });
    defer allocator.free(result.stderr);
    
    if (result.term.Exited != 0) {
        std.debug.print("Command failed with exit code {}: {s}\n", .{ result.term.Exited, result.stderr });
        return error.CommandFailed;
    }
    
    // Filter out lines that don't look like CSV
    var filtered_output = std.ArrayList(u8).init(allocator);
    defer filtered_output.deinit();
    
    var lines = std.mem.splitScalar(u8, result.stdout, '\n');
    var found_header = false;
    
    while (lines.next()) |line| {
        // Look for CSV header or CSV data lines
        if (std.mem.startsWith(u8, line, "test_type,") or 
            std.mem.startsWith(u8, line, "unit,") or 
            std.mem.startsWith(u8, line, "blackbox,")) {
            found_header = true;
            try filtered_output.appendSlice(line);
            try filtered_output.append('\n');
        } else if (found_header and line.len == 0) {
            // Keep empty lines after we've found CSV data
            try filtered_output.append('\n');
        }
    }
    
    return filtered_output.toOwnedSlice();
}

fn runTestSuite(allocator: std.mem.Allocator, binary_path: []const u8, args: []const []const u8) ![]TestResult {
    var full_args = std.ArrayList([]const u8).init(allocator);
    defer full_args.deinit();
    
    try full_args.append(binary_path);
    try full_args.appendSlice(args);
    
    const output = runCommand(allocator, full_args.items) catch |err| {
        std.debug.print("Failed to run test suite: {}\n", .{err});
        return &[_]TestResult{};
    };
    defer allocator.free(output);
    
    var results = std.ArrayList(TestResult).init(allocator);
    var lines = std.mem.splitScalar(u8, output, '\n');
    
    while (lines.next()) |line| {
        if (parseCSVLine(allocator, line)) |result| {
            if (result) |test_result| {
                try results.append(test_result);
            }
        } else |err| {
            if (err != error.OutOfMemory) {
                // Ignore parsing errors for malformed lines
                continue;
            }
            return err;
        }
    }
    
    return results.toOwnedSlice();
}

fn printCSVHeader() void {
    std.debug.print("test_type,test_name,status,duration_ms,error_message\n", .{});
}

fn printCSVResult(result: TestResult) void {
    if (result.error_message) |error_msg| {
        // Escape quotes in error message
        std.debug.print("{s},{s},{s},{d:.2},\"{s}\"\n", .{ result.test_type, result.test_name, result.status, result.duration_ms, error_msg });
    } else {
        std.debug.print("{s},{s},{s},{d:.2},\n", .{ result.test_type, result.test_name, result.status, result.duration_ms });
    }
}

fn calculateSummary(results: []const TestResult) TestSummary {
    var summary = TestSummary{};
    
    for (results) |result| {
        summary.total_tests += 1;
        summary.total_duration_ms += result.duration_ms;
        
        if (std.mem.eql(u8, result.status, "PASS")) {
            summary.passed_tests += 1;
        } else {
            summary.failed_tests += 1;
        }
        
        if (std.mem.eql(u8, result.test_type, "unit")) {
            summary.unit_tests += 1;
        } else if (std.mem.eql(u8, result.test_type, "blackbox")) {
            summary.blackbox_tests += 1;
        }
    }
    
    return summary;
}

fn printSummary(summary: TestSummary) void {
    std.debug.print("\n", .{});
    std.debug.print("# Test Summary\n", .{});
    std.debug.print("## Results\n", .{});
    std.debug.print("- Total Tests: {d}\n", .{summary.total_tests});
    std.debug.print("- Passed: {d}\n", .{summary.passed_tests});
    std.debug.print("- Failed: {d}\n", .{summary.failed_tests});
    std.debug.print("- Unit Tests: {d}\n", .{summary.unit_tests});
    std.debug.print("- Blackbox Tests: {d}\n", .{summary.blackbox_tests});
    std.debug.print("- Total Duration: {d:.2}ms\n", .{summary.total_duration_ms});
    
    const success_rate = if (summary.total_tests > 0) 
        (@as(f64, @floatFromInt(summary.passed_tests)) / @as(f64, @floatFromInt(summary.total_tests))) * 100.0
    else 
        0.0;
    std.debug.print("- Success Rate: {d:.1}%\n", .{success_rate});
    
    if (summary.failed_tests == 0) {
        std.debug.print("\n🎉 All tests passed!\n", .{});
    } else {
        std.debug.print("\n💥 {d} tests failed!\n", .{summary.failed_tests});
    }
}

fn writeCSVToFile(allocator: std.mem.Allocator, results: []const TestResult, filename: []const u8) !void {
    const file = try fs.cwd().createFile(filename, .{});
    defer file.close();
    
    const writer = file.writer();
    try writer.print("test_type,test_name,status,duration_ms,error_message\n", .{});
    
    for (results) |result| {
        if (result.error_message) |error_msg| {
            // Escape quotes in error message for CSV
            const escaped_error = try std.mem.replaceOwned(u8, allocator, error_msg, "\"", "\"\"");
            defer allocator.free(escaped_error);
            try writer.print("{s},{s},{s},{d:.2},\"{s}\"\n", .{ result.test_type, result.test_name, result.status, result.duration_ms, escaped_error });
        } else {
            try writer.print("{s},{s},{s},{d:.2},\n", .{ result.test_type, result.test_name, result.status, result.duration_ms });
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);
    
    // Show usage if explicitly requested
    if (args.len >= 2 and (std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h"))) {
        std.debug.print("Usage: {s} [--output-file <filename>] [--quiet]\n", .{args[0]});
        std.debug.print("       Runs both unit and blackbox tests and outputs combined CSV results\n", .{});
        std.debug.print("\nOptions:\n", .{});
        std.debug.print("  --output-file <filename>  Write CSV results to file instead of stdout\n", .{});
        std.debug.print("  --quiet                   Only output CSV, no summary\n", .{});
        return;
    }
    
    var output_file: ?[]const u8 = null;
    var quiet = false;
    var arg_index: usize = 1;
    
    // Parse command line arguments
    while (arg_index < args.len) {
        if (std.mem.eql(u8, args[arg_index], "--output-file") and arg_index + 1 < args.len) {
            output_file = args[arg_index + 1];
            arg_index += 2;
        } else if (std.mem.eql(u8, args[arg_index], "--quiet")) {
            quiet = true;
            arg_index += 1;
        } else {
            arg_index += 1;
        }
    }
    
    if (!quiet) {
        std.debug.print("🧪 Running combined test suite...\n", .{});
        std.debug.print("\n", .{});
    }
    
    var all_results = std.ArrayList(TestResult).init(allocator);
    defer {
        for (all_results.items) |result| {
            allocator.free(result.test_type);
            allocator.free(result.test_name);
            allocator.free(result.status);
            if (result.error_message) |msg| allocator.free(msg);
        }
        all_results.deinit();
    }
    
    // Run unit tests
    if (!quiet) {
        std.debug.print("📝 Running unit tests...\n", .{});
    }
    
    if (runTestSuite(allocator, "./zig-out/bin/ctx-unit-csv", &[_][]const u8{})) |unit_results| {
        defer allocator.free(unit_results);
        try all_results.appendSlice(unit_results);
    } else |err| {
        if (!quiet) {
            std.debug.print("⚠️  Unit tests failed to run: {}\n", .{err});
        }
    }
    
    // Run blackbox tests  
    if (!quiet) {
        std.debug.print("🎯 Running blackbox tests...\n", .{});
    }
    
    if (runTestSuite(allocator, "./zig-out/bin/ctx-test-csv", &[_][]const u8{"./zig-out/bin/ctx"})) |blackbox_results| {
        defer allocator.free(blackbox_results);
        try all_results.appendSlice(blackbox_results);
    } else |err| {
        if (!quiet) {
            std.debug.print("⚠️  Blackbox tests failed to run: {}\n", .{err});
        }
    }
    
    // Output results
    if (output_file) |filename| {
        try writeCSVToFile(allocator, all_results.items, filename);
        if (!quiet) {
            std.debug.print("📊 Results written to: {s}\n", .{filename});
        }
    } else {
        if (!quiet) {
            std.debug.print("📊 Combined CSV Results:\n", .{});
            std.debug.print("\n", .{});
        }
        printCSVHeader();
        for (all_results.items) |result| {
            printCSVResult(result);
        }
    }
    
    if (!quiet) {
        const summary = calculateSummary(all_results.items);
        printSummary(summary);
    }
    
    // Exit with error code if any tests failed
    const summary = calculateSummary(all_results.items);
    if (summary.failed_tests > 0) {
        process.exit(1);
    }
}