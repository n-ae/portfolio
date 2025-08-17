# Testing Structure

This directory contains comprehensive tests for the ctx application.

## Test Types

### Unit Tests (`src/unit_tests.zig`)
Fast-running tests that test individual modules in isolation:
- **Validation tests**: Test context name validation, environment variable validation, git branch validation
- **Shell tests**: Test shell detection and command generation for different shell types  
- **Context tests**: Test context manager functionality like name parsing and memory management
- **Main tests**: Test main module integration and compilation

Run with: `zig build test-unit`

### Integration Tests (`test-integration`)
Tests the main module with all dependencies:
- Tests the complete application module integration
- Ensures all modules work together correctly

Run with: `zig build test-integration`

### Blackbox Tests (`src/test.zig`)
End-to-end tests that run the actual binary as a subprocess:
- **CLI Interface Tests**: Help, version, invalid commands
- **Save Command Tests**: Valid/invalid context saving
- **List Command Tests**: Empty and populated context lists
- **Restore Command Tests**: Valid/invalid context restoration
- **Delete Command Tests**: Valid/invalid context deletion
- **Integration Workflows**: Complete save/restore/delete workflows

Run with: `zig build test-blackbox`

## Running All Tests

```bash
# Run all tests (unit + integration + blackbox)
zig build test && zig build test-blackbox

# Or run individual test suites
zig build test-unit        # Fast unit tests
zig build test-integration # Integration tests  
zig build test-blackbox    # End-to-end tests
```

## CSV Test Results

For automated testing and CI/CD integration, you can generate CSV output:

```bash
# Unit tests with CSV output
zig build test-unit-csv

# Performance benchmarks with CSV output  
zig build test-performance-csv

# Direct CSV output using unified test runner
./zig-out/bin/ctx-test-runner --type unit --format csv > unit_results.csv
./zig-out/bin/ctx-test-runner --type performance --format csv --output perf_results.csv
./zig-out/bin/ctx-test-runner --type all --format csv --output all_results.csv
```

### CSV Formats

**Unit Test CSV Format:**
```csv
unit,validation_context_name_valid,PASS,0.04,
unit,validation_env_var_valid,PASS,0.00,
unit,shell_detection,PASS,0.15,
```

**Performance Test CSV Format:**
```csv
test_name,duration_ns,iterations
string_concatenation,14110,1000
context_name_validation,117,1000
file_write,106534,1000
```

**Fields:**
- Unit tests: `test_type,test_name,status,duration_ms,error_message`
- Performance tests: `test_name,duration_ns,iterations` (nanosecond precision)

## Test Philosophy

1. **Unit tests** should run quickly and test individual functions/modules in isolation
2. **Integration tests** ensure modules work together correctly
3. **Blackbox tests** verify the complete user experience works as expected

This multi-layered approach ensures:
- Fast feedback during development (unit tests)
- Confidence in module integration (integration tests)  
- Verification of user-facing functionality (blackbox tests)

## Adding New Tests

- Add unit tests to `src/unit_tests.zig` for new functions/modules
- Integration tests are automatically included when you add tests to source files
- Add blackbox tests to `src/test.zig` for new CLI functionality

All tests should be run after each change to ensure no regressions.