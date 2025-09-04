# Lua Implementation v5.0.0 (Ultra-Optimized)

High-performance Lua XML processor with ultra-optimizations.

## Files
- `fixml.lua` - Ultra-optimized Lua implementation (v5.0.0)

## Usage
```bash
lua fixml.lua [options] <xml-file>

Options:
  --organize, -o      Apply logical organization
  --replace, -r       Replace original file
  --fix-warnings, -f  Fix XML warnings
```

## Performance
- **Average**: 50.45ms across test files
- **Scaling**: 40.3x slower (38.9% efficient) - Good for interpreted language
- **Optimization**: +27.4% improvement over v4.0.0

## Key Optimizations
- Byte-level operations instead of regex patterns
- Pre-allocated buffers with capacity hints
- Single-pass algorithms eliminate O(n²) operations
- Chunked I/O for large files
- Cached indentation strings
- Plain text search instead of pattern matching
- Custom line iterator avoiding gmatch overhead