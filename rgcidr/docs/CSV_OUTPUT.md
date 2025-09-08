# CSV Output for rgcidr Test Suite

The `test.lua` script now supports CSV output format for integration with data analysis tools, spreadsheets, and automated reporting systems.

## Usage

### Standard Output (Default)
```bash
lua scripts/test.lua
```

### CSV Output
```bash
# Long form
lua scripts/test.lua --csv

# Short form  
lua scripts/test.lua -c

# Save to file
lua scripts/test.lua --csv > test_results.csv
```

### Help
```bash
lua scripts/test.lua --help
```

## CSV Format

The CSV output follows the exact specification requested:

```csv
uat,test scenario,result
rgcidr,grepcidr,basic_cidr_match,pass
rgcidr,grepcidr,boundary_cidrs,pass
rgcidr,grepcidr,cidr_mask_extremes,pass
...
```

### Column Definitions

- **uat**: Always `rgcidr,grepcidr` (Unit Acceptance Test identifier)
- **test scenario**: Name of the test case (e.g., `basic_cidr_match`)  
- **result**: Test outcome (`pass` or `fail`)

## Integration Examples

### Excel/Google Sheets
```bash
lua scripts/test.lua --csv > test_results.csv
# Import test_results.csv into Excel or Google Sheets
```

### Data Analysis (Python pandas)
```python
import pandas as pd
df = pd.read_csv('test_results.csv')
print(f"Success rate: {len(df[df['result']=='pass'])/len(df)*100:.1f}%")
```

### Automated CI/CD Reporting
```bash
# Generate CSV report
lua scripts/test.lua --csv > results.csv

# Parse results
TOTAL=$(tail -n +2 results.csv | wc -l)
PASSED=$(grep ",pass$" results.csv | wc -l) 
FAILED=$(grep ",fail$" results.csv | wc -l)

echo "Tests: $TOTAL, Passed: $PASSED, Failed: $FAILED"
```

## Features

- **Silent Mode**: In CSV mode, only CSV data is output (no build logs or progress messages)
- **Backward Compatible**: Standard output mode unchanged 
- **Error Handling**: Exit codes preserved (0 = success, 1 = failures)
- **Complete Results**: All 37 test cases included in CSV output

## Sample Output

Current test suite results (all passing):
- **Total tests**: 37
- **Passed**: 37  
- **Failed**: 0
- **Success rate**: 100.0%

The CSV format makes it easy to integrate rgcidr test results into reporting dashboards, automated quality gates, and compliance tracking systems.
