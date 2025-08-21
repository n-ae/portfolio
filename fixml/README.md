# FIXML - High-Performance XML Processor

A collection of optimized XML processors implemented in 5 languages, focused on deduplication, formatting, and XML best practices.

## 🚀 Latest Optimized Implementations

### **Final Versions (O(n) time/space complexity)**

| Language | Version | Location | Performance |
|----------|---------|----------|-------------|
| **Zig** | v2.0.0 | `zig/fixml` | 🥇 **3.51ms avg** |
| **Rust** | v2.0.0 | `rust/fixml` | 🥈 **4.60ms avg** |
| **Go** | v2.0.0 | `go/fixml` | 🥉 **12.94ms avg** |
| **OCaml** | v2.0.0 | `ocaml/fixml` | **25.67ms avg** |
| **Lua** | v5.0.0 | `lua fixml.lua` | **50.45ms avg** |

## 📁 Directory Structure

```
fixml/
├── lua/                        # Lua implementation v5.0.0
│   ├── fixml.lua              # Ultra-optimized Lua source
│   └── README.md
├── go/                         # Go implementation v2.0.0  
│   ├── fixml                  # Compiled binary
│   ├── fixml.go               # Go source code
│   └── README.md
├── rust/                       # Rust implementation v2.0.0
│   ├── fixml                  # Compiled binary
│   ├── fixml.rs               # Rust source code  
│   └── README.md
├── zig/                        # Zig implementation v2.0.0 🏆
│   ├── fixml                  # macOS ARM64 binary
│   ├── fixml_linux_x64        # Linux AMD64 binary
│   ├── fixml_windows_x64.exe  # Windows AMD64 binary
│   ├── src/fixml_simple.zig   # Zig source code
│   └── README.md
├── ocaml/                      # OCaml implementation v2.0.0
│   ├── fixml                  # Compiled binary  
│   ├── fixml.ml               # OCaml source code
│   └── README.md
├── benchmarks/                 # Performance benchmarking suite
│   ├── final_benchmark.py     # Primary comprehensive benchmark
│   ├── lua_optimization_benchmark.py
│   └── README.md
├── tests/                      # Test files and utilities
│   ├── samples/               # XML test files (0.6KB - 940KB)
│   ├── fel.sh                 # File comparison utility
│   └── README.md
└── README.md                   # This file
```

## ⚡ Performance Benchmarks

All implementations achieve **O(n) time and space complexity** through:

- **Single-pass processing** eliminates O(n²) string operations
- **Capacity pre-allocation** minimizes garbage collection  
- **Bulk operations** reduce system call overhead

### **Scaling Verification (0.6KB → 940KB = 1567x larger)**

| Implementation | Scale Factor | Efficiency | Status |
|---------------|--------------|------------|--------|
| **Zig v2.0.0** | 1.4x slower | 1119% efficient | 🟢 **EXCELLENT** |
| **Rust v2.0.0** | 1.2x slower | 1306% efficient | 🟢 **EXCELLENT** |
| **Go v2.0.0** | 8.7x slower | 180% efficient | ✅ **LINEAR** |
| **OCaml v2.0.0** | 7.9x slower | 198% efficient | ✅ **LINEAR** |
| **Lua v5.0.0** | 40.3x slower | 38.9% efficient | 🟡 **GOOD** |

## 🛠️ Usage

### **Basic Usage**
```bash
# Zig (fastest)
zig/fixml tests/samples/sample-with-duplicates.csproj

# Rust (most consistent)  
rust/fixml tests/samples/sample-with-duplicates.csproj

# Lua (most portable)
cd lua && lua fixml.lua ../tests/samples/sample-with-duplicates.csproj
```

### **Advanced Options**
```bash
# Fix XML warnings automatically
zig/fixml --fix-warnings tests/samples/test-none-update.csproj

# Apply logical organization  
rust/fixml --organize tests/samples/Sodexo.BackOffice.Api.csproj

# Replace original file atomically
go/fixml --replace tests/samples/a.csproj
```

## 🔬 Benchmarking

### **Primary Benchmark**
```bash
cd benchmarks && python3 final_benchmark.py
```

### **Lua Optimization Analysis**  
```bash
cd benchmarks && python3 lua_optimization_benchmark.py
```

## ✨ Key Features

- ⚡ **High Performance** - O(n) complexity across all implementations
- 🔄 **Deduplication** - Removes duplicate XML elements intelligently  
- 📐 **Formatting** - Consistent 2-space indentation
- 🏥 **XML Best Practices** - Warnings and auto-fixes
- 🔒 **Atomic Operations** - Safe file replacement via temp files
- 📊 **Cross-Language** - Compare 5 different language implementations

## 🎯 Optimization Techniques

### **Universal Optimizations**
1. **Single-pass algorithms** replace multi-pass regex operations
2. **Pre-allocated buffers** with capacity hints
3. **Bulk string operations** instead of character-by-character 
4. **Hash-based deduplication** with efficient key generation
5. **Cached indentation** strings to avoid repeated allocations

### **Language-Specific**
- **Zig/Rust**: Direct memory control, zero-cost abstractions
- **Go**: Efficient garbage collection, string builders  
- **OCaml**: Functional optimizations, buffer pre-allocation
- **Lua**: Byte-level operations, chunked I/O, custom iterators

## 📈 Results Summary

**Champion: Zig v2.0.0** - Maximum performance through systems programming
**Runner-up: Rust v2.0.0** - Excellent consistency with memory safety  
**Bronze: Go v2.0.0** - Great balance of performance and simplicity
**OCaml v2.0.0** - Solid functional approach with good scaling
**Lua v5.0.0** - Impressive optimization for interpreted language (+27.4% vs v4.0.0)

All implementations successfully converted **quadratic behavior to linear scaling**, achieving production-ready performance across file sizes from 0.6KB to 1MB+.