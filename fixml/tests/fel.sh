#!/bin/bash

# Modified fel.sh to work with fixml output
# Usage: ./fel.sh original_file processed_file

if [ $# -ne 2 ]; then
    echo "Usage: $0 <original_file> <processed_file>"
    echo "Example: $0 sample.csproj sample.csproj.organized"
    exit 1
fi

original_file=$1
processed_file=$2

if [ ! -f "$original_file" ]; then
    echo "Error: Original file '$original_file' not found"
    exit 1
fi

if [ ! -f "$processed_file" ]; then
    echo "Error: Processed file '$processed_file' not found"
    exit 1
fi

# Compare files, ignoring whitespace differences and BOM characters
comm -3 \
    <(sed 's/^\xEF\xBB\xBF//; s/^[[:space:]]*//; s/[[:space:]]*$//' "$original_file" | sort -u) \
    <(sed 's/^\xEF\xBB\xBF//; s/^[[:space:]]*//; s/[[:space:]]*$//' "$processed_file" | sort -u)
