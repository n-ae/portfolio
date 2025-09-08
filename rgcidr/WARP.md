# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

rgcidr is a Zig reimplementation of grepcidr, a tool for filtering IPv4 and IPv6 addresses against CIDR (Classless Inter-Domain Routing) patterns. The project consists of both a library module and a CLI executable built with Zig 0.15.1+.

## Project Structure

The project follows Zig's standard dual-module pattern:

- `src/root.zig` - Library module root exposing the `rgcidr` module for consumers
- `src/main.zig` - Executable entry point that imports and uses the library module  
- `build.zig` - Standard Zig build configuration with module, executable, and test definitions
- `grepcidr/` - Contains the original C implementation for reference (including README, C source, and man page)

The build system creates two artifacts:
1. A library module named "rgcidr" for embedding in other Zig projects
2. An executable named "rgcidr" for standalone CLI usage

## Common Commands

### Building
```bash
# Build the executable (default)
zig build

# Build with optimizations
zig build -Doptimize=ReleaseFast
zig build -Doptimize=ReleaseSafe
zig build -Doptimize=ReleaseSmall

# Cross-compile for different targets
zig build -Dtarget=x86_64-linux
zig build -Dtarget=aarch64-macos
```

### Running
```bash
# Run the executable directly
zig build run

# Run with arguments
zig build run -- arg1 arg2

# Run installed binary
./zig-out/bin/rgcidr
```

### Testing
```bash
# Run all tests
zig build test

# Run tests with fuzzing
zig build test --fuzz

# Run library module tests only
zig build -Dtest=mod

# Run executable tests only  
zig build -Dtest=exe
```

### Development
```bash
# List all available build steps
zig build -l

# Verbose build output
zig build --verbose

# Build with debug information
zig build -Doptimize=Debug

# Fetch dependencies (if any added later)
zig build --fetch
```

### Testing
```bash
# Run the comprehensive test suite
lua scripts/test.lua

# Or run it directly (if executable)
./scripts/test.lua
```

The test suite uses a file-based approach with three types of files:
- `*.given` - Input data files
- `*.action` - Command arguments to test
- `*.expected` - Expected output files

Tests are automatically discovered from the `tests/` directory and cover all major grepcidr functionality including CIDR matching, IPv6 support, command-line flags, and proper exit codes.

## Architecture Notes

### Module Design
The project implements Zig's recommended dual-module architecture:

- **Library module** (`src/root.zig`): Provides core CIDR filtering functionality that can be imported by other Zig projects via `@import("rgcidr")`
- **Executable module** (`src/main.zig`): CLI wrapper that imports the library module and handles command-line interface

This pattern allows the same codebase to serve both as a standalone tool and as an embeddable library.

### Build System
The `build.zig` uses modern Zig 0.15.1+ build system features:
- `b.addModule()` creates the library module for external consumption
- `b.createModule()` creates the internal executable module
- Module imports system connects the executable to the library
- Separate test targets for both modules enable comprehensive testing

### Original Implementation Reference
The `grepcidr/` directory contains the original C implementation for reference, including:
- Complete C source code (`grepcidr.c`)
- Documentation (`README`, man page)
- Build system (`Makefile`)

This reference implementation handles IPv4/IPv6 CIDR matching, IP ranges, and various command-line options that should guide the Zig implementation.

## Development Context

This project is a Zig learning/portfolio project that reimplements existing C functionality. When working on features:

1. Reference the original grepcidr functionality in `grepcidr/README` for expected behavior
2. The current Zig implementation is minimal/skeletal - core CIDR logic needs implementation
3. Follow Zig conventions for error handling, memory management, and testing
4. Maintain compatibility with the library/executable dual-module pattern

The project requires Zig 0.15.1 minimum as specified in `build.zig.zon`.
