# Zig Implementation v2.0.0 (Optimized)

Ultra-high-performance Zig XML processor - **Champion** 🏆

## Files
- `fixml-aarch64-macos` - Native macOS binary (ARM64)
- `fixml-x86_64-linux` - Linux AMD64 binary  
- `fixml-x86_64-windows.exe` - Windows AMD64 binary
- `src/main.zig` - Zig source code (v2.0.0)

## Usage
```bash
./fixml-aarch64-macos [options] <xml-file>

# For Linux
./fixml-x86_64-linux [options] <xml-file>

# For Windows
./fixml-x86_64-windows.exe [options] <xml-file>

Options:
  --organize, -o      Apply logical organization
  --replace, -r       Replace original file
  --fix-warnings, -f  Fix XML warnings
```

## Performance
- **Average**: 3.51ms across test files 🥇 **CHAMPION**
- **Scaling**: 1.4x slower (1119% efficient) - **EXCELLENT** linear scaling
- **Consistency**: σ=0.75ms (very stable)

## Key Optimizations
- Direct memory control with zero-cost abstractions
- Single-pass processing with pre-allocated capacity
- Bulk operations using buffer slices
- Efficient byte-level string operations
- Custom indentation buffer to avoid allocations
- Systems-level performance optimizations

## Building from Source

This project is built with Zig version 0.15.1. You can build it for different targets using the following commands:

- **macOS (aarch64):**
  ```bash
  zig build -Dtarget=aarch64-macos
  ```
- **Linux (x86_64):**
  ```bash
  zig build -Dtarget=x86_64-linux
  ```
- **Windows (x86_64):**
  ```bash
  zig build -Dtarget=x86_64-windows
  ```

The compiled binaries will be located in the `zig-out/bin` directory.
