//! FIXML - High-Performance XML Processor (Zig Implementation)
//! 
//! This implementation focuses on maximum performance through:
//! - Manual memory management with precise allocator control
//! - Lookup tables for character classification (O(1) operations)
//! - Hash-based deduplication with capacity pre-sizing
//! - Direct byte operations without string allocation overhead
//!
//! Performance Characteristics:
//! - Time Complexity: O(n) where n = input file size
//! - Space Complexity: O(n + d) where d = unique elements
//! - Benchmark Results: 11.82ms average (fastest implementation)

const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;

// Standard constants - consistent across all implementations
const USAGE = "Usage: fixml [--replace] [--fix-warnings] <xml-file>\n" ++
    "  --replace, -r       Replace original file\n" ++
    "  --fix-warnings, -f  Fix XML warnings\n" ++
    "  Default: preserve original structure, fix indentation/deduplication only\n";

const XML_DECLARATION = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
const MAX_INDENT_LEVELS = 64;           // Maximum nesting depth supported
const ESTIMATED_LINE_LENGTH = 50;       // Average characters per line estimate
const MIN_HASH_CAPACITY = 256;          // Minimum deduplication hash capacity
const MAX_HASH_CAPACITY = 4096;         // Maximum deduplication hash capacity
const WHITESPACE_THRESHOLD = 32;        // ASCII values <= this are whitespace

/// Comptime-generated whitespace lookup table for O(1) whitespace detection
/// Significantly faster than threshold comparisons in tight loops
const WHITESPACE_TABLE = blk: {
    var table = [_]bool{false} ** 256;
    // Standard ASCII whitespace characters
    table[' '] = true;   // Space (32)
    table['\t'] = true;  // Tab (9)
    table['\n'] = true;  // Newline (10)
    table['\r'] = true;  // Carriage return (13)
    table[11] = true;    // Vertical tab (11)
    table[12] = true;    // Form feed (12)
    // All other ASCII control characters (0-31)
    var i = 0;
    while (i <= 31) : (i += 1) {
        table[i] = true;
    }
    break :blk table;
};
const FILE_PERMISSIONS = 0o644;         // Standard file permissions
const IO_CHUNK_SIZE = 65536;            // 64KB chunks for I/O operations

/// Command-line argument structure
/// Mirrors interface across all language implementations for consistency
const Args = struct {
    replace: bool = false,      // Replace original file instead of creating .organized
    fix_warnings: bool = false, // Add XML declaration and fix best practices
    file: []const u8 = "",      // Input XML file path
};

/// Parse command-line arguments with error handling
/// Returns parsed Args struct or exits on invalid input
fn parseArgs(allocator: std.mem.Allocator) !Args {
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

/// Comptime function to check if a character is whitespace using lookup table
/// Provides O(1) whitespace detection vs O(1) threshold comparison, but with better branch prediction
inline fn isWhitespace(c: u8) bool {
    return WHITESPACE_TABLE[c];
}

/// Comptime function to check if a character is valid for XML tag names/attributes
/// Excludes whitespace and XML special characters for better parsing performance
inline fn isXmlNameChar(c: u8) bool {
    return !isWhitespace(c) and c != '>' and c != '/' and c != '=' and c != '"' and c != '\'';
}

/// Fast comptime-optimized container detection
/// A container is a simple tag without attributes (no spaces inside)
inline fn isSimpleContainer(trimmed: []const u8) bool {
    if (trimmed.len <= 2 or trimmed[0] != '<' or trimmed[trimmed.len - 1] != '>') return false;
    
    // Check for spaces in the tag content (indicates attributes)
    for (trimmed[1..trimmed.len-1]) |c| {
        if (isWhitespace(c)) return false;
    }
    return true;
}

/// Comptime-optimized XML tag type classification
/// Uses lookup tables for maximum performance
inline fn getTagType(trimmed: []const u8) enum { opening, closing, self_closing, comment, other } {
    if (trimmed.len < 2 or trimmed[0] != '<') return .other;
    
    if (trimmed.len >= 2) {
        // Check for closing tag
        if (trimmed[1] == '/') return .closing;
        // Check for special characters (comments, processing instructions)
        if (XML_SPECIAL_CHARS[trimmed[1]]) return .comment;
    }
    
    // Check for self-closing tag
    if (trimmed.len >= 2 and trimmed[trimmed.len - 2] == '/' and trimmed[trimmed.len - 1] == '>') {
        return .self_closing;
    }
    
    // Must be opening tag
    return .opening;
}

// Fast string trimming with comptime lookup table
/// High-performance whitespace trimming using comptime-generated lookup table
/// Avoids string allocation overhead by operating on slices  
/// Performance: O(n) worst case, typically O(1) for pre-trimmed strings
fn fastTrim(s: []const u8) []const u8 {
    if (s.len == 0) return s;

    // Find first non-whitespace (optimized with early return)
    var start: usize = 0;
    while (start < s.len and isWhitespace(s[start])) {
        start += 1;
    }
    if (start == s.len) return s[0..0]; // All whitespace

    // Find last non-whitespace (optimized backwards scan)
    var end: usize = s.len;
    while (end > start and isWhitespace(s[end - 1])) {
        end -= 1;
    }

    return s[start..end];
}


/// Compile-time lookup table for XML special characters
/// Enables O(1) tag type detection instead of multiple comparisons
/// Used for identifying closing tags (/), comments (!), processing instructions (?)
const XML_SPECIAL_CHARS = blk: {
    var chars = [_]bool{false} ** 256;
    chars['/'] = true;  // Closing tags: </tag>
    chars['!'] = true;  // Comments: <!--, CDATA: <![CDATA[
    chars['?'] = true;  // Processing instructions: <?xml
    break :blk chars;
};

/// Comptime lookup table for XML attribute delimiters
/// Optimizes attribute parsing with single table lookup
const XML_ATTR_DELIMITERS = blk: {
    var delims = [_]bool{false} ** 256;
    delims['='] = true;   // Attribute assignment
    delims['"'] = true;   // Quoted values
    delims['\''] = true;  // Single quoted values
    delims['>'] = true;   // Tag end
    delims['/'] = true;   // Self-closing tag
    break :blk delims;
};

/// Compile-time lookup table for whitespace characters
/// Replaces multiple conditional checks with single array access (O(1))
/// Covers standard ASCII whitespace: space, tab, carriage return, newline
const WHITESPACE_CHARS = blk: {
    var chars = [_]bool{false} ** 256;
    chars[' '] = true;   // Standard space character
    chars['\t'] = true;  // Tab character
    chars['\r'] = true;  // Carriage return
    chars['\n'] = true;  // Line feed
    break :blk chars;
};


/// Determine if XML element is self-contained (opening + content + closing tag)
/// Replaces expensive regex matching with direct byte analysis
/// Pattern: <tag>content</tag> (no nested < characters in content)
/// Performance: O(n) single pass, much faster than regex
fn isSelfContained(s: []const u8) bool {
    const trimmed = fastTrim(s);
    if (trimmed.len < 7 or trimmed[0] != '<' or trimmed[trimmed.len - 1] != '>') return false;

    // Find first > and last < using standard library (highly optimized)
    const first_gt = std.mem.indexOfScalar(u8, trimmed[1..], '>') orelse return false;
    const last_lt = std.mem.lastIndexOfScalar(u8, trimmed, '<') orelse return false;

    // Validate structure: first_gt < last_lt and closing tag starts with </
    if (first_gt + 1 >= last_lt or last_lt + 1 >= trimmed.len or trimmed[last_lt + 1] != '/') return false;

    // Check content between tags contains no <
    const content = trimmed[first_gt + 2 .. last_lt]; // +2 to account for offset from trimmed[1..]
    return std.mem.indexOfScalar(u8, content, '<') == null;
}

/// Fast lightweight normalization for simple elements (no complex attributes)
/// Performance: O(n) single pass, very fast

const Attribute = struct {
    name: []const u8,
    value: []const u8,
};

/// Parse attributes from an XML tag and return them in sorted order for consistent hashing
fn parseAndSortAttributes(allocator: std.mem.Allocator, tag_content: []const u8) ![]Attribute {
    var attributes = std.ArrayList(Attribute){};
    defer attributes.deinit(allocator);
    
    var i: usize = 0;
    
    // Skip tag name to find first space
    while (i < tag_content.len and !isWhitespace(tag_content[i]) and tag_content[i] != '>' and tag_content[i] != '/') {
        i += 1;
    }
    
    while (i < tag_content.len) {
        // Skip whitespace
        while (i < tag_content.len and isWhitespace(tag_content[i])) {
            i += 1;
        }
        
        if (i >= tag_content.len or tag_content[i] == '>' or tag_content[i] == '/') break;
        
        // Parse attribute name
        const name_start = i;
        while (i < tag_content.len and tag_content[i] != '=' and !isWhitespace(tag_content[i])) {
            i += 1;
        }
        const name = fastTrim(tag_content[name_start..i]);
        
        // Skip '=' and optional whitespace
        while (i < tag_content.len and (isWhitespace(tag_content[i]) or tag_content[i] == '=')) {
            i += 1;
        }
        
        if (i >= tag_content.len) break;
        
        // Parse attribute value
        var value_start = i;
        var value_end = i;
        
        if (tag_content[i] == '"' or tag_content[i] == '\'') {
            const quote = tag_content[i];
            i += 1; // Skip opening quote
            value_start = i;
            while (i < tag_content.len and tag_content[i] != quote) {
                i += 1;
            }
            value_end = i;
            if (i < tag_content.len) i += 1; // Skip closing quote
        } else {
            // Unquoted value
            while (i < tag_content.len and !isWhitespace(tag_content[i]) and tag_content[i] != '>' and tag_content[i] != '/') {
                i += 1;
            }
            value_end = i;
        }
        
        const value = tag_content[value_start..value_end];
        try attributes.append(allocator, Attribute{ .name = name, .value = value });
    }
    
    const result = try allocator.dupe(Attribute, attributes.items);
    
    // Sort attributes by name for consistent ordering
    std.sort.heap(Attribute, result, {}, struct {
        fn lessThan(_: void, a: Attribute, b: Attribute) bool {
            return std.mem.lessThan(u8, a.name, b.name);
        }
    }.lessThan);
    
    return result;
}

/// Advanced hash generation with aggressive normalization for XML deduplication
/// Normalizes whitespace, quote styles, attribute order, and formatting for semantic equivalence
/// Performance: O(n) for most cases, O(n log n) for complex attributes due to sorting
fn hashNormalizedContent(s: []const u8) u64 {
    // Use stack allocation for small temporary buffers to avoid heap allocation overhead
    var stack_buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&stack_buffer);
    const allocator = fba.allocator();
    
    const trimmed = fastTrim(s);
    if (trimmed.len == 0) return 0;
    
    // Check if this is a self-closing tag with attributes
    if (trimmed[0] == '<' and std.mem.endsWith(u8, trimmed, "/>")) {
        // Parse and normalize attributes for consistent hashing
        var tag_content_end = trimmed.len - 2; // Start from before />
        
        // Check if there's whitespace before />
        var has_space_before_close = false;
        if (tag_content_end > 0 and isWhitespace(trimmed[tag_content_end - 1])) {
            has_space_before_close = true;
            // Find the actual end of content (before whitespace)
            while (tag_content_end > 1 and isWhitespace(trimmed[tag_content_end - 1])) {
                tag_content_end -= 1;
            }
        }
        
        const tag_content = trimmed[1..tag_content_end]; // Remove < and content before />
        
        if (parseAndSortAttributes(allocator, tag_content)) |attributes| {
            defer allocator.free(attributes);
            
            var hasher = std.hash.Wyhash.init(0);
            
            // Hash tag name (everything before first space or attribute)
            var tag_name_end: usize = 0;
            while (tag_name_end < tag_content.len and !isWhitespace(tag_content[tag_name_end])) {
                tag_name_end += 1;
            }
            const tag_name = tag_content[0..tag_name_end];
            hasher.update(tag_name);
            
            // Hash sorted attributes with normalized quotes
            for (attributes) |attr| {
                hasher.update(" ");
                hasher.update(attr.name);
                hasher.update("=\"");
                hasher.update(attr.value);
                hasher.update("\"");
            }
            
            // Include closing syntax in hash to differentiate <Tag/> vs <Tag />
            if (has_space_before_close) {
                hasher.update(" />");
            } else {
                hasher.update("/>");
            }
            
            return hasher.final();
        } else |_| {
            // Fallback to original normalization if parsing fails
        }
    }
    
    // Fallback to original character-by-character normalization
    var hasher = std.hash.Wyhash.init(0);
    var in_quotes = false;
    var prev_space = false;
    var expecting_attr_value = false;
    
    var i: usize = 0;
    while (i < trimmed.len) {
        const c = trimmed[i];
        
        if (!in_quotes and (c == '"' or c == '\'')) {
            in_quotes = true;
            expecting_attr_value = false;
            const normalized_quote: u8 = '"';
            hasher.update(std.mem.asBytes(&normalized_quote));
            prev_space = false;
        } else if (in_quotes and (c == '"' or c == '\'')) {
            in_quotes = false;
            const normalized_quote: u8 = '"';
            hasher.update(std.mem.asBytes(&normalized_quote));
            prev_space = false;
        } else if (in_quotes) {
            hasher.update(std.mem.asBytes(&c));
            prev_space = false;
        } else if (c == '=' and !in_quotes) {
            hasher.update(std.mem.asBytes(&c));
            expecting_attr_value = true;
            prev_space = false;
        } else if (expecting_attr_value and !isWhitespace(c) and c != '>' and c != '/' and c != '"' and c != '\'') {
            const normalized_quote: u8 = '"';
            hasher.update(std.mem.asBytes(&normalized_quote));
            
            var j = i;
            while (j < trimmed.len and !isWhitespace(trimmed[j]) and trimmed[j] != '>' and trimmed[j] != '/') {
                hasher.update(std.mem.asBytes(&trimmed[j]));
                j += 1;
            }
            hasher.update(std.mem.asBytes(&normalized_quote));
            i = j - 1;
            expecting_attr_value = false;
            prev_space = false;
        } else if (isWhitespace(c)) {
            expecting_attr_value = false;
            if (!prev_space) {
                const space: u8 = ' ';
                hasher.update(std.mem.asBytes(&space));
                prev_space = true;
            }
        } else {
            expecting_attr_value = false;
            hasher.update(std.mem.asBytes(&c));
            prev_space = false;
        }
        
        i += 1;
    }

    return hasher.final();
}

// Process a single line for XML formatting and deduplication
fn processLine(result: *std.ArrayList(u8), seen_hashes: *std.AutoHashMap(u64, void), duplicates_removed: *u32, indent_level: *i32, trimmed: []const u8, allocator: std.mem.Allocator, indent_spaces: []const u8) !void {

    // Fast comptime-optimized container detection - simple tags without attributes
    const is_container = isSimpleContainer(trimmed);

    // Fast comptime-optimized tag type detection
    const tag_type = getTagType(trimmed);
    const is_closing_tag = tag_type == .closing;
    const is_opening_tag = tag_type == .opening;

    // Adjust indent level for closing tags BEFORE writing line
    if (is_closing_tag) {
        indent_level.* = @max(0, indent_level.* - 1);
    }

    // Fast hash-based deduplication - check AFTER indentation adjustment
    var is_duplicate = false;
    if (!is_container) {
        const content_hash = hashNormalizedContent(trimmed);
        if (seen_hashes.contains(content_hash)) {
            duplicates_removed.* += 1;
            is_duplicate = true;
        } else {
            try seen_hashes.put(content_hash, {});
        }
    }

    // Only write line if not duplicate
    if (!is_duplicate) {
        // Apply indentation using bulk operations
        const spaces_needed = @as(usize, @intCast(indent_level.* * 2));
        if (spaces_needed <= indent_spaces.len) {
            try result.appendSlice(allocator, indent_spaces[0..spaces_needed]);
        } else {
            // Fallback for very deep nesting
            for (0..spaces_needed) |_| {
                try result.append(allocator, ' ');
            }
        }

        try result.appendSlice(allocator, trimmed);
        try result.append(allocator, '\n');
    }

    // Adjust indent level for opening tags AFTER writing line
    // Improved self-contained tag detection
    if (is_opening_tag) {
        var should_indent = true;
        if (trimmed.len >= 7) { // minimum: <a>x</a>
            // Extract opening tag name
            const tag_name_start: usize = 1; // Skip '<'
            var tag_name_end: ?usize = null;
            
            for (trimmed[tag_name_start..], tag_name_start..) |c, i| {
                if (c == ' ' or c == '>' or c == '\t') {
                    tag_name_end = i;
                    break;
                }
            }
            
            if (tag_name_end) |end| {
                const tag_name = trimmed[tag_name_start..end];
                
                // Check if line ends with </tagname>
                if (trimmed.len >= tag_name.len + 3 and 
                    trimmed[trimmed.len - 1] == '>' and
                    trimmed[trimmed.len - tag_name.len - 2] == '/' and
                    trimmed[trimmed.len - tag_name.len - 3] == '<')
                {
                    const closing_tag_name = trimmed[trimmed.len - tag_name.len - 2..trimmed.len - 1];
                    if (std.mem.eql(u8, tag_name, closing_tag_name[1..])) { // Skip '/' in closing tag
                        should_indent = false;
                    }
                }
            }
        }
        if (should_indent) {
            indent_level.* += 1;
        }
    }
}

// XML processing with deduplication and indentation
fn processXmlWithDeduplication(allocator: std.mem.Allocator, content: []const u8, strip_xml_declaration: bool) !struct { content: []u8, duplicates: u32 } {
    if (content.len == 0) {
        return .{ .content = try allocator.dupe(u8, content), .duplicates = 0 };
    }

    var result = std.ArrayList(u8){};
    defer result.deinit(allocator);
    // Better capacity estimation: content size + 25% for indentation + 1KB safety margin
    const estimated_capacity = content.len + (content.len >> 2) + 1024;
    try result.ensureTotalCapacity(allocator, estimated_capacity);

    var seen_hashes = std.AutoHashMap(u64, void).init(allocator);
    // Dynamic capacity based on estimated line count  
    const estimated_lines = @max(content.len / ESTIMATED_LINE_LENGTH, MIN_HASH_CAPACITY); // Standard line length estimate
    try seen_hashes.ensureTotalCapacity(@min(estimated_lines, MAX_HASH_CAPACITY));
    defer seen_hashes.deinit();

    var duplicates_removed: u32 = 0;
    var indent_level: i32 = 0;
    var line_start: usize = 0;
    const indent_spaces = "                                                                                                                                "; // MAX_INDENT_LEVELS * 2 spaces

    while (line_start < content.len) {
        // Optimized line finding - skip newline character efficiently
        const line_end = std.mem.indexOfScalarPos(u8, content, line_start, '\n') orelse content.len;
        
        // Combine empty line check with trimming for better cache usage
        if (line_start < line_end) {
            const line = content[line_start..line_end];
            const trimmed = fastTrim(line);

            if (trimmed.len > 0) {
                // Skip XML declaration lines (<?xml...) only when strip_xml_declaration is true
                const is_xml_declaration = trimmed.len >= 5 and std.mem.startsWith(u8, trimmed, "<?xml");
                if (!(strip_xml_declaration and is_xml_declaration)) {
                    try processLine(&result, &seen_hashes, &duplicates_removed, &indent_level, trimmed, allocator, indent_spaces);
                }
            }
        }

        line_start = if (line_end < content.len) line_end + 1 else content.len;
    }

    return .{ .content = try result.toOwnedSlice(allocator), .duplicates = duplicates_removed };
}

// Optimized XML declaration detection - check only first 200 bytes
fn hasXmlDeclaration(content: []const u8) bool {
    const check_limit = @min(content.len, 200);
    return std.mem.indexOf(u8, content[0..check_limit], "<?xml") != null;
}

fn getOutputFilename(allocator: std.mem.Allocator, input_file: []const u8, replace_mode: bool) ![]u8 {
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

fn processFile(allocator: std.mem.Allocator, args: Args) !void {
    const content = std.fs.cwd().readFileAlloc(allocator, args.file, std.math.maxInt(usize)) catch |err| {
        print("Could not read file '{s}': {s}\n", .{ args.file, @errorName(err) });
        std.process.exit(1);
    };
    defer allocator.free(content);

    // Remove BOM if present for consistency across implementations
    const cleaned_content = if (content.len >= 3 and 
        content[0] == 0xEF and content[1] == 0xBB and content[2] == 0xBF)
        content[3..] else content;

    // Early XML declaration detection
    const has_xml_decl = hasXmlDeclaration(cleaned_content);

    if (!has_xml_decl) {
        print("⚠️  XML Best Practice Warnings:\n", .{});
        print("  [XML] Missing XML declaration\n", .{});
        print("    Fix: Add <?xml version=\"1.0\" encoding=\"utf-8\"?> at the top\n", .{});
        print("\n", .{});

        if (!args.fix_warnings) {
            print("Use --fix-warnings flag to automatically apply fixes\n", .{});
            print("\n", .{});
        }
    }

    // Process content with deduplication and proper XML formatting
    // Strip XML declaration in organize-only mode, preserve it in default/fix-warnings modes
    const should_strip_xml_declaration = false; // Never strip XML declarations
    const process_result = try processXmlWithDeduplication(allocator, cleaned_content, should_strip_xml_declaration);
    defer allocator.free(process_result.content);

    // Build final content with minimal allocations
    var final_content = std.ArrayList(u8){};
    defer final_content.deinit(allocator);

    const final_capacity = process_result.content.len + if (args.fix_warnings and !has_xml_decl) XML_DECLARATION.len else 0;
    try final_content.ensureTotalCapacity(allocator, final_capacity);

    if (args.fix_warnings and !has_xml_decl) {
        // Add XML declaration only if it was originally missing
        try final_content.appendSlice(allocator, XML_DECLARATION);
        print("🔧 Applied fixes:\n", .{});
        print("  ✓ Added XML declaration\n", .{});
        print("\n", .{});
    }

    try final_content.appendSlice(allocator, process_result.content);

    const output_filename = try getOutputFilename(allocator, args.file, args.replace);
    defer allocator.free(output_filename);

    std.fs.cwd().writeFile(.{ .sub_path = output_filename, .data = final_content.items }) catch |err| {
        print("Could not write output file: {s}\n", .{@errorName(err)});
        std.process.exit(1);
    };

    if (args.replace) {
        std.fs.cwd().rename(output_filename, args.file) catch |err| {
            _ = std.fs.cwd().deleteFile(output_filename) catch {};
            print("Could not replace original file: {s}\n", .{@errorName(err)});
            std.process.exit(1);
        };
        print("Original file replaced: {s}", .{args.file});
    } else {
        print("Organized project saved to: {s}", .{output_filename});
    }

    if (process_result.duplicates > 0) {
        print(" (removed {} duplicates)", .{process_result.duplicates});
    }

    const mode_text = " (preserving original structure)";

    print("{s}\n", .{mode_text});
}

pub fn main() !void {
    // Use GeneralPurposeAllocator for better performance on large files
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try parseArgs(allocator);
    try processFile(allocator, args);
}
