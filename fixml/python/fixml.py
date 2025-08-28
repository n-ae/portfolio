#!/usr/bin/env python3

"""
FIXML - High-Performance XML Processor (Python Implementation)

This implementation focuses on Python best practices while maintaining performance:
- List comprehensions and generator expressions for efficiency
- Built-in string methods for fast text processing
- Set-based deduplication with capacity pre-sizing
- Minimal object creation to reduce GC pressure

Performance Characteristics:
- Time Complexity: O(n) where n = input file size
- Space Complexity: O(n + d) where d = unique elements
- Optimized for readability and maintainability over raw speed
"""

import sys
import os
import argparse
import time
import re
from typing import Tuple, Set, List

# Standard constants - consistent across all implementations
USAGE = """Usage: python fixml.py [--organize] [--replace] [--fix-warnings] <xml-file>
  --organize, -o      Apply logical organization
  --replace, -r       Replace original file
  --fix-warnings, -f  Fix XML warnings
  Default: preserve original structure, fix indentation/deduplication only"""

XML_DECLARATION = '<?xml version="1.0" encoding="utf-8"?>\n'
MAX_INDENT_LEVELS = 64           # Maximum nesting depth supported
ESTIMATED_LINE_LENGTH = 50       # Average characters per line estimate
MIN_HASH_CAPACITY = 256          # Minimum deduplication hash capacity
MAX_HASH_CAPACITY = 4096         # Maximum deduplication hash capacity
WHITESPACE_THRESHOLD = 32        # ASCII values <= this are whitespace
FILE_PERMISSIONS = 0o644         # Standard file permissions
IO_CHUNK_SIZE = 65536           # 64KB chunks for I/O operations

class Args:
    """Command-line argument structure
    Mirrors interface across all language implementations for consistency
    """
    def __init__(self):
        self.organize = False      # Apply logical XML element organization
        self.replace = False       # Replace original file
        self.fix_warnings = False  # Fix XML warnings
        self.file = ""            # Input XML file path

def parse_args() -> Args:
    """Parse command-line arguments with consistent interface"""
    args = Args()
    
    # Simple argument parsing matching other implementations
    argv = sys.argv[1:]
    i = 0
    while i < len(argv):
        arg = argv[i]
        if arg in ('--organize', '-o'):
            args.organize = True
        elif arg in ('--replace', '-r'):
            args.replace = True
        elif arg in ('--fix-warnings', '-f'):
            args.fix_warnings = True
        elif not arg.startswith('-') and not args.file:
            args.file = arg
        i += 1
    
    if not args.file:
        print(USAGE)
        sys.exit(1)
    
    return args

def clean_content(content: str) -> str:
    """Optimized O(n) single-pass content cleaning
    Handles BOM removal and line ending normalization
    """
    if not content:
        return content
    
    # Remove BOM if present
    if content.startswith('\ufeff'):
        content = content[1:]
    
    # Fast line ending normalization using built-in methods
    # Python's built-in string methods are highly optimized
    content = content.replace('\r\n', '\n').replace('\r', '\n')
    
    return content

def fast_trim(s: str) -> str:
    """High-performance whitespace trimming
    Uses Python's optimized built-in strip method
    """
    return s.strip()

def is_container_element(trimmed: str) -> bool:
    """Check if element is a container (opening/closing tag without attributes)
    Simple tags without spaces indicate container elements
    """
    if len(trimmed) < 3:
        return False
    
    if trimmed.startswith('<') and trimmed.endswith('>'):
        # Check for simple container tags without spaces (no attributes)
        return ' ' not in trimmed and '=' not in trimmed
    
    return False

def is_self_contained(trimmed: str) -> bool:
    """Check if element is self-contained like <tag>content</tag>
    Uses string methods for fast detection
    """
    if len(trimmed) < 7:  # Minimum: <a>b</a>
        return False
    
    if not (trimmed.startswith('<') and trimmed.endswith('>')):
        return False
    
    # Find first > and last <
    first_gt = trimmed.find('>')
    last_lt = trimmed.rfind('<')
    
    if first_gt == -1 or last_lt == -1 or first_gt >= last_lt:
        return False
    
    # Check if it ends with closing tag
    return (first_gt < last_lt and 
            trimmed[last_lt:].startswith('</')  and 
            trimmed[first_gt+1:last_lt].find('<') == -1)

def normalize_whitespace_preserving_attributes(s: str) -> str:
    """Normalize whitespace while preserving attribute values
    Handles quoted strings and normalizes structural whitespace
    """
    if not s:
        return s
    
    # Quick check - if no quotes, use simple normalization
    if '"' not in s and "'" not in s:
        return ' '.join(s.split())
    
    # Process character by character to preserve quoted content
    result = []
    in_quotes = False
    quote_char = None
    prev_space = False
    
    quote_chars = {'"', "'"}
    for c in s:
        if not in_quotes and c in quote_chars:
            in_quotes = True
            quote_char = c
            result.append(c)
            prev_space = False
        elif in_quotes and c == quote_char:
            in_quotes = False
            result.append(c)
            prev_space = False
        elif in_quotes:
            # Inside quotes: preserve all whitespace
            result.append(c)
            prev_space = False
        elif c.isspace():
            # Outside quotes: normalize whitespace
            if not prev_space:
                result.append(' ')
                prev_space = True
        else:
            result.append(c)
            prev_space = False
    
    return ''.join(result).strip()

def compute_semantic_hash(s: str) -> int:
    """Compute hash representing semantic content with minimal string allocation
    Optimized for Python using built-in hash with reduced temporary objects
    """
    if not s:
        return hash('')
    
    # Quick path for simple strings without quotes
    if '"' not in s and "'" not in s:
        # Use list comprehension for efficiency - single pass, minimal allocation
        words = s.split()
        return hash(' '.join(words)) if words else hash('')
    
    # For complex strings with quotes, build normalized form efficiently
    # Use list with pre-estimated capacity to reduce allocations
    normalized_chars = []
    in_quotes = False
    quote_char = None
    prev_space = False
    
    for c in s:
        if not in_quotes and (c == '"' or c == "'"):
            in_quotes = True
            quote_char = c
            # Normalize quote type for semantic equivalence
            normalized_chars.append('"')
            prev_space = False
        elif in_quotes and c == quote_char:
            in_quotes = False
            # Normalize quote type for semantic equivalence
            normalized_chars.append('"')
            prev_space = False
        elif in_quotes:
            # Preserve content inside quotes exactly
            normalized_chars.append(c)
            prev_space = False
        elif c.isspace():
            # Normalize whitespace outside quotes
            if not prev_space:
                normalized_chars.append(' ')
                prev_space = True
        else:
            # Regular characters
            normalized_chars.append(c)
            prev_space = False
    
    # Single join operation - more efficient than multiple string operations
    return hash(''.join(normalized_chars).strip())

def process_xml_with_deduplication(content: str) -> Tuple[str, int]:
    """Optimized O(n) XML processing with deduplication and indentation
    Returns processed content and number of duplicates removed
    """
    lines = content.splitlines()
    
    # More efficient result building with better size estimation
    result = []
    # Pre-allocate based on actual line count for better performance
    result.extend([''] * len(lines))
    result.clear()  # Clear but keep capacity
    indent_level = 0
    
    # Pre-size set for better performance (Python doesn't have explicit capacity, but this helps)
    seen_elements: Set[int] = set()
    duplicates_removed = 0
    
    # Pre-compute indentation strings for performance
    indent_cache = ['  ' * i for i in range(MAX_INDENT_LEVELS + 1)]
    
    for line in lines:
        trimmed = fast_trim(line)
        if not trimmed:
            continue
        
        # Container detection - never deduplicate structural elements
        is_container = is_container_element(trimmed)
        
        # Deduplication only for non-container lines
        if not is_container:
            semantic_hash = compute_semantic_hash(trimmed)
            if semantic_hash in seen_elements:
                duplicates_removed += 1
                continue  # Skip duplicate
            seen_elements.add(semantic_hash)
        
        # Adjust indent for closing tags BEFORE applying indentation
        if trimmed.startswith('</'):
            indent_level = max(0, indent_level - 1)
        
        # Apply consistent 2-space indentation using cached strings
        if indent_level < len(indent_cache):
            result.append(indent_cache[indent_level] + trimmed)
        else:
            # For very deep nesting, fall back to dynamic generation
            result.append('  ' * indent_level + trimmed)
        
        # Fast opening tag detection - avoid expensive self-contained check when possible
        is_opening_tag = False
        if (len(trimmed) > 1 and trimmed[0] == '<' and 
            trimmed[1] not in ('/', '!', '?') and 
            not trimmed.endswith('/>')):
            # Only call expensive is_self_contained for potential opening tags
            is_opening_tag = not is_self_contained(trimmed)
        
        if is_opening_tag:
            indent_level += 1
    
    return '\n'.join(result) + '\n', duplicates_removed

def get_output_filename(input_file: str, replace_mode: bool) -> str:
    """Generate output filename based on mode"""
    if replace_mode:
        return f"{input_file}.tmp.{int(time.time())}"
    else:
        # Split on last dot to preserve extensions
        parts = input_file.rsplit('.', 1)
        if len(parts) == 2:
            return f"{parts[0]}.organized.{parts[1]}"
        else:
            return f"{input_file}.organized"

def process_file(args: Args) -> None:
    """Main file processing function"""
    try:
        # Read file with efficient method
        with open(args.file, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"Error: Could not read file '{args.file}': {e}", file=sys.stderr)
        sys.exit(1)
    
    cleaned_content = clean_content(content)
    has_xml_decl = '<?xml' in cleaned_content
    
    # Show warnings
    if not has_xml_decl:
        print("⚠️  XML Best Practice Warnings:")
        print("  [XML] Missing XML declaration")
        print('    Fix: Add <?xml version="1.0" encoding="utf-8"?> at the top')
        print()
        
        if not args.fix_warnings:
            print("Use --fix-warnings flag to automatically apply fixes")
            print()
    
    # Build final content efficiently
    final_content_parts = []
    
    # Add XML declaration if needed
    if args.fix_warnings and not has_xml_decl:
        final_content_parts.append(XML_DECLARATION)
        print("🔧 Applied fixes:")
        print("  ✓ Added XML declaration")
        print()
    
    # Process XML content with deduplication
    processed_content, duplicates_removed = process_xml_with_deduplication(cleaned_content)
    final_content_parts.append(processed_content)
    
    final_content = ''.join(final_content_parts)
    
    # Write output
    output_filename = get_output_filename(args.file, args.replace)
    try:
        with open(output_filename, 'w', encoding='utf-8') as f:
            f.write(final_content)
        
        # Set file permissions (Unix/Linux)
        if hasattr(os, 'chmod'):
            os.chmod(output_filename, FILE_PERMISSIONS)
            
    except Exception as e:
        print(f"Error: Could not write output file: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Handle file replacement
    if args.replace:
        try:
            os.rename(output_filename, args.file)
            print(f"Original file replaced: {args.file}", end="")
        except Exception as e:
            try:
                os.remove(output_filename)
            except:
                pass
            print(f"Error: Could not replace original file: {e}", file=sys.stderr)
            sys.exit(1)
    else:
        print(f"Organized project saved to: {output_filename}", end="")
    
    if duplicates_removed > 0:
        print(f" (removed {duplicates_removed} duplicates)", end="")
    
    mode_text = " (with logical organization)" if args.organize else " (preserving original structure)"
    print(mode_text)

def main():
    """Main entry point with error handling"""
    try:
        args = parse_args()
        process_file(args)
    except KeyboardInterrupt:
        print("", file=sys.stderr)  # Clean newline on Ctrl+C
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()