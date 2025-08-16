# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Zig-based context session manager called `ctx` - a CLI tool that saves and restores development contexts including git branches, working directories, and environment variables. The project builds an executable with comprehensive testing infrastructure.

## Build Commands

- `zig build` - Build the project (creates executable and CSV test executables)
- `zig build run` - Build and run the executable
- `zig build test` - Run all tests (unit + integration)
- `zig build test-blackbox` - Run end-to-end blackbox tests
- `zig build test-csv` - Run all tests with CSV output for CI/CD
- `zig build --release=fast` - Build optimized release version
- `zig build --help` - Show all available build options

## Architecture

The project follows standard Zig conventions:

- **src/main.zig** - Main executable entry point containing the CLI application logic
- **build.zig** - Build configuration for executable and CSV test infrastructure

### Core Components

- **ContextManager** (`src/context.zig`) - Main struct handling context operations (save/restore/list/delete)
- **Storage** (`src/storage.zig`) - File persistence layer with JSON serialization and atomic operations
- **ContextCommands** (`src/context_commands.zig`) - Shell command generation for context restoration
- **Context** (`src/validation.zig`) - Data structure storing session state (name, timestamp, git branch, working directory, environment variables, etc.)
- **Config** (`src/config.zig`) - Centralized configuration constants and limits
- **Shell** (`src/shell.zig`) - Cross-platform shell detection and command generation

### Key Dependencies

- **clap** - Command-line argument parsing (version 0.10.0 from zig-clap)

### Context Storage

Contexts are saved as JSON files in `~/.ctx/` directory. Each context file contains serialized Context struct data.

## Testing Structure

**Unit Tests** (`src/unit_tests.zig`):
- Fast-running tests for individual modules (validation, shell, context, main)
- 12 tests covering validation logic, shell detection, context management, and module integration
- Run with: `zig build test`

**Blackbox Tests** (`src/test.zig`):
- End-to-end tests that run the actual binary as subprocess
- 26 comprehensive tests covering CLI interface, save/restore/list/delete workflows
- Run with: `zig build test-blackbox`

**CSV Test Infrastructure**:
- **Unit CSV Tests** (`src/unit_tests_csv.zig`) - Unit tests with CSV output (12 tests)
- **Blackbox CSV Tests** (`src/test_csv.zig`) - Blackbox tests with CSV output (11 tests)
- **CSV Runner** (`scripts/csv_runner.zig`) - Consolidated test runner with combined results
- Combined CSV output for CI/CD integration (23 total tests)
- Run with: `zig build test-csv`

**Test All**: `zig build test && zig build test-blackbox`

## Development Notes

- **Maintainable Architecture**: Modular design with clear separation of concerns:
  - `context.zig` - Core business logic (ContextManager)
  - `storage.zig` - File persistence and JSON serialization
  - `context_commands.zig` - Shell command generation
  - `validation.zig` - Data validation and Context struct
  - `config.zig` - Centralized configuration constants
  - `shell.zig` - Cross-platform shell detection
  - `unit_tests_csv.zig` / `test_csv.zig` - CSV test infrastructure
- **Memory Management**: All allocations use GeneralPurposeAllocator with proper cleanup and defer patterns
- **Error Handling**: Standardized error propagation with separated user-facing error messages
- **Testing**: Comprehensive 3-tier testing (unit, blackbox, CSV reporting) with 23 total tests
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

- `csv_runner.zig` - Consolidated CSV test runner for CI/CD integration
- `podman_build.zig` - Container build management with memory-safe implementation
- `podman_test.zig` - Containerized test execution

## Important Instructions

**Documentation Maintenance**: Always keep documentation up to date when making changes to the codebase. This ensures consistency and helps maintain project clarity.
- Don't remove .claude