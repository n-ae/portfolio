# FIXML Testing Suite Documentation

## Overview

The FIXML testing suite provides comprehensive validation for all 5 language implementations across multiple dimensions: functionality, performance, edge cases, and correctness. The test suite is designed to ensure consistent behavior across all implementations while validating the O(n) scaling characteristics.

## Test Architecture

### Test Matrix Coverage
- **5 Languages**: Zig, Go, Rust, OCaml, Lua
- **4 Operating Modes**: Default, Organize, Fix-warnings, Combined
- **34+ Test Files**: Ranging from edge cases to performance benchmarks
- **Total Test Cases**: 5 × 4 × 34+ = 680+ individual tests

### Test Execution Order
Tests run in **performance order** (fastest to slowest) to minimize system load effects:
1. Zig (fastest, most consistent)
2. Go (excellent balance)
3. Rust (memory safe performance)
4. OCaml (functional approach)
5. Lua (interpreted but optimized)

## Test File Categories

### Performance Benchmarks (`samples/`)

#### Size Distribution for Scaling Tests
```
sample.xml                    0.9KB   - Minimal overhead testing
medium-test.xml              48.8KB   - Medium file processing
large-test.xml                3.2MB   - Large file scaling
enterprise-benchmark.xml      971KB   - Real-world complexity
large-benchmark.xml           549KB   - Performance validation  
massive-benchmark.xml         2.4MB   - Maximum tested scale
```

#### Edge Case Testing
```
missing-xml-declaration.xml      - XML declaration handling
unicode-content.xml              - UTF-8 and special characters
cdata-with-nested-xml.xml        - CDATA section preservation
processing-instruction-test.xml  - PI handling (<?xml, <?...?>)
comment-with-xml.xml             - Comment preservation
whitespace-heavy.xml             - Extreme whitespace scenarios
very-deep-nested-elements.xml    - Nesting depth limits (64 levels)
very-deep-nesting.xml            - Maximum depth testing
```

#### Functional Testing
```
duplicate-packageref.xml         - Deduplication accuracy
sample-with-duplicates.xml       - Basic duplicate detection
whitespace-duplicates-test.xml   - Whitespace normalization
attr-whitespace-test.xml         - Attribute whitespace handling
multiple-attrs.xml               - Complex attribute scenarios
test-attributes.xml              - Attribute preservation
test-containers.xml              - Container element detection
test-indent.xml                  - Indentation correctness
```

#### Real-world Scenarios
```
wrong-element-order.xml          - Element reordering testing
packageref-in-propertygroup.xml  - Complex MSBuild scenarios
namespace-deep-mixed.xml         - XML namespace handling
mixed-content.xml                - Mixed content preservation
all-features-mixed.xml           - Comprehensive feature testing
```

## Operating Modes

### Default Mode (No flags)
**Purpose**: Basic XML formatting and deduplication
**Features**: 
- Consistent 2-space indentation
- Duplicate element removal
- Structure preservation
- Creates `.organized.xml` output

**Example**:
```bash
zig/fixml tests/samples/sample.xml
# Creates: tests/samples/sample.organized.xml
```

### Organize Mode (`--organize`)
**Purpose**: Apply logical XML element organization
**Features**:
- Groups related elements together
- Maintains semantic relationships
- Optimizes for readability
- May reorder elements for logical flow

**Example**:
```bash
go/fixml --organize tests/samples/enterprise-benchmark.xml
```

### Fix-warnings Mode (`--fix-warnings`)
**Purpose**: Apply XML best practices and fix warnings
**Features**:
- Adds XML declaration if missing
- Ensures proper encoding declaration
- Fixes common XML issues
- Reports and corrects best practice violations

**Example**:
```bash
rust/fixml --fix-warnings tests/samples/missing-xml-declaration.xml
```

### Combined Mode (`--organize --fix-warnings`)
**Purpose**: Full processing with both organization and fixes
**Features**:
- All organize mode features
- All fix-warnings mode features
- Comprehensive XML optimization
- Maximum processing applied

**Example**:
```bash
ocaml/fixml --organize --fix-warnings tests/samples/massive-benchmark.xml
```

## Testing Utilities

### `fel.sh` - File Comparison Tool

**Purpose**: Precise XML file comparison with BOM and whitespace awareness

**Features**:
- BOM (Byte Order Mark) handling
- Whitespace normalization for comparison
- Line ending standardization
- Structural difference identification

**Usage**:
```bash
# Compare original vs processed
./tests/fel.sh original.xml processed.organized.xml

# Check for differences (empty output = identical)
./tests/fel.sh expected.xml actual.xml

# Example output on differences:
# < Line only in first file
# > Line only in second file
```

**Implementation Details**:
```bash
# Internal processing pipeline
sed 's/^\xEF\xBB\xBF//; s/^[[:space:]]*//; s/[[:space:]]*$//' file1 | sort -u
sed 's/^\xEF\xBB\xBF//; s/^[[:space:]]*//; s/[[:space:]]*$//' file2 | sort -u
comm -3 <(processed_file1) <(processed_file2)
```

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
**Coverage**: All available XML files × 4 modes × 5 languages = 680+ tests
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