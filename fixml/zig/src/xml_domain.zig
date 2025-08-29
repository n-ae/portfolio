//! XML Processing Domain Module
//! 
//! Encapsulates all XML-specific knowledge and operations following Domain-Driven Design.
//! Implements Martin Fowler's Extract Module refactoring to separate XML concerns.

const std = @import("std");

/// XML Processing Domain - encapsulates XML-specific knowledge
pub const XmlDomain = struct {
    pub const DECLARATION = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
    pub const DECL_MIN_LENGTH = 5;
    pub const DECL_PREFIX = "<?xml";
    pub const MAX_NESTING_DEPTH = 64;
    pub const BOM: [3]u8 = .{ 0xEF, 0xBB, 0xBF };
    pub const BOM_SIZE = 3;
    
    /// Check if a line contains an XML declaration
    pub fn isDeclarationLine(line: []const u8) bool {
        return line.len >= DECL_MIN_LENGTH and
               line[0] == '<' and line[1] == '?' and
               std.mem.startsWith(u8, line, DECL_PREFIX);
    }
    
    /// Remove UTF-8 BOM if present at start of content
    pub fn removeBomIfPresent(content: []const u8) []const u8 {
        return if (content.len >= BOM_SIZE and
            std.mem.eql(u8, content[0..BOM_SIZE], &BOM))
            content[BOM_SIZE..]
        else
            content;
    }
    
    /// Check if content has XML declaration in first few lines
    pub fn hasXmlDeclaration(content: []const u8, check_limit: usize) bool {
        const limit = @min(content.len, check_limit);
        const slice = content[0..limit];
        
        var i: usize = 0;
        while (i + 5 <= slice.len) {
            if (isDeclarationLine(slice[i..])) {
                return true;
            }
            // Skip to next line
            if (std.mem.indexOfScalarPos(u8, slice, i, '\n')) |newline| {
                i = newline + 1;
            } else {
                break;
            }
        }
        return false;
    }
};

/// XML tag classification for processing
pub const TagType = enum {
    opening,
    closing,
    self_closing,
    comment,
    other,
};

/// XML attribute structure for parsing
pub const Attribute = struct {
    name: []const u8,
    value: []const u8,
};

/// XML tag type classification with pattern matching
pub fn getTagType(trimmed: []const u8) TagType {
    if (trimmed.len < 2 or trimmed[0] != '<') return .other;

    const second_char = trimmed[1];
    switch (second_char) {
        '/' => return .closing,
        '!', '?' => return .comment,
        else => {},
    }

    // Fast self-closing detection
    if (trimmed.len >= 3 and
        trimmed[trimmed.len - 2] == '/' and
        trimmed[trimmed.len - 1] == '>')
    {
        return .self_closing;
    }

    return .opening;
}

/// Check if tag is a simple container (no attributes)
pub fn isSimpleContainer(trimmed: []const u8) bool {
    if (trimmed.len <= 2 or trimmed[0] != '<' or trimmed[trimmed.len - 1] != '>') return false;
    if (trimmed[trimmed.len - 2] == '/') return false; // Self-closing

    const tag_content = trimmed[1 .. trimmed.len - 1];
    return std.mem.indexOf(u8, tag_content, "=") == null;
}

/// Extract tag name from XML tag
pub fn extractTagName(tag: []const u8) []const u8 {
    if (tag.len < 2 or tag[0] != '<') return tag;

    const start = if (tag[1] == '/') @as(usize, 2) else @as(usize, 1);
    if (start >= tag.len) return tag[start..start];

    var end = start;
    while (end < tag.len) {
        const char = tag[end];
        if (char == ' ' or char == '>' or char == '\t' or char == '/' or char == '=') break;
        end += 1;
    }

    return tag[start..end];
}

/// Detect self-contained XML elements: <tag>content</tag>
pub fn isSelfContained(s: []const u8) bool {
    const MIN_SELF_CONTAINED_LENGTH = 5;
    
    if (s.len < MIN_SELF_CONTAINED_LENGTH) return false;
    if (s[0] != '<' or s[s.len - 1] != '>') return false;

    // Find opening and closing tag positions
    const first_gt = std.mem.indexOfScalar(u8, s[1..], '>') orelse return false;
    const last_lt = std.mem.lastIndexOfScalar(u8, s, '<') orelse return false;

    // Verify proper tag structure
    if (first_gt + 1 >= last_lt or
        last_lt + 1 >= s.len or
        s[last_lt + 1] != '/') return false;

    // Ensure no nested tags in content
    const content_start = first_gt + 2;
    const content = s[content_start..last_lt];
    return std.mem.indexOfScalar(u8, content, '<') == null;
}

/// Validate XML tag boundaries
pub fn isValidXmlTag(s: []const u8) bool {
    return s.len >= 2 and s[0] == '<' and s[s.len - 1] == '>';
}