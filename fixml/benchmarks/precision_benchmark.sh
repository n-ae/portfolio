#!/bin/bash

echo "=== PRECISION MSBuild Project Organizer Benchmark ==="
echo "Multiple runs with statistical analysis"
echo ""

# Number of benchmark runs
RUNS=10

# Test files
TEST_FILES=("whitespace-duplicates-test.csproj" "medium-test.csproj" "large-benchmark.csproj" "massive-benchmark.csproj")

# Function to calculate statistics
calculate_stats() {
    local values=("$@")
    local sum=0
    local count=${#values[@]}
    
    # Calculate mean
    for val in "${values[@]}"; do
        sum=$(python3 -c "print($sum + $val)")
    done
    local mean=$(python3 -c "print($sum / $count)")
    
    # Find min and max
    local min=${values[0]}
    local max=${values[0]}
    for val in "${values[@]}"; do
        min=$(python3 -c "print(min($min, $val))")
        max=$(python3 -c "print(max($max, $val))")
    done
    
    # Calculate standard deviation
    local variance=0
    for val in "${values[@]}"; do
        local diff=$(python3 -c "print(($val - $mean) ** 2)")
        variance=$(python3 -c "print($variance + $diff)")
    done
    variance=$(python3 -c "print($variance / $count)")
    local stddev=$(python3 -c "import math; print(math.sqrt($variance))")
    
    printf "Mean: %7.4fs | Min: %7.4fs | Max: %7.4fs | StdDev: %7.4fs" "$mean" "$min" "$max" "$stddev"
}

# Benchmark function with multiple runs
benchmark_multiple() {
    local name="$1"
    local cmd="$2"
    local times=()
    
    echo -n "Running $name ($RUNS runs): "
    
    # Warmup run
    eval "$cmd" > /dev/null 2>&1
    
    # Actual benchmark runs
    for i in $(seq 1 $RUNS); do
        echo -n "."
        start_time=$(python3 -c "import time; print(time.perf_counter())")
        eval "$cmd" > /dev/null 2>&1
        end_time=$(python3 -c "import time; print(time.perf_counter())")
        runtime=$(python3 -c "print($end_time - $start_time)")
        times+=($runtime)
    done
    
    echo ""
    echo -n "  $name: "
    calculate_stats "${times[@]}"
    echo ""
    
    # Return the minimum time for ranking
    echo "${times[@]}" | tr ' ' '\n' | sort -n | head -1
}

# Check binaries exist
echo "Checking optimized binaries..."
if [[ ! -f "./zig-out/bin/fixml" ]]; then
    echo "Building Zig optimized binary..."
    zig build -Doptimize=ReleaseFast
fi

if [[ ! -f "./fixml_go" ]]; then
    echo "Building Go optimized binary..."
    go build -ldflags="-s -w" -o fixml_go fixml.go
fi

if [[ ! -f "./fixml_ocaml" ]]; then
    echo "Building OCaml optimized binary..."
    ocamlopt -O3 -o fixml_ocaml fixml_simple.ml 2>/dev/null || echo "OCaml compilation failed"
fi

# Check if LuaJIT is available
if command -v luajit >/dev/null 2>&1; then
    HAS_LUAJIT=true
    echo "LuaJIT found - will benchmark both Lua and LuaJIT"
else
    HAS_LUAJIT=false
    echo "LuaJIT not found - benchmarking Lua only"
fi

echo ""

# Run benchmarks for each test file
for test_file in "${TEST_FILES[@]}"; do
    if [[ -f "$test_file" ]]; then
        lines=$(wc -l < "$test_file")
        echo "==========================================="
        echo "BENCHMARKING: $test_file ($lines lines)"
        echo "==========================================="
        
        # Store results for ranking
        declare -A results
        
        # Zig
        if [[ -f "./zig-out/bin/fixml" ]]; then
            zig_min=$(benchmark_multiple "Zig ReleaseFast" "./zig-out/bin/fixml $test_file")
            results["Zig ReleaseFast"]=$zig_min
        fi
        
        # Go
        if [[ -f "./fixml_go" ]]; then
            go_min=$(benchmark_multiple "Go Optimized" "./fixml_go $test_file")
            results["Go Optimized"]=$go_min
        fi
        
        # OCaml
        if [[ -f "./fixml_ocaml" ]]; then
            ocaml_min=$(benchmark_multiple "OCaml Native" "./fixml_ocaml $test_file")
            results["OCaml Native"]=$ocaml_min
        fi
        
        # LuaJIT
        if [[ "$HAS_LUAJIT" = true ]]; then
            luajit_min=$(benchmark_multiple "LuaJIT" "luajit fixml.lua $test_file")
            results["LuaJIT"]=$luajit_min
        fi
        
        # Lua Standard
        lua_min=$(benchmark_multiple "Lua Standard" "lua fixml.lua $test_file")
        results["Lua Standard"]=$lua_min
        
        echo ""
        echo "PERFORMANCE RANKING:"
        echo "===================="
        
        # Sort and display results
        (
            for lang in "${!results[@]}"; do
                echo "${results[$lang]} $lang"
            done
        ) | sort -n | awk '{
            if (NR == 1) fastest = $1
            speedup = $1 / fastest
            printf "%d. %-15s: %7.4fs (%4.1fx slower than fastest)\n", NR, $2, $1, speedup
        }'
        
        echo ""
        
        # Clear results for next iteration
        unset results
        declare -A results
    fi
done

echo "==========================================="
echo "BINARY SIZE COMPARISON:"
echo "==========================================="
ls -lh zig-out/bin/fixml fixml_go fixml_ocaml 2>/dev/null | awk '{printf "%-15s: %s\n", $9, $5}'

echo ""
echo "OPTIMIZATION DETAILS:"
echo "===================="
echo "• Zig: -Doptimize=ReleaseFast (aggressive optimizations, no safety checks)"
echo "• Go: -ldflags='-s -w' (stripped binary, size optimized)"
echo "• OCaml: -O3 (maximum native compiler optimizations)"
echo "• LuaJIT: Trace compilation JIT with hotspot optimization"
echo "• Lua: Bytecode interpreter (reference baseline)"
echo ""
echo "Statistical significance: $RUNS runs per test, showing mean ± std deviation"