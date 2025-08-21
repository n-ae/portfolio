# Testing Suite

Test files and utilities for FIXML implementations.

## Test Files (`samples/`)

### Size Spectrum
- **`test-none-update.csproj`** (0.6 KB) - Tiny file with None Update elements
- **`sample-with-duplicates.csproj`** (1.2 KB) - Small file with duplicate detection
- **`Sodexo.BackOffice.Api.csproj`** (11 KB) - Medium complexity project file
- **`a.csproj`** (940 KB) - Large file for scaling tests

### Specialized Tests
- Files with various XML structures and edge cases
- MSBuild project files with different element types
- Files testing BOM handling, line ending normalization
- Complex project files from real-world scenarios

## Testing Utilities

### `fel.sh`
File comparison tool for output verification:
```bash
./fel.sh file1.csproj file2.csproj
```
- Compares XML files with BOM and whitespace handling
- Identifies structural differences
- Handles organized vs original file comparisons

## Test Categories

1. **Functional Tests** - Verify correct XML processing
2. **Performance Tests** - Scaling behavior across file sizes  
3. **Edge Case Tests** - BOM, line endings, malformed XML
4. **Deduplication Tests** - Element duplicate detection
5. **Formatting Tests** - Indentation and structure preservation

## Usage

Run tests from individual language directories:
```bash
# From lua/ directory
lua fixml.lua ../tests/samples/sample-with-duplicates.csproj

# From zig/ directory  
./fixml ../tests/samples/a.csproj

# Compare results
../tests/fel.sh original.csproj processed.organized.csproj
```

All test files are organized by complexity and use cases to provide comprehensive validation of the XML processing implementations.