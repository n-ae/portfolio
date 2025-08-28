# FIXML Project Memory

## Core Project Structure
- **Main Directory**: `/Users/username/dev/portfolio/fixml`
- **Languages**: Zig (primary focus), Go, Rust, OCaml, Lua
- **Purpose**: High-performance XML processor with multiple language implementations
- **Performance Target**: ~20ms average processing time
- **Quality Standard**: 138/138 tests passing (100% coverage)

## Zig Implementation Focus
- **File**: `zig/src/main.zig` (main implementation)
- **Performance**: Currently ~19.84ms average (fastest implementation)
- **Architecture**: Martin Fowler refactoring principles with comptime optimizations
- **Build Command**: `zig build -Doptimize=ReleaseFast`

## Repeated User Instructions Pattern

### Primary Assessment Request
"For zig, assess before and after, and improve correctness, performance and/or simplicity of code for each implementation. One improvement should not hurt the other. Rebuild successfully & run 'lua test.lua comprehensive' and 'lua benchmark.lua comprehensive' to verify."

### Refactoring Request Pattern
"For zig, assess before and after, refactor. Take a look at Martin Fowler's suggestions. It should not hurt the correctness or performance other. Rebuild successfully & run 'lua test.lua comprehensive' and 'lua benchmark.lua comprehensive' to assess."

### Key Requirements (ALWAYS)
1. **Correctness**: Must maintain 138/138 test coverage
2. **Performance**: No regressions, target improvements
3. **Testing**: Always run `lua test.lua comprehensive` 
4. **Benchmarking**: Always run `lua benchmark.lua comprehensive`
5. **Build Verification**: Ensure `zig build` succeeds

## Martin Fowler Refactoring Principles Applied
- Replace Magic Numbers with Named Constants
- Extract Method for complex operations
- Introduce Parameter Object for related parameters
- Introduce Explaining Variable for complex expressions
- Remove Duplicate Code

## Testing Commands
```bash
# Essential test suite (MUST pass 138/138)
lua test.lua comprehensive

# Performance benchmarking 
lua benchmark.lua comprehensive

# Quick tests for development
lua test.lua quick

# Zig-specific tests
zig build test
```

## Build Commands
```bash
# Development build
zig build

# Optimized release (for benchmarking)
zig build -Doptimize=ReleaseFast

# Debug with safety checks
zig build -Doptimize=Debug
```

## Performance Constants (Current Optimizations)
```zig
// Core processing constants
const MIN_SELF_CONTAINED_LENGTH = 7;
const CHUNK_SIZE_U64 = 8;
const LARGE_STRING_THRESHOLD = 16;
const ESTIMATED_LINE_LENGTH = 50;
const MIN_HASH_CAPACITY = 256;
const MAX_HASH_CAPACITY = 4096;
const LOAD_FACTOR_NUMERATOR = 4;
const LOAD_FACTOR_DENOMINATOR = 3;
const INDENT_OVERHEAD_PERCENT = 8;
const SAFETY_MARGIN_PERCENT = 16;
const MAX_SAFETY_MARGIN_KB = 1;
const MAX_FILE_SIZE_MB = 100;
```

## Critical Success Metrics
- **Test Coverage**: 138/138 tests MUST pass
- **Performance**: ~19-20ms average processing time
- **Memory**: O(n + d) space complexity
- **Time**: O(n) time complexity

## Optimization Areas Explored
1. **Comptime Optimizations**: Pre-computed lookup tables, vectorized processing
2. **Hash Functions**: FNV-1a with unrolled processing
3. **Memory Management**: Stack-allocated buffers, adaptive capacity estimation
4. **SIMD Processing**: 8-byte chunk processing with comptime unrolling
5. **Deduplication**: Hash-based with optimal load factors

## Common Error Patterns & Fixes
- **Unused Constants**: Remove after SIMD optimizations
- **Type Mismatches**: Ensure u32/usize consistency for hash operations
- **ArrayList Initialization**: Use correct `ArrayList(T){}` syntax
- **Hash Seed Values**: Keep within u64 range
- **API Compatibility**: Check Zig version compatibility for ComptimeStringMap

## Git Workflow
- **Current Branch**: `fixml`
- **Main Branch**: `main` (for PRs)
- **Modified Files**: Track with git status before commits
- **Never commit** unless explicitly requested by user

## GitHub Workflows Created
- **CI**: `.github/workflows/ci.yml` (testing, benchmarking)
- **Release**: `.github/workflows/release.yml` (cross-platform builds)
- **Publishing**: `.github/workflows/publish.yml` (Homebrew, AUR, Docker)
- **Issue Automation**: `.github/workflows/issue-automation.yml`

## Response Style Requirements
- Be concise (max 4 lines unless detail requested)
- Minimize output tokens
- No unnecessary preamble/postamble
- Direct answers without explanations unless asked
- No code explanation summaries unless requested

## XML Specification Compliance Requirements

### W3C XML Specification (https://www.w3.org/TR/xml/)
Based on official W3C XML 1.0 specification analysis:

1. **Element Name Rules**:
   - Names must start with: letter, underscore (_), or colon (:)
   - Can contain: letters, digits, hyphens (-), periods (.), underscores (_)
   - Names beginning with "xml" (case-insensitive) are reserved
   - Unicode characters are allowed per specification

2. **Attribute Rules**:
   - No duplicate attributes in single tag
   - Attribute values must be normalized (whitespace processed)
   - External entity references prohibited in attribute values
   - "<" character not allowed in attribute values
   - Both single and double quotes supported for attribute values

3. **Self-Closing Tag Syntax**:
   - Empty elements can use "/>" syntax
   - Minimum self-closing tag: `<a/>` (3 characters)
   - Minimum self-contained element: `<a>x</a>` (5 characters)
   - Recommended for elements declared as EMPTY

4. **Character Encoding**:
   - Must support UTF-8 and UTF-16
   - Encoding specified via XML declaration
   - Byte Order Mark (BOM) can indicate encoding
   - Illegal byte sequences are fatal error

5. **Whitespace Handling**:
   - Whitespace preserved in content by default
   - Can be normalized based on xml:space attribute
   - Line breaks normalized to single #xA character

6. **Comments and Processing Instructions**:
   - Comments: Cannot contain "--" within comment
   - PI targets cannot start with "xml" (case-insensitive)
   - Proper syntax: `<!-- comment -->` and `<?target data?>`

7. **CDATA Sections**:
   - Literal text without markup interpretation
   - Syntax: `<![CDATA[content]]>`
   - Cannot nest CDATA sections
   - Terminator "]]>" cannot appear in content

8. **Document Structure**:
   - Must have exactly one root element
   - Elements must be properly nested
   - Optional XML declaration specifying version
   - Optional DOCTYPE declaration allowed

### Current Implementation Status
- ✅ MIN_SELF_CONTAINED_LENGTH fixed from 7 to 5 characters
- ✅ Enhanced XML name character validation per spec
- ✅ Proper Unicode character support (basic)
- ✅ Whitespace handling compliance
- ✅ Self-closing tag syntax support
- ✅ Attribute parsing and normalization
- ✅ Comment and CDATA preservation
- ✅ Document structure validation

### Test Coverage
- Created comprehensive XML spec test suite: `/tests/xml-spec-compliance/`
- Tests cover: element names, attributes, self-closing, encoding, whitespace, comments, CDATA
- All tests pass with current implementation
- Maintains 138/138 test coverage (100% correctness)

## Tool Usage Patterns
- Use `TodoWrite` for multi-step tasks
- Prefer `Task` tool for file searches to reduce context
- Batch tool calls when possible for performance
- Always verify builds and tests after changes