# ctx - Development Context Session Manager

A Zig-based CLI tool for saving and restoring development contexts including git branches, working directories, and environment variables. Built with maintainable architecture and comprehensive testing infrastructure.

## Quick Start

```bash
# Build the project
zig build

# Save current development context
./zig-out/bin/ctx save feature-work

# List saved contexts
./zig-out/bin/ctx list

# Restore a context
./zig-out/bin/ctx restore feature-work

# Delete a context
./zig-out/bin/ctx delete feature-work
```

## Installation

```bash
# Build optimized release version
zig build --release=fast

# The ctx binary will be available at ./zig-out/bin/ctx
```

## Architecture

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
│   ├── test.zig                  # Unified test runner
│   ├── .performance.test.zig     # Performance benchmarks
│   ├── .blackbox.test.zig        # End-to-end blackbox tests
│   ├── validation.unit.test.zig  # Validation module unit tests
│   ├── shell.unit.test.zig       # Shell module unit tests
│   ├── context.unit.test.zig     # Context module unit tests
│   └── main.integration.test.zig # Integration tests
├── scripts/                      # Build & container automation
│   ├── podman_build.zig          # Container build orchestration
│   └── podman_test.zig           # Container testing with CSV support
├── build.zig                     # Build system configuration
└── Containerfile                 # Multi-stage container builds
```

### Core Components

- **ContextManager** (`src/context.zig`) - Main struct handling context operations (save/restore/list/delete)
- **Storage** (`src/storage.zig`) - File persistence layer with JSON serialization and atomic operations
- **Context** (`src/validation.zig`) - Data structure storing session state (name, timestamp, git branch, working directory, environment variables, etc.)
- **Config** (`src/config.zig`) - Centralized configuration constants and limits
- **Shell** (`src/shell.zig`) - Cross-platform shell detection and command generation

### Key Dependencies

- **clap** - Command-line argument parsing (version 0.10.0 from zig-clap)

### Context Storage

Contexts are saved as JSON files in `~/.ctx/` directory. Each context file contains serialized Context struct data.

## Build Commands

### Core Application
- `zig build` - Build the project (creates main executable and test tools)
- `zig build run` - Build and run the executable
- `zig build --release=fast` - Build optimized release version

### Testing Commands
- `zig build test` - Run all tests (unit + integration + performance + blackbox)
- `zig build test -- [OPTIONS]` - Run specific tests with options

**Test Runner Options:**
- `--type unit|integration|performance|blackbox|all` - Select test type (default: all)
- `--format standard|csv` - Select output format (default: standard)
- `--output FILE` - Write results to file instead of stdout

**Examples:**
- `zig build test` - Run all tests with standard output
- `zig build test -- --type unit` - Run unit tests only
- `zig build test -- --type integration` - Run integration tests only
- `zig build test -- --type blackbox` - Run blackbox tests only
- `zig build test -- --type unit --format csv` - Unit tests with CSV output
- `zig build test -- --type performance --format csv --output perf.csv` - Performance tests to file

## Testing Structure

### Test Types

**Unit Tests** (individual `*.unit.test.zig` files):
- `validation.unit.test.zig` - Context name and environment variable validation tests
- `shell.unit.test.zig` - Shell detection and command formatting tests  
- `context.unit.test.zig` - Context manager memory management tests
- Fast-running tests for individual modules in isolation
- Run via standard Zig test runner

**Integration Tests** (`main.integration.test.zig`):
- Tests module dependencies and configuration constants
- Ensures all modules work together correctly
- Verifies application-level integration

**Blackbox Tests** (`.blackbox.test.zig`):
- End-to-end tests that run the actual binary as subprocess
- 26 comprehensive tests covering CLI interface, save/restore/list/delete workflows
- Tests include: CLI interface, save/restore/list/delete commands, complete workflows

**Performance Tests** (`.performance.test.zig`):
- Systematic performance benchmarking with configurable iterations
- Warmup iterations to stabilize measurements
- Multiple benchmark categories (string ops, file I/O, context operations)
- CSV output for trend analysis

### Running Tests

```bash
# Run all tests (unit + integration + performance + blackbox)
zig build test

# Run individual test suites
zig build test -- --type unit         # Fast unit tests
zig build test -- --type integration  # Integration tests
zig build test -- --type blackbox     # End-to-end tests
zig build test -- --type performance  # Performance benchmarks
```

### CSV Test Output

For automated testing and CI/CD integration:

```bash
# Unit tests with CSV output
zig build test -- --type unit --format csv

# Performance benchmarks with CSV output
zig build test -- --type performance --format csv --output perf_results.csv

# All tests with CSV output
zig build test -- --type all --format csv --output all_results.csv
```

**CSV Formats:**

Unit Test CSV Format:
```csv
test_type,test_name,status,duration_ms,error_message
unit,validation_context_name_valid,PASS,0.04,
unit,validation_env_var_valid,PASS,0.00,
unit,shell_detection,PASS,0.15,
```

Performance Test CSV Format:
```csv
test_name,duration_ns,iterations
string_concatenation,14110,1000
context_name_validation,117,1000
file_write,106534,1000
```

## Container Infrastructure

The project includes comprehensive containerized testing infrastructure:

### Container Commands

```bash
# Build container images
zig run scripts/podman_build.zig -- [TARGET]    # runtime, builder, all

# Run tests in containers with CSV support
zig run scripts/podman_test.zig -- [OPTIONS] [TEST_TYPE]
  # Options: --csv, --output file.csv, --verbose, --keep
  # Types: unit, blackbox, performance, all, interactive
```

### Container Examples

```bash
# Basic container testing
zig run scripts/podman_test.zig -- unit

# Container testing with CSV output
zig run scripts/podman_test.zig -- --csv --output container_results.csv all

# Performance testing in container
zig run scripts/podman_test.zig -- performance

# Interactive container session
zig run scripts/podman_test.zig -- interactive
```

### Container Strategy

1. **Runtime Container** (`Containerfile`): Minimal production-ready Alpine Linux container (~60 MB)
2. **Builder Container**: Development/testing environment with Zig, source code, and built binaries (~200 MB)
3. **Build Scripts**: Consolidated build and test orchestration using Zig

## Performance Monitoring

### Benchmark Categories

1. **String Operations**: Concatenation, allocation, comparison
2. **Context Operations**: Name validation, shell detection, env var parsing
3. **File I/O**: Read/write operations, context serialization
4. **Memory Management**: Allocation patterns, cleanup verification

### Performance Tracking

Performance tests generate CSV output with nanosecond precision for trend analysis:

```bash
# Run performance benchmarks
./zig-out/bin/ctx-test-runner --type performance --format csv --output performance.csv
```

## Development Guidelines

### Core Design Principles

1. **Maintainable Architecture**: Modular design with clear separation of concerns
2. **Parameter-Driven Design**: Use CLI parameters instead of separate binaries
3. **Comprehensive Testing**: Multiple test types (unit, integration, blackbox, performance)
4. **Memory Safety**: All allocations use GeneralPurposeAllocator with proper cleanup
5. **Cross-Platform Support**: Multiple shells (bash, zsh, fish, cmd, powershell)

### Memory Management
- All allocations use GeneralPurposeAllocator with proper cleanup and defer patterns
- Standardized error propagation with separated user-facing error messages

### Git Integration
- Branch tracking and switching with proper validation
- Atomic file operations prevent corruption during context save/restore

### Adding New Features

1. **Core Logic**: Add to appropriate module in `src/`
2. **Tests**: Add to appropriate `*.unit.test.zig` file for the module being tested
3. **Performance**: Add benchmarks to `.performance.test.zig` if relevant
4. **Integration**: Ensure blackbox tests cover new CLI functionality
5. **Container**: Test in containerized environment

### Development Workflow

```bash
# Local development testing
zig build test                                        # Fast feedback (all tests)
zig build test -- --type performance                 # Performance regression check

# Pre-commit testing
zig build test -- --type unit --format csv --output unit_results.csv
zig build test -- --type performance --format csv --output perf_results.csv
zig run scripts/podman_test.zig -- all  # Container validation

# CI/CD Pipeline
zig run scripts/podman_test.zig -- --csv --output ci_results.csv all
```

## Configuration

### Environment Variables
- `HOME`: Context storage location (~/.ctx/)
- `SHELL`: Shell detection override

### Configuration Files
- `src/config.zig`: Application constants
- `build.zig`: Build configuration

## Tool Preferences

- **Always use `fd` instead of `find`**: 
  - `fd pattern` instead of `find . -name pattern`
  - `fd -e zig` instead of `find . -name "*.zig"`
  - `fd -t f pattern` for files only
- **Always use `rg` (ripgrep) instead of `grep`**:
  - `rg pattern` instead of `grep -r pattern`
  - `rg pattern --type zig` instead of `grep -r pattern *.zig`
  - `rg -n pattern` for line numbers
  - `rg -l pattern` for filenames only

## Contributing

1. Follow the maintainable architecture principles
2. Add comprehensive tests for new functionality
3. Update documentation when making changes
4. Run all tests before submitting changes
5. Use the unified test runner for consistent testing

This project prioritizes long-term maintainability through clear architecture, comprehensive testing, and parameter-driven design over binary proliferation.
