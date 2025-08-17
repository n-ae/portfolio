# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Zig-based context session manager called `ctx` - a CLI tool that saves and restores development contexts including git branches, working directories, and environment variables. The project builds multiple executables with comprehensive testing infrastructure.

## Build Commands

### Core Application
- `zig build` - Build the project (creates main executable and test tools)
- `zig build run` - Build and run the executable
- `zig build --release=fast` - Build optimized release version

### Testing Commands
- `zig build test` - Run all standard tests (unit + integration)
- `zig build test-unit` - Run unit tests only
- `zig build test-unit-csv` - Run unit tests with CSV output
- `zig build test-integration` - Run integration tests only
- `zig build test-blackbox` - Run end-to-end blackbox tests
- `zig build test-performance` - Run performance benchmarks (standard output)
- `zig build test-performance-csv` - Run performance benchmarks with CSV output

### Consolidated Test Runner
- `./zig-out/bin/ctx-test-runner [OPTIONS]` - Unified test runner with configurable output
  - `--type unit|performance|all` - Select test type (default: all)
  - `--format standard|csv` - Select output format (default: standard)
  - `--output FILE` - Write results to file instead of stdout
  - Examples:
    - `./zig-out/bin/ctx-test-runner` - Run all tests, standard output
    - `./zig-out/bin/ctx-test-runner --type unit --format csv` - Unit tests with CSV
    - `./zig-out/bin/ctx-test-runner --type performance --format csv --output perf.csv` - Performance to file
- `./zig-out/bin/ctx-test <ctx-binary-path>` - Blackbox test runner

## Container Infrastructure

The project includes comprehensive containerized testing infrastructure:

- `zig run scripts/podman_build.zig -- [TARGET]` - Build container images (runtime, builder, all)
- `zig run scripts/podman_test.zig -- [OPTIONS] [TEST_TYPE]` - Run tests in containers with CSV support
  - Options: `--csv`, `--output file.csv`, `--verbose`, `--keep`
  - Types: `unit`, `blackbox`, `performance`, `all`, `interactive`

### Container Examples
```bash
# Basic container testing
zig run scripts/podman_test.zig -- unit

# Container testing with CSV output
zig run scripts/podman_test.zig -- --csv --output container_results.csv all

# Performance testing in container
zig run scripts/podman_test.zig -- performance
```

See `ARCHITECTURE.md` for maintainable architecture guidelines.

## Architecture

The project follows standard Zig conventions:

- **src/main.zig** - Main executable entry point containing the CLI application logic
- **build.zig** - Build configuration for executable and CSV test infrastructure

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

## Testing Structure

**Unit Tests** (`src/unit_tests_enhanced.zig`):
- Fast-running tests for individual modules (validation, shell, context, main)
- 12 tests covering validation logic, shell detection, context management, and module integration
- Run with: `zig build test`

**Blackbox Tests** (`src/test.zig`):
- End-to-end tests that run the actual binary as subprocess
- 26 comprehensive tests covering CLI interface, save/restore/list/delete workflows
- Run with: `zig build test-blackbox`

**Enhanced CSV Test Infrastructure**:
- **Unit Tests** (`src/unit_tests_enhanced.zig`) - Works with both standard Zig test runner and CSV output
- **Performance Tests** (`src/performance_tests.zig`) - Performance benchmarks with nanosecond precision CSV output
- **Unified Test Runner** (`src/test_runner.zig`) - Consolidated test runner with configurable output formats
- **Container CSV Testing** via `./zig-out/bin/ctx-test-runner --type unit --format csv` and `./zig-out/bin/ctx-test-runner --type performance --format csv`
- Run with: `zig build test-unit-csv` and `zig build test-performance-csv`

**Test All**: `zig build test && zig build test-blackbox`

## Development Notes

- **Maintainable Architecture**: Modular design with clear separation of concerns:
  - `context.zig` - Core business logic (ContextManager)
  - `storage.zig` - File persistence and JSON serialization
  - `validation.zig` - Data validation and Context struct
  - `config.zig` - Centralized configuration constants
  - `shell.zig` - Cross-platform shell detection
  - `unit_tests_enhanced.zig` / `performance_tests.zig` - Enhanced CSV test infrastructure
- **Memory Management**: All allocations use GeneralPurposeAllocator with proper cleanup and defer patterns
- **Error Handling**: Standardized error propagation with separated user-facing error messages
- **Testing**: Comprehensive testing (unit, blackbox, performance, CSV reporting) with 26 blackbox tests
- **Persistence**: Atomic file operations prevent corruption during context save/restore
- **Cross-Platform**: Support for multiple shells (bash, zsh, fish, cmd, powershell)
- **Git Integration**: Branch tracking and switching with proper validation

## Container Infrastructure

The project includes comprehensive container support for isolated testing:

**Containerfile**:
- Multi-stage builds for runtime (~60 MB) and builder (~200 MB) environments
- Uses Alpine Linux with package manager Zig installation for reliability
- Non-root user setup for security best practices
- Optimized for both Docker and Podman with proper caching

**Container Images**:
- `runtime` - Minimal production deployment with ctx CLI only
- `builder` - Development/testing environment with Zig, source code, and built binaries

**Build Commands**:
- `zig run scripts/podman_build.zig -- runtime` - Build runtime image
- `zig run scripts/podman_build.zig -- builder` - Build builder image  
- `zig run scripts/podman_build.zig -- all` - Build all images

**Testing Commands**:
- `zig run scripts/podman_test.zig -- unit` - Run unit tests in container
- `zig run scripts/podman_test.zig -- blackbox` - Run blackbox tests in container
- `zig run scripts/podman_test.zig -- all` - Run all tests in container
- `zig run scripts/podman_test.zig -- interactive` - Interactive container session

## Scripts Directory

All scripts are implemented in Zig for consistency and maintainability:

- `podman_build.zig` - Container build management with memory-safe implementation
- `podman_test.zig` - Containerized test execution with CSV support

## Important Instructions

**Documentation Maintenance**: Always keep documentation up to date when making changes to the codebase. This ensures consistency and helps maintain project clarity.
- Don't remove .claude
- **Always use fd instead of find**: 
  - `fd pattern` instead of `find . -name pattern`
  - `fd -e zig` instead of `find . -name "*.zig"`
  - `fd -t f pattern` for files only
- **Always use ripgrep (rg) instead of grep**:
  - `rg pattern` instead of `grep -r pattern`
  - `rg pattern --type zig` instead of `grep -r pattern *.zig`
  - `rg -n pattern` for line numbers
  - `rg -l pattern` for filenames only