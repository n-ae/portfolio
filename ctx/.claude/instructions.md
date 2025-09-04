# Claude Code Instructions for ctx Project

## Project Overview

This is a Zig-based context session manager called `ctx` - a CLI tool that saves and restores development contexts including git branches, working directories, and environment variables. The project has undergone significant consolidation to eliminate duplication and improve maintainability.

## Core Principles

### 1. Parameter-Driven Design Over Binary Proliferation
- **NEVER** create separate binaries when functionality can be achieved via parameters
- Use unified test runner (`src/test_runner.zig`) with configurable options instead of multiple specialized executables
- Example: `./zig-out/bin/ctx-test-runner --type unit --format csv` instead of separate `ctx-unit-csv` binary

### 2. Maintainable Architecture
- Modular design with clear separation of concerns
- Each module has well-defined responsibilities and minimal coupling
- Function complexity should be kept low (prefer multiple focused functions over large complex ones)

### 3. Comprehensive Testing Strategy
- **Unit Tests** (`src/unit_tests.zig`) - Fast feedback, isolated functions, works with both Zig test runner and CSV output
- **Integration Tests** - Module interaction testing
- **Blackbox Tests** (`src/test.zig`) - End-to-end CLI testing with subprocess execution
- **Performance Tests** (`src/performance_tests.zig`) - Benchmarking with nanosecond precision CSV output
- **Container Tests** - Isolated environment testing via Podman scripts

### 4. Documentation as Single Source of Truth
- **README.md** is the primary documentation file (consolidated from ARCHITECTURE.md, tests/README.md, CLAUDE.md)
- Always update documentation when making changes
- Maintain consistency between code and documentation

## Build, Test, and Run

For detailed information on building, testing, and running the project, please see the following sections in the main `README.md` file:

*   **[Build and Run](../README.md#build-and-run)**
*   **[Testing](../README.md#testing)**
*   **[Container Infrastructure](../README.md#container-infrastructure)**

## Code Organization

For a detailed breakdown of the project's architecture and code organization, please see the **[Architecture](../README.md#architecture)** section in the main `README.md` file.

## Development Guidelines

### Code Quality Standards
1. **Memory Management**: Use GeneralPurposeAllocator with proper cleanup and defer patterns
2. **Error Handling**: Standardized error propagation with user-facing error messages
3. **Function Complexity**: Keep functions focused and simple (extract complex logic into separate functions)
4. **Testing**: Add comprehensive tests for all new functionality
5. **Documentation**: Update README.md when making architectural changes

### Testing Requirements
- Add unit tests to `src/unit_tests.zig` for new functions/modules
- Add blackbox tests to `src/test.zig` for new CLI functionality
- Add performance benchmarks to `src/performance_tests.zig` for performance-critical features
- Verify container testing works with new changes

### Tool Preferences
- **Always use `fd` instead of `find`**:
  - `fd pattern` instead of `find . -name pattern`
  - `fd -e zig` instead of `find . -name "*.zig"`
- **Always use `rg` (ripgrep) instead of `grep`**:
  - `rg pattern` instead of `grep -r pattern`
  - `rg pattern --type zig` for Zig files only
  - `rg -n pattern` for line numbers

## Project History & Context

### Major Consolidation (2025-08-17)
- **Eliminated Duplication**: Removed `unit_tests_enhanced.zig`, consolidated into `unit_tests.zig`
- **Unified Test Runner**: Created `src/test_runner.zig` to replace multiple specialized binaries
- **Parameter-Driven Design**: Reduced from 4 executables to 2 via parameter configuration
- **Documentation Consolidation**: Merged ARCHITECTURE.md, tests/README.md, CLAUDE.md into README.md
- **Function Complexity Reduction**: Extracted `captureCurrentContext` into focused functions
- **Added Missing Functionality**: Implemented `restoreContext` method that was being called but didn't exist

### Quality Improvements
- Fixed CSV output formatting issues (proper newlines instead of `\\n` literals)
- Implemented proper memory management with allocator cleanup
- Added comprehensive error handling and validation
- Established maintainable architecture assessment process

## Key Constraints & Requirements

### What NOT to Do
- **Do NOT** create separate binaries when parameters can achieve the same functionality
- **Do NOT** duplicate logic across multiple files
- **Do NOT** leave functions overly complex (extract into smaller focused functions)
- **Do NOT** forget to update documentation when making changes
- **Do NOT** assume libraries are available without checking (verify in package.json, build.zig.zon, etc.)

### What TO Do
- **DO** use parameter-driven design
- **DO** maintain comprehensive test coverage
- **DO** keep documentation up to date
- **DO** follow memory safety patterns
- **DO** use the unified test runner for all testing needs
- **DO** verify container infrastructure works with changes

## CSV Output Support

For details on generating CSV output for test results, please see the **[CSV Test Output](../README.md#csv-test-output)** section in the main `README.md` file.

## Maintainability Assessment

The project undergoes regular maintainability assessments stored in `reports/` directory. Key metrics include:
- Function complexity
- Code duplication
- Test coverage
- Documentation accuracy
- Architecture adherence

When making changes, consider the impact on long-term maintainability and follow the established patterns for consistency.