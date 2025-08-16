#!/bin/bash

# CSV Test Runner for ctx
# Runs both unit and blackbox tests and outputs combined CSV results

set -e

# Default values
OUTPUT_FILE=""
QUIET=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --output-file)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--output-file <filename>] [--quiet]"
            echo "       Runs both unit and blackbox tests and outputs combined CSV results"
            echo ""
            echo "Options:"
            echo "  --output-file <filename>  Write CSV results to file instead of stdout"
            echo "  --quiet                   Only output CSV, no summary"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Temporary files for test results
UNIT_RESULTS=$(mktemp)
BLACKBOX_RESULTS=$(mktemp)
COMBINED_RESULTS=$(mktemp)

# Cleanup function
cleanup() {
    rm -f "$UNIT_RESULTS" "$BLACKBOX_RESULTS" "$COMBINED_RESULTS"
}
trap cleanup EXIT

if [ "$QUIET" = false ]; then
    echo "🧪 Running combined test suite..."
    echo ""
fi

# Run unit tests and capture CSV output
if [ "$QUIET" = false ]; then
    echo "📝 Running unit tests..."
fi

if ./zig-out/bin/ctx-unit-csv 2>/dev/null | grep -E "(test_type|unit,)" > "$UNIT_RESULTS"; then
    if [ "$QUIET" = false ]; then
        echo "✅ Unit tests completed"
    fi
else
    if [ "$QUIET" = false ]; then
        echo "⚠️  Unit tests failed to run"
    fi
fi

# Run blackbox tests and capture CSV output
if [ "$QUIET" = false ]; then
    echo "🎯 Running blackbox tests..."
fi

if ./zig-out/bin/ctx-test-csv ./zig-out/bin/ctx 2>/dev/null | grep -E "(test_type|blackbox,)" > "$BLACKBOX_RESULTS"; then
    if [ "$QUIET" = false ]; then
        echo "✅ Blackbox tests completed"
    fi
else
    if [ "$QUIET" = false ]; then
        echo "⚠️  Blackbox tests failed to run"
    fi
fi

# Combine results
echo "test_type,test_name,status,duration_ms,error_message" > "$COMBINED_RESULTS"

# Add unit test results (skip header)
if [ -s "$UNIT_RESULTS" ]; then
    tail -n +2 "$UNIT_RESULTS" >> "$COMBINED_RESULTS"
fi

# Add blackbox test results (skip header)
if [ -s "$BLACKBOX_RESULTS" ]; then
    tail -n +2 "$BLACKBOX_RESULTS" >> "$COMBINED_RESULTS"
fi

# Output results
if [ -n "$OUTPUT_FILE" ]; then
    cp "$COMBINED_RESULTS" "$OUTPUT_FILE"
    if [ "$QUIET" = false ]; then
        echo "📊 Results written to: $OUTPUT_FILE"
    fi
else
    if [ "$QUIET" = false ]; then
        echo "📊 Combined CSV Results:"
        echo ""
    fi
    cat "$COMBINED_RESULTS"
fi

# Calculate and display summary if not quiet
if [ "$QUIET" = false ]; then
    TOTAL_TESTS=$(tail -n +2 "$COMBINED_RESULTS" | wc -l | tr -d ' ')
    PASSED_TESTS=$(tail -n +2 "$COMBINED_RESULTS" | grep -c ",PASS," 2>/dev/null || echo "0")
    FAILED_TESTS=$(tail -n +2 "$COMBINED_RESULTS" | grep -c ",FAIL," 2>/dev/null || echo "0")
    UNIT_TESTS=$(tail -n +2 "$COMBINED_RESULTS" | grep -c "^unit," 2>/dev/null || echo "0")
    BLACKBOX_TESTS=$(tail -n +2 "$COMBINED_RESULTS" | grep -c "^blackbox," 2>/dev/null || echo "0")
    
    echo ""
    echo "# Test Summary"
    echo "## Results"
    echo "- Total Tests: $TOTAL_TESTS"
    echo "- Passed: $PASSED_TESTS"
    echo "- Failed: $FAILED_TESTS"
    echo "- Unit Tests: $UNIT_TESTS"
    echo "- Blackbox Tests: $BLACKBOX_TESTS"
    
    if [ "$TOTAL_TESTS" -gt 0 ]; then
        SUCCESS_RATE=$(echo "scale=1; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc -l 2>/dev/null || echo "0.0")
        echo "- Success Rate: ${SUCCESS_RATE}%"
    else
        echo "- Success Rate: 0.0%"
    fi
    
    if [ "$FAILED_TESTS" -eq 0 ]; then
        echo ""
        echo "🎉 All tests passed!"
    else
        echo ""
        echo "💥 $FAILED_TESTS tests failed!"
        exit 1
    fi
fi