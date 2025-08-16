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

For automated testing and CI/CD integration, you can generate normalized CSV output:

```bash
# Generate CSV results using shell script (recommended)
./scripts/run_csv_tests.sh test_results.csv

# Or use individual CSV test commands
zig build test-unit-csv     # Unit tests with CSV output
zig build test-blackbox-csv # Blackbox tests with CSV output
zig build test-csv          # Combined CSV output (Zig-based)
```

### CSV Format

The CSV output follows this format:
```csv
test_type,test_name,status,duration_ms,error_message
unit,validation_context_name_valid,PASS,1.23,
blackbox,save_valid_context,PASS,45.67,
unit,invalid_test,FAIL,2.34,"Expected success but got error"
```

**Fields:**
- `test_type`: "unit" or "blackbox"
- `test_name`: Descriptive test name (underscores, no spaces)
- `status`: "PASS" or "FAIL"
- `duration_ms`: Execution time in milliseconds
- `error_message`: Error details (quoted if present, empty if passed)

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