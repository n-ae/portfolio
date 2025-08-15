# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Zig-based context session manager called `ctx` - a CLI tool that saves and restores development contexts including git branches, working directories, and environment variables. The project builds both a static library and an executable.

## Build Commands

- `zig build` - Build the project (creates both library and executable)
- `zig build run` - Build and run the executable
- `zig build test` - Run unit tests for both library and executable modules
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

## Development Notes

- The executable module imports the library module via `exe_mod.addImport("ctx_lib", lib_mod)`
- Uses standard Zig JSON serialization for context persistence
- Git integration for branch tracking and switching
- Placeholder functionality exists for editor integration and shell history
- All allocations use a GeneralPurposeAllocator with proper cleanup