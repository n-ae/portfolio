#!/bin/bash

echo "=== COMPREHENSIVE FIXML TEST ==="
echo "Testing all implementations on all modes"

# Test each language implementation
languages=("rust/fixml" "go/fixml" "ocaml/fixml" "zig/fixml")
lua_cmd="lua lua/fixml.lua"

# Test modes
modes=("" "--organize" "--fix-warnings" "--organize --fix-warnings")
mode_names=("default" "organize" "fix-warnings" "organize+fix-warnings")

# Test with files in originals directory
test_files=(tests/samples/originals/*.csproj)

echo "Testing on ${#test_files[@]} original files with ${#modes[@]} modes each"
echo

total_tests=0
passed_tests=0

for i in "${!languages[@]}"; do
    lang="${languages[$i]}"
    lang_name=$(basename $(dirname "$lang"))
    
    echo "=== Testing $lang_name ==="
    
    for j in "${!modes[@]}"; do
        mode="${modes[$j]}"
        mode_name="${mode_names[$j]}"
        
        mode_passed=0
        mode_total=0
        
        for file in "${test_files[@]}"; do
            if [[ -f "$file" ]]; then
                mode_total=$((mode_total + 1))
                total_tests=$((total_tests + 1))
                
                # Run the command
                if ./"$lang" $mode "$file" >/dev/null 2>&1; then
                    # Check fel.sh
                    if output=$(./tests/fel.sh "$file" "${file%.csproj}.organized.csproj" 2>&1); then
                        if [[ -z "$output" ]]; then
                            mode_passed=$((mode_passed + 1))
                            passed_tests=$((passed_tests + 1))
                        fi
                    fi
                fi
            fi
        done
        
        echo "  $mode_name: $mode_passed/$mode_total passed"
    done
    echo
done

# Test Lua separately
echo "=== Testing lua ==="
for j in "${!modes[@]}"; do
    mode="${modes[$j]}"
    mode_name="${mode_names[$j]}"
    
    mode_passed=0
    mode_total=0
    
    for file in "${test_files[@]}"; do
        if [[ -f "$file" ]]; then
            mode_total=$((mode_total + 1))
            total_tests=$((total_tests + 1))
            
            # Run the command
            if $lua_cmd $mode "$file" >/dev/null 2>&1; then
                # Check fel.sh
                if output=$(./tests/fel.sh "$file" "${file%.csproj}.organized.csproj" 2>&1); then
                    if [[ -z "$output" ]]; then
                        mode_passed=$((mode_passed + 1))
                        passed_tests=$((passed_tests + 1))
                    fi
                fi
            fi
        fi
    done
    
    echo "  $mode_name: $mode_passed/$mode_total passed"
done

echo
echo "=== FINAL RESULTS ==="
echo "Total tests: $total_tests"
echo "Passed tests: $passed_tests"
echo "Success rate: $(echo "scale=2; $passed_tests * 100 / $total_tests" | bc -l)%"