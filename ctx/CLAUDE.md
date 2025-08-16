# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Zig-based context session manager called `ctx` - a CLI tool that saves and restores development contexts including git branches, working directories, and environment variables. The project builds both a static library and an executable.

## Build Commands

- `zig build` - Build the project (creates both library and executable)
- `zig build run` - Build and run the executable
- `zig build test` - Run all tests (unit + integration)
- `zig build test-unit` - Run fast unit tests only
- `zig build test-integration` - Run integration tests only
- `zig build test-blackbox` - Run end-to-end blackbox tests
- `./scripts/run_csv_tests.sh` - Generate CSV test results for CI/CD
- `zig build --release=fast` - Build optimized release version
- `zig build --help` - Show all available build options

## Architecture

The project follows standard Zig conventions:

- **src/main.zig** - Main executable entry point containing the CLI application logic
- **src/root.zig** - Library entry point with a simple add function (mostly boilerplate)
- **build.zig** - Build configuration creating two modules:
  - `lib_mod` - Static library module (root: src/root.zig)
  - `exe_mod` - Executable module (root: src/main.zig) that imports the library

### Core Components

- **ContextManager** - Main struct handling context operations (save/restore/list/delete)
- **Context** - Data structure storing session state (name, timestamp, git branch, working directory, environment variables, etc.)
- **SubCommand** - Enum defining CLI commands (save, restore, list, delete)

### Key Dependencies

- **clap** - Command-line argument parsing (version 0.10.0 from zig-clap)

### Context Storage

Contexts are saved as JSON files in `~/.ctx/` directory. Each context file contains serialized Context struct data.

## Testing Structure

**Unit Tests** (`src/unit_tests.zig`):
- Fast-running tests for individual modules (validation, shell, context, main)
- Test validation logic, shell detection, context management, and module integration
- Run with: `zig build test-unit`

**Integration Tests** (built into main module):
- Test complete module integration and ensure all components work together
- Run with: `zig build test-integration`

**Blackbox Tests** (`src/test.zig`):
- End-to-end tests that run the actual binary as subprocess
- 26 comprehensive tests covering CLI interface, save/restore/list/delete workflows
- Run with: `zig build test-blackbox`

**Test All**: `zig build test && zig build test-blackbox`

## Development Notes

- Modular architecture with separated concerns (validation.zig, shell.zig, context.zig, main.zig)
- Uses standard Zig JSON serialization for context persistence
- Cross-platform shell detection and command generation (bash, zsh, fish, cmd, powershell)
- Git integration for branch tracking and switching
- Resilient context save/restore with atomic file operations
- All allocations use a GeneralPurposeAllocator with proper cleanup
- Code follows Martin Fowler refactoring principles for maintainability