const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const HashMap = std.HashMap;

const USAGE = "Usage: fixml [--organize] [--replace] [--fix-warnings] <xml-file>\n" ++
    "  --organize, -o      Apply logical organization\n" ++
    "  --replace, -r       Replace original file\n" ++
    "  --fix-warnings, -f  Fix XML warnings\n" ++
    "  Default: preserve original structure, fix indentation/deduplication only\n";

const XML_DECLARATION = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";

const Args = struct {
    organize: bool = false,
    replace: bool = false,
    fix_warnings: bool = false,
    file: []const u8 = "",
};

fn parseArgs(allocator: std.mem.Allocator) !Args {
    const args_slice = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args_slice);

    var parsed = Args{};
    var file_set = false;

    for (args_slice[1..]) |arg| {
        if (std.mem.eql(u8, arg, "--organize") or std.mem.eql(u8, arg, "-o")) {
            parsed.organize = true;
        } else if (std.mem.eql(u8, arg, "--replace") or std.mem.eql(u8, arg, "-r")) {
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

// Fast container element detection with common pattern optimization
fn isContainerElement(s: []const u8) bool {
    const trimmed = std.mem.trim(u8, s, " \t\r\n");
    if (trimmed.len < 3 or trimmed[0] != '<' or trimmed[trimmed.len - 1] != '>') return false;

    const inner = if (trimmed.len > 2 and trimmed[1] == '/')
        // Closing tag: </tag>
        trimmed[2 .. trimmed.len - 1]
        // Opening tag: <tag>
    else
        trimmed[1 .. trimmed.len - 1];

    return isValidTagNameFast(inner);
}

// Fast tag name validation with lookup table
const VALID_TAG_CHARS = blk: {
    var chars = [_]bool{false} ** 256;
    // a-z
    for ('a'..('z' + 1)) |c| chars[c] = true;
    // A-Z
    for ('A'..('Z' + 1)) |c| chars[c] = true;
    // 0-9
    for ('0'..('9' + 1)) |c| chars[c] = true;
    // Special chars
    chars[':'] = true;
    chars['-'] = true;
    chars['.'] = true;
    break :blk chars;
};

fn isValidTagNameFast(s: []const u8) bool {
    if (s.len == 0) return false;
    for (s) |c| {
        if (!VALID_TAG_CHARS[c]) return false;
    }
    return true;
}

// Check if element is self-contained like <tag>content</tag>
// Matches Go regex: ^<[^>]+>[^<]*</[^>]+>$
fn isSelfContained(s: []const u8) bool {
    const trimmed = std.mem.trim(u8, s, " \t\r\n");
    if (trimmed.len < 7) return false; // minimum: <a>x</a>

    // Must start with < and end with >
    if (trimmed[0] != '<' or trimmed[trimmed.len - 1] != '>') return false;

    // Find first > and last <
    var first_gt: ?usize = null;
    var last_lt: ?usize = null;

    for (trimmed, 0..) |c, i| {
        if (c == '>' and first_gt == null) {
            first_gt = i;
        }
        if (c == '<' and i > 0) { // Skip the initial <
            last_lt = i;
        }
    }

    if (first_gt == null or last_lt == null) return false;
    if (first_gt.? >= last_lt.?) return false;

    // Check that closing tag starts with </
    if (last_lt.? + 1 >= trimmed.len or trimmed[last_lt.? + 1] != '/') return false;

    // Check that content between tags contains no <
    const content = trimmed[first_gt.? + 1 .. last_lt.?];
    for (content) |c| {
        if (c == '<') return false;
    }

    return true;
}

// Fast hash-based normalization without string allocation
fn hashNormalizedContent(s: []const u8) u64 {
    const trimmed = std.mem.trim(u8, s, " \t\r\n");
    if (trimmed.len == 0) return 0;

    var hasher = std.hash.Wyhash.init(0);
    var in_quotes = false;
    var quote_char: u8 = 0;
    var prev_space = false;

    for (trimmed) |c| {
        if (!in_quotes and (c == '"' or c == '\'')) {
            in_quotes = true;
            quote_char = c;
            hasher.update(&[_]u8{c});
            prev_space = false;
        } else if (in_quotes and c == quote_char) {
            in_quotes = false;
            hasher.update(&[_]u8{c});
            prev_space = false;
        } else if (in_quotes) {
            // Inside quotes: preserve all whitespace
            hasher.update(&[_]u8{c});
            prev_space = false;
        } else if (c == ' ' or c == '\t' or c == '\n' or c == '\r') {
            // Outside quotes: normalize whitespace
            if (!prev_space) {
                hasher.update(&[_]u8{' '});
                prev_space = true;
            }
        } else {
            hasher.update(&[_]u8{c});
            prev_space = false;
        }
    }

    return hasher.final();
}

// XML processing with deduplication and indentation
fn processXmlWithDeduplication(allocator: std.mem.Allocator, content: []const u8) !struct { content: []u8, duplicates: u32 } {
    if (content.len == 0) {
        return .{ .content = try allocator.dupe(u8, content), .duplicates = 0 };
    }

    var result = std.ArrayList(u8){};
    defer result.deinit(allocator);
    try result.ensureTotalCapacity(allocator, content.len + 1024); // Pre-allocate with buffer

    var seen_hashes = std.AutoHashMap(u64, void).init(allocator);
    try seen_hashes.ensureTotalCapacity(256); // Pre-allocate hash map
    defer seen_hashes.deinit();

    var duplicates_removed: u32 = 0;
    var indent_level: i32 = 0;

    // Single-pass processing with inline line handling
    var i: usize = 0;
    var line_start: usize = 0;
    const indent_spaces = "                                        "; // 40 spaces max

    while (i <= content.len) : (i += 1) {
        if (i != content.len and content[i] != '\n') continue;

        if (i <= line_start) {
            line_start = i + 1;
            continue;
        }

        const line = content[line_start..i];
        const trimmed = std.mem.trim(u8, line, " \t\r\n");

        // XML-agnostic container detection
        const is_container = isContainerElement(trimmed);

        // Fast hash-based deduplication
        var should_skip = false;
        if (!is_container) {
            const content_hash = hashNormalizedContent(trimmed);
            if (seen_hashes.contains(content_hash)) {
                duplicates_removed += 1;
                should_skip = true;
            } else {
                try seen_hashes.put(content_hash, {});
            }
        }

        if (should_skip) {
            line_start = i + 1;
            continue;
        }

        // Fast tag type detection
        const first_char = trimmed[0];
        const second_char = if (trimmed.len > 1) trimmed[1] else 0;
        const is_closing_tag = first_char == '<' and second_char == '/';
        const is_opening_tag = first_char == '<' and second_char != '/' and
            second_char != '!' and second_char != '?' and
            !std.mem.endsWith(u8, trimmed, "/>");

        // Adjust indent level for closing tags BEFORE writing line
        if (is_closing_tag) {
            indent_level = @max(0, indent_level - 1);
        }

        // Apply indentation using bulk operations
        const spaces_needed = @as(usize, @intCast(indent_level * 2));
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

        // Adjust indent level for opening tags AFTER writing line
        if (is_opening_tag and !isSelfContained(trimmed)) {
            indent_level += 1;
        }
        line_start = i + 1;
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

    // Early XML declaration detection
    const has_xml_decl = hasXmlDeclaration(content);

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
    const process_result = try processXmlWithDeduplication(allocator, content);
    defer allocator.free(process_result.content);

    // Build final content with minimal allocations
    var final_content = std.ArrayList(u8){};
    defer final_content.deinit(allocator);

    const final_capacity = process_result.content.len + if (args.fix_warnings and !has_xml_decl) XML_DECLARATION.len else 0;
    try final_content.ensureTotalCapacity(allocator, final_capacity);

    if (args.fix_warnings and !has_xml_decl) {
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

    const mode_text = if (args.organize)
        " (with logical organization)"
    else
        " (preserving original structure)";

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
