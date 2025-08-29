//! Character Classification Domain Module
//!
//! High-performance character classification using bit manipulation and lookup tables.
//! Optimized for XML parsing with comptime-generated masks for O(1) classification.

/// Character Classification Domain - encapsulates character-based operations
pub const CharacterDomain = struct {
    pub const ASCII_CONTROL_CHAR_MAX = 31;
    pub const WHITESPACE_THRESHOLD = 32;
    
    // Comptime-optimized whitespace detection using bit manipulation
    pub const WHITESPACE_MASK = blk: {
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
    
    pub const XML_SPECIAL_MASK = blk: {
        var mask: u256 = 0;
        mask |= (@as(u256, 1) << '/'); // Closing tags
        mask |= (@as(u256, 1) << '!'); // Comments/CDATA
        mask |= (@as(u256, 1) << '?'); // Processing instructions
        break :blk mask;
    };
    
    pub const XML_DELIMITER_MASK = blk: {
        var mask: u256 = 0;
        mask |= (@as(u256, 1) << '='); // Attribute assignment
        mask |= (@as(u256, 1) << '"'); // Double quotes
        mask |= (@as(u256, 1) << '\''); // Single quotes
        mask |= (@as(u256, 1) << '>'); // Tag end
        mask |= (@as(u256, 1) << '/'); // Self-closing
        break :blk mask;
    };
    
    /// Ultra-fast whitespace detection using bit manipulation
    pub inline fn isWhitespace(c: u8) bool {
        return (WHITESPACE_MASK >> c) & 1 != 0;
    }
    
    /// Fast XML special character detection
    pub inline fn isXmlSpecial(c: u8) bool {
        return (XML_SPECIAL_MASK >> c) & 1 != 0;
    }
    
    /// Fast XML delimiter detection
    pub inline fn isXmlDelimiter(c: u8) bool {
        return (XML_DELIMITER_MASK >> c) & 1 != 0;
    }
    
    /// Check if character is valid for XML identifiers
    pub inline fn isValidXmlIdentifier(c: u8) bool {
        return !isWhitespace(c) and c != '>' and c != '/' and c != '=' and c != '"' and c != '\'';
    }
    
    /// Check if character can start an XML Name per XML specification
    pub inline fn isXmlNameStartChar(c: u8) bool {
        return (c >= 'A' and c <= 'Z') or
            (c >= 'a' and c <= 'z') or
            c == '_' or c == ':' or
            c >= 0xC0; // Basic Unicode support
    }

    /// Check if character can continue an XML Name per XML specification
    pub inline fn isXmlNameChar(c: u8) bool {
        return isXmlNameStartChar(c) or
            (c >= '0' and c <= '9') or
            c == '-' or c == '.' or
            c == 0xB7; // Middle dot
    }
};

/// Vectorized whitespace detection for large strings
pub fn hasWhitespaceInSlice(slice: []const u8) bool {
    if (slice.len == 0) return false;

    // Fast path for short strings
    if (slice.len <= 8) {
        for (slice) |byte| {
            if (CharacterDomain.isWhitespace(byte)) return true;
        }
        return false;
    }

    const CHUNK_SIZE = 8;
    const BITS_PER_BYTE = 8;
    var i: usize = 0;

    // Process 8-byte chunks with bit operations
    while (i + CHUNK_SIZE <= slice.len) {
        const chunk_bytes = slice[i .. i + CHUNK_SIZE];
        const chunk_u64 = std.mem.readInt(u64, @ptrCast(chunk_bytes), .little);

        // Unrolled byte extraction
        comptime var shift = 0;
        inline while (shift < 64) : (shift += BITS_PER_BYTE) {
            const byte = @as(u8, @truncate(chunk_u64 >> shift));
            if ((CharacterDomain.WHITESPACE_MASK >> byte) & 1 != 0) return true;
        }
        i += CHUNK_SIZE;
    }

    // Handle remaining bytes
    while (i < slice.len) : (i += 1) {
        if (CharacterDomain.isWhitespace(slice[i])) return true;
    }

    return false;
}

const std = @import("std");