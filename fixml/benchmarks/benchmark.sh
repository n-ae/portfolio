#!/bin/bash

echo "=== MSBuild Project Organizer Performance Comparison ==="
echo ""

# Create a medium-sized test file
echo "Generating medium test file (5000 lines)..."
zig run -D 5000 generate_large_csproj.zig > /dev/null 2>&1 || true

# Create versions for different sizes
cp large-test.csproj medium-test.csproj
head -5000 large-test.csproj > medium-test.csproj

echo "Test file: medium-test.csproj ($(wc -l < medium-test.csproj) lines)"
echo ""

echo "Performance Results (3 runs each, best time reported):"
echo "======================================================="

# Function to run benchmark
run_benchmark() {
    local name="$1"
    local cmd="$2"
    local best_time=999999
    
    for i in {1..3}; do
        start_time=$(date +%s.%N)
        eval "$cmd" > /dev/null 2>&1
        end_time=$(date +%s.%N)
        runtime=$(echo "$end_time - $start_time" | bc -l)
        if (( $(echo "$runtime < $best_time" | bc -l) )); then
            best_time=$runtime
        fi
    done
    
    printf "%-10s: %6.3f seconds\n" "$name" "$best_time"
}

# Test compiled binary performance
echo "Compiled Binaries:"
run_benchmark "Zig" "./zig-out/bin/fixml medium-test.csproj"

# Test interpreted/runtime performance  
echo ""
echo "Interpreted/Runtime:"
run_benchmark "Lua" "lua fixml.lua medium-test.csproj"
run_benchmark "Go" "go run fixml.go medium-test.csproj"
run_benchmark "OCaml" "ocaml fixml_simple.ml medium-test.csproj"

echo ""
echo "Summary:"
echo "- Zig: Pre-compiled binary, optimized"
echo "- Lua: Lightweight scripting, JIT compilation"  
echo "- Go: Compilation overhead in 'go run'"
echo "- OCaml: Interpreted mode with compilation overhead"
echo ""
echo "For production use, all languages can be compiled to optimized binaries."