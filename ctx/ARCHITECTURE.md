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
│   ├── validation.zig            # Input validation & data structures
│   ├── shell.zig                 # Shell detection & compatibility
│   ├── config.zig                # Application configuration constants
│   │
│   │
│   ├── unit_tests.zig            # Standard Zig unit tests
│   ├── unit_tests_enhanced.zig   # Enhanced tests with CSV support (NEW)
│   ├── performance_tests.zig     # Performance benchmarks (NEW)
│   └── test.zig                  # Blackbox/integration tests
│
├── scripts/                      # Build & container automation
│   ├── podman_build.zig          # Container build orchestration
│   ├── podman_test.zig           # Enhanced container testing (UPDATED)
│
├── tests/performance/string/     # Legacy string operation benchmarks
│   ├── benchmark.zig             # String benchmark implementations  
│   └── performance_test.zig      # String performance test
├── tests/README.md               # Testing documentation
│
├── build.zig                     # Enhanced build system (UPDATED)
└── [Container & docs files]
```

## 🎯 **Core Design Principles**

### **1. Simplified Testing Approach**
- **Standard Zig test runner** for core functionality
- **CSV output support** via dedicated executables
- **Performance benchmarking** with configurable parameters
- **Multiple test types**: Unit, integration, blackbox, performance

### **2. Clear Module Boundaries**
```zig
main.zig           → CLI interface & command routing
context.zig         → Business logic & orchestration  
storage.zig         → Data persistence
config.zig → Application configuration
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

### **Consolidated Testing Approach**

**Current Implementation**: Tests use a unified test runner with configurable output formats and test types.

**Available Test Commands**:
- `zig build test-unit-csv` - Unit tests with CSV output
- `zig build test-performance` - Performance benchmarks (standard output)
- `zig build test-performance-csv` - Performance benchmarks with CSV output
- `./zig-out/bin/ctx-test-runner --type unit --format csv` - Direct CSV unit test output
- `./zig-out/bin/ctx-test-runner --type performance --format csv` - CSV performance results

### **Performance Testing (`src/performance_tests.zig`)**

**Purpose**: Systematic performance benchmarking with configurable iterations.

**Key Features**:
- Warmup iterations to stabilize measurements
- Configurable iteration counts
- Multiple benchmark categories (string ops, file I/O, context operations)
- CSV output for trend analysis

**Usage**:
```bash
./zig-out/bin/ctx-test-runner --type performance --format csv --output performance.csv
```

### **Unit Tests (`src/unit_tests_enhanced.zig`)**

**Purpose**: Comprehensive unit tests with dual output capabilities.

**Key Features**:
- Works with standard Zig test runner (`zig build test`)
- Enhanced with timing measurement and CSV output via test runner
- Memory-safe with proper allocator management
- Modular test functions for external consumption

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
zig build test-performance       # Performance benchmarks (standard output)
zig build test-performance-csv   # Performance benchmarks → CSV output

# Container testing
zig run scripts/podman_build.zig -- [TARGET]           # Build containers
zig run scripts/podman_test.zig -- [OPTIONS] [TYPE]    # Test in containers
```

### **CSV Output Capabilities**

All testing now supports CSV output for CI/CD integration via the unified test runner:

```bash
# Unit tests with CSV
./zig-out/bin/ctx-test-runner --type unit --format csv > unit_results.csv

# Performance benchmarks with CSV
./zig-out/bin/ctx-test-runner --type performance --format csv --output perf_results.csv

# All tests with CSV
./zig-out/bin/ctx-test-runner --type all --format csv --output all_results.csv

# Container tests with CSV
zig run scripts/podman_test.zig -- --csv --output container_results.csv unit
```

## 🐳 **Container Infrastructure**

### **Container Strategy**

1. **Primary Container** (`Containerfile`): Production-ready Alpine Linux container
2. **Build Scripts**: Consolidated build and test orchestration

### **Container Testing Workflow**

```bash
# Build test container
zig run scripts/podman_build.zig -- builder

# Run tests in container with CSV output
zig run scripts/podman_test.zig -- --csv unit
zig run scripts/podman_test.zig -- --csv performance  
zig run scripts/podman_test.zig -- --csv blackbox
```

## 📈 **Performance Monitoring**

### **Benchmark Categories**

1. **String Operations**: Concatenation, allocation, comparison
2. **Context Operations**: Name validation, shell detection, env var parsing
3. **File I/O**: Read/write operations, context serialization
4. **Memory Management**: Allocation patterns, cleanup verification

### **Performance Tracking**

```csv
test_name,duration_ns,iterations
string_concatenation,13035,1000
context_name_validation,117,1000
file_write,106534,1000
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
2. **Tests**: Add to `unit_tests_enhanced.zig` (standard Zig tests + CSV capability via test runner)
3. **Performance**: Add benchmarks to `performance_tests.zig` if relevant
4. **Integration**: Ensure blackbox tests cover new CLI functionality
5. **Container**: Test in containerized environment

### **Testing Strategy**

```bash
# Local development testing
zig build test                    # Fast feedback
zig build test-performance        # Performance regression check

# Pre-commit testing  
zig build test-unit-csv           # Generate CSV unit test results
zig build test-performance-csv    # Performance benchmarks with CSV
zig run scripts/podman_test.zig -- all  # Container validation

# CI/CD Pipeline
zig run scripts/podman_test.zig -- --csv --output ci_results.csv all
```

## 📚 **File Organization**

### **Essential Files (Keep)**
- **Core Application**: `src/{main,context,storage,validation,shell,config}.zig`
- **Build System**: `build.zig`, `build.zig.zon`
- **Testing Infrastructure**: `src/unit_tests_enhanced.zig`, `src/performance_tests.zig`, `src/test.zig`, `src/test_runner.zig`
- **Container Infrastructure**: `Containerfile`, `scripts/podman_{build,test}.zig`
- **Documentation**: `CLAUDE.md`, `tests/README.md`, `ARCHITECTURE.md`

### **Optional Files (Advanced Use Cases)**
- **Performance Deep Dive**: `tests/performance/string/`

### **Maintenance Notes**

- **Unified Testing**: Single test file (`unit_tests_enhanced.zig`) works with both Zig test runner and external test runner
- **Parameter-Driven**: Features controlled via CLI parameters rather than separate binaries
- **Clear Interfaces**: Each module has well-defined responsibilities and minimal coupling
- **Testability**: All components can be tested in isolation and integration

This architecture provides a solid foundation for long-term maintainability while supporting advanced testing and deployment scenarios.