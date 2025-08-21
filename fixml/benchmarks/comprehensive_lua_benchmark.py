#!/usr/bin/env python3

import time
import subprocess
import statistics
import os
import sys

def run_benchmark(command, test_file, runs=1000, warmup=10):
    """Run comprehensive benchmark with 1000 iterations"""
    print(f"Benchmarking: {command} {test_file}")
    print(f"Warmup: {warmup} runs, Main: {runs} runs")
    
    # Warmup runs
    for i in range(warmup):
        try:
            subprocess.run(command.split() + [test_file], 
                         capture_output=True, check=True, timeout=30)
        except:
            pass
        if (i + 1) % 5 == 0:
            print(f"  Warmup: {i+1}/{warmup}")
    
    # Actual benchmark runs
    times = []
    for i in range(runs):
        start_time = time.perf_counter()
        try:
            result = subprocess.run(command.split() + [test_file], 
                                  capture_output=True, check=True, timeout=30)
            end_time = time.perf_counter()
            times.append(end_time - start_time)
        except subprocess.SubprocessError as e:
            print(f"  Run {i+1} failed: {e}")
            return None
        
        # Progress indicator every 100 runs
        if (i + 1) % 100 == 0:
            print(f"  Progress: {i+1}/{runs} ({(i+1)/runs*100:.1f}%)")
    
    if not times:
        return None
        
    # Calculate comprehensive statistics
    mean_time = statistics.mean(times)
    median_time = statistics.median(times)
    stdev_time = statistics.stdev(times) if len(times) > 1 else 0
    min_time = min(times)
    max_time = max(times)
    
    # Calculate percentiles
    sorted_times = sorted(times)
    p95 = sorted_times[int(0.95 * len(sorted_times))]
    p99 = sorted_times[int(0.99 * len(sorted_times))]
    
    print(f"  Mean: {mean_time:.6f}s ± {stdev_time:.6f}s")
    print(f"  Median: {median_time:.6f}s")
    print(f"  95th percentile: {p95:.6f}s")
    print(f"  99th percentile: {p99:.6f}s")
    print(f"  Range: {min_time:.6f}s - {max_time:.6f}s")
    print(f"  CV: {(stdev_time/mean_time)*100:.2f}%")
    
    return {
        'mean': mean_time,
        'median': median_time,
        'stdev': stdev_time,
        'min': min_time,
        'max': max_time,
        'p95': p95,
        'p99': p99,
        'times': times,
        'cv': (stdev_time/mean_time)*100
    }

def create_large_test_file(base_file, multiplier, output_file):
    """Create larger test files by duplicating content"""
    with open(base_file, 'r') as f:
        content = f.read()
    
    # Extract the project structure
    project_start = content[:content.find('<ItemGroup')]
    project_end = '</Project>'
    
    # Extract all ItemGroups
    import re
    item_groups = re.findall(r'<ItemGroup[^>]*>.*?</ItemGroup>', content, re.DOTALL)
    
    # Create multiplied content
    multiplied_groups = item_groups * multiplier
    
    new_content = project_start
    for group in multiplied_groups:
        new_content += group + '\n\n'
    new_content += project_end
    
    with open(output_file, 'w') as f:
        f.write(new_content)
    
    return output_file

def get_file_stats(filename):
    """Get file statistics"""
    if not os.path.exists(filename):
        return None
    
    size = os.path.getsize(filename)
    with open(filename, 'r') as f:
        content = f.read()
        lines = len(content.splitlines())
        itemgroups = content.count('<ItemGroup')
        items = content.count('Include=')
    
    return {
        'size_kb': size / 1024,
        'lines': lines,
        'itemgroups': itemgroups,
        'items': items
    }

def main():
    print("=== Comprehensive Lua Implementation Benchmark ===")
    print("1000 iterations per test with variance reduction\n")
    
    # Base test files
    base_files = [
        "sample-with-duplicates.csproj",
        "whitespace-duplicates-test.csproj"
    ]
    
    # Create test files of different sizes
    test_files = []
    multipliers = [1, 5, 10, 25]  # Original, 5x, 10x, 25x larger
    
    for base_file in base_files:
        if not os.path.exists(base_file):
            print(f"Warning: {base_file} not found, skipping")
            continue
            
        for mult in multipliers:
            if mult == 1:
                test_files.append((base_file, f"{base_file} (Original)"))
            else:
                large_file = f"{base_file}.{mult}x"
                create_large_test_file(base_file, mult, large_file)
                test_files.append((large_file, f"{base_file} ({mult}x size)"))
    
    # Lua implementations to test
    implementations = [
        ("lua fixml.lua", "Original Lua"),
        ("lua fixml_minimal.lua", "Minimal Lua"),
        ("luajit fixml.lua", "Original Lua (LuaJIT)"),
        ("luajit fixml_minimal.lua", "Minimal Lua (LuaJIT)")
    ]
    
    all_results = {}
    
    for test_file, test_name in test_files:
        print(f"\n{'='*70}")
        print(f"Testing: {test_name}")
        
        # Show file statistics
        stats = get_file_stats(test_file)
        if stats:
            print(f"File stats: {stats['size_kb']:.1f}KB, {stats['lines']} lines, {stats['items']} items")
        print('='*70)
        
        file_results = {}
        
        for command, impl_name in implementations:
            print(f"\n--- {impl_name} ---")
            result = run_benchmark(command, test_file, runs=1000, warmup=10)
            if result:
                file_results[impl_name] = result
            print()
        
        all_results[test_name] = file_results
    
    # Comprehensive summary
    print(f"\n{'='*80}")
    print("COMPREHENSIVE PERFORMANCE SUMMARY")
    print('='*80)
    
    for test_name, file_results in all_results.items():
        print(f"\n{test_name}")
        print("-" * len(test_name))
        
        if not file_results:
            continue
            
        # Sort by median time
        sorted_results = sorted(file_results.items(), key=lambda x: x[1]['median'])
        
        if sorted_results:
            fastest = sorted_results[0]
            print(f"{'Implementation':<25} {'Median':<12} {'Mean':<12} {'Speedup':<10} {'CV%':<8}")
            print("-" * 75)
            
            for name, stats in sorted_results:
                speedup = stats['median'] / fastest[1]['median']
                print(f"{name:<25} {stats['median']:.6f}s  {stats['mean']:.6f}s  {speedup:.2f}x      {stats['cv']:.2f}%")
    
    # Performance scaling analysis
    print(f"\n{'='*80}")
    print("PERFORMANCE SCALING ANALYSIS")
    print('='*80)
    
    # Group results by base file and implementation
    scaling_data = {}
    for test_name, file_results in all_results.items():
        for impl_name, stats in file_results.items():
            base_name = test_name.split(' (')[0]
            if base_name not in scaling_data:
                scaling_data[base_name] = {}
            if impl_name not in scaling_data[base_name]:
                scaling_data[base_name][impl_name] = {}
            
            size_key = test_name.split(' (')[1].rstrip(')') if ' (' in test_name else "Original"
            scaling_data[base_name][impl_name][size_key] = stats['median']
    
    for base_name, impl_data in scaling_data.items():
        print(f"\nScaling for {base_name}:")
        print(f"{'Implementation':<25} {'Original':<12} {'5x':<12} {'10x':<12} {'25x':<12}")
        print("-" * 73)
        
        for impl_name, size_data in impl_data.items():
            row = f"{impl_name:<25}"
            for size in ["Original", "5x size", "10x size", "25x size"]:
                if size in size_data:
                    row += f" {size_data[size]:.6f}s"
                else:
                    row += f" {'N/A':<11}"
            print(row)

if __name__ == "__main__":
    main()