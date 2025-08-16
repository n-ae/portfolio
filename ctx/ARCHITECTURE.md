# ctx CLI - Maintainable Architecture Guide

This document describes the refactored, maintainable architecture of the ctx CLI project, focusing on simplicity, clarity, and long-term maintainability.

## 🏗️ **Architecture Overview**

The ctx CLI follows a clean, modular architecture with clear separation of concerns:

```
ctx/
├── src/                          # Core application code
│   ├── main.zig                  # CLI entry point & command parsing
│   ├── context.zig               # Core ContextManager business logic
│   ├── storage.zig               # File persistence & JSON serialization
│   ├── context_commands.zig      # Shell command generation
│   ├── validation.zig            # Input validation & data structures
│   ├── shell.zig                 # Shell detection & compatibility
│   ├── config.zig                # Application configuration constants
│   │
│   ├── test_framework.zig        # Unified testing framework (NEW)
│   ├── unit_tests.zig            # Standard Zig unit tests
│   ├── unit_tests_enhanced.zig   # Enhanced tests with CSV support (NEW)
│   ├── performance_tests.zig     # Performance benchmarks (NEW)
│   └── test.zig                  # Blackbox/integration tests
│
├── scripts/                      # Build & container automation
│   ├── podman_build.zig          # Container build orchestration
│   ├── podman_test.zig           # Enhanced container testing (UPDATED)
│   └── podman_test_multiplatform.zig  # Advanced multiplatform testing
│
├── tests/                        # Performance tests & documentation
│   ├── performance/string/       # String operation benchmarks
│   └── README.md                 # Testing documentation
│
├── build.zig                     # Enhanced build system (UPDATED)
└── [Container & docs files]
```

## 🎯 **Core Design Principles**

### **1. Unified Testing Framework**
- **Single source of truth** for test result formatting
- **Multiple output formats**: Standard, CSV, JSON
- **Consistent API** across all test types
- **Performance measurement** built-in

### **2. Clear Module Boundaries**
```zig
main.zig           → CLI interface & command routing
context.zig         → Business logic & orchestration  
storage.zig         → Data persistence
context_commands.zig → Shell command generation
validation.zig      → Input validation & types
shell.zig          → Cross-shell compatibility
```

### **3. Enhanced Testing Strategy**
```
Unit Tests     → Fast feedback, isolated functions
Integration    → Module interaction testing
Blackbox       → End-to-end CLI testing
Performance    → Benchmark critical operations
Container      → Isolated environment testing
```

## 🔧 **Key Components**

### **Test Framework (`src/test_framework.zig`)**

**Purpose**: Unified testing infrastructure supporting multiple output formats.

**Key Features**:
- Automatic timing measurement
- CSV/JSON export capability
- Error message handling
- Test suite aggregation

**Usage**:
```zig
const test_functions = [_]struct { name: []const u8, func: fn () anyerror!void }{
    .{ .name = "validation_test", .func = testValidation },
    .{ .name = "context_test", .func = testContext },
};

try test_framework.runTestSuite("unit", test_functions, allocator, .csv, "results.csv");
```

### **Performance Testing (`src/performance_tests.zig`)**

**Purpose**: Systematic performance benchmarking with configurable iterations.

**Key Features**:
- Warmup iterations to stabilize measurements
- Configurable iteration counts
- Multiple benchmark categories (string ops, file I/O, context operations)
- CSV/JSON output for trend analysis

**Usage**:
```bash
./zig-out/bin/ctx-performance --csv --output performance.csv
```

### **Enhanced Unit Tests (`src/unit_tests_enhanced.zig`)**

**Purpose**: Backwards-compatible unit tests with enhanced output capabilities.

**Key Features**:
- All original unit tests preserved
- Enhanced with timing and CSV output
- Command-line argument parsing
- Dual compatibility (Zig test runner + standalone executable)

## 📊 **Build System**

### **Available Build Targets**

```bash
# Core application
zig build                        # Build main ctx executable
zig build run                    # Build and run ctx

# Standard testing  
zig build test                   # Run all standard tests
zig build test-unit              # Unit tests only
zig build test-integration       # Integration tests only
zig build test-blackbox          # Blackbox tests only

# Enhanced testing with CSV support
zig build test-unit-csv          # Unit tests → CSV output
zig build test-performance       # Performance benchmarks
zig build test-performance-csv   # Performance → CSV output
zig build test-csv               # All tests → CSV output

# Container testing
zig run scripts/podman_build.zig -- [TARGET]           # Build containers
zig run scripts/podman_test.zig -- [OPTIONS] [TYPE]    # Test in containers
```

### **CSV Output Capabilities**

All testing now supports CSV output for CI/CD integration:

```bash
# Unit tests with CSV
./zig-out/bin/ctx-unit-tests --csv --output unit_results.csv

# Performance benchmarks with CSV
./zig-out/bin/ctx-performance --csv --output perf_results.csv

# Container tests with CSV
zig run scripts/podman_test.zig -- --csv --output container_results.csv unit
```

## 🐳 **Container Infrastructure**

### **Simplified Container Strategy**

1. **Primary Container** (`Containerfile`): Production-ready Alpine Linux container
2. **Enhanced Container** (`Containerfile.multiplatform`): Multi-shell testing environment
3. **Build Scripts**: Consolidated build and test orchestration

### **Container Testing Workflow**

```bash
# Build test container
zig run scripts/podman_build.zig -- builder

# Run tests in container with CSV output
zig run scripts/podman_test.zig -- --csv unit
zig run scripts/podman_test.zig -- --csv performance  
zig run scripts/podman_test.zig -- --csv blackbox

# Advanced multiplatform testing (when needed)
zig run scripts/podman_test_multiplatform.zig -- --platform linux/amd64 blackbox
```

## 📈 **Performance Monitoring**

### **Benchmark Categories**

1. **String Operations**: Concatenation, allocation, comparison
2. **Context Operations**: Name validation, shell detection, env var parsing
3. **File I/O**: Read/write operations, JSON serialization
4. **Memory Management**: Allocation patterns, cleanup verification

### **Performance Tracking**

```csv
test_type,test_name,status,duration_ms,error_message
performance,string_concatenation,PASS,0.05,
performance,context_name_validation,PASS,0.02,
performance,file_write,PASS,1.23,
```

## 🎛️ **Configuration Management**

### **Environment Variables**
- `HOME`: Context storage location (~/.ctx/)
- `SHELL`: Shell detection override
- `TARGET_PLATFORM`: Container platform specification

### **Configuration Files**
- `src/config.zig`: Application constants
- `build.zig`: Build configuration
- `CLAUDE.md`: Development guidelines

## 🔄 **Development Workflow**

### **Adding New Features**

1. **Core Logic**: Add to appropriate module in `src/`
2. **Tests**: Add to `unit_tests_enhanced.zig` using test framework
3. **Performance**: Add benchmarks to `performance_tests.zig` if relevant
4. **Integration**: Ensure blackbox tests cover new CLI functionality
5. **Container**: Test in containerized environment

### **Testing Strategy**

```bash
# Local development testing
zig build test                    # Fast feedback
zig build test-performance        # Performance regression check

# Pre-commit testing  
zig build test-csv                # Generate CI-compatible results
zig run scripts/podman_test.zig -- all  # Container validation

# CI/CD Pipeline
zig run scripts/podman_test.zig -- --csv --output ci_results.csv all
```

## 📚 **File Organization**

### **Essential Files (Keep)**
- **Core Application**: `src/{main,context,storage,validation,shell,config,context_commands}.zig`
- **Build System**: `build.zig`, `build.zig.zon`
- **Testing Framework**: `src/test_framework.zig`, `src/unit_tests_enhanced.zig`, `src/performance_tests.zig`
- **Integration Tests**: `src/test.zig`
- **Container Infrastructure**: `Containerfile`, `scripts/podman_{build,test}.zig`
- **Documentation**: `CLAUDE.md`, `tests/README.md`, `ARCHITECTURE.md`

### **Optional Files (Advanced Use Cases)**
- **Multiplatform**: `Containerfile.multiplatform`, `scripts/podman_test_multiplatform.zig`
- **Performance Deep Dive**: `tests/performance/string/`
- **Additional Docs**: `MULTIPLATFORM.md`

### **Maintenance Notes**

- **Backwards Compatibility**: Original `unit_tests.zig` preserved for Zig test runner compatibility
- **Incremental Adoption**: Enhanced features are additive, not replacing existing functionality
- **Clear Interfaces**: Each module has well-defined responsibilities and minimal coupling
- **Testability**: All components can be tested in isolation and integration

This architecture provides a solid foundation for long-term maintainability while supporting advanced testing and deployment scenarios.