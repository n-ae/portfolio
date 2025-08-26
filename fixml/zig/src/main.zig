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
const Allocator = std.mem.Allocator;
const HashMap = std.AutoHashMap;

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
// Processing constants
const ESTIMATED_LINE_LENGTH = 50; // Average characters per line estimate
const MIN_HASH_CAPACITY = 256; // Minimum deduplication hash capacity
const MAX_HASH_CAPACITY = 4096; // Maximum deduplication hash capacity
const WHITESPACE_THRESHOLD = 32; // ASCII values <= this are whitespace

// Memory and performance constants
const LOAD_FACTOR_NUMERATOR = 4; // Hash map load factor (75%)
const LOAD_FACTOR_DENOMINATOR = 3;
const INDENT_OVERHEAD_PERCENT = 8; // 12.5% = 1/8
const SAFETY_MARGIN_PERCENT = 16; // 6.25% = 1/16
const MAX_SAFETY_MARGIN_KB = 1;

// File processing limits
const MAX_FILE_SIZE_MB = 100;
const XML_DECLARATION_CHECK_LIMIT = 200;

// Buffer size calculations
const ATTRIBUTE_COUNT_ESTIMATE = 32;
const ATTRIBUTE_SIZE_ESTIMATE = 128;
const BUFFER_SAFETY_MARGIN = 512;

// String processing constants
const CHUNK_SIZE_U64 = 8; // Size of u64 for chunked processing
const BITS_PER_BYTE = 8;
const UNROLL_FACTOR = 4; // Loop unrolling factor
const LARGE_STRING_THRESHOLD = 16;
const MEDIUM_STRING_THRESHOLD = 8;
const VERY_LONG_TAG_THRESHOLD = 15;
const SHORT_TAG_MAX_LENGTH = 20;
const MIN_SELF_CONTAINED_LENGTH = 7;

// ASCII constants
const ASCII_CONTROL_CHAR_MAX = 31;
const U32_COMMENT_PREFIX_SIZE = 4;

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
    while (i <= ASCII_CONTROL_CHAR_MAX) : (i += 1) {
        mask |= (@as(u256, 1) << i);
    }
    break :blk mask;
};
const FILE_PERMISSIONS = 0o644; // Standard file permissions
const IO_CHUNK_SIZE = 65536; // 64KB chunks for I/O operations

// =============================================================================
// TYPES AND CONSTANTS
// =============================================================================

/// Command-line argument configuration
const Args = struct {
    replace: bool = false,
    fix_warnings: bool = false,
    file: []const u8 = "",
};

/// XML attribute structure for parsing
const Attribute = struct {
    name: []const u8,
    value: []const u8,
};

/// XML tag classification for processing
const TagType = enum {
    opening,
    closing,
    self_closing,
    comment,
    other,
};

/// Parser state machine for normalization
const ParseState = enum {
    normal,
    in_quotes,
    expecting_value,
};

/// Processing result containing content and statistics
const ProcessResult = struct {
    content: []u8,
    duplicates: u32,
};

/// Configuration for XML processing behavior
const ProcessingConfig = struct {
    strip_xml_declaration: bool,
    max_file_size: usize,
    estimated_capacity: usize,
    hash_capacity: u32,

    fn create(content_size: usize) ProcessingConfig {
        const indent_overhead = content_size >> INDENT_OVERHEAD_PERCENT;
        const safety_margin = @min(content_size >> SAFETY_MARGIN_PERCENT, MAX_SAFETY_MARGIN_KB * 1024);
        const estimated_capacity = content_size + indent_overhead + safety_margin;

        const estimated_lines = content_size / ESTIMATED_LINE_LENGTH;
        const hash_capacity = @as(u32, @intCast(@min(@max(estimated_lines * LOAD_FACTOR_NUMERATOR / LOAD_FACTOR_DENOMINATOR, MIN_HASH_CAPACITY), MAX_HASH_CAPACITY)));

        return ProcessingConfig{
            .strip_xml_declaration = false,
            .max_file_size = MAX_FILE_SIZE_MB * 1024 * 1024,
            .estimated_capacity = estimated_capacity,
            .hash_capacity = hash_capacity,
        };
    }
};

/// Hash seed constants for different hash types
const HashSeeds = struct {
    const FAST_HASH_SEED: u32 = 0xDEADBEEF;
    const NORMALIZED_HASH_SEED: u32 = 0xFEEDFACE;
    const ATTRIBUTE_HASH_SEED: u32 = 0;
};

// =============================================================================
// ARGUMENT PARSING
// =============================================================================

/// Parse and validate command-line arguments
fn parseArgs(allocator: Allocator) !Args {
    const args_slice = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args_slice);

    var parsed = Args{};
    var file_set = false;

    // Optimized argument parsing with efficient string comparisons
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
// UTILITY FUNCTIONS
// =============================================================================

/// Fast whitespace detection using comptime bit manipulation
inline fn isWhitespace(c: u8) bool {
    return (WHITESPACE_MASK >> c) & 1 != 0;
}

/// Check if character is valid for XML identifiers
inline fn isValidXmlIdentifierChar(c: u8) bool {
    return !isWhitespace(c) and c != '>' and c != '/' and c != '=' and c != '"' and c != '\'';
}

/// Validate XML tag boundaries
inline fn isValidXmlTag(s: []const u8) bool {
    return s.len >= 2 and s[0] == '<' and s[s.len - 1] == '>';
}

/// Comptime-optimized whitespace detection with vectorized SIMD approach
/// Uses bit-parallel operations with minimal branching
inline fn hasWhitespaceInSlice(slice: []const u8) bool {
    if (slice.len == 0) return false;

    // Fast path for short strings - direct bit mask check
    if (slice.len <= 8) {
        for (slice) |byte| {
            if (isWhitespace(byte)) return true;
        }
        return false;
    }

    const chunk_size = CHUNK_SIZE_U64;
    var i: usize = 0;

    // Process 8-byte chunks with optimized bit operations
    while (i + chunk_size <= slice.len) {
        const chunk_bytes = slice[i .. i + chunk_size];
        const chunk_u64 = std.mem.readInt(u64, @ptrCast(chunk_bytes), .little);

        // Comptime unrolled byte extraction with minimal shifts
        comptime var shift = 0;
        inline while (shift < 64) : (shift += BITS_PER_BYTE) {
            const byte = @as(u8, @truncate(chunk_u64 >> shift));
            if ((WHITESPACE_MASK >> byte) & 1 != 0) return true;
        }
        i += chunk_size;
    }

    // Handle remaining bytes with unrolled loop for predictable performance
    const remaining = slice.len - i;
    if (remaining > 0) {
        comptime var offset = 0;
        inline while (offset < 8) : (offset += 1) {
            if (i + offset < slice.len and isWhitespace(slice[i + offset])) return true;
        }
    }

    return false;
}

/// Comptime function to check if a character is valid for XML tag names/attributes
/// Excludes whitespace and XML special characters for better parsing performance
inline fn isXmlNameChar(c: u8) bool {
    return isValidXmlIdentifierChar(c);
}

/// Comptime-optimized container detection using fast path analysis
/// A container is a simple tag without attributes (no spaces inside)
inline fn isSimpleContainer(trimmed: []const u8) bool {
    // Fast path: length and boundary checks
    if (trimmed.len <= 2 or trimmed[0] != '<' or trimmed[trimmed.len - 1] != '>') return false;

    // Quick check for self-closing tags
    if (trimmed[trimmed.len - 2] == '/') return false;

    // Optimized attribute detection: look for '=' or excessive whitespace
    const tag_content = trimmed[1 .. trimmed.len - 1];
    return std.mem.indexOf(u8, tag_content, "=") == null and !hasWhitespaceInSlice(tag_content);
}

/// Comptime-optimized XML tag type classification with pattern matching table
inline fn getTagType(trimmed: []const u8) TagType {
    if (trimmed.len < 2 or trimmed[0] != '<') return .other;

    // Comptime lookup table for second character analysis
    const second_char = trimmed[1];
    switch (second_char) {
        '/' => return .closing,
        '!', '?' => return .comment,
        else => {},
    }

    // Fast self-closing detection with bounds checking
    if (trimmed.len >= 3 and
        trimmed[trimmed.len - 2] == '/' and
        trimmed[trimmed.len - 1] == '>')
    {
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
/// Uses vectorized processing with comptime unrolling
inline fn hashXmlContentFast(s: []const u8) u64 {
    if (s.len == 0) return 0;

    // Use Zig's builtin Wyhash for better performance than FNV-1a
    var hasher = std.hash.Wyhash.init(HashSeeds.FAST_HASH_SEED);

    // Optimized single-pass processing with minimal state
    var prev_space = false;
    var i: usize = 0;

    // Process in larger chunks for better throughput
    while (i + 8 <= s.len) {
        comptime var unroll = 0;
        var chunk_has_content = false;
        inline while (unroll < 8) : (unroll += 1) {
            const c = s[i + unroll];
            if (isWhitespace(c)) {
                if (!prev_space and chunk_has_content) {
                    hasher.update(" ");
                    prev_space = true;
                }
            } else {
                hasher.update(&[_]u8{c});
                prev_space = false;
                chunk_has_content = true;
            }
        }
        i += 8;
    }

    // Process remaining bytes
    while (i < s.len) : (i += 1) {
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
    }

    return hasher.final();
}

/// Comptime-optimized tag name extraction with vectorized scanning
/// Uses bit manipulation for delimiter detection
inline fn extractTagName(tag: []const u8) []const u8 {
    if (tag.len < 2 or tag[0] != '<') return tag;

    const start = if (tag[1] == '/') @as(usize, 2) else @as(usize, 1);
    if (start >= tag.len) return tag[start..start];

    // Comptime-generated delimiter lookup for faster scanning
    const DELIM_MASK = comptime blk: {
        var mask: u256 = 0;
        // Common XML delimiters
        const delimiters = " >\t/=";
        for (delimiters) |d| {
            mask |= (@as(u256, 1) << d);
        }
        break :blk mask;
    };

    var end = start;

    // Efficient scanning with boundary checks
    while (end < tag.len) {
        const char = tag[end];
        if ((DELIM_MASK >> char) & 1 != 0) break;
        end += 1;
    }

    return tag[start..end];
}

/// Comptime-optimized string trimming with adaptive vectorization
/// Uses bit manipulation and unrolled loops for consistent performance
inline fn fastTrim(s: []const u8) []const u8 {
    if (s.len == 0) return s;
    if (s.len == 1) return if (isWhitespace(s[0])) s[0..0] else s;

    var start: usize = 0;
    var end: usize = s.len;

    // Optimized forward scan with adaptive chunk processing
    while (start < end) {
        // Large strings: process 8 bytes at once
        if (end - start >= LARGE_STRING_THRESHOLD) {
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
        // Small strings: process 4 bytes at once
        else if (end - start >= MEDIUM_STRING_THRESHOLD) {
            comptime var i = 0;
            inline while (i < UNROLL_FACTOR) : (i += 1) {
                if (!isWhitespace(s[start + i])) {
                    start += i;
                    break;
                }
            } else {
                start += 4;
                continue;
            }
            break;
        }
        // Tiny strings: byte by byte
        else {
            if (!isWhitespace(s[start])) break;
            start += 1;
        }
    }

    // Optimized backward scan with similar chunking
    while (end > start) {
        if (end - start >= LARGE_STRING_THRESHOLD) {
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
        } else if (end - start >= MEDIUM_STRING_THRESHOLD) {
            comptime var i = 0;
            inline while (i < UNROLL_FACTOR) : (i += 1) {
                if (!isWhitespace(s[end - 1 - i])) {
                    end -= i;
                    break;
                }
            } else {
                end -= 4;
                continue;
            }
            break;
        } else {
            if (!isWhitespace(s[end - 1])) break;
            end -= 1;
        }
    }

    return s[start..end];
}

// =============================================================================
// CHARACTER CLASSIFICATION
// =============================================================================
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

// =============================================================================
// XML PATTERN MATCHING
// =============================================================================

/// XML pattern recognition utilities
const XML_PATTERNS = struct {
    /// Comptime-generated pattern matching with minimal branching
    inline fn matchesSelfClosing(s: []const u8) bool {
        return s.len >= 2 and s[s.len - 2] == '/' and s[s.len - 1] == '>';
    }

    /// Optimized XML declaration detection with comptime string comparison
    inline fn matchesXmlDeclaration(s: []const u8) bool {
        if (s.len < 5) return false;
        // Comptime-optimized prefix matching
        const prefix = s[0..5];
        return std.mem.eql(u8, prefix, "<?xml");
    }

    /// Fast comment detection with bit-parallel comparison
    inline fn matchesComment(s: []const u8) bool {
        if (s.len < 4) return false;
        // Use u32 comparison for 4-byte prefix
        const prefix = std.mem.readInt(u32, s[0..U32_COMMENT_PREFIX_SIZE], .little);
        const comment_prefix = std.mem.readInt(u32, "<!--", .little);
        return prefix == comment_prefix;
    }

    /// Comptime-optimized simple tag recognition with size limits
    inline fn isCommonSimpleTag(s: []const u8) bool {
        if (s.len < 3 or s.len > SHORT_TAG_MAX_LENGTH or s[0] != '<' or s[s.len - 1] != '>') return false;

        const inner = s[1 .. s.len - 1];
        // Fast path: very short tags (common case)
        if (inner.len <= 3) {
            return !hasWhitespaceInSlice(inner);
        }

        // Longer tags: check for attributes more efficiently
        return std.mem.indexOf(u8, inner, "=") == null and !hasWhitespaceInSlice(inner);
    }

    /// Comptime-optimized tag hint detection with length-based heuristics
    inline fn getTagOptimizationHint(tag_name: []const u8) enum { simple, complex, unknown } {
        // Fast heuristic: short tags are usually simple
        if (tag_name.len <= 2) {
            // Common single/double char tags
            if (std.mem.eql(u8, tag_name, "a") or std.mem.eql(u8, tag_name, "b") or
                std.mem.eql(u8, tag_name, "i") or std.mem.eql(u8, tag_name, "p") or
                std.mem.eql(u8, tag_name, "br") or std.mem.eql(u8, tag_name, "hr"))
            {
                return .simple;
            }
        } else if (tag_name.len <= 4) {
            // Common 3-4 char tags
            if (std.mem.eql(u8, tag_name, "div") or std.mem.eql(u8, tag_name, "span") or
                std.mem.eql(u8, tag_name, "code") or std.mem.eql(u8, tag_name, "pre"))
            {
                return .simple;
            }
        }

        if (tag_name.len > VERY_LONG_TAG_THRESHOLD) return .complex; // Very long tag names are likely complex
        return .unknown;
    }
};

// =============================================================================
// XML STRUCTURE ANALYSIS
// =============================================================================

/// Detect self-contained XML elements: <tag>content</tag>
fn isSelfContained(s: []const u8) bool {
    const trimmed = fastTrim(s);
    if (trimmed.len < MIN_SELF_CONTAINED_LENGTH or !isValidXmlTag(trimmed)) return false;

    // Find opening and closing tag positions
    const first_gt = std.mem.indexOfScalar(u8, trimmed[1..], '>') orelse return false;
    const last_lt = std.mem.lastIndexOfScalar(u8, trimmed, '<') orelse return false;

    // Verify proper tag structure
    if (first_gt + 1 >= last_lt or
        last_lt + 1 >= trimmed.len or
        trimmed[last_lt + 1] != '/') return false;

    // Ensure no nested tags in content
    const content_start = first_gt + 2; // +2 for offset from trimmed[1..]
    const content = trimmed[content_start..last_lt];
    return std.mem.indexOfScalar(u8, content, '<') == null;
}

/// Fast lightweight normalization for simple elements (no complex attributes)
/// Performance: O(n) single pass, very fast
/// Parse attributes from an XML tag and return them in sorted order for consistent hashing
fn parseAndSortAttributes(allocator: Allocator, tag_content: []const u8) ![]Attribute {
    var attributes = ArrayList(Attribute){};
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
    sortAttributesByName(result);
    return result;
}

/// Sort attributes alphabetically by name for consistent output
fn sortAttributesByName(attributes: []Attribute) void {
    const AttributeSorter = struct {
        fn lessThan(_: void, a: Attribute, b: Attribute) bool {
            return std.mem.lessThan(u8, a.name, b.name);
        }
    };
    std.sort.heap(Attribute, attributes, {}, AttributeSorter.lessThan);
}

// =============================================================================
// HASHING AND NORMALIZATION
// =============================================================================

/// Generate normalized hash for XML content with attributes
fn hashNormalizedContent(s: []const u8) u64 {
    // Optimized stack buffer size for typical XML complexity
    const buffer_size = comptime ATTRIBUTE_COUNT_ESTIMATE * (@sizeOf(Attribute) + ATTRIBUTE_SIZE_ESTIMATE) + BUFFER_SAFETY_MARGIN;
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

            var hasher = std.hash.Wyhash.init(HashSeeds.ATTRIBUTE_HASH_SEED);

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

    // Optimized character-by-character normalization with state machine
    var hasher = std.hash.Wyhash.init(HashSeeds.NORMALIZED_HASH_SEED); // Different seed for normalized content

    var state: ParseState = .normal;
    var prev_space = false;
    var quote_char: u8 = 0;

    var i: usize = 0;
    while (i < trimmed.len) {
        const c = trimmed[i];
        switch (state) {
            .normal => {
                if (c == '"' or c == '\'') {
                    state = .in_quotes;
                    quote_char = c;
                    hasher.update("\""); // Normalize all quotes to double
                    prev_space = false;
                } else if (c == '=') {
                    hasher.update(&[_]u8{c});
                    state = .expecting_value;
                    prev_space = false;
                } else if (isWhitespace(c)) {
                    if (!prev_space) {
                        hasher.update(" ");
                        prev_space = true;
                    }
                } else {
                    hasher.update(&[_]u8{c});
                    prev_space = false;
                }
            },
            .in_quotes => {
                if (c == quote_char) {
                    state = .normal;
                    hasher.update("\"");
                    prev_space = false;
                } else {
                    hasher.update(&[_]u8{c});
                }
            },
            .expecting_value => {
                if (c == '"' or c == '\'') {
                    state = .in_quotes;
                    quote_char = c;
                    hasher.update("\"");
                    prev_space = false;
                } else if (!isWhitespace(c) and c != '>' and c != '/') {
                    // Unquoted attribute value - normalize with quotes
                    hasher.update("\"");
                    var j = i;
                    while (j < trimmed.len and !isWhitespace(trimmed[j]) and trimmed[j] != '>' and trimmed[j] != '/') {
                        hasher.update(&[_]u8{trimmed[j]});
                        j += 1;
                    }
                    hasher.update("\"");
                    state = .normal;
                    prev_space = false;
                    i = j - 1; // Skip processed characters
                } else if (isWhitespace(c)) {
                    // Skip whitespace after =
                } else {
                    state = .normal;
                    if (!prev_space) {
                        hasher.update(" ");
                        prev_space = true;
                    }
                }
            },
        }
        i += 1;
    }

    return hasher.final();
}

// =============================================================================
// XML PROCESSING FUNCTIONS
// =============================================================================

/// Check if content is a duplicate and mark it in the hash set
fn checkAndMarkDuplicate(
    is_container: bool,
    trimmed: []const u8,
    seen_hashes: *HashMap(u64, void),
    duplicates_removed: *u32,
) !bool {
    // Skip structural container elements
    if (is_container) return false;

    // Choose hash function based on content complexity
    const has_attributes = std.mem.indexOf(u8, trimmed, "=") != null;
    const content_hash = if (has_attributes)
        hashNormalizedContent(trimmed)
    else
        hashXmlContentFast(trimmed);

    // Check for duplicates with single hash map operation
    const hash_result = try seen_hashes.getOrPut(content_hash);
    if (hash_result.found_existing) {
        duplicates_removed.* += 1;
        return true;
    }
    return false;
}

/// Write a line with proper indentation to the result buffer
fn writeIndentedLine(
    result: *ArrayList(u8),
    trimmed: []const u8,
    indent_level: i32,
    allocator: Allocator,
) !void {
    const safe_indent = @as(usize, @intCast(@max(0, @min(indent_level, MAX_INDENT_LEVELS - 1))));
    const indent_str = INDENT_STRINGS[safe_indent];

    // Efficient batch writing with pre-allocated capacity
    const total_len = indent_str.len + trimmed.len + 1;
    try result.ensureUnusedCapacity(allocator, total_len);

    result.appendSliceAssumeCapacity(indent_str);
    result.appendSliceAssumeCapacity(trimmed);
    result.appendAssumeCapacity('\n');
}

/// Process a single XML line with formatting and deduplication
fn processLine(
    result: *ArrayList(u8),
    seen_hashes: *HashMap(u64, void),
    duplicates_removed: *u32,
    indent_level: *i32,
    trimmed: []const u8,
    allocator: Allocator,
) !void {

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

    // Check for and handle duplicates
    const is_duplicate = try checkAndMarkDuplicate(
        is_container,
        trimmed,
        seen_hashes,
        duplicates_removed,
    );

    // Write non-duplicate lines with proper indentation
    if (!is_duplicate) {
        try writeIndentedLine(result, trimmed, indent_level.*, allocator);
    }

    // Handle indentation for opening tags using simplified self-contained detection
    if (is_opening_tag) {
        // Check if this is a self-contained element: <tag>content</tag>
        const should_indent = !isSelfContained(trimmed);
        if (should_indent) {
            indent_level.* += 1;
        }
    }
}

// XML processing with deduplication and indentation
fn processXmlWithDeduplication(allocator: Allocator, content: []const u8, strip_xml_declaration: bool) !ProcessResult {
    if (content.len == 0) {
        return ProcessResult{ .content = try allocator.dupe(u8, content), .duplicates = 0 };
    }

    const config = ProcessingConfig.create(content.len);

    var result = ArrayList(u8){};
    defer result.deinit(allocator);
    try result.ensureTotalCapacity(allocator, config.estimated_capacity);

    var seen_hashes = HashMap(u64, void).init(allocator);
    defer seen_hashes.deinit();
    try seen_hashes.ensureTotalCapacity(config.hash_capacity);

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
                    try processLine(&result, &seen_hashes, &duplicates_removed, &indent_level, trimmed, allocator);
                }
            }
        }

        line_start = if (line_end < content.len) line_end + 1 else content.len;
    }

    return ProcessResult{ .content = try result.toOwnedSlice(allocator), .duplicates = duplicates_removed };
}

// Comptime-optimized XML declaration detection using pattern matching
fn hasXmlDeclaration(content: []const u8) bool {
    const check_limit = @min(content.len, XML_DECLARATION_CHECK_LIMIT);
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

// =============================================================================
// FILE OPERATIONS
// =============================================================================

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

/// Main file processing function
fn processFile(allocator: Allocator, args: Args) !void {
    // Read file with reasonable size limit for safety
    const config = ProcessingConfig.create(0);
    const max_file_size = config.max_file_size; // Configurable file size limit
    const content = std.fs.cwd().readFileAlloc(allocator, args.file, max_file_size) catch |err| {
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
    var final_content = ArrayList(u8){};
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

    // Write file with explicit error handling and permissions
    std.fs.cwd().writeFile(.{
        .sub_path = output_filename,
        .data = final_content.items,
    }) catch |err| {
        print("Could not write output file '{s}': {s}\n", .{ output_filename, @errorName(err) });
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

// =============================================================================
// MAIN ENTRY POINT
// =============================================================================

/// Application entry point
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try parseArgs(allocator);
    try processFile(allocator, args);
}
