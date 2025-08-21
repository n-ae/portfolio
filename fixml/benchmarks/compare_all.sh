#!/bin/bash

# Script to compare all sample files with fixml output and generate CSV results
# Creates result.csv with comparison data

echo "file,mode,exclusive_lines_count,differences" > result.csv

# Function to process a file and add to CSV
process_file() {
    local original_file="$1"
    local mode="$2"
    
    if [ ! -f "$original_file" ]; then
        echo "Warning: $original_file not found, skipping"
        return
    fi
    
    local base_name=$(basename "$original_file" .csproj)
    
    # Generate organized files
    echo "Processing $original_file..."
    
    # Generate preserve mode output
    lua fixml_final.lua "$original_file" > /dev/null 2>&1
    local preserve_file="${original_file}.organized"
    
    # Generate organize mode output  
    lua fixml_final.lua --organize "$original_file" > /dev/null 2>&1
    # Organize mode overwrites the .organized file, so we need to rename it
    if [ -f "$preserve_file" ]; then
        cp "$preserve_file" "${original_file}.preserve"
    fi
    local organize_file="$preserve_file"  # This now contains organize mode output
    
    # Compare preserve mode
    if [ -f "${original_file}.preserve" ]; then
        local preserve_diff=$(./fel.sh "$original_file" "${original_file}.preserve" | wc -l)
        local preserve_details=$(./fel.sh "$original_file" "${original_file}.preserve" | tr '\n' ';' | sed 's/;$//')
        echo "$base_name,preserve,$preserve_diff,\"$preserve_details\"" >> result.csv
    fi
    
    # Compare organize mode
    if [ -f "$organize_file" ]; then
        local organize_diff=$(./fel.sh "$original_file" "$organize_file" | wc -l)
        local organize_details=$(./fel.sh "$original_file" "$organize_file" | tr '\n' ';' | sed 's/;$//')
        echo "$base_name,organize,$organize_diff,\"$organize_details\"" >> result.csv
    fi
}

# Make fel.sh executable
chmod +x fel.sh

# Process all sample files
echo "Processing sample files..."

# Process main sample files
for file in sample.csproj sample-with-duplicates.csproj; do
    if [ -f "$file" ]; then
        process_file "$file"
    fi
done

# Process a selection of csprojs files (not all 79+ files to keep it manageable)
echo "Processing selected production files..."
sample_csprojs=(
    "csprojs/Sodexo.BackOffice.Abstraction.csproj"
    "csprojs/Sodexo.BackOffice.Api.csproj"
    "csprojs/Sodexo.BackOffice.Test.csproj"
    "csprojs/Sodexo.BackOffice.Domain.csproj"
    "csprojs/Sodexo.BackOffice.Core.csproj"
)

for file in "${sample_csprojs[@]}"; do
    if [ -f "$file" ]; then
        process_file "$file"
    fi
done

echo "Comparison complete. Results written to result.csv"
echo
echo "CSV Summary:"
echo "============"
cat result.csv | column -t -s ','

# Clean up temporary files
echo
echo "Cleaning up temporary files..."
rm -f *.preserve
rm -f csprojs/*.preserve

echo "Done!"