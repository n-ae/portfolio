# Project Memory and Context

## Current State Summary

### Project Status
- **Repository**: /Users/username/dev/portfolio/ctx
- **Primary Branch**: main
- **Last Major Work**: Documentation consolidation and maintainability improvements (2025-08-17)
- **Current Phase**: Stable, consolidated architecture with comprehensive testing

### Recent Major Changes
1. **Code Consolidation**: Eliminated duplicate test infrastructure, unified into parameter-driven design
2. **Documentation Consolidation**: Created single README.md from multiple documentation files
3. **Testing Enhancement**: Implemented unified test runner with CSV support
4. **Architecture Improvements**: Function complexity reduction, missing method implementation

## Key Technical Details

### Dependencies
- **clap**: Command-line argument parsing (version 0.10.0 from zig-clap)
- **Zig**: Primary development language
- **Alpine Linux**: Container base image
- **Podman**: Container runtime (Docker compatible)

### Technical Architecture

For a detailed breakdown of the project's technical architecture, file structure, build system, and testing strategy, please refer to the following documents:

*   **[Main README](../README.md)**: For the primary project documentation.
*   **[AI Instructions](./instructions.md)**: For AI-specific development guidelines.

## Critical Implementation Details

### Memory Management Pattern
```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
defer _ = gpa.deinit();
const allocator = gpa.allocator();
// Always use defer patterns for cleanup
```

### CSV Output and Commands

For details on CSV output formats and a quick reference for testing commands, please see the following documents:

*   **[Main README](../README.md)**: For the primary project documentation on testing and CSV output.
*   **[AI Instructions](./instructions.md)**: For AI-specific guidelines on testing and development.

## User Preferences and Requirements

### Explicit User Feedback
1. **"Why do we need unit_tests.zig still?"** - Led to consolidation eliminating duplication
2. **"Remove any duplicated logic like that. If a functionality is possible via a parameter etc. don't introduce another binary, build step etc."** - Core principle for parameter-driven design
3. **"Ensure that the docs reflect latest changes"** - Led to documentation consolidation

### Design Philosophy
- **Parameter-driven over binary proliferation**: Single test runner with options vs multiple binaries
- **Single source of truth**: README.md consolidates all documentation
- **Maintainable architecture**: Clear module boundaries, minimal coupling
- **Comprehensive testing**: Multiple test types with CSV output for CI/CD

## Tool and Command Preferences
- **Search**: Use `rg` (ripgrep) instead of `grep`
- **Find**: Use `fd` instead of `find`
- **Container**: Podman preferred (Docker compatible)
- **Testing**: Always verify with all test types before considering complete

## Known Issues and Solutions

### Fixed Issues
1. **Missing `restoreContext` method**: Implemented complete method with proper error handling
2. **CSV output formatting**: Fixed string literals to use proper newlines
3. **Function pointer compilation**: Updated type definitions for Zig compiler requirements
4. **Duplicate test infrastructure**: Consolidated into unified approach

### Architecture Strengths
- Modular design with clear separation of concerns
- Memory-safe with proper allocator usage
- Cross-platform shell support
- Atomic file operations prevent corruption
- Comprehensive error handling

## Project Evolution Timeline

### Previous Session Work
- Code consolidation and duplication elimination
- CSV test support implementation
- Function complexity reduction
- Command generation refactoring

### Current Session Work
- Maintainability assessment creation (56 findings across 8 categories)
- Quality improvements based on assessment
- Major consolidation removing duplicate logic
- Documentation consolidation into single README.md
- Creation of .claude instruction and memory files


This memory serves as a comprehensive context for future Claude Code sessions working on this project.
