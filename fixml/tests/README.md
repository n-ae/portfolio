# FIXML Test Suite

Organized test structure for FIXML implementations across multiple languages.

## Overview

The FIXML testing suite provides comprehensive validation for all 5 language implementations across multiple dimensions: functionality, performance, edge cases, and XML specification compliance. Tests are now organized into logical categories for better maintainability.

## Test Architecture

### Test Matrix Coverage
- **5 Languages**: Zig, Go, Rust, OCaml, Lua
- **2 Operating Modes**: Default, Fix-warnings  
- **53 Test Files**: Organized by category and purpose
- **Total Test Cases**: 5 × 2 × 53 = 530 individual tests

### Test Execution Order
Tests run in **performance order** (fastest to slowest) to minimize system load effects:
1. Zig (fastest, most consistent)
2. Go (excellent balance)
3. Rust (memory safe performance)
4. OCaml (functional approach)
5. Lua (interpreted but optimized)

## Test Categories

### `functional/` - Core Functionality Tests
- **Basic XML Structure**: `basic-xml-structure.xml` - Core XML parsing and organization
- **Attribute Handling**: `attribute-handling-test.xml` - XML attribute processing
- **CDATA Processing**: `cdata-content.xml`, `cdata-with-nested-xml.xml` - CDATA section handling
- **Container Elements**: `container-elements-test.xml` - Nested element structures
- **Duplicate Elements**: `duplicate-elements-test.xml` - Element deduplication
- **Indentation**: `indentation-test.xml` - XML formatting and indentation
- **Mixed Content**: `mixed-content.xml` - Text and element mixed content
- **Namespaces**: `namespace-deep-mixed.xml` - XML namespace handling
- **Special Characters**: `special-chars.xml`, `unicode-content.xml` - Character encoding
- **XML Declarations**: `missing-xml-declaration.xml`, `xml-declaration-warnings-test.xml`

### `performance/` - Performance and Scale Tests
- **Enterprise Scale**: `enterprise-scale-benchmark.xml` - Large enterprise XML files
- **Large Benchmarks**: `large-benchmark.xml`, `massive-scale-benchmark.xml` - Performance testing
- **Deep Nesting**: `very-deep-nested-elements.xml`, `very-deep-nesting.xml` - Nested structure limits

### `regression/` - Bug Fix Validation Tests  
- **Element Ordering**: `element-ordering-fix.xml` - Element order preservation
- **Package Reference Duplication**: `packageref-duplication-bug.xml` - Specific MSBuild bug fixes
- **Whitespace Duplication**: `whitespace-duplication-fix.xml` - Whitespace handling fixes

### `xml-spec-compliance/` - XML Specification Compliance
- **Attribute Rules**: `attribute-quoting.xml`, `attribute-rules.xml` - XML attribute specifications
- **CDATA Sections**: `cdata-sections.xml` - CDATA specification compliance
- **Character Handling**: `character-encoding.xml`, `character-references.xml` - Character specifications
- **Comments & PI**: `comments-and-pi.xml`, `comment-spaces.xml` - Comment and processing instruction handling
- **Element Rules**: `element-name-rules.xml`, `empty-elements.xml` - Element naming and structure rules
- **Whitespace**: `whitespace-handling.xml` - XML whitespace specification compliance

### `edge-cases/` - Boundary Condition Tests
- **Edge Cases**: `edge-case-elements.xml` - Unusual but valid XML constructs

## Test Modes

### Quick Mode (`lua test.lua quick [language]`)
Runs a curated subset of 16 core tests covering essential functionality.

### Spec Compliance Mode (`lua test.lua spec [language]`) 
Runs XML specification compliance tests (22 tests).

### Comprehensive Mode (`lua test.lua comprehensive [language]`)
Runs all tests across all categories (53 tests total).

## Test File Naming Convention

- **Base Files**: `test-name.xml` - Original XML input
- **Default Expected**: `test-name.d.expected.xml` - Expected output in default mode  
- **Fix-Warnings Expected**: `test-name.f.expected.xml` - Expected output with fix-warnings mode
- **Combined Expected**: `test-name.df.expected.xml` - Used when default and fix-warnings produce same output

## Running Tests

```bash
# Quick test single language
lua test.lua quick zig

# Spec compliance all languages  
lua test.lua spec all

# Full comprehensive test
lua test.lua comprehensive all
```

## Testing Utilities

### `fel.sh` - File Comparison Tool
Precise XML file comparison with BOM and whitespace awareness for validating test results.

## Test Execution

### Quick Test Suite
**Purpose**: Rapid validation during development
**Coverage**: 16 representative files × 4 modes × 5 languages = 320 tests
**Duration**: ~30 seconds
**Usage**:
```bash
lua test.lua quick
```

**File Selection**:
- Core functionality samples
- Key edge cases  
- Performance representatives
- Error condition tests

### Comprehensive Test Suite  
**Purpose**: Complete validation before releases
**Coverage**: All available XML files × 4 modes × 5 languages = 1,620 tests
**Duration**: ~2-3 minutes
**Usage**:
```bash
lua test.lua comprehensive
```

### Individual Language Testing
**Purpose**: Focused testing during language-specific development
**Usage**:
```bash
# Test only specific language
lua test.lua quick zig
lua test.lua comprehensive rust go
lua test.lua quick all  # Same as default
```

## Performance Testing

### Benchmark Execution
```bash
# Quick benchmark (1 file, 5 iterations) - Development
lua benchmark.lua quick

# Comprehensive benchmark (6 files, 20 iterations) - CI/Release
lua benchmark.lua benchmark  

# Full benchmark (all files, extended iterations) - Research
lua benchmark.lua comprehensive
```

### Benchmark Output Analysis
```bash
# View results in tabular format
cat benchmark-results-*.csv | column -t -s,

# Extract specific language performance
grep "^zig," benchmark-results-*.csv

# Compare scaling across file sizes
awk -F, 'NR>1 {print $3,$5}' benchmark-results-*.csv | sort -k2 -n
```

## Expected Output Patterns

### Success Indicators
```bash
# Test run success
=== FIXML Test (quick mode) ===
Files: 16, Languages: zig go rust ocaml lua
...
Total: 320/320 (100%)

# Benchmark success
FIXML Performance Benchmark
==================================================
Mode: benchmark | Iterations: 20 | Implementations: 5
...
Benchmark complete! Tested 5 implementations successfully.
```

### Failure Investigation
```bash
# Check test-results.csv for failures
grep "fail" test-results.csv

# Manual verification of specific failure
zig/fixml tests/samples/problematic-file.xml
./tests/fel.sh tests/samples/problematic-file.xml tests/samples/problematic-file.organized.xml
```

## Test Development Guidelines

### Adding New Test Cases

1. **Create test file** in `tests/samples/`:
```bash
# Add new XML file with descriptive name
cp new-scenario.xml tests/samples/
```

2. **Generate expected outputs** for all modes:
```bash
# Use Zig as reference implementation (fastest, most reliable)
zig/fixml tests/samples/new-scenario.xml
zig/fixml --organize tests/samples/new-scenario.xml  
zig/fixml --fix-warnings tests/samples/new-scenario.xml
zig/fixml --organize --fix-warnings tests/samples/new-scenario.xml

# Rename to expected format
mv tests/samples/new-scenario.organized.xml tests/samples/new-scenario.d.expected.xml
# ... repeat for other modes (.o.expected.xml, .f.expected.xml, .of.expected.xml)
```

3. **Validate across all implementations**:
```bash
lua test.lua comprehensive
```

### Test File Naming Conventions
- **Original files**: `descriptive-name.xml`
- **Expected outputs**: `descriptive-name.{mode}.expected.xml`
  - `.d.expected.xml` - Default mode
  - `.o.expected.xml` - Organize mode  
  - `.f.expected.xml` - Fix-warnings mode
  - `.of.expected.xml` - Combined mode
- **Generated outputs**: `descriptive-name.organized.xml`

### Performance Test Considerations
- **File sizes**: Include range from 1KB to 10MB+ for scaling tests
- **Content complexity**: Vary nesting depth, attribute count, text content
- **Real-world samples**: Include actual XML files from production systems
- **Edge cases**: Test boundary conditions and error scenarios

## Continuous Integration Integration

### Test Automation
```bash
#!/bin/bash
# CI pipeline test script

# Build all implementations
lua build_config.lua

# Run quick tests
lua test.lua quick || exit 1

# Run performance regression check  
lua benchmark.lua quick > current-benchmark.txt
# Compare with baseline...

# Generate test report
echo "All tests passed at $(date)"
```

### Regression Detection
- **Performance**: Flag >10% performance degradation
- **Functionality**: Any test failure blocks deployment
- **Memory**: Monitor for memory usage increases
- **Build**: Ensure all implementations compile successfully

The FIXML testing suite provides comprehensive validation ensuring that all implementations maintain identical functionality while showcasing the performance characteristics unique to each programming language.