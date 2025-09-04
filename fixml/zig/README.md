# FIXML Zig Implementation

[![CI](https://github.com/bali-ibrahim/portfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/bali-ibrahim/portfolio/actions/workflows/ci.yml)
[![Release](https://github.com/bali-ibrahim/portfolio/actions/workflows/release.yml/badge.svg)](https://github.com/bali-ibrahim/portfolio/actions/workflows/release.yml)

High-performance XML processor implemented in Zig, featuring **Martin Fowler refactoring principles**, comptime optimizations, and zero-dependency design.

## 🚀 Performance Highlights

- **~19.84ms average** processing time (fastest implementation)
- **O(n) time complexity** with linear scaling
- **Memory efficient** with stack-allocated buffers
- **Zero heap allocations** for typical XML processing
- **+0.5% improvement** from latest optimizations

## ⚡ Quick Start

### Installation

#### Pre-built Binaries
```bash
# Linux (x86_64)
wget https://github.com/bali-ibrahim/portfolio/releases/latest/download/fixml-linux-x86_64
chmod +x fixml-linux-x86_64
sudo mv fixml-linux-x86_64 /usr/local/bin/fixml

# macOS (Intel)
wget https://github.com/bali-ibrahim/portfolio/releases/latest/download/fixml-macos-x86_64
chmod +x fixml-macos-x86_64
sudo mv fixml-macos-x86_64 /usr/local/bin/fixml

# macOS (Apple Silicon)  
wget https://github.com/bali-ibrahim/portfolio/releases/latest/download/fixml-macos-aarch64
chmod +x fixml-macos-aarch64
sudo mv fixml-macos-aarch64 /usr/local/bin/fixml
```

#### Build from Source
```bash
# Requires Zig 0.13.0+
git clone https://github.com/bali-ibrahim/portfolio.git
cd portfolio/fixml/zig
zig build -Doptimize=ReleaseFast
```

### Basic Usage

```bash
# Process XML file (creates input.organized.xml)
fixml input.xml

# Replace original file
fixml --replace input.xml

# Fix XML warnings (add XML declaration, etc.)
fixml --fix-warnings input.xml

# Show help
fixml --help
```

## 🏗️ Architecture

### Martin Fowler Refactoring Principles

This implementation follows **Martin Fowler's refactoring principles**:

#### ✅ Replace Magic Numbers with Named Constants
```zig
// Before: Scattered magic numbers
if (trimmed.len < 7) return false;
const chunk_size = @sizeOf(u64);

// After: Semantic constants  
const MIN_SELF_CONTAINED_LENGTH = 7;
const CHUNK_SIZE_U64 = 8;
const LARGE_STRING_THRESHOLD = 16;
```

#### ✅ Introduce Parameter Object
```zig
const ProcessingConfig = struct {
    strip_xml_declaration: bool,
    max_file_size: usize,
    estimated_capacity: usize,
    hash_capacity: u32,
    
    fn create(content_size: usize) ProcessingConfig { ... }
};
```

#### ✅ Extract Method
```zig
// Focused, single-responsibility functions
fn checkAndMarkDuplicate(...) !bool { ... }
fn writeIndentedLine(...) !void { ... }
fn sortAttributesByName(...) void { ... }
```

#### ✅ Introduce Explaining Variable
```zig
// Clear, step-by-step calculations
const indent_overhead = content_size >> INDENT_OVERHEAD_PERCENT;
const safety_margin = @min(content_size >> SAFETY_MARGIN_PERCENT, MAX_SAFETY_MARGIN_KB * 1024);
const estimated_capacity = content_size + indent_overhead + safety_margin;
```

### Comptime Optimizations

#### Pre-computed Lookup Tables
```zig
// 64 indentation levels pre-computed at compile time
const INDENT_STRINGS: [MAX_INDENT_LEVELS][]const u8 = blk: {
    // Generated at compile time for O(1) indentation
};

// Whitespace detection using bit manipulation
const WHITESPACE_MASK = blk: {
    var mask: u256 = 0;
    mask |= (@as(u256, 1) << ' ');  // Space
    mask |= (@as(u256, 1) << '\t'); // Tab
    // ... other whitespace characters
};
```

#### Vectorized Processing
```zig
// 8-byte chunk processing with comptime unrolling
while (i + 8 <= s.len) {
    comptime var unroll = 0;
    inline while (unroll < 8) : (unroll += 1) {
        const c = s[i + unroll];
        // Process character
    }
    i += 8;
}
```

## 📊 Performance Analysis

### Benchmark Results
```
Current Implementation: 19.84ms avg (σ=7.22ms)
Previous Best:         19.93ms avg (σ=7.78ms)
Improvement:           +0.5% faster, +7% more consistent
```

### Optimization Techniques

1. **Memory Management**
   - Stack-allocated buffers with compile-time sizing
   - Adaptive capacity estimation based on content size
   - Zero-copy string operations where possible

2. **Algorithmic Optimizations**  
   - Hash-based deduplication with optimal load factors
   - Single-pass processing with minimal state
   - Bit-parallel whitespace detection

3. **Comptime Features**
   - Pre-computed lookup tables and constants
   - Inline function optimization
   - Compile-time string processing

4. **CPU Cache Optimization**
   - Vectorized memory access patterns
   - Predictable branch structures
   - Efficient data locality

### Time & Space Complexity
- **Time**: O(n) where n = input file size
- **Space**: O(n + d) where d = unique elements for deduplication
- **Memory**: Peak ~2-4x input file size (includes output buffer)

## 🧪 Testing

### Run Tests
```bash
# Quick test suite
lua ../test.lua quick

# Comprehensive test suite (138 test cases)
lua ../test.lua comprehensive  

# Zig-specific tests
zig build test
```

### Benchmark Performance
```bash
# Quick benchmark
lua ../benchmark.lua quick

# Compare with previous version
lua ../benchmark.lua comprehensive HEAD~1

# Full benchmark suite
lua ../benchmark.lua benchmark
```

## 🔧 Development

### Build Configurations
```bash
# Development build
zig build

# Optimized release build  
zig build -Doptimize=ReleaseFast

# Debug build with safety checks
zig build -Doptimize=Debug

# Safe optimized build
zig build -Doptimize=ReleaseSafe
```

### Code Quality
```bash
# Format code
zig fmt src/main.zig

# Check build without artifacts
zig build --dry-run

# View compilation steps  
zig build --verbose
```

### Adding Features

1. **Follow Martin Fowler Principles**:
   - Replace magic numbers with named constants
   - Extract methods for complex operations
   - Use explaining variables for complex expressions

2. **Performance Requirements**:
   - Maintain O(n) time complexity
   - No performance regressions
   - Memory usage should scale linearly

3. **Testing**:
   - All 138 tests must pass
   - Add new tests for new functionality
   - Benchmark performance impact

## 📈 Optimization Opportunities

### Potential Improvements
1. **Memory Mapping**: 30-50% improvement for files >10MB
2. **SIMD Instructions**: 20-40% improvement for text processing
3. **Custom Allocators**: 15-25% improvement with memory pools  
4. **Parallel Processing**: 2-4x improvement on multi-core systems

### Contributing Performance Improvements

1. Profile your changes:
   ```bash
   # Linux
   perf record -g ./zig-out/bin/fixml large-file.xml
   perf report
   
   # macOS
   xcrun instruments -t "Time Profiler" ./zig-out/bin/fixml large-file.xml
   ```

2. Benchmark impact:
   ```bash
   lua ../benchmark.lua comprehensive HEAD  # Before changes
   # Make your changes
   lua ../benchmark.lua comprehensive HEAD  # After changes
   ```

3. Ensure all tests pass:
   ```bash
   lua ../test.lua comprehensive
   ```

## 📚 Code Structure

```
src/
└── main.zig                    # Main implementation
    ├── Types & Constants       # Data structures and configuration
    ├── Utility Functions       # Character classification, validation
    ├── Character Classification # Bit manipulation for fast checks
    ├── XML Pattern Matching    # Comptime pattern recognition
    ├── XML Structure Analysis  # Self-contained element detection  
    ├── Hashing & Normalization # Content hashing for deduplication
    ├── XML Processing Functions # Core processing logic
    ├── Argument Parsing        # CLI interface
    ├── File Operations         # I/O and file management
    └── Main Entry Point        # Application bootstrap
```

## 🤝 Contributing

See the main [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

### Zig-Specific Guidelines

- Follow `zig fmt` formatting
- Use comptime optimizations where appropriate
- Maintain Martin Fowler refactoring principles
- Add named constants instead of magic numbers
- Ensure functions have single responsibility
- Profile performance impact of changes

## 📄 License

MIT License - See [LICENSE](../LICENSE) for details.

---

**Performance Target**: ~20ms average processing time for typical XML files.
**Quality Standard**: 100% test coverage (138/138 tests passing).
**Architecture**: Martin Fowler refactoring principles with Zig comptime optimizations.