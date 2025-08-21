#!/usr/bin/env python3

import time
import subprocess
import statistics
import os

def run_benchmark(command, test_file, runs=10, warmup=3):
    """Run benchmark with warmup and statistical analysis"""
    print(f"Benchmarking: {command} {test_file}")
    
    # Warmup runs
    for _ in range(warmup):
        try:
            subprocess.run(command.split() + [test_file], 
                         capture_output=True, check=True, timeout=30)
        except:
            pass
    
    # Actual benchmark runs
    times = []
    for i in range(runs):
        start_time = time.time()
        try:
            result = subprocess.run(command.split() + [test_file], 
                                  capture_output=True, check=True, timeout=30)
            end_time = time.time()
            times.append(end_time - start_time)
        except subprocess.SubprocessError as e:
            print(f"  Run {i+1} failed: {e}")
            return None
    
    if not times:
        return None
        
    # Calculate statistics
    mean_time = statistics.mean(times)
    median_time = statistics.median(times)
    stdev_time = statistics.stdev(times) if len(times) > 1 else 0
    min_time = min(times)
    max_time = max(times)
    
    print(f"  Mean: {mean_time:.4f}s ± {stdev_time:.4f}s")
    print(f"  Median: {median_time:.4f}s")
    print(f"  Range: {min_time:.4f}s - {max_time:.4f}s")
    
    return {
        'mean': mean_time,
        'median': median_time,
        'stdev': stdev_time,
        'min': min_time,
        'max': max_time,
        'times': times
    }

def main():
    print("=== Lua Implementation Benchmark ===\n")
    
    # Test files
    test_files = [
        "sample-with-duplicates.csproj",
        "whitespace-duplicates-test.csproj"
    ]
    
    # Lua implementations to test
    implementations = [
        ("lua fixml.lua", "Original Lua"),
        ("lua fixml_minimal.lua", "Minimal Lua"),
        ("luajit fixml.lua", "Original Lua (LuaJIT)"),
        ("luajit fixml_minimal.lua", "Minimal Lua (LuaJIT)")
    ]
    
    results = {}
    
    for test_file in test_files:
        if not os.path.exists(test_file):
            print(f"Warning: {test_file} not found, skipping")
            continue
            
        print(f"\n{'='*50}")
        print(f"Testing with: {test_file}")
        print('='*50)
        
        file_results = {}
        
        for command, name in implementations:
            result = run_benchmark(command, test_file, runs=15, warmup=3)
            if result:
                file_results[name] = result
            print()
        
        results[test_file] = file_results
    
    # Summary comparison
    print(f"\n{'='*60}")
    print("PERFORMANCE SUMMARY")
    print('='*60)
    
    for test_file, file_results in results.items():
        print(f"\nFile: {test_file}")
        print("-" * 40)
        
        # Sort by median time
        sorted_results = sorted(file_results.items(), key=lambda x: x[1]['median'])
        
        if sorted_results:
            fastest = sorted_results[0]
            print(f"{'Implementation':<25} {'Median':<10} {'vs Fastest':<12}")
            print("-" * 47)
            
            for name, stats in sorted_results:
                speedup = stats['median'] / fastest[1]['median']
                print(f"{name:<25} {stats['median']:.4f}s   {speedup:.2f}x")

if __name__ == "__main__":
    main()