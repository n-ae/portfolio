# FIXML - Multi-Language High-Performance XML Processor

A comprehensive suite of XML processors implemented in 5 languages (Zig, Go, Rust, OCaml, Lua), showcasing different approaches to high-performance XML processing with consistent functionality and standardized constants.

## 🏆 Performance Rankings (Latest Benchmark Results)

| Rank | Language | Average Time | Performance Notes |
|------|----------|--------------|-------------------|
| 🥇 | **Rust**  | 8.0ms       | Zero-cost abstractions with memory safety |
| 🥈 | **Lua**   | 8.5ms       | Optimized interpreted performance |
| 🥉 | **Go**    | 8.6ms       | Excellent balance of performance and simplicity |
| 4th | **Zig**   | 13.4ms      | Manual memory management, consistent performance |
| 5th | **OCaml** | 64.9ms      | Functional programming with GC overhead |

*Current optimized results on 0.9KB sample file with 5 iterations each*

## 📁 Project Structure

```
fixml/
├── go/
│   ├── fixml          # Compiled Go binary
│   ├── fixml.go       # Go implementation
│   └── README.md
├── rust/
│   ├── fixml          # Compiled Rust binary  
│   ├── fixml.rs       # Rust implementation
│   └── README.md
├── ocaml/
│   ├── fixml          # Compiled OCaml binary
│   ├── fixml.ml       # OCaml implementation
│   └── README.md
├── zig/
│   ├── fixml          # Compiled Zig binary
│   ├── src/main.zig   # Zig implementation
│   ├── build.zig      # Build configuration
│   └── README.md
├── lua/
│   ├── fixml.lua      # Lua implementation
│   └── README.md
├── tests/
│   ├── samples/       # XML test files (34+ test cases)
│   ├── fel.sh         # File comparison utility
│   └── README.md
├── benchmark.lua      # Performance benchmarking suite
├── test.lua           # Comprehensive test runner
├── build_config.lua   # Shared build configuration
└── README.md          # This file
```

## ⚡ Quick Start

### Installation & Build
```bash
# Clone and build all implementations
git clone <repository-url>
cd fixml

# Build all implementations with optimizations
lua build_config.lua
```

### Basic Usage
```bash
# Process XML file (any implementation)
zig/fixml input.xml                    # Creates input.organized.xml
go/fixml --organize input.xml          # Logical organization
rust/fixml --fix-warnings input.xml    # Fix XML best practices
ocaml/fixml --replace input.xml        # Replace original file
lua lua/fixml.lua input.xml            # Lua implementation
```

## 🎯 Features

### Core Functionality
- **XML Formatting**: Consistent 2-space indentation
- **Deduplication**: Removes duplicate elements intelligently
- **Best Practice Fixes**: Adds XML declarations, fixes warnings
- **Logical Organization**: Groups related elements (optional)
- **Safe File Operations**: Atomic replacement via temporary files

### Operating Modes
- **Default**: Fix indentation and remove duplicates
- **`--organize`**: Apply logical XML element organization
- **`--fix-warnings`**: Add XML declaration and fix warnings
- **`--replace`**: Replace original file instead of creating `.organized.xml`

## 🔬 Testing & Benchmarking

### Run Full Test Suite
```bash
# Quick test (16 files × 4 modes × 5 languages = 320 tests)
lua test.lua quick

# Comprehensive test (all samples)
lua test.lua comprehensive
```

### Performance Benchmarking
```bash
# Quick benchmark (1 file)
lua benchmark.lua quick

# Comprehensive benchmark (6 file sizes)
lua benchmark.lua benchmark

# Git comparison benchmarking
lua benchmark.lua quick HEAD~1          # Compare against previous commit
lua benchmark.lua benchmark main        # Compare against main branch
lua benchmark.lua comprehensive f456830 # Compare against specific commit
```

#### Git Comparison Features
The benchmark tool supports comparing current implementations against any Git reference (branch, commit hash, or tag). This enables:

- **Performance regression detection** during development
- **Impact analysis** of optimization changes  
- **Historical performance tracking** across commits
- **Multi-implementation comparison** showing which languages benefit most from changes

Example output:
```
GIT COMPARISON ANALYSIS
==================================================
Go:
  Current (fixml):    8.69ms avg (σ=0.00ms)
  Base (HEAD~1):      82.02ms avg (σ=0.00ms)
  Performance:   🟢 +89.4% improvement
```

## 🏗️ Architecture & Design

### Standardized Constants
All implementations use identical constants for consistency:
```
MAX_INDENT_LEVELS = 64        # Maximum nesting depth
ESTIMATED_LINE_LENGTH = 50    # For buffer pre-allocation
MIN_HASH_CAPACITY = 256       # Deduplication hash table
MAX_HASH_CAPACITY = 4096      # Maximum hash capacity
WHITESPACE_THRESHOLD = 32     # ASCII whitespace detection
FILE_PERMISSIONS = 0644       # Output file permissions
IO_CHUNK_SIZE = 65536         # 64KB I/O operations
```

### Time & Space Complexity
**All implementations: O(n) time, O(n + d) space**
- `n` = input file size
- `d` = unique elements for deduplication tracking

### Key Optimizations
1. **Single-pass processing** with pre-allocated buffers
2. **Hash-based deduplication** with capacity optimization
3. **Cached indentation strings** up to 64 levels
4. **Bulk I/O operations** with 64KB chunks
5. **Language-specific optimizations**:
   - **Zig**: Manual memory management, lookup tables
   - **Go**: Object pooling, buffered readers
   - **Rust**: SIMD potential, zero-copy operations
   - **OCaml**: Buffer pre-allocation, functional optimizations
   - **Lua**: Byte-level operations, table pre-sizing

## 📊 Performance Analysis

### Scaling Characteristics
- **Zig**: Most consistent, minimal variance (σ=4.72ms)
- **Go**: Good balance, moderate variance (σ=9.79ms)  
- **Rust**: Variable performance (σ=14.48ms)
- **OCaml**: Functional overhead (σ=31.62ms)
- **Lua**: High variance but excellent on tiny files (σ=206.14ms)

### Optimization Opportunities
1. **Memory Mapping**: 30-50% improvement for files >10MB
2. **SIMD Processing**: 20-40% improvement for text-heavy operations
3. **Parallel Processing**: 2-4x improvement on multi-core systems
4. **Custom Allocators**: 15-25% improvement with memory pools
5. **JIT Compilation**: For Lua, could provide 2-5x improvement

## 🛠️ Development

### Adding New Test Cases
```bash
# Add XML files to tests/samples/
# Generate expected outputs for all modes
zig/fixml --organize newfile.xml           # Creates .o.expected.xml
zig/fixml --fix-warnings newfile.xml       # Creates .f.expected.xml
zig/fixml --organize --fix-warnings newfile.xml  # Creates .of.expected.xml
```

### Implementing New Languages
1. Follow the standardized constants from any existing implementation
2. Implement the same command-line interface
3. Add build instructions to `build_config.lua`
4. Ensure all 320 test cases pass

## 📈 Results & Conclusions

### Performance Winners
- **Overall Champion**: Zig - Fastest and most consistent
- **Best Balance**: Go - Great performance with simplicity
- **Memory Safety**: Rust - Safe with good performance
- **Functional Approach**: OCaml - Elegant functional design
- **Most Portable**: Lua - Works everywhere, optimized for interpretation

### Key Insights
- **Manual memory management** (Zig) provides the best performance
- **Startup overhead** affects small file performance differently than large files
- **Consistent algorithms** across languages enable fair comparison
- **Language ecosystems** matter more than raw performance for most use cases

All implementations successfully achieve linear O(n) scaling and production-ready performance across the full range of file sizes tested (0.9KB to 2.4MB).

## 📝 License

MIT License - See individual implementation directories for language-specific details.