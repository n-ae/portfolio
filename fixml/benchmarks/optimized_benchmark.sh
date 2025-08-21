#!/bin/bash

echo "=== OPTIMIZED MSBuild Project Organizer Performance Comparison ==="
echo ""

# Ensure all binaries are built
echo "Verifying optimized binaries exist..."
ls -la fixml_go fixml_ocaml zig-out/bin/fixml 2>/dev/null || echo "Some binaries missing"

# Test files of different sizes
test_files=("whitespace-duplicates-test.csproj" "medium-test.csproj" "large-benchmark.csproj")

for test_file in "${test_files[@]}"; do
    if [[ -f "$test_file" ]]; then
        lines=$(wc -l < "$test_file")
        echo "Testing with: $test_file ($lines lines)"
        echo "============================================="
        
        # Function to run multiple tests and get average
        run_benchmark() {
            local name="$1"
            local cmd="$2"
            local times=()
            
            echo -n "$name: "
            
            # Run 5 times and calculate average
            for i in {1..5}; do
                start_time=$(python3 -c "import time; print(time.perf_counter())")
                eval "$cmd" > /dev/null 2>&1
                end_time=$(python3 -c "import time; print(time.perf_counter())")
                runtime=$(python3 -c "print($end_time - $start_time)")
                times+=($runtime)
                echo -n "."
            done
            
            # Calculate average
            avg=$(python3 -c "times=[$( IFS=,; echo "${times[*]}" )]; print(f'{sum(times)/len(times):.4f}')")
            min_time=$(python3 -c "times=[$( IFS=,; echo "${times[*]}" )]; print(f'{min(times):.4f}')")
            
            printf " avg: %6.4fs, best: %6.4fs\n" "$avg" "$min_time"
            
            # Store for comparison
            case "$name" in
                "Zig ReleaseFast") zig_time=$min_time ;;
                "Go Optimized") go_time=$min_time ;;
                "OCaml Native") ocaml_time=$min_time ;;
                "LuaJIT") luajit_time=$min_time ;;
                "Lua Standard") lua_time=$min_time ;;
            esac
        }
        
        # Run optimized benchmarks
        run_benchmark "Zig ReleaseFast" "./zig-out/bin/fixml $test_file"
        run_benchmark "Go Optimized" "./fixml_go $test_file"  
        run_benchmark "OCaml Native" "./fixml_ocaml $test_file"
        run_benchmark "LuaJIT" "luajit fixml.lua $test_file"
        run_benchmark "Lua Standard" "lua fixml.lua $test_file"
        
        echo ""
        echo "Performance Ranking for $test_file:"
        echo "-----------------------------------"
        
        # Sort and display results
        python3 -c "
results = [
    ('Zig ReleaseFast', $zig_time),
    ('Go Optimized', $go_time), 
    ('OCaml Native', $ocaml_time),
    ('LuaJIT', $luajit_time),
    ('Lua Standard', $lua_time)
]
results.sort(key=lambda x: x[1])
for i, (name, time) in enumerate(results, 1):
    speedup = results[-1][1] / time
    print(f'{i}. {name:<15}: {time:.4f}s ({speedup:.1f}x faster than slowest)')
"
        echo ""
        echo ""
    fi
done

echo "Binary Sizes:"
echo "============="
ls -lh fixml_go fixml_ocaml zig-out/bin/fixml 2>/dev/null | awk '{print $9 ": " $5}'

echo ""
echo "Summary of Optimizations Applied:"
echo "================================="
echo "• Zig: -Doptimize=ReleaseFast (maximum speed optimizations)"
echo "• Go: -ldflags='-s -w' (strip debug info, optimize size)"  
echo "• OCaml: -O3 (native compilation with max optimizations)"
echo "• LuaJIT: Just-in-time compilation with trace compilation"
echo "• Lua: Standard interpreter (baseline)"