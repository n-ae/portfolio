//! FIXML - High-Performance XML Processor (Zig Implementation)
//!
//! Modular architecture following Martin Fowler's refactoring principles:
//! - Extract Module: Separated concerns into focused domain modules
//! - Single Responsibility: Each module handles one core responsibility
//! - Command Pattern: Pluggable hash computation strategies
//! - Domain-Driven Design: Business logic encapsulated in domain objects
//!
//! Performance Characteristics:
//! - Time Complexity: O(n) where n = input file size
//! - Space Complexity: O(n + d) where d = unique elements
//! - Architecture: Modular with zero-overhead abstractions

const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const HashMap = std.AutoHashMap;

// Import domain modules - Extract Module refactoring
const xml_domain = @import("xml_domain.zig");
const character_domain = @import("character_domain.zig");
const performance_config = @import("performance_config.zig");
const hash_command = @import("hash_command.zig");
const processing = @import("processing.zig");

// Advanced pattern modules - Martin Fowler refactoring patterns
const xml_service = @import("xml_service.zig");
const processing_strategy = @import("processing_strategy.zig");
const xml_specification = @import("xml_specification.zig");

// Domain aliases for cleaner code
const XmlDomain = xml_domain.XmlDomain;
const CharacterDomain = character_domain.CharacterDomain;
const PerformanceDomain = performance_config.PerformanceDomain;
const ProcessingConfig = performance_config.ProcessingConfig;
const HashCommand = hash_command.HashCommand;
const ProcessingContext = processing.ProcessingContext;
const ProcessResult = processing.ProcessResult;

// Advanced pattern aliases
const XmlProcessingService = xml_service.XmlProcessingService;
const AdvancedProcessingStrategy = processing_strategy.ProcessingStrategy;
const StrategyFactory = processing_strategy.StrategyFactory;
const XmlSpecification = xml_specification.XmlSpecification;
const XmlSpecifications = xml_specification.XmlSpecifications;
const SpecificationValidator = xml_specification.SpecificationValidator;

// Application constants
const USAGE = "Usage: fixml [--replace] [--fix-warnings] <xml-file>\n" ++
    "  --replace, -r       Replace original file\n" ++
    "  --fix-warnings, -f  Fix XML warnings\n" ++
    "  Default: preserve original structure, fix indentation/deduplication only\n";

// Legacy constants for compatibility
const XML_DECLARATION_CHECK_LIMIT = 200;
const FILE_PERMISSIONS = 0o644;

// =============================================================================
// ARGUMENT PARSING
// =============================================================================

/// Command-line argument configuration
const Args = struct {
    replace: bool = false,
    fix_warnings: bool = false,
    file: []const u8 = "",
};

/// Parse and validate command-line arguments
fn parseArgs(allocator: Allocator) !Args {
    const args_slice = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args_slice);

    var parsed = Args{};
    var file_set = false;

    for (args_slice[1..]) |arg| {
        if (std.mem.eql(u8, arg, "--replace") or std.mem.eql(u8, arg, "-r")) {
            parsed.replace = true;
        } else if (std.mem.eql(u8, arg, "--fix-warnings") or std.mem.eql(u8, arg, "-f")) {
            parsed.fix_warnings = true;
        } else if (!std.mem.startsWith(u8, arg, "-") and !file_set) {
            parsed.file = try allocator.dupe(u8, arg);
            file_set = true;
        }
    }

    if (!file_set) {
        print("{s}", .{USAGE});
        std.process.exit(1);
    }

    return parsed;
}

// =============================================================================
// PROCESSING MODES AND STRATEGY (Legacy compatibility)
// =============================================================================

/// Legacy processing modes for backward compatibility
const ProcessingMode = enum {
    default,
    fix_warnings,
};

// =============================================================================
// MAIN PROCESSING FUNCTION
// =============================================================================

/// Advanced XML processing using Service Layer pattern
fn processXmlWithAdvancedService(allocator: Allocator, content: []const u8, fix_warnings: bool) !XmlProcessingService.XmlProcessingResult {
    // Guard Clause for empty content
    if (content.len == 0) {
        return XmlProcessingService.XmlProcessingResult{
            .content = try allocator.dupe(u8, content),
            .statistics = std.mem.zeroes(XmlProcessingService.XmlProcessingResult.ProcessingStatistics),
            .warnings = &[_]XmlProcessingService.XmlProcessingResult.ProcessingWarning{},
        };
    }
    
    // Create advanced processing strategy
    const strategy = StrategyFactory.createStrategyFromBool(fix_warnings);
    
    // Initialize advanced XML processing service
    var service = XmlProcessingService.init(allocator, strategy, content.len);
    
    // Process using advanced service layer
    return try service.processXmlDocument(content);
}

/// Legacy processing function for backward compatibility
fn processXmlWithDeduplication(allocator: Allocator, content: []const u8, _: bool, fix_warnings: bool) !ProcessResult {
    // Use advanced service and convert result to legacy format
    var advanced_result = try processXmlWithAdvancedService(allocator, content, fix_warnings);
    defer advanced_result.deinit(allocator);
    
    return ProcessResult{ 
        .content = try allocator.dupe(u8, advanced_result.content), 
        .duplicates = advanced_result.statistics.duplicates_removed 
    };
}

// =============================================================================
// FILE OPERATIONS
// =============================================================================

/// Handle XML declaration warnings
inline fn handleXmlDeclarationWarnings(has_xml_decl: bool, fix_warnings: bool) void {
    if (!has_xml_decl) {
        print("⚠️  XML Best Practice Warnings:\n", .{});
        print("  [XML] Missing XML declaration\n", .{});
        print("    Fix: Add <?xml version=\"1.0\" encoding=\"utf-8\"?> at the top\n", .{});
        print("\n", .{});

        if (!fix_warnings) {
            print("Use --fix-warnings flag to automatically apply fixes\n", .{});
            print("\n", .{});
        }
    }
}

/// Build final output content using advanced strategy pattern
inline fn buildFinalContentAdvanced(allocator: Allocator, process_result: ProcessResult, strategy: AdvancedProcessingStrategy, has_xml_decl: bool) !ArrayList(u8) {
    var final_content = ArrayList(u8){};
    const should_add_declaration = strategy.shouldAddXmlDeclaration(has_xml_decl);
    const final_capacity = process_result.content.len + if (should_add_declaration) XmlDomain.DECLARATION.len else 0;
    try final_content.ensureTotalCapacity(allocator, final_capacity);

    if (should_add_declaration) {
        try final_content.appendSlice(allocator, XmlDomain.DECLARATION);
        print("🔧 Applied fixes ({s}):\n", .{strategy.getModeName()});
        print("  ✓ Added XML declaration\n", .{});
        print("\n", .{});
    }

    try final_content.appendSlice(allocator, process_result.content);
    return final_content;
}

/// Write output file with error handling
inline fn writeOutputFile(final_content: []const u8, output_filename: []const u8) !void {
    std.fs.cwd().writeFile(.{
        .sub_path = output_filename,
        .data = final_content,
    }) catch |err| {
        print("Could not write output file '{s}': {s}\n", .{ output_filename, @errorName(err) });
        std.process.exit(1);
    };
}

/// Handle file replacement logic
inline fn handleFileReplacement(output_filename: []const u8, original_file: []const u8, replace_mode: bool) void {
    if (replace_mode) {
        std.fs.cwd().rename(output_filename, original_file) catch |err| {
            _ = std.fs.cwd().deleteFile(output_filename) catch {};
            print("Could not replace original file: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        };
        print("Original file replaced: {s}", .{original_file});
    } else {
        print("Organized project saved to: {s}", .{output_filename});
    }
}

/// Generate appropriate output filename based on mode
fn getOutputFilename(allocator: Allocator, input_file: []const u8, replace_mode: bool) ![]u8 {
    if (replace_mode) {
        const timestamp = @as(u64, @intCast(std.time.timestamp()));
        return try std.fmt.allocPrint(allocator, "{s}.tmp.{d}", .{ input_file, timestamp });
    } else {
        if (std.mem.lastIndexOfScalar(u8, input_file, '.')) |dot_pos| {
            const name = input_file[0..dot_pos];
            const ext = input_file[dot_pos + 1 ..];
            return try std.fmt.allocPrint(allocator, "{s}.organized.{s}", .{ name, ext });
        } else {
            return try std.fmt.allocPrint(allocator, "{s}.organized", .{input_file});
        }
    }
}

/// Simplified processFile function that uses only working legacy logic
fn processFile(allocator: Allocator, args: Args) !void {
    // Create advanced processing strategy (for declarations only)
    const strategy = if (args.fix_warnings) AdvancedProcessingStrategy.createFixWarnings() else AdvancedProcessingStrategy.createDefault();

    // Read file with size limit
    const config = ProcessingConfig.create(0);
    const max_file_size = config.max_file_size;
    const content = std.fs.cwd().readFileAlloc(allocator, args.file, max_file_size) catch |err| {
        print("Could not read file '{s}': {s}\n", .{ args.file, @errorName(err) });
        std.process.exit(1);
    };
    defer allocator.free(content);

    // Remove BOM and detect XML declaration using domain functions
    const cleaned_content = XmlDomain.removeBomIfPresent(content);
    const has_xml_decl = XmlDomain.hasXmlDeclaration(cleaned_content, XML_DECLARATION_CHECK_LIMIT);

    // Handle warnings
    handleXmlDeclarationWarnings(has_xml_decl, args.fix_warnings);

    // Process content with legacy processing (proven to work)
    const should_strip_xml_declaration = false;
    const process_result = try processXmlWithDeduplication(allocator, cleaned_content, should_strip_xml_declaration, args.fix_warnings);
    defer allocator.free(process_result.content);

    // Build final content using strategy (simplified)
    var final_content = ArrayList(u8){};
    defer final_content.deinit(allocator);
    
    const should_add_declaration = strategy.shouldAddXmlDeclaration(has_xml_decl);
    const final_capacity = process_result.content.len + if (should_add_declaration) XmlDomain.DECLARATION.len else 0;
    try final_content.ensureTotalCapacity(allocator, final_capacity);

    if (should_add_declaration) {
        try final_content.appendSlice(allocator, XmlDomain.DECLARATION);
        print("🔧 Applied fixes ({s} strategy):\n", .{strategy.getModeName()});
        print("  ✓ Added XML declaration\n", .{});
        print("\n", .{});
    }

    try final_content.appendSlice(allocator, process_result.content);

    // Get output filename and write file
    const output_filename = try getOutputFilename(allocator, args.file, args.replace);
    defer allocator.free(output_filename);

    try writeOutputFile(final_content.items, output_filename);

    // Handle file replacement and status messages
    handleFileReplacement(output_filename, args.file, args.replace);

    if (process_result.duplicates > 0) {
        print(" (removed {d} duplicates)", .{process_result.duplicates});
    }
    print(" (using legacy architecture)\n", .{});
}
// =============================================================================
// MAIN ENTRY POINT
// =============================================================================

/// Application entry point with modular architecture
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try parseArgs(allocator);
    try processFile(allocator, args);
}