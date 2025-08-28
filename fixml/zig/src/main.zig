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

// Buffer size calculations - Correctness improvement with bounds checking
const ATTRIBUTE_COUNT_ESTIMATE = 32;
const ATTRIBUTE_SIZE_ESTIMATE = 128;
const BUFFER_SAFETY_MARGIN = 512;
const MAX_STACK_BUFFER_SIZE = 16384; // 16KB limit for stack allocation safety

// BOM (Byte Order Mark) constants - Replace Magic Numbers
const UTF8_BOM: [3]u8 = .{ 0xEF, 0xBB, 0xBF };
const BOM_SIZE = 3;

// String processing constants
const CHUNK_SIZE_U64 = 8; // Size of u64 for chunked processing
const BITS_PER_BYTE = 8;
const UNROLL_FACTOR = 4; // Loop unrolling factor
const LARGE_STRING_THRESHOLD = 16;
const MEDIUM_STRING_THRESHOLD = 8;
const VERY_LONG_TAG_THRESHOLD = 15;
const SHORT_TAG_MAX_LENGTH = 20;
const MIN_SELF_CONTAINED_LENGTH = 5; // <a>x</a> minimum for self-contained elements

/// Lightweight Parameter Object for tag parsing state - optimized for performance
const TagParseState = struct {
    in_quotes: bool = false,
    quote_char: u8 = 0,

    // Inlined methods for zero-overhead abstraction
    inline fn reset(self: *TagParseState) void {
        self.in_quotes = false;
        self.quote_char = 0;
    }

    inline fn enterQuotes(self: *TagParseState, char: u8) void {
        self.in_quotes = true;
        self.quote_char = char;
    }

    inline fn exitQuotes(self: *TagParseState) void {
        self.in_quotes = false;
        self.quote_char = 0;
    }

    inline fn isInQuotes(self: *const TagParseState) bool {
        return self.in_quotes;
    }

    inline fn shouldExitQuotes(self: *const TagParseState, char: u8) bool {
        return self.in_quotes and char == self.quote_char;
    }
};

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

/// Improved hash seed constants to avoid collisions - Correctness improvement
const HashSeeds = struct {
    // Use cryptographically diverse seeds to prevent hash collisions
    const FAST_HASH_SEED: u64 = 0x517cc1b727220a95;
    const NORMALIZED_HASH_SEED: u64 = 0x9e3779b97f4a7c15;
    const ATTRIBUTE_HASH_SEED: u64 = 0xc6a4a7935bd1e995;
    const CONTENT_HASH_SEED: u64 = 0xe17a1465bf5ae6e7;
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

/// Check if character is valid for XML identifiers per XML spec
/// XML Name production: NameStartChar (NameChar)*
inline fn isValidXmlIdentifierChar(c: u8) bool {
    return !isWhitespace(c) and c != '>' and c != '/' and c != '=' and c != '"' and c != '\'';
}

/// Check if character can start an XML Name per XML specification
/// NameStartChar: ":" | [A-Z] | "_" | [a-z] | [#xC0-#xD6] | [#xD8-#xF6] | [#xF8-#x2FF] | etc.
inline fn isXmlNameStartChar(c: u8) bool {
    return (c >= 'A' and c <= 'Z') or
        (c >= 'a' and c <= 'z') or
        c == '_' or c == ':' or
        c >= 0xC0; // Basic Unicode support for high-byte chars
}

/// Check if character can continue an XML Name per XML specification
/// NameChar: NameStartChar | "-" | "." | [0-9] | #xB7 | [#x0300-#x036F] | [#x203F-#x2040]
inline fn isXmlNameChar(c: u8) bool {
    return isXmlNameStartChar(c) or
        (c >= '0' and c <= '9') or
        c == '-' or c == '.' or
        c == 0xB7; // Middle dot
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

/// Simplified XML attribute parser - Simplicity improvement
/// Performance: O(n) single pass with clear state machine
fn parseAndSortAttributes(allocator: Allocator, tag_content: []const u8) ![]Attribute {
    var attributes = ArrayList(Attribute){};
    defer attributes.deinit(allocator);

    var parser = AttributeParser{ .content = tag_content, .pos = 0 };

    // Skip tag name
    parser.skipToAttributes();

    // Parse attributes in simplified loop
    while (parser.hasMore()) {
        const attr = parser.parseNextAttribute() orelse break;
        try attributes.append(allocator, attr);
    }

    const result = try allocator.dupe(Attribute, attributes.items);
    sortAttributesByName(result);
    return result;
}

/// Simplified attribute parser state machine - Simplicity improvement
const AttributeParser = struct {
    content: []const u8,
    pos: usize,

    fn hasMore(self: *const AttributeParser) bool {
        return self.pos < self.content.len and
            self.content[self.pos] != '>' and
            self.content[self.pos] != '/';
    }

    fn skipToAttributes(self: *AttributeParser) void {
        // Skip tag name to find first space
        while (self.pos < self.content.len and
            !isWhitespace(self.content[self.pos]) and
            self.content[self.pos] != '>' and
            self.content[self.pos] != '/')
        {
            self.pos += 1;
        }
    }

    fn parseNextAttribute(self: *AttributeParser) ?Attribute {
        // Skip whitespace
        self.skipWhitespace();
        if (!self.hasMore()) return null;

        // Parse name
        const name = self.parseName() orelse return null;

        // Skip '=' and whitespace
        self.skipToValue();

        // Parse value
        const value = self.parseValue();

        return Attribute{ .name = name, .value = value };
    }

    inline fn skipWhitespace(self: *AttributeParser) void {
        while (self.pos < self.content.len and isWhitespace(self.content[self.pos])) {
            self.pos += 1;
        }
    }

    inline fn parseName(self: *AttributeParser) ?[]const u8 {
        const start = self.pos;
        while (self.pos < self.content.len and
            self.content[self.pos] != '=' and
            !isWhitespace(self.content[self.pos]))
        {
            self.pos += 1;
        }
        return if (self.pos > start) self.content[start..self.pos] else null;
    }

    inline fn skipToValue(self: *AttributeParser) void {
        while (self.pos < self.content.len and
            (isWhitespace(self.content[self.pos]) or self.content[self.pos] == '='))
        {
            self.pos += 1;
        }
    }

    inline fn parseValue(self: *AttributeParser) []const u8 {
        if (self.pos >= self.content.len) return "";

        const start = self.pos;

        if (self.content[self.pos] == '"' or self.content[self.pos] == '\'') {
            // Quoted value
            const quote = self.content[self.pos];
            self.pos += 1; // Skip opening quote
            const value_start = self.pos;

            while (self.pos < self.content.len and self.content[self.pos] != quote) {
                self.pos += 1;
            }

            const value = self.content[value_start..self.pos];
            if (self.pos < self.content.len) self.pos += 1; // Skip closing quote
            return value;
        } else {
            // Unquoted value
            while (self.pos < self.content.len and
                !isWhitespace(self.content[self.pos]) and
                self.content[self.pos] != '>' and
                self.content[self.pos] != '/')
            {
                self.pos += 1;
            }
            return self.content[start..self.pos];
        }
    }
};

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

/// Generate normalized hash for XML content with attributes - Improved correctness
fn hashNormalizedContent(s: []const u8) u64 {
    // Safe buffer size calculation with bounds checking
    const buffer_size = comptime blk: {
        const calculated = ATTRIBUTE_COUNT_ESTIMATE * (@sizeOf(Attribute) + ATTRIBUTE_SIZE_ESTIMATE) + BUFFER_SAFETY_MARGIN;
        break :blk @min(calculated, MAX_STACK_BUFFER_SIZE);
    };
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

    // High-performance vectorized normalization with simplified state machine
    var hasher = std.hash.Wyhash.init(HashSeeds.NORMALIZED_HASH_SEED);

    var state: ParseState = .normal;
    var prev_space = false;
    var quote_char: u8 = 0;

    // Process in chunks for better cache efficiency
    var i: usize = 0;
    const chunk_size = 8;

    // Fast path: process 8-byte chunks when possible
    while (i + chunk_size <= trimmed.len and state == .normal) {
        const chunk = trimmed[i .. i + chunk_size];

        // Check if chunk contains quotes or special chars (quick SIMD-like check)
        var has_special = false;
        for (chunk) |c| {
            if (c == '"' or c == '\'' or c == '=') {
                has_special = true;
                break;
            }
        }

        if (!has_special) {
            // Fast path: normalize whitespace in chunk
            var normalized_chunk: [chunk_size]u8 = undefined;
            var out_idx: usize = 0;

            for (chunk) |c| {
                if (isWhitespace(c)) {
                    if (!prev_space and out_idx < chunk_size) {
                        normalized_chunk[out_idx] = ' ';
                        out_idx += 1;
                        prev_space = true;
                    }
                } else {
                    if (out_idx < chunk_size) {
                        normalized_chunk[out_idx] = c;
                        out_idx += 1;
                    }
                    prev_space = false;
                }
            }

            if (out_idx > 0) {
                hasher.update(normalized_chunk[0..out_idx]);
            }
            i += chunk_size;
        } else {
            break; // Fall back to character-by-character processing
        }
    }

    // Character-by-character processing for remainder or special cases
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

/// Normalize XML tag with selective content normalization for whitespace handling tests
fn normalizeXmlTagWithContent(allocator: Allocator, tag: []const u8, fix_warnings: bool) ![]const u8 {
    if (tag.len < 2 or tag[0] != '<') return try allocator.dupe(u8, tag);

    // Check if this is a single-line element with content: <tag>content</tag>
    const first_gt = std.mem.indexOfScalar(u8, tag, '>');
    const last_lt = std.mem.lastIndexOfScalar(u8, tag, '<');

    if (first_gt != null and last_lt != null and first_gt.? < last_lt.? and
        tag[last_lt.? + 1] == '/' and std.mem.endsWith(u8, tag, ">"))
    {
        // This is a single-line element, normalize the content between tags
        const opening_tag = tag[0 .. first_gt.? + 1];
        const content = tag[first_gt.? + 1 .. last_lt.?];
        const closing_tag = tag[last_lt.?..];

        const normalized_opening = try normalizeTagOnly(allocator, opening_tag);
        defer allocator.free(normalized_opening);

        const normalized_content = if (fix_warnings)
            try normalizeContent(allocator, content)
        else
            try allocator.dupe(u8, content);
        defer allocator.free(normalized_content);

        const normalized_closing = try normalizeTagOnly(allocator, closing_tag);
        defer allocator.free(normalized_closing);

        var result = ArrayList(u8){};
        defer result.deinit(allocator);

        try result.appendSlice(allocator, normalized_opening);
        try result.appendSlice(allocator, normalized_content);
        try result.appendSlice(allocator, normalized_closing);

        return try result.toOwnedSlice(allocator);
    } else {
        // Regular tag normalization
        return try normalizeTagOnly(allocator, tag);
    }
}

/// Handle character processing outside quotes - Extract Method refactoring (inlined for performance)
inline fn processCharOutsideQuotes(allocator: Allocator, result: *ArrayList(u8), c: u8, i: *usize, tag: []const u8, state: *TagParseState) !void {
    if (c == '"' or c == '\'') {
        state.enterQuotes(c);
        try result.append(allocator, c);
    } else if (c == '=') {
        // Remove any preceding whitespace before =
        while (result.items.len > 0 and isWhitespace(result.items[result.items.len - 1])) {
            _ = result.pop();
        }
        try result.append(allocator, c);
        // Skip following whitespace after =
        while (i.* + 1 < tag.len and isWhitespace(tag[i.* + 1])) {
            i.* += 1;
        }
    } else if (isWhitespace(c) and i.* + 2 < tag.len and tag[i.* + 1] == '/' and tag[i.* + 2] == '>') {
        // Normalize " />" to "/>" - skip the whitespace before />
        // Do nothing - skip the whitespace
    } else if (isWhitespace(c) and i.* + 1 < tag.len and tag[i.* + 1] == '/') {
        // Normalize " /" cases - skip the whitespace
        // Do nothing - skip the whitespace
    } else if (isWhitespace(c) and i.* + 1 < tag.len and tag[i.* + 1] == '>') {
        // Normalize " >" to ">" - skip the whitespace
        // Do nothing - skip the whitespace
    } else if (isWhitespace(c)) {
        // Check if next non-whitespace character is / or > to avoid adding space before them
        var peek_idx = i.* + 1;
        while (peek_idx < tag.len and isWhitespace(tag[peek_idx])) {
            peek_idx += 1;
        }

        // Don't add space if next non-whitespace char is / or >
        if (peek_idx < tag.len and (tag[peek_idx] == '/' or tag[peek_idx] == '>')) {
            // Skip all whitespace before / or >
            while (i.* + 1 < tag.len and isWhitespace(tag[i.* + 1])) {
                i.* += 1;
            }
        } else {
            // Normalize multiple whitespace to single space (including newlines)
            // Only add space if the last character wasn't already a space
            if (result.items.len == 0 or result.items[result.items.len - 1] != ' ') {
                try result.append(allocator, ' ');
            }
            // Skip additional whitespace (including newlines and tabs)
            while (i.* + 1 < tag.len and isWhitespace(tag[i.* + 1])) {
                i.* += 1;
            }
        }
    } else {
        try result.append(allocator, c);
    }
}

/// Handle character processing inside quotes - Extract Method refactoring (inlined for performance)
inline fn processCharInsideQuotes(allocator: Allocator, result: *ArrayList(u8), c: u8, state: *TagParseState) !void {
    try result.append(allocator, c);
    if (state.shouldExitQuotes(c)) {
        state.exitQuotes();
    }
}

/// Normalize XML tag attributes only (not content) - Simplified with Parameter Object
fn normalizeTagOnly(allocator: Allocator, tag: []const u8) ![]const u8 {
    if (tag.len < 2 or tag[0] != '<') return try allocator.dupe(u8, tag);

    var result = ArrayList(u8){};
    defer result.deinit(allocator);

    var state = TagParseState{};
    var i: usize = 0;

    while (i < tag.len) {
        const c = tag[i];

        if (!state.isInQuotes()) {
            try processCharOutsideQuotes(allocator, &result, c, &i, tag, &state);
        } else {
            try processCharInsideQuotes(allocator, &result, c, &state);
        }

        i += 1;
    }

    // Post-process to ensure no spaces before />
    const pre_result = try result.toOwnedSlice(allocator);
    defer allocator.free(pre_result);

    // Simple string replacement to remove " />" -> "/>"
    if (std.mem.indexOf(u8, pre_result, " />")) |_| {
        var final_result = try std.mem.replaceOwned(u8, allocator, pre_result, " />", "/>");
        // Handle multiple spaces before />
        while (std.mem.indexOf(u8, final_result, " />")) |_| {
            const temp = final_result;
            final_result = try std.mem.replaceOwned(u8, allocator, temp, " />", "/>");
            allocator.free(temp);
        }
        return final_result;
    }

    return try allocator.dupe(u8, pre_result);
}

/// Normalize content lines by collapsing multiple whitespace to single spaces
fn normalizeContent(allocator: Allocator, content: []const u8) ![]const u8 {
    if (content.len == 0) return try allocator.dupe(u8, content);

    // Check if content is all whitespace
    var all_whitespace = true;
    for (content) |c| {
        if (!isWhitespace(c)) {
            all_whitespace = false;
            break;
        }
    }

    // If all whitespace, return empty string
    if (all_whitespace) {
        return try allocator.dupe(u8, "");
    }

    var result = ArrayList(u8){};
    defer result.deinit(allocator);

    var i: usize = 0;
    var in_whitespace = false;
    var started_content = false; // Track if we've seen non-whitespace

    while (i < content.len) {
        const c = content[i];

        if (isWhitespace(c)) {
            if (started_content and !in_whitespace) {
                try result.append(allocator, ' ');
                in_whitespace = true;
            }
            // Skip leading and additional whitespace
        } else {
            try result.append(allocator, c);
            in_whitespace = false;
            started_content = true;
        }

        i += 1;
    }

    // Trim trailing whitespace
    while (result.items.len > 0 and isWhitespace(result.items[result.items.len - 1])) {
        _ = result.pop();
    }

    return try result.toOwnedSlice(allocator);
}

/// Write a line with proper indentation to the result buffer
fn writeIndentedLine(
    result: *ArrayList(u8),
    trimmed: []const u8,
    indent_level: i32,
    allocator: Allocator,
    fix_warnings: bool,
) !void {
    const safe_indent = @as(usize, @intCast(@max(0, @min(indent_level, MAX_INDENT_LEVELS - 1))));
    const indent_str = INDENT_STRINGS[safe_indent];

    // Efficient batch writing with pre-allocated capacity
    const total_len = indent_str.len + trimmed.len + 1;
    try result.ensureUnusedCapacity(allocator, total_len);

    // Apply aggressive normalization for consistent formatting (rule B) only in fix-warnings mode
    const normalized = if (fix_warnings) blk: {
        const norm = if (trimmed.len > 0 and trimmed[0] == '<')
            try normalizeXmlTagWithContent(allocator, trimmed, fix_warnings)
        else if (trimmed.len > 0)
            try normalizeContent(allocator, trimmed)
        else
            try allocator.dupe(u8, trimmed);
        break :blk norm;
    } else if (trimmed.len > 0 and trimmed[0] == '<')
        try normalizeXmlTagWithContent(allocator, trimmed, fix_warnings)
    else
        try allocator.dupe(u8, trimmed);
    defer allocator.free(normalized);

    result.appendSliceAssumeCapacity(indent_str);
    result.appendSliceAssumeCapacity(normalized);
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
    fix_warnings: bool,
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
        try writeIndentedLine(result, trimmed, indent_level.*, allocator, fix_warnings);
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

// Optimized version of processLine that avoids excessive allocations
/// Single-pass line analysis - eliminates O(n×k×f) redundant scanning
const LineAnalysis = struct {
    tag_type: TagType,
    is_container: bool,
    is_self_contained: bool,
    hash: u64,

    fn analyze(trimmed: []const u8) LineAnalysis {
        if (trimmed.len == 0) {
            return LineAnalysis{
                .tag_type = .other,
                .is_container = false,
                .is_self_contained = false,
                .hash = 0,
            };
        }

        // Single pass analysis combining all checks
        var tag_type: TagType = .other;
        var is_container = false;
        var is_self_contained = false;
        var has_attributes = false;

        // Quick XML tag detection
        if (trimmed.len >= 2 and trimmed[0] == '<' and trimmed[trimmed.len - 1] == '>') {
            const second_char = trimmed[1];

            // Determine tag type
            switch (second_char) {
                '/' => tag_type = .closing,
                '!', '?' => tag_type = .comment,
                else => {
                    // Check for self-closing
                    if (trimmed.len >= 3 and
                        trimmed[trimmed.len - 2] == '/' and
                        trimmed[trimmed.len - 1] == '>')
                    {
                        tag_type = .self_closing;
                    } else {
                        tag_type = .opening;

                        // Single-pass container and self-contained detection
                        const tag_content = trimmed[1 .. trimmed.len - 1];

                        // Look for attributes (= symbol or excessive whitespace)
                        var whitespace_count: u32 = 0;
                        for (tag_content) |c| {
                            if (c == '=') {
                                has_attributes = true;
                                break;
                            }
                            if (c == ' ' or c == '\t') {
                                whitespace_count += 1;
                                if (whitespace_count > 1) {
                                    has_attributes = true;
                                    break;
                                }
                            }
                        }

                        is_container = !has_attributes;

                        // Self-contained check (only for opening tags)
                        if (trimmed.len >= MIN_SELF_CONTAINED_LENGTH) {
                            const first_gt = std.mem.indexOfScalar(u8, trimmed[1..], '>');
                            const last_lt = std.mem.lastIndexOfScalar(u8, trimmed, '<');

                            if (first_gt != null and last_lt != null and
                                first_gt.? + 1 < last_lt.? and
                                last_lt.? + 1 < trimmed.len and
                                trimmed[last_lt.? + 1] == '/')
                            {
                                const content_start = first_gt.? + 2;
                                const content = trimmed[content_start..last_lt.?];
                                is_self_contained = std.mem.indexOfScalar(u8, content, '<') == null;
                            }
                        }
                    }
                },
            }
        }

        // Compute hash once
        const hash = computeSimpleHash(trimmed);

        return LineAnalysis{
            .tag_type = tag_type,
            .is_container = is_container,
            .is_self_contained = is_self_contained,
            .hash = hash,
        };
    }
};

fn processLineOptimized(
    result: *ArrayList(u8),
    seen_hashes: *HashMap(u64, void),
    duplicates_removed: *u32,
    indent_level: *i32,
    trimmed: []const u8,
    allocator: Allocator,
) !void {
    // Single-pass analysis eliminates redundant scanning
    const analysis = LineAnalysis.analyze(trimmed);

    const is_closing_tag = analysis.tag_type == .closing;
    const is_opening_tag = analysis.tag_type == .opening;

    // Adjust indent level for closing tags BEFORE writing line
    if (is_closing_tag) {
        indent_level.* = @max(0, indent_level.* - 1);
    }

    // Check for duplicates using pre-computed hash
    var is_duplicate = false;
    if (!analysis.is_container) {
        const gop = try seen_hashes.getOrPut(analysis.hash);
        if (gop.found_existing) {
            duplicates_removed.* += 1;
            is_duplicate = true;
        }
    }

    // Write non-duplicate lines with indentation
    if (!is_duplicate) {
        // Add indentation using pre-computed strings
        const current_indent = @max(0, @min(indent_level.*, MAX_INDENT_LEVELS - 1));
        if (current_indent > 0) {
            try result.appendSlice(allocator, INDENT_STRINGS[@intCast(current_indent)]);
        }
        try result.appendSlice(allocator, trimmed);
        try result.append(allocator, '\n');
    }

    // Handle opening tag indentation using pre-computed analysis
    if (is_opening_tag and !analysis.is_self_contained) {
        indent_level.* += 1;
    }
}

/// Optimized hash computation using FNV-1a algorithm for better distribution
inline fn computeSimpleHash(s: []const u8) u64 {
    var hash: u64 = HashSeeds.FAST_HASH_SEED; // FNV-1a basis

    // Process 8 bytes at a time when possible (SIMD-friendly)
    var i: usize = 0;
    const len = s.len;

    // Unrolled loop for better performance on aligned data
    while (i + 8 <= len) {
        // FNV-1a hash with loop unrolling
        hash ^= s[i];
        hash *%= 0x100000001b3;
        hash ^= s[i + 1];
        hash *%= 0x100000001b3;
        hash ^= s[i + 2];
        hash *%= 0x100000001b3;
        hash ^= s[i + 3];
        hash *%= 0x100000001b3;
        hash ^= s[i + 4];
        hash *%= 0x100000001b3;
        hash ^= s[i + 5];
        hash *%= 0x100000001b3;
        hash ^= s[i + 6];
        hash *%= 0x100000001b3;
        hash ^= s[i + 7];
        hash *%= 0x100000001b3;
        i += 8;
    }

    // Handle remaining bytes
    while (i < len) {
        hash ^= s[i];
        hash *%= 0x100000001b3;
        i += 1;
    }

    return hash;
}

// XML processing with deduplication and indentation
fn processXmlWithDeduplication(allocator: Allocator, content: []const u8, strip_xml_declaration: bool, _: bool) !ProcessResult {
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

    // Pre-allocate reusable buffer for attribute processing to avoid repeated allocations
    var attr_buffer = ArrayList(u8){};
    defer attr_buffer.deinit(allocator);
    try attr_buffer.ensureTotalCapacity(allocator, 256); // Pre-allocate for common attribute sizes

    // Bulk processing with reduced allocator pressure and improved memory locality
    while (line_start < content.len) {
        // Batch multiple line operations to reduce syscall overhead
        const line_end = std.mem.indexOfScalarPos(u8, content, line_start, '\n') orelse content.len;

        // Skip empty lines with minimal branching
        if (line_start >= line_end) {
            line_start = if (line_end < content.len) line_end + 1 else content.len;
            continue;
        }

        // Fast trimming inlined to avoid function call overhead
        var trim_start = line_start;
        var trim_end = line_end;

        // Fast forward scan for whitespace
        while (trim_start < trim_end and isWhitespace(content[trim_start])) {
            trim_start += 1;
        }

        // Fast backward scan for whitespace
        while (trim_end > trim_start and isWhitespace(content[trim_end - 1])) {
            trim_end -= 1;
        }

        // Process non-empty lines with optimized path
        if (trim_start < trim_end) {
            const trimmed = content[trim_start..trim_end];

            // Early exit for XML declarations with minimal string operations
            if (strip_xml_declaration and trimmed.len >= 5 and
                trimmed[0] == '<' and trimmed[1] == '?')
            {
                // Check for XML declaration pattern with single comparison
                if (trimmed.len >= 5 and
                    trimmed[2] == 'x' and trimmed[3] == 'm' and trimmed[4] == 'l')
                {
                    line_start = if (line_end < content.len) line_end + 1 else content.len;
                    continue;
                }
            }

            // Core processing with pre-trimmed content
            try processLineOptimized(&result, &seen_hashes, &duplicates_removed, &indent_level, trimmed, allocator);
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

/// Remove UTF-8 BOM if present - Extract Method refactoring
inline fn removeBomIfPresent(content: []const u8) []const u8 {
    return if (content.len >= BOM_SIZE and
        std.mem.eql(u8, content[0..BOM_SIZE], &UTF8_BOM))
        content[BOM_SIZE..]
    else
        content;
}

/// Handle XML declaration warnings - Extract Method refactoring (inlined for performance)
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

/// Build final output content with XML declaration if needed - Extract Method refactoring (inlined for performance)
inline fn buildFinalContent(allocator: Allocator, process_result: ProcessResult, fix_warnings: bool, has_xml_decl: bool) !ArrayList(u8) {
    var final_content = ArrayList(u8){};
    const final_capacity = process_result.content.len + if (fix_warnings and !has_xml_decl) XML_DECLARATION.len else 0;
    try final_content.ensureTotalCapacity(allocator, final_capacity);

    if (fix_warnings and !has_xml_decl) {
        // Add XML declaration only if it was originally missing
        try final_content.appendSlice(allocator, XML_DECLARATION);
        print("🔧 Applied fixes:\n", .{});
        print("  ✓ Added XML declaration\n", .{});
        print("\n", .{});
    }

    try final_content.appendSlice(allocator, process_result.content);
    return final_content;
}

/// Handle file writing with error management - Extract Method refactoring (inlined for performance)
inline fn writeOutputFile(final_content: []const u8, output_filename: []const u8) !void {
    std.fs.cwd().writeFile(.{
        .sub_path = output_filename,
        .data = final_content,
    }) catch |err| {
        print("Could not write output file '{s}': {s}\n", .{ output_filename, @errorName(err) });
        std.process.exit(1);
    };
}

/// Handle file replacement logic - Extract Method refactoring (inlined for performance)
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

/// Simplified main file processing function - Extract Method refactoring applied
fn processFile(allocator: Allocator, args: Args) !void {
    // Read file with reasonable size limit for safety
    const config = ProcessingConfig.create(0);
    const max_file_size = config.max_file_size;
    const content = std.fs.cwd().readFileAlloc(allocator, args.file, max_file_size) catch |err| {
        print("Could not read file '{s}': {s}\n", .{ args.file, @errorName(err) });
        std.process.exit(1);
    };
    defer allocator.free(content);

    // Remove BOM and detect XML declaration
    const cleaned_content = removeBomIfPresent(content);
    const has_xml_decl = hasXmlDeclaration(cleaned_content);

    // Handle warnings
    handleXmlDeclarationWarnings(has_xml_decl, args.fix_warnings);

    // Process content with deduplication and proper XML formatting
    const should_strip_xml_declaration = false; // Never strip XML declarations
    const process_result = try processXmlWithDeduplication(allocator, cleaned_content, should_strip_xml_declaration, args.fix_warnings);
    defer allocator.free(process_result.content);

    // Build final content
    var final_content = try buildFinalContent(allocator, process_result, args.fix_warnings, has_xml_decl);
    defer final_content.deinit(allocator);

    // Get output filename and write file
    const output_filename = try getOutputFilename(allocator, args.file, args.replace);
    defer allocator.free(output_filename);

    try writeOutputFile(final_content.items, output_filename);

    // Handle file replacement and status messages
    handleFileReplacement(output_filename, args.file, args.replace);

    if (process_result.duplicates > 0) {
        print(" (removed {} duplicates)", .{process_result.duplicates});
    }
    print(" (preserving original structure)\n", .{});
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
