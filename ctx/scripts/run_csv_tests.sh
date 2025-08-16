#!/bin/bash

# Simple CSV Test Runner
# Combines unit and blackbox test outputs into a single CSV

OUTPUT_FILE="${1:-test_results.csv}"

echo "🧪 Running CSV tests..."

# Create header
echo "test_type,test_name,status,duration_ms,error_message" > "$OUTPUT_FILE"

# Run unit tests and append (skip header)
echo "📝 Running unit tests..."
./zig-out/bin/ctx-unit-csv 2>/dev/null | grep "^unit," >> "$OUTPUT_FILE"

# Run blackbox tests and append (skip header)  
echo "🎯 Running blackbox tests..."
./zig-out/bin/ctx-test-csv ./zig-out/bin/ctx 2>/dev/null | grep "^blackbox," >> "$OUTPUT_FILE"

echo "📊 Results written to: $OUTPUT_FILE"

# Show summary
TOTAL=$(grep -c "^unit,\|^blackbox," "$OUTPUT_FILE" 2>/dev/null || echo "0")
PASSED=$(grep -c ",PASS," "$OUTPUT_FILE" 2>/dev/null || echo "0")
FAILED=$(grep -c ",FAIL," "$OUTPUT_FILE" 2>/dev/null || echo "0")

echo ""
echo "# Summary"
echo "- Total Tests: $TOTAL"
echo "- Passed: $PASSED" 
echo "- Failed: $FAILED"

if [ "$FAILED" -eq 0 ]; then
    echo "🎉 All tests passed!"
else
    echo "💥 $FAILED tests failed!"
fi

# Also output to stdout
echo ""
echo "# CSV Results:"
cat "$OUTPUT_FILE"