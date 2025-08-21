#!/usr/bin/env python3

import subprocess
import time
import statistics
import os
import sys

def run_command(cmd, runs=10):
    """Run a command multiple times and collect timing statistics"""
    times = []
    
    # Warmup run
    try:
        subprocess.run(cmd, shell=True, capture_output=True, check=True)
    except subprocess.CalledProcessError:
        return None
    
    # Benchmark runs
    for _ in range(runs):
        start = time.perf_counter()
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, check=True)
            end = time.perf_counter()
            times.append(end - start)
        except subprocess.CalledProcessError as e:
            print(f"Error running {cmd}: {e}")
            return None
    
    return {
        'times': times,
        'mean': statistics.mean(times),
        'min': min(times),
        'max': max(times),
        'stdev': statistics.stdev(times) if len(times) > 1 else 0
    }

def format_stats(stats):
    """Format statistics for display"""
    if stats is None:
        return "FAILED"
    return f"Mean: {stats['mean']:.4f}s | Min: {stats['min']:.4f}s | Max: {stats['max']:.4f}s | StdDev: {stats['stdev']:.4f}s"

def check_file_exists(filepath):
    """Check if file exists"""
    return os.path.isfile(filepath)

def get_file_size(filepath):
    """Get human readable file size"""
    try:
        size = os.path.getsize(filepath)
        for unit in ['B', 'K', 'M', 'G']:
            if size < 1024:
                return f"{size:.0f}{unit}"
            size /= 1024
        return f"{size:.1f}T"
    except:
        return "N/A"

def main():
    print("=== ROBUST MSBuild Project Organizer Benchmark ===")
    print("Statistical analysis with multiple runs")
    print()
    
    # Test files
    test_files = [
        "whitespace-duplicates-test.csproj",
        "medium-test.csproj", 
        "large-benchmark.csproj",
        "massive-benchmark.csproj"
    ]
    
    # Build binaries if needed
    print("Checking and building optimized binaries...")
    
    # Zig
    if not check_file_exists("zig-out/bin/fixml"):
        print("Building Zig optimized binary...")
        subprocess.run(["zig", "build", "-Doptimize=ReleaseFast"], check=True)
    
    # Go
    if not check_file_exists("fixml_go"):
        print("Building Go optimized binary...")
        subprocess.run(["go", "build", "-ldflags=-s -w", "-o", "fixml_go", "fixml.go"], check=True)
    
    # OCaml
    if not check_file_exists("fixml_ocaml"):
        print("Building OCaml optimized binary...")
        try:
            subprocess.run(["ocamlopt", "-O3", "-o", "fixml_ocaml", "fixml_simple.ml"], 
                         check=True, capture_output=True)
        except:
            print("OCaml compilation failed - skipping")
    
    # Check for LuaJIT
    has_luajit = subprocess.run(["which", "luajit"], capture_output=True).returncode == 0
    print(f"LuaJIT available: {has_luajit}")
    print()
    
    # Define benchmarks
    benchmarks = [
        ("Zig ReleaseFast", "./zig-out/bin/fixml"),
        ("Go Optimized", "./fixml_go"),
        ("OCaml Native", "./fixml_ocaml"),
        ("Lua Standard", "lua fixml.lua"),
    ]
    
    if has_luajit:
        benchmarks.append(("LuaJIT", "luajit fixml.lua"))
    
    # Run benchmarks for each test file
    for test_file in test_files:
        if not check_file_exists(test_file):
            continue
            
        lines = sum(1 for _ in open(test_file))
        print(f"=" * 50)
        print(f"BENCHMARKING: {test_file} ({lines:,} lines)")
        print(f"=" * 50)
        
        results = {}
        
        for name, base_cmd in benchmarks:
            if not (base_cmd.startswith('./') and check_file_exists(base_cmd.split()[0])) and not base_cmd.startswith(('lua', 'luajit')):
                continue
                
            cmd = f"{base_cmd} {test_file}"
            print(f"Running {name} (10 runs)...", end=" ", flush=True)
            
            stats = run_command(cmd, runs=10)
            if stats:
                results[name] = stats
                print("✓")
                print(f"  {name}: {format_stats(stats)}")
            else:
                print("✗ FAILED")
            print()
        
        # Ranking
        if results:
            print("PERFORMANCE RANKING:")
            print("=" * 20)
            
            sorted_results = sorted(results.items(), key=lambda x: x[1]['min'])
            fastest_time = sorted_results[0][1]['min']
            
            for i, (name, stats) in enumerate(sorted_results, 1):
                speedup = stats['min'] / fastest_time
                print(f"{i}. {name:<15}: {stats['min']:.4f}s ({speedup:.1f}x slower than fastest)")
            
            print()
    
    # Binary sizes
    print("=" * 50)
    print("BINARY SIZE COMPARISON:")
    print("=" * 50)
    
    binaries = [
        ("Zig", "zig-out/bin/fixml"),
        ("Go", "fixml_go"),
        ("OCaml", "fixml_ocaml")
    ]
    
    for name, path in binaries:
        if check_file_exists(path):
            size = get_file_size(path)
            print(f"{name:<10}: {size}")
    
    print()
    print("OPTIMIZATION DETAILS:")
    print("=" * 20)
    print("• Zig: -Doptimize=ReleaseFast (aggressive optimizations)")
    print("• Go: -ldflags='-s -w' (stripped binary)")
    print("• OCaml: -O3 (maximum native optimizations)")
    print("• LuaJIT: JIT compilation with trace optimization")
    print("• Lua: Standard bytecode interpreter")
    print()
    print("Statistics: 10 runs per test with warmup")

if __name__ == "__main__":
    main()