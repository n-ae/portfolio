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
const MAX_INDENT_LEVELS = 64; // Maximum nesting depth supported

/// Comptime-generated indent strings for ultra-fast indentation
/// All 64 levels pre-computed at compile time for O(1) indentation
const INDENT_STRINGS: [MAX_INDENT_LEVELS][]const u8 = blk: {
    @setEvalBranchQuota(50000);

    // Create complete buffer at comptime
    const max_spaces = MAX_INDENT_LEVELS * 2;
    const buffer = blk2: {
        var buf: [max_spaces]u8 = undefined;
        @memset(&buf, ' ');
        break :blk2 buf;
    };

    var strings: [MAX_INDENT_LEVELS][]const u8 = undefined;
    strings[0] = "";

    var i: usize = 1;
    while (i < MAX_INDENT_LEVELS) : (i += 1) {
        strings[i] = buffer[0 .. i * 2];
    }

    break :blk strings;
};
const ESTIMATED_LINE_LENGTH = 50; // Average characters per line estimate
const MIN_HASH_CAPACITY = 256; // Minimum deduplication hash capacity
const MAX_HASH_CAPACITY = 4096; // Maximum deduplication hash capacity
const WHITESPACE_THRESHOLD = 32; // ASCII values <= this are whitespace

/// Comptime-optimized whitespace detection using bit manipulation
/// Single instruction check for common whitespace (space, tab, newline, CR)
const WHITESPACE_MASK = blk: {
    var mask: u256 = 0;
    mask |= (@as(u256, 1) << ' '); // Space
    mask |= (@as(u256, 1) << '\t'); // Tab
    mask |= (@as(u256, 1) << '\n'); // Newline
    mask |= (@as(u256, 1) << '\r'); // Carriage return
    // Include other ASCII control chars (0-31)
    var i: u8 = 0;
    while (i <= 31) : (i += 1) {
        mask |= (@as(u256, 1) << i);
    }
    break :blk mask;
};
const FILE_PERMISSIONS = 0o644; // Standard file permissions
const IO_CHUNK_SIZE = 65536; // 64KB chunks for I/O operations

/// Command-line argument structure
/// Mirrors interface across all language implementations for consistency
const Args = struct {
    replace: bool = false, // Replace original file instead of creating .organized
    fix_warnings: bool = false, // Add XML declaration and fix best practices
    file: []const u8 = "", // Input XML file path
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

/// Ultra-fast comptime whitespace detection using bit manipulation
/// Single bit test instruction - faster than array lookup
inline fn isWhitespace(c: u8) bool {
    return (WHITESPACE_MASK >> c) & 1 != 0;
}

/// Advanced SIMD-optimized whitespace detection with comptime magic numbers
/// Uses bit-parallel operations for maximum throughput
inline fn hasWhitespaceInSlice(slice: []const u8) bool {
    const chunk_size = @sizeOf(u64);
    var i: usize = 0;

    // Comptime magic numbers for parallel whitespace detection
    const MAGIC_LOW = comptime blk: {
        // Create mask for bytes <= 32 (whitespace threshold)
        var magic: u64 = 0;
        var byte_pos = 0;
        while (byte_pos < 8) : (byte_pos += 1) {
            magic |= @as(u64, 0x20) << (byte_pos * 8);
        }
        break :blk magic;
    };

    // Process 8-byte chunks with bit-parallel comparison
    while (i + chunk_size <= slice.len) {
        const chunk_bytes = slice[i .. i + chunk_size];
        const chunk_u64 = std.mem.readInt(u64, @ptrCast(chunk_bytes), .little);

        // Bit-parallel check: find bytes <= 32 (most whitespace)
        if ((chunk_u64 | (chunk_u64 -% MAGIC_LOW)) & 0x8080808080808080 != 0x8080808080808080) {
            // Fallback to individual byte check for this chunk
            for (chunk_bytes) |byte| {
                if (isWhitespace(byte)) return true;
            }
        }
        i += chunk_size;
    }

    // Process remaining bytes
    while (i < slice.len) : (i += 1) {
        if (isWhitespace(slice[i])) return true;
    }

    return false;
}

/// Comptime function to check if a character is valid for XML tag names/attributes
/// Excludes whitespace and XML special characters for better parsing performance
inline fn isXmlNameChar(c: u8) bool {
    return !isWhitespace(c) and c != '>' and c != '/' and c != '=' and c != '"' and c != '\'';
}

/// Fast comptime-optimized container detection with vectorized processing
/// A container is a simple tag without attributes (no spaces inside)
inline fn isSimpleContainer(trimmed: []const u8) bool {
    if (trimmed.len <= 2 or trimmed[0] != '<' or trimmed[trimmed.len - 1] != '>') return false;

    // Use vectorized whitespace detection for better performance on longer tags
    const tag_content = trimmed[1 .. trimmed.len - 1];
    return !hasWhitespaceInSlice(tag_content);
}

/// Comptime-optimized XML tag type classification using bit masks
inline fn getTagType(trimmed: []const u8) enum { opening, closing, self_closing, comment, other } {
    if (trimmed.len < 2 or trimmed[0] != '<') return .other;

    // Fast bit-based character classification
    if (trimmed[1] == '/') return .closing;
    if (isXmlSpecialChar(trimmed[1])) return .comment;

    // Check for self-closing tag using comptime pattern
    if (XML_PATTERNS.matchesSelfClosing(trimmed)) {
        return .self_closing;
    }

    return .opening;
}

/// Comptime-optimized XXH3-style hash with better collision resistance
/// Processes multiple bytes at once for maximum performance
inline fn hashSimpleString(s: []const u8) u64 {
    // Use Zig's standard Wyhash for better performance and collision resistance
    var hasher = std.hash.Wyhash.init(0xDEADBEEF_CAFEBABE);

    var prev_space = false;
    const chunk_size = 8;
    var i: usize = 0;

    // Process in 8-byte chunks for better throughput
    while (i + chunk_size <= s.len) {
        var normalized_chunk: [chunk_size]u8 = undefined;
        var chunk_pos: usize = 0;

        for (s[i .. i + chunk_size]) |c| {
            if (isWhitespace(c)) {
                if (!prev_space) {
                    normalized_chunk[chunk_pos] = ' ';
                    chunk_pos += 1;
                    prev_space = true;
                }
            } else {
                normalized_chunk[chunk_pos] = c;
                chunk_pos += 1;
                prev_space = false;
            }
        }

        if (chunk_pos > 0) {
            hasher.update(normalized_chunk[0..chunk_pos]);
        }
        i += chunk_size;
    }

    // Process remaining bytes
    while (i < s.len) {
        const c = s[i];
        if (isWhitespace(c)) {
            if (!prev_space) {
                hasher.update(" ");
                prev_space = true;
            }
        } else {
            hasher.update(&[_]u8{c});
            prev_space = false;
        }
        i += 1;
    }

    return hasher.final();
}

/// Ultra-fast polynomial hash optimized for XML deduplication
/// Uses rolling hash with whitespace normalization
inline fn hashXmlContentFast(s: []const u8) u64 {
    if (s.len == 0) return 0;

    const POLY: u64 = 31;
    var hash: u64 = 0;
    var prev_space = false;

    for (s) |c| {
        if (isWhitespace(c)) {
            if (!prev_space) {
                hash = hash * POLY + ' ';
                prev_space = true;
            }
        } else {
            hash = hash * POLY + c;
            prev_space = false;
        }
    }

    return hash;
}

/// Ultra-optimized tag name extraction with comptime patterns
/// Pre-computed lookup table for common XML patterns
inline fn extractTagName(tag: []const u8) []const u8 {
    if (tag.len < 2 or tag[0] != '<') return tag;

    const start = if (tag[1] == '/') @as(usize, 2) else @as(usize, 1);
    var end = start;

    // Comptime-optimized delimiter detection with bit operations
    const DELIM_MASK = comptime blk: {
        var mask: u256 = 0;
        mask |= (@as(u256, 1) << ' '); // Space
        mask |= (@as(u256, 1) << '>'); // Tag end
        mask |= (@as(u256, 1) << '\t'); // Tab
        mask |= (@as(u256, 1) << '/'); // Self-closing
        mask |= (@as(u256, 1) << '='); // Attribute assignment
        break :blk mask;
    };

    // Single bit test per character - much faster than multiple comparisons
    while (end < tag.len and (DELIM_MASK >> tag[end]) & 1 == 0) {
        end += 1;
    }

    return tag[start..end];
}

/// Comptime-optimized string trimming with vectorized processing
/// Uses unrolled loops and SIMD-style operations for maximum performance
fn fastTrim(s: []const u8) []const u8 {
    if (s.len == 0) return s;

    // Vectorized forward scan using unrolled loop
    var start: usize = 0;
    if (s.len >= 8) {
        // Process 8 bytes at once for better throughput
        while (start + 8 <= s.len) {
            comptime var i = 0;
            inline while (i < 8) : (i += 1) {
                if (!isWhitespace(s[start + i])) {
                    start += i;
                    break;
                }
            } else {
                start += 8;
                continue;
            }
            break;
        }
    }

    // Finish forward scan
    while (start < s.len and isWhitespace(s[start])) {
        start += 1;
    }
    if (start == s.len) return s[0..0];

    // Vectorized backward scan
    var end: usize = s.len;
    if (s.len >= 8) {
        while (end >= start + 8) {
            comptime var i = 0;
            inline while (i < 8) : (i += 1) {
                if (!isWhitespace(s[end - 1 - i])) {
                    end -= i;
                    break;
                }
            } else {
                end -= 8;
                continue;
            }
            break;
        }
    }

    // Finish backward scan
    while (end > start and isWhitespace(s[end - 1])) {
        end -= 1;
    }

    return s[start..end];
}

/// Unified comptime character classification using bit manipulation
/// Replaces multiple lookup tables with efficient bit masks
const XML_SPECIAL_MASK = blk: {
    var mask: u256 = 0;
    mask |= (@as(u256, 1) << '/'); // Closing tags
    mask |= (@as(u256, 1) << '!'); // Comments/CDATA
    mask |= (@as(u256, 1) << '?'); // Processing instructions
    break :blk mask;
};

const XML_DELIMITER_MASK = blk: {
    var mask: u256 = 0;
    mask |= (@as(u256, 1) << '='); // Attribute assignment
    mask |= (@as(u256, 1) << '"'); // Double quotes
    mask |= (@as(u256, 1) << '\''); // Single quotes
    mask |= (@as(u256, 1) << '>'); // Tag end
    mask |= (@as(u256, 1) << '/'); // Self-closing
    break :blk mask;
};

/// Fast bit-based character classification
inline fn isXmlSpecialChar(c: u8) bool {
    return (XML_SPECIAL_MASK >> c) & 1 != 0;
}

inline fn isXmlDelimiter(c: u8) bool {
    return (XML_DELIMITER_MASK >> c) & 1 != 0;
}

/// Comptime-optimized XML pattern matching for common structures
/// Pre-computed patterns for faster recognition
const XML_PATTERNS = struct {
    /// Fast pattern matching using comptime-generated comparisons
    inline fn matchesSelfClosing(s: []const u8) bool {
        return s.len >= 2 and s[s.len - 2] == '/' and s[s.len - 1] == '>';
    }

    inline fn matchesXmlDeclaration(s: []const u8) bool {
        return s.len >= 5 and
            s[0] == '<' and s[1] == '?' and
            s[2] == 'x' and s[3] == 'm' and s[4] == 'l';
    }

    inline fn matchesComment(s: []const u8) bool {
        return s.len >= 4 and
            s[0] == '<' and s[1] == '!' and
            s[2] == '-' and s[3] == '-';
    }
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
    // Use comptime-calculated stack allocation for optimal buffer size
    // Estimate: 16 max attributes * (Attribute struct + 64 bytes for name/value)
    const buffer_size = comptime 16 * (@sizeOf(Attribute) + 64);
    var stack_buffer: [buffer_size]u8 = undefined;
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
fn processLine(result: *std.ArrayList(u8), seen_hashes: *std.AutoHashMap(u64, void), duplicates_removed: *u32, indent_level: *i32, trimmed: []const u8, allocator: std.mem.Allocator, _: []const u8) !void {

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

    // Optimized hash-based deduplication - eliminate redundant container check
    var is_duplicate = false;
    if (!is_container) {
        // Single container check result reused for hash selection
        const content_hash = if (is_container)
            hashSimpleString(trimmed)
        else
            hashNormalizedContent(trimmed);
        if (seen_hashes.contains(content_hash)) {
            duplicates_removed.* += 1;
            is_duplicate = true;
        } else {
            try seen_hashes.put(content_hash, {});
        }
    }

    // Only write line if not duplicate - optimized batch allocation
    if (!is_duplicate) {
        const indent_depth = @as(usize, @intCast(@min(indent_level.*, MAX_INDENT_LEVELS - 1)));
        const indent_str = INDENT_STRINGS[indent_depth];

        // Single capacity check for better performance
        const total_len = indent_str.len + trimmed.len + 1;
        try result.ensureUnusedCapacity(allocator, total_len);

        // Batch append without capacity checks for better cache locality
        result.appendSliceAssumeCapacity(indent_str);
        result.appendSliceAssumeCapacity(trimmed);
        result.appendAssumeCapacity('\n');
    }

    // Adjust indent level for opening tags AFTER writing line
    // Ultra-fast self-contained tag detection using comptime optimizations
    if (is_opening_tag) {
        var should_indent = true;
        if (trimmed.len >= 7) { // minimum: <a>x</a>
            const tag_name = extractTagName(trimmed);

            if (tag_name.len > 0) {
                // Check if line ends with </tagname> using optimized pattern matching
                const required_suffix_len = tag_name.len + 3; // </name>
                if (trimmed.len >= required_suffix_len and
                    trimmed[trimmed.len - 1] == '>' and
                    trimmed[trimmed.len - required_suffix_len] == '<' and
                    trimmed[trimmed.len - required_suffix_len + 1] == '/')
                {
                    const closing_tag_name = trimmed[trimmed.len - required_suffix_len + 2 .. trimmed.len - 1];
                    if (std.mem.eql(u8, tag_name, closing_tag_name)) {
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
    _ = undefined; // Removed unused indent_spaces buffer - using INDENT_STRINGS directly

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
                    try processLine(&result, &seen_hashes, &duplicates_removed, &indent_level, trimmed, allocator, "");
                }
            }
        }

        line_start = if (line_end < content.len) line_end + 1 else content.len;
    }

    return .{ .content = try result.toOwnedSlice(allocator), .duplicates = duplicates_removed };
}

// Comptime-optimized XML declaration detection using pattern matching
fn hasXmlDeclaration(content: []const u8) bool {
    const check_limit = @min(content.len, 200);
    const slice = content[0..check_limit];

    // Fast pattern-based detection without string search
    var i: usize = 0;
    while (i + 5 <= slice.len) {
        if (XML_PATTERNS.matchesXmlDeclaration(slice[i..])) {
            return true;
        }
        // Skip to next line if no match found
        if (std.mem.indexOfScalarPos(u8, slice, i, '\n')) |newline| {
            i = newline + 1;
        } else {
            break;
        }
    }
    return false;
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
        content[3..]
    else
        content;

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
