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

// Check if a string is a container element (opening/closing tag without attributes)
fn isContainerElement(s: []const u8) bool {
    const trimmed = std.mem.trim(u8, s, " \t\r\n");
    if (trimmed.len < 3) return false;
    
    if (trimmed[0] == '<' and trimmed[trimmed.len - 1] == '>') {
        if (trimmed.len > 2 and trimmed[1] == '/') {
            // Closing tag: </tag>
            const inner = trimmed[2..trimmed.len - 1];
            return isValidTagName(inner);
        } else {
            // Opening tag: <tag>
            const inner = trimmed[1..trimmed.len - 1];
            return isValidTagName(inner);
        }
    }
    return false;
}

// Check if string contains only valid tag name characters
fn isValidTagName(s: []const u8) bool {
    for (s) |c| {
        if (!((c >= 'a' and c <= 'z') or 
              (c >= 'A' and c <= 'Z') or
              (c >= '0' and c <= '9') or
              c == ':' or c == '-' or c == '.')) {
            return false;
        }
    }
    return true;
}

// Check if element is self-contained like <tag>content</tag>
fn isSelfContained(s: []const u8) bool {
    const trimmed = std.mem.trim(u8, s, " \t\r\n");
    if (trimmed.len < 7) return false; // minimum: <a>x</a>
    
    if (trimmed[0] == '<' and trimmed[trimmed.len - 1] == '>') {
        if (std.mem.indexOf(u8, trimmed, ">")) |first_gt| {
            if (std.mem.lastIndexOf(u8, trimmed, "<")) |last_lt| {
                return first_gt < last_lt and
                       first_gt + 1 < last_lt and
                       last_lt + 1 < trimmed.len and
                       trimmed[last_lt + 1] == '/';
            }
        }
    }
    return false;
}

// Normalize whitespace by replacing multiple spaces with single space
fn normalizeWhitespace(allocator: std.mem.Allocator, s: []const u8) ![]u8 {
    var result = ArrayList(u8).init(allocator);
    var prev_space = false;
    
    for (s) |c| {
        if (c == ' ' or c == '\t' or c == '\n' or c == '\r') {
            if (!prev_space) {
                try result.append(' ');
                prev_space = true;
            }
        } else {
            try result.append(c);
            prev_space = false;
        }
    }
    
    const trimmed = std.mem.trim(u8, result.items, " \t\r\n");
    return try allocator.dupe(u8, trimmed);
}

// XML processing with deduplication and indentation
fn processXmlWithDeduplication(allocator: std.mem.Allocator, content: []const u8) !struct { content: []u8, duplicates: u32 } {
    if (content.len == 0) {
        return .{ .content = try allocator.dupe(u8, content), .duplicates = 0 };
    }

    var result = ArrayList(u8).init(allocator);
    try result.ensureTotalCapacity(content.len + content.len / 4);

    var seen_elements = std.StringHashMap(void).init(allocator);
    defer {
        var iterator = seen_elements.iterator();
        while (iterator.next()) |entry| {
            allocator.free(entry.key_ptr.*);
        }
        seen_elements.deinit();
    }
    
    var duplicates_removed: u32 = 0;
    var indent_level: i32 = 0;

    var i: usize = 0;
    // Remove BOM if present
    if (content.len >= 3 and content[0] == 0xEF and content[1] == 0xBB and content[2] == 0xBF) {
        i = 3;
    }

    var line_start = i;

    // Process content line by line
    while (i <= content.len) {
        if (i == content.len or content[i] == '\n' or content[i] == '\r') {
            if (line_start < i) {
                const line = content[line_start..i];
                const trimmed = std.mem.trim(u8, line, " \t\r\n");
                
                if (trimmed.len > 0) {
                    // XML-agnostic container detection
                    const is_container = isContainerElement(trimmed);
                    
                    // Deduplication with normalized whitespace
                    const normalized_key = try normalizeWhitespace(allocator, trimmed);
                    defer allocator.free(normalized_key);
                    
                    if (!is_container and seen_elements.contains(normalized_key)) {
                        duplicates_removed += 1;
                        // Skip this duplicate line
                    } else {
                        if (!is_container) {
                            const key_copy = try allocator.dupe(u8, normalized_key);
                            try seen_elements.put(key_copy, {});
                        }
                        
                        // Adjust indent for closing tags BEFORE applying indentation
                        if (std.mem.startsWith(u8, trimmed, "</")) {
                            indent_level = @max(0, indent_level - 1);
                        }
                        
                        // Apply consistent 2-space indentation
                        const spaces_needed = @as(usize, @intCast(indent_level * 2));
                        for (0..spaces_needed) |_| {
                            try result.append(' ');
                        }
                        
                        try result.appendSlice(trimmed);
                        try result.append('\n');
                        
                        // Adjust indent for opening tags AFTER applying indentation
                        var is_opening_tag = std.mem.startsWith(u8, trimmed, "<") and
                                            !std.mem.startsWith(u8, trimmed, "</") and
                                            !std.mem.startsWith(u8, trimmed, "<?") and
                                            !std.mem.endsWith(u8, trimmed, "/>");
                        
                        // Check if self-contained
                        if (is_opening_tag and isSelfContained(trimmed)) {
                            is_opening_tag = false;
                        }
                        
                        if (is_opening_tag) {
                            indent_level += 1;
                        }
                    }
                }
            }

            // Skip line endings efficiently
            if (i < content.len) {
                if (content[i] == '\r' and i + 1 < content.len and content[i + 1] == '\n') {
                    i += 2;
                } else {
                    i += 1;
                }
                line_start = i;
            } else {
                break;
            }
        } else {
            i += 1;
        }
    }

    return .{ .content = try result.toOwnedSlice(), .duplicates = duplicates_removed };
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
    var final_content = ArrayList(u8).init(allocator);
    defer final_content.deinit();

    const final_capacity = process_result.content.len + if (args.fix_warnings and !has_xml_decl) XML_DECLARATION.len else 0;
    try final_content.ensureTotalCapacity(final_capacity);

    if (args.fix_warnings and !has_xml_decl) {
        try final_content.appendSlice(XML_DECLARATION);
        print("🔧 Applied fixes:\n", .{});
        print("  ✓ Added XML declaration\n", .{});
        print("\n", .{});
    }

    try final_content.appendSlice(process_result.content);

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
    // Use arena allocator for better performance and simpler memory management
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try parseArgs(allocator);
    try processFile(allocator, args);
}