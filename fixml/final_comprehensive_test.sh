#!/bin/bash

echo "=== FINAL COMPREHENSIVE FIXML TEST ==="
echo "Testing all implementations on all modes with originals"

# Test each language implementation
languages=("rust/fixml" "go/fixml" "ocaml/fixml" "zig/fixml")
lua_cmd="lua lua/fixml.lua"

# Test files from originals directory
test_files=(tests/samples/originals/*.csproj)
num_files=${#test_files[@]}

echo "Testing on $num_files original files"
echo

total_tests=0
passed_tests=0

for i in "${!languages[@]}"; do
    lang="${languages[$i]}"
    lang_name=$(basename $(dirname "$lang"))
    
    echo "=== Testing $lang_name ==="
    
    # Test default mode
    default_passed=0
    for file in "${test_files[@]}"; do
        if [[ -f "$file" ]]; then
            total_tests=$((total_tests + 1))
            if ./"$lang" "$file" >/dev/null 2>&1; then
                if output=$(./tests/fel.sh "$file" "${file%.csproj}.organized.csproj" 2>&1); then
                    if [[ -z "$output" ]]; then
                        default_passed=$((default_passed + 1))
                        passed_tests=$((passed_tests + 1))
                    fi
                fi
            fi
        fi
    done
    echo "  default: $default_passed/$num_files passed"
    
    # Test organize mode
    organize_passed=0
    for file in "${test_files[@]}"; do
        if [[ -f "$file" ]]; then
            total_tests=$((total_tests + 1))
            if ./"$lang" --organize "$file" >/dev/null 2>&1; then
                if output=$(./tests/fel.sh "$file" "${file%.csproj}.organized.csproj" 2>&1); then
                    if [[ -z "$output" ]]; then
                        organize_passed=$((organize_passed + 1))
                        passed_tests=$((passed_tests + 1))
                    fi
                fi
            fi
        fi
    done
    echo "  organize: $organize_passed/$num_files passed"
    
    # Test fix-warnings mode (different test - just check XML declaration added)
    fix_warnings_passed=0
    for file in "${test_files[@]}"; do
        if [[ -f "$file" ]]; then
            total_tests=$((total_tests + 1))
            if ./"$lang" --fix-warnings "$file" >/dev/null 2>&1; then
                output_file="${file%.csproj}.organized.csproj"
                if [[ -f "$output_file" ]] && head -1 "$output_file" | grep -q "<?xml"; then
                    fix_warnings_passed=$((fix_warnings_passed + 1))
                    passed_tests=$((passed_tests + 1))
                fi
            fi
        fi
    done
    echo "  fix-warnings: $fix_warnings_passed/$num_files passed"
    
    # Clean up generated files
    find tests/samples -name "*.organized.csproj" -delete
    echo
done

# Test Lua separately
echo "=== Testing lua ==="

# Test default mode
default_passed=0
for file in "${test_files[@]}"; do
    if [[ -f "$file" ]]; then
        total_tests=$((total_tests + 1))
        if $lua_cmd "$file" >/dev/null 2>&1; then
            if output=$(./tests/fel.sh "$file" "${file%.csproj}.organized.csproj" 2>&1); then
                if [[ -z "$output" ]]; then
                    default_passed=$((default_passed + 1))
                    passed_tests=$((passed_tests + 1))
                fi
            fi
        fi
    fi
done
echo "  default: $default_passed/$num_files passed"

# Test organize mode  
organize_passed=0
for file in "${test_files[@]}"; do
    if [[ -f "$file" ]]; then
        total_tests=$((total_tests + 1))
        if $lua_cmd --organize "$file" >/dev/null 2>&1; then
            if output=$(./tests/fel.sh "$file" "${file%.csproj}.organized.csproj" 2>&1); then
                if [[ -z "$output" ]]; then
                    organize_passed=$((organize_passed + 1))
                    passed_tests=$((passed_tests + 1))
                fi
            fi
        fi
    fi
done
echo "  organize: $organize_passed/$num_files passed"

# Test fix-warnings mode
fix_warnings_passed=0
for file in "${test_files[@]}"; do
    if [[ -f "$file" ]]; then
        total_tests=$((total_tests + 1))
        if $lua_cmd --fix-warnings "$file" >/dev/null 2>&1; then
            output_file="${file%.csproj}.organized.csproj"
            if [[ -f "$output_file" ]] && head -1 "$output_file" | grep -q "<?xml"; then
                fix_warnings_passed=$((fix_warnings_passed + 1))
                passed_tests=$((passed_tests + 1))
            fi
        fi
    fi
done
echo "  fix-warnings: $fix_warnings_passed/$num_files passed"

# Final cleanup
find tests/samples -name "*.organized.csproj" -delete

echo
echo "=== FINAL RESULTS ==="
echo "Total tests: $total_tests"
echo "Passed tests: $passed_tests"
if [ $total_tests -gt 0 ]; then
    success_rate=$(echo "scale=2; $passed_tests * 100 / $total_tests" | bc -l)
    echo "Success rate: ${success_rate}%"
fi