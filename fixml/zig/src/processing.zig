//! XML Processing Module
//!
//! Core XML processing logic with line-by-line processing, trimming, and deduplication.
//! Implements Martin Fowler's Extract Method and Parameter Object patterns.

const std = @import("std");
const xml_domain = @import("xml_domain.zig");
const character_domain = @import("character_domain.zig");
const hash_command = @import("hash_command.zig");

const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const HashMap = std.AutoHashMap;
const XmlDomain = xml_domain.XmlDomain;
const CharacterDomain = character_domain.CharacterDomain;
const HashCommand = hash_command.HashCommand;

/// Processing context to eliminate data clumps - Parameter Object refactoring
pub const ProcessingContext = struct {
    allocator: Allocator,
    result: *ArrayList(u8),
    seen_hashes: *HashMap(u64, void),
    duplicates_removed: *u32,
    indent_level: *i32,
    strip_xml_declaration: bool,
};

/// Line boundaries for trimming operations - Replace Data Value with Object
pub const LineBounds = struct {
    start: usize,
    end: usize,
    
    pub fn fromRange(line_start: usize, line_end: usize) LineBounds {
        return LineBounds{ .start = line_start, .end = line_end };
    }
    
    pub fn isEmpty(self: LineBounds) bool {
        return self.start >= self.end;
    }
    
    pub fn length(self: LineBounds) usize {
        return if (self.end > self.start) self.end - self.start else 0;
    }
};

/// Processing result containing content and statistics
pub const ProcessResult = struct {
    content: []u8,
    duplicates: u32,
};

/// Extract trimming logic - Extract Method refactoring  
pub fn fastTrimLine(content: []const u8, bounds: LineBounds) LineBounds {
    if (bounds.isEmpty()) return bounds;
    
    var trim_start = bounds.start;
    var trim_end = bounds.end;
    
    // Fast forward scan with unrolled loop
    const chunk_size = 4;
    while (trim_start + chunk_size <= trim_end) {
        const chunk = content[trim_start .. trim_start + chunk_size];
        if (!CharacterDomain.isWhitespace(chunk[0])) break;
        if (!CharacterDomain.isWhitespace(chunk[1])) { trim_start += 1; break; }
        if (!CharacterDomain.isWhitespace(chunk[2])) { trim_start += 2; break; }
        if (!CharacterDomain.isWhitespace(chunk[3])) { trim_start += 3; break; }
        trim_start += chunk_size;
    }
    
    // Handle remaining forward bytes
    while (trim_start < trim_end and CharacterDomain.isWhitespace(content[trim_start])) {
        trim_start += 1;
    }
    
    // Fast backward scan with unrolled loop
    while (trim_end > trim_start + chunk_size) {
        if (!CharacterDomain.isWhitespace(content[trim_end - 1])) break;
        if (!CharacterDomain.isWhitespace(content[trim_end - 2])) { trim_end -= 1; break; }
        if (!CharacterDomain.isWhitespace(content[trim_end - 3])) { trim_end -= 2; break; }
        if (!CharacterDomain.isWhitespace(content[trim_end - 4])) { trim_end -= 3; break; }
        trim_end -= chunk_size;
    }
    
    // Handle remaining backward bytes  
    while (trim_end > trim_start and CharacterDomain.isWhitespace(content[trim_end - 1])) {
        trim_end -= 1;
    }
    
    return LineBounds{ .start = trim_start, .end = trim_end };
}

/// Process single line in context - Extract Method refactoring
pub fn processLineInContext(context: ProcessingContext, content: []const u8, bounds: LineBounds) !void {
    const trimmed = content[bounds.start..bounds.end];
    
    // Guard Clause refactoring - early return for XML declarations
    if (context.strip_xml_declaration and XmlDomain.isDeclarationLine(trimmed)) {
        return; // Skip XML declaration
    }
    
    // Delegate to optimized line processor
    try processLineOptimized(
        context.result,
        context.seen_hashes,
        context.duplicates_removed,
        context.indent_level,
        trimmed,
        context.allocator
    );
}

/// Line iteration logic - Extract Method refactoring  
pub fn processAllLines(context: ProcessingContext, content: []const u8) !void {
    var line_start: usize = 0;
    
    while (line_start < content.len) {
        const line_end = std.mem.indexOfScalarPos(u8, content, line_start, '\n') orelse content.len;
        const raw_bounds = LineBounds.fromRange(line_start, line_end);
        
        // Guard Clause - skip empty lines
        if (raw_bounds.isEmpty()) {
            line_start = if (line_end < content.len) line_end + 1 else content.len;
            continue;
        }
        
        const trimmed_bounds = fastTrimLine(content, raw_bounds);
        
        // Guard Clause - skip whitespace-only lines
        if (!trimmed_bounds.isEmpty()) {
            try processLineInContext(context, content, trimmed_bounds);
        }
        
        line_start = if (line_end < content.len) line_end + 1 else content.len;
    }
}

/// Optimized line processing with single-pass analysis
fn processLineOptimized(
    result: *ArrayList(u8),
    seen_hashes: *HashMap(u64, void),
    duplicates_removed: *u32,
    indent_level: *i32,
    trimmed: []const u8,
    allocator: Allocator,
) !void {
    // Single-pass analysis
    const analysis = analyzeXmlLine(trimmed);
    
    const is_closing_tag = analysis.tag_type == xml_domain.TagType.closing;
    const is_opening_tag = analysis.tag_type == xml_domain.TagType.opening;
    
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
        try writeIndentedLine(result, trimmed, indent_level.*, allocator);
    }
    
    // Handle opening tag indentation using pre-computed analysis
    if (is_opening_tag and !analysis.is_self_contained) {
        indent_level.* += 1;
    }
}

/// Single-pass line analysis - eliminates redundant scanning
const LineAnalysis = struct {
    tag_type: xml_domain.TagType,
    is_container: bool,
    is_self_contained: bool,
    hash: u64,
};

fn analyzeXmlLine(trimmed: []const u8) LineAnalysis {
    var result = LineAnalysis{
        .tag_type = .other,
        .is_container = false,
        .is_self_contained = false,
        .hash = 0,
    };
    
    if (trimmed.len == 0) return result;
    result.hash = hash_command.computeSimpleHash(trimmed);
    
    // Use domain functions
    result.tag_type = xml_domain.getTagType(trimmed);
    result.is_container = xml_domain.isSimpleContainer(trimmed);
    result.is_self_contained = xml_domain.isSelfContained(trimmed);
    
    return result;
}

/// Write line with proper indentation
fn writeIndentedLine(
    result: *ArrayList(u8),
    trimmed: []const u8,
    indent_level: i32,
    allocator: Allocator,
) !void {
    const safe_indent = @as(usize, @intCast(@max(0, @min(indent_level, XmlDomain.MAX_NESTING_DEPTH - 1))));
    
    // Add indentation spaces (2 spaces per level)
    const indent_spaces = safe_indent * 2;
    var i: usize = 0;
    while (i < indent_spaces) : (i += 1) {
        try result.append(allocator, ' ');
    }
    
    // Add content and newline
    try result.appendSlice(allocator, trimmed);
    try result.append(allocator, '\n');
}