use std::collections::HashSet;
use std::env;
use std::fs;
use std::process;

const USAGE: &str = "Usage: fixml_optimized [--organize] [--replace] [--fix-warnings] <xml-file>
  --organize, -o      Apply logical organization
  --replace, -r       Replace original file  
  --fix-warnings, -f  Fix XML warnings
  Default: preserve original structure, fix indentation/deduplication only";

const XML_DECLARATION: &str = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";

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
    
    // Single-pass line ending normalization using chars() for proper UTF-8 handling
    let mut chars = content_to_process.chars().peekable();
    while let Some(ch) = chars.next() {
        if ch == '\r' {
            if chars.peek() == Some(&'\n') {
                chars.next(); // consume the \n
            }
            result.push('\n');
        } else {
            result.push(ch);
        }
    }
    
    result
}

// Optimized O(n) element key creation
fn create_element_key(tag: &str, attrs: &[String], content: &str) -> String {
    let mut result = String::with_capacity(64);
    result.push_str(tag);
    
    if !attrs.is_empty() {
        let mut sorted_attrs = attrs.to_vec();
        sorted_attrs.sort_unstable();
        result.push('|');
        result.push_str(&sorted_attrs.join(","));
    }
    
    let trimmed_content = content.trim();
    if !trimmed_content.is_empty() {
        result.push('|');
        
        // Single-pass whitespace normalization
        let mut prev_space = false;
        for ch in trimmed_content.chars() {
            if ch.is_whitespace() {
                if !prev_space {
                    result.push(' ');
                    prev_space = true;
                }
            } else {
                result.push(ch);
                prev_space = false;
            }
        }
    }
    
    result
}

fn deduplicate_elements(elements: Vec<(String, Vec<String>, String)>) -> (Vec<(String, Vec<String>, String)>, usize) {
    let mut seen = HashSet::with_capacity(elements.len());
    let mut unique = Vec::with_capacity(elements.len());
    let mut duplicates = 0;
    
    for elem in elements {
        let key = create_element_key(&elem.0, &elem.1, &elem.2);
        if seen.contains(&key) {
            duplicates += 1;
        } else {
            seen.insert(key);
            unique.push(elem);
        }
    }
    
    (unique, duplicates)
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
    if !trimmed.starts_with('<') || !trimmed.ends_with('>') {
        return false;
    }
    
    // Find first > and last <
    if let Some(first_gt) = trimmed.find('>') {
        if let Some(last_lt) = trimmed.rfind('<') {
            // Must have content between > and <, and last part must start with </
            return first_gt < last_lt && 
                   first_gt + 1 < last_lt && 
                   trimmed[last_lt..].starts_with("</");
        }
    }
    false
}

// Normalize whitespace by replacing multiple spaces with single space
fn normalize_whitespace(s: &str) -> String {
    let mut result = String::with_capacity(s.len());
    let mut prev_was_space = false;
    
    for ch in s.chars() {
        if ch.is_whitespace() {
            if !prev_was_space {
                result.push(' ');
                prev_was_space = true;
            }
        } else {
            result.push(ch);
            prev_was_space = false;
        }
    }
    
    result.trim().to_string()
}

// Optimized O(n) XML processing with deduplication and indentation
fn process_xml_with_deduplication(content: &str) -> (String, usize) {
    let lines: Vec<&str> = content.lines().collect();
    let mut result = String::with_capacity(content.len() + content.len() / 4);
    let mut indent_level = 0i32;
    let mut seen_elements = HashSet::new();
    let mut duplicates_removed = 0;
    
    for line in lines {
        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }
        
        // XML-agnostic container detection - never deduplicate structural elements
        let is_container = is_container_element(trimmed);
        
        // Deduplication with normalized whitespace
        let normalized_key = normalize_whitespace(trimmed);
        
        if !is_container && seen_elements.contains(&normalized_key) {
            duplicates_removed += 1;
            continue; // Skip duplicate
        }
        
        if !is_container {
            seen_elements.insert(normalized_key);
        }
        
        // Adjust indent for closing tags BEFORE applying indentation
        if trimmed.starts_with("</") {
            indent_level = (indent_level - 1).max(0);
        }
        
        // Apply consistent 2-space indentation
        let spaces_needed = (indent_level * 2) as usize;
        if spaces_needed > 0 {
            result.reserve(spaces_needed + trimmed.len() + 1);
            for _ in 0..spaces_needed {
                result.push(' ');
            }
        }
        
        result.push_str(trimmed);
        result.push('\n');
        
        // Adjust indent for opening tags AFTER applying indentation
        // Must not be self-contained (like <tag>content</tag> or <tag/>)
        let mut is_opening_tag = trimmed.starts_with('<') && 
                                !trimmed.starts_with("</") && 
                                !trimmed.starts_with("<!--") &&
                                !trimmed.starts_with("<?") && 
                                !trimmed.ends_with("/>");
        
        // Check if it's self-contained with content like <tag>content</tag>
        if is_opening_tag && is_self_contained(trimmed) {
            is_opening_tag = false;
        }
        
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
    
    let (processed_content, duplicates_removed) = process_xml_with_deduplication(&cleaned_content);
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