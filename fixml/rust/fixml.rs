use std::collections::HashSet;
use std::env;
use std::fs;
use std::process;

// Standard constants - consistent across all implementations
const USAGE: &str = "Usage: fixml [--organize] [--replace] [--fix-warnings] <xml-file>
  --organize, -o      Apply logical organization
  --replace, -r       Replace original file
  --fix-warnings, -f  Fix XML warnings
  Default: preserve original structure, fix indentation/deduplication only";

const XML_DECLARATION: &str = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
const MAX_INDENT_LEVELS: usize = 64;        // Maximum nesting depth supported
const ESTIMATED_LINE_LENGTH: usize = 50;    // Average characters per line estimate
const MIN_HASH_CAPACITY: usize = 256;       // Minimum deduplication hash capacity
const MAX_HASH_CAPACITY: usize = 4096;      // Maximum deduplication hash capacity
const WHITESPACE_THRESHOLD: u8 = 32;        // ASCII values <= this are whitespace
const FILE_PERMISSIONS: u32 = 0o644;        // Standard file permissions
const IO_CHUNK_SIZE: usize = 65536;         // 64KB chunks for I/O operations

#[derive(Default)]
struct Args {
    organize: bool,
    replace: bool,
    fix_warnings: bool,
    file: String,
}

fn parse_args() -> Args {
    let args: Vec<String> = env::args().collect();
    let mut parsed = Args::default();
    
    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--organize" | "-o" => parsed.organize = true,
            "--replace" | "-r" => parsed.replace = true,
            "--fix-warnings" | "-f" => parsed.fix_warnings = true,
            arg if !arg.starts_with('-') && parsed.file.is_empty() => {
                parsed.file = arg.to_string();
            }
            _ => {}
        }
        i += 1;
    }
    
    if parsed.file.is_empty() {
        eprintln!("{}", USAGE);
        process::exit(1);
    }
    
    parsed
}

// Optimized O(n) single-pass content cleaning
fn clean_content(content: &str) -> String {
    if content.is_empty() {
        return String::new();
    }
    
    let mut result = String::with_capacity(content.len());
    
    // Remove BOM if present
    let content_to_process = if content.starts_with('\u{FEFF}') {
        &content[3..]
    } else {
        content
    };
    
    // Simplified line ending normalization - use Rust's built-in methods
    // This is much faster and simpler than manual byte operations
    result.push_str(&content_to_process.replace("\r\n", "\n").replace('\r', "\n"));
    
    result
}


// Check if a string is a container element (opening/closing tag without attributes or content)
fn is_container_element(s: &str) -> bool {
    let trimmed = s.trim();
    if trimmed.len() < 3 {
        return false;
    }
    
    // Check for opening container: <tag>
    if trimmed.starts_with('<') && trimmed.ends_with('>') && !trimmed.starts_with("</") {
        let inner = &trimmed[1..trimmed.len()-1];
        // Must contain only valid tag name characters (no spaces, attributes, etc.)
        inner.chars().all(|c| c.is_alphanumeric() || c == ':' || c == '-' || c == '.')
    } else if trimmed.starts_with("</") && trimmed.ends_with('>') {
        // Check for closing container: </tag>
        let inner = &trimmed[2..trimmed.len()-1];
        inner.chars().all(|c| c.is_alphanumeric() || c == ':' || c == '-' || c == '.')
    } else {
        false
    }
}

// Check if a string is self-contained like <tag>content</tag>
fn is_self_contained(s: &str) -> bool {
    let trimmed = s.trim();
    if trimmed.len() < 7 { // Minimum: <a>b</a>
        return false;
    }
    if !trimmed.starts_with('<') || !trimmed.ends_with('>') {
        return false;
    }
    
    // Extract opening tag name
    let tag_name_start = 1; // Skip '<'
    let mut tag_name_end = None;
    
    for (i, c) in trimmed[tag_name_start..].char_indices() {
        if c == ' ' || c == '>' || c == '\t' {
            tag_name_end = Some(tag_name_start + i);
            break;
        }
    }
    
    if let Some(end) = tag_name_end {
        let tag_name = &trimmed[tag_name_start..end];
        
        // Check if line ends with </tagname>
        if trimmed.len() >= tag_name.len() + 3 &&
           trimmed.chars().nth_back(0) == Some('>') &&
           trimmed.len() >= tag_name.len() + 3 {
            
            let potential_close_start = trimmed.len() - tag_name.len() - 3;
            if potential_close_start < trimmed.len() &&
               trimmed[potential_close_start..].starts_with("</") {
                let closing_tag_name = &trimmed[potential_close_start + 2..trimmed.len() - 1];
                return closing_tag_name == tag_name;
            }
        }
    }
    false
}

// Simplified whitespace normalization leveraging Rust's optimized string methods
fn normalize_whitespace(s: &str) -> String {
    // Quick check - if no quotes, use simple normalization
    if !s.contains('"') && !s.contains('\'') {
        // Optimized: avoid intermediate vector allocation
        return s.split_whitespace().fold(String::new(), |mut acc, word| {
            if !acc.is_empty() { acc.push(' '); }
            acc.push_str(word);
            acc
        });
    }
    
    // For quoted content, use simplified character iteration
    let mut result = String::with_capacity(s.len());
    let mut chars = s.chars();
    let mut in_quotes = false;
    let mut quote_char = '\0';
    let mut prev_was_space = false;
    
    while let Some(c) = chars.next() {
        if !in_quotes && (c == '"' || c == '\'') {
            in_quotes = true;
            quote_char = c;
            result.push(c);
            prev_was_space = false;
        } else if in_quotes && c == quote_char {
            in_quotes = false;
            result.push(c);
            prev_was_space = false;
        } else if in_quotes {
            // Inside quotes: preserve all characters
            result.push(c);
            prev_was_space = false;
        } else if c.is_whitespace() {
            // Outside quotes: normalize whitespace
            if !prev_was_space {
                result.push(' ');
                prev_was_space = true;
            }
        } else {
            result.push(c);
            prev_was_space = false;
        }
    }
    
    result.trim().to_string()
}

// Pre-computed indentation strings (standardized across all implementations)
static INDENT_STRINGS: [&str; 65] = [
    "",                                                                                             // 0
    "  ", "    ", "      ", "        ", "          ",                                              // 1-5
    "            ", "              ", "                ", "                  ", "                    ", // 6-10
    "                      ", "                        ", "                          ", "                            ", "                              ", // 11-15
    "                                ", "                                  ", "                                    ", "                                      ", "                                        ", // 16-20
    "                                          ", "                                            ", "                                              ", "                                                ", "                                                  ", // 21-25
    "                                                    ", "                                                      ", "                                                        ", "                                                          ", "                                                            ", // 26-30
    "                                                              ", "                                                                ", "                                                                  ", "                                                                    ", "                                                                      ", // 31-35
    "                                                                        ", "                                                                          ", "                                                                            ", "                                                                              ", "                                                                                ", // 36-40
    "                                                                                  ", "                                                                                    ", "                                                                                      ", "                                                                                        ", "                                                                                          ", // 41-45
    "                                                                                            ", "                                                                                              ", "                                                                                                ", "                                                                                                  ", "                                                                                                    ", // 46-50
    "                                                                                                      ", "                                                                                                        ", "                                                                                                          ", "                                                                                                            ", "                                                                                                              ", // 51-55
    "                                                                                                                ", "                                                                                                                  ", "                                                                                                                    ", "                                                                                                                      ", "                                                                                                                        ", // 56-60
    "                                                                                                                          ", "                                                                                                                            ", "                                                                                                                              ", "                                                                                                                                " // 61-64
];

// Optimized O(n) XML processing with deduplication and indentation
fn process_xml_with_deduplication(content: &str, strip_xml_declaration: bool) -> (String, usize) {
    let mut result = String::with_capacity(content.len() + content.len() / 4);
    let mut indent_level = 0i32;
    let mut seen_elements = HashSet::with_capacity(std::cmp::min(
        std::cmp::max(content.len() / ESTIMATED_LINE_LENGTH, MIN_HASH_CAPACITY),
        MAX_HASH_CAPACITY
    ));
    let mut duplicates_removed = 0;
    
    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }
        
        // Skip XML declaration lines only when strip_xml_declaration is true
        let is_xml_declaration = trimmed.len() >= 5 && trimmed.starts_with("<?xml");
        if strip_xml_declaration && is_xml_declaration {
            continue;
        }
        
        // XML-agnostic container detection - never deduplicate structural elements
        let is_container = is_container_element(trimmed);

        // Deduplication only for non-container lines
        if !is_container {
            let normalized_key = normalize_whitespace(trimmed);
            if seen_elements.contains(&normalized_key) {
                duplicates_removed += 1;
                continue; // Skip duplicate
            }
            seen_elements.insert(normalized_key);
        }
        
        // Adjust indent for closing tags BEFORE applying indentation
        if trimmed.starts_with("</") {
            indent_level = (indent_level - 1).max(0);
        }
        
        // Apply consistent 2-space indentation using pre-computed strings
        let level = indent_level as usize;
        if level > 0 {
            if level < INDENT_STRINGS.len() {
                result.reserve(INDENT_STRINGS[level].len() + trimmed.len() + 1);
                result.push_str(INDENT_STRINGS[level]);
            } else {
                // For very deep nesting, fall back to dynamic generation
                let deep_indent = " ".repeat(level * 2);
                result.reserve(deep_indent.len() + trimmed.len() + 1);
                result.push_str(&deep_indent);
            }
        }
        
        result.push_str(trimmed);
        result.push('\n');
        
        // Fast opening tag detection - avoid expensive self-contained check when possible
        let bytes = trimmed.as_bytes();
        let is_opening_tag = if !bytes.is_empty() && bytes[0] == b'<' && bytes.len() > 1 {
            if bytes[1] == b'/' || bytes[1] == b'!' || bytes[1] == b'?' {
                false // Definitely not opening tag
            } else if trimmed.ends_with("/>") {
                false // Self-closing tag
            } else {
                // Only call expensive is_self_contained for potential opening tags
                !is_self_contained(trimmed)
            }
        } else {
            false
        };
        
        if is_opening_tag {
            indent_level += 1;
        }
    }
    
    (result, duplicates_removed)
}

fn get_output_filename(input_file: &str, replace_mode: bool) -> String {
    if replace_mode {
        format!("{}.tmp.{}", input_file, std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs())
    } else {
        match input_file.rfind('.') {
            Some(dot_pos) => {
                let name = &input_file[..dot_pos];
                let ext = &input_file[dot_pos + 1..];
                format!("{}.organized.{}", name, ext)
            }
            None => format!("{}.organized", input_file),
        }
    }
}

fn process_file(args: &Args) -> Result<(), Box<dyn std::error::Error>> {
    let content = fs::read_to_string(&args.file)
        .map_err(|e| format!("Could not read file '{}': {}", args.file, e))?;
    
    let cleaned_content = clean_content(&content);
    let has_xml_decl = cleaned_content.contains("<?xml");
    
    if !has_xml_decl {
        println!("⚠️  XML Best Practice Warnings:");
        println!("  [XML] Missing XML declaration");
        println!("    Fix: Add <?xml version=\"1.0\" encoding=\"utf-8\"?> at the top");
        println!();
        
        if !args.fix_warnings {
            println!("Use --fix-warnings flag to automatically apply fixes");
            println!();
        }
    }
    
    let mut final_content = String::with_capacity(cleaned_content.len() + 100);
    
    if args.fix_warnings && !has_xml_decl {
        final_content.push_str(XML_DECLARATION);
        println!("🔧 Applied fixes:");
        println!("  ✓ Added XML declaration");
        println!();
    }
    
    // Never strip XML declarations - always preserve them
    let should_strip_xml_declaration = false;
    let (processed_content, duplicates_removed) = process_xml_with_deduplication(&cleaned_content, should_strip_xml_declaration);
    final_content.push_str(&processed_content);
    
    let output_filename = get_output_filename(&args.file, args.replace);
    fs::write(&output_filename, final_content)
        .map_err(|e| format!("Could not write output file: {}", e))?;
    
    if args.replace {
        fs::rename(&output_filename, &args.file)
            .map_err(|e| {
                let _ = fs::remove_file(&output_filename);
                format!("Could not replace original file: {}", e)
            })?;
        print!("Original file replaced: {}", args.file);
    } else {
        print!("Organized project saved to: {}", output_filename);
    }
    
    if duplicates_removed > 0 {
        print!(" (removed {} duplicates)", duplicates_removed);
    }
    
    let mode_text = if args.organize {
        " (with logical organization)"
    } else {
        " (preserving original structure)"
    };
    
    println!("{}", mode_text);
    Ok(())
}

fn main() {
    let args = parse_args();
    
    if let Err(e) = process_file(&args) {
        eprintln!("Error: {}", e);
        process::exit(1);
    }
}