#!/usr/bin/env python3

import subprocess
import time
import statistics
import os

def benchmark_impl(name, command, test_file, iterations=30):
    """Benchmark a single implementation with high precision."""
    times = []
    success_count = 0
    
    for i in range(iterations):
        # Clean up previous output
        output_file = test_file.replace('.csproj', '.organized.csproj')
        if os.path.exists(output_file):
            os.remove(output_file)
        
        # Warm up run (not counted)
        if i == 0:
            subprocess.run(command + [test_file], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=15)
        
        start_time = time.perf_counter()
        try:
            result = subprocess.run(
                command + [test_file],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=15
            )
            end_time = time.perf_counter()
            
            if result.returncode == 0:
                times.append((end_time - start_time) * 1000)  # ms
                success_count += 1
        except:
            pass
    
    if not times:
        return None
        
    return {
        'mean': statistics.mean(times),
        'min': min(times),
        'max': max(times),
        'median': statistics.median(times),
        'stddev': statistics.stdev(times) if len(times) > 1 else 0.0,
        'success_rate': (success_count / iterations) * 100
    }

def main():
    # Focus on Lua optimization comparison + best performers
    implementations = [
        ('Lua v4.0.0 (Optimized)', ['lua', 'temp_old_versions/fixml_optimized.lua']),
        ('Lua v5.0.0 (Ultra)', ['lua', 'fixml_ultra_optimized.lua']),
        ('Zig v2.0.0 (Champion)', ['./fixml_simple_optimized']),
        ('Rust v2.0.0 (Runner-up)', ['./fixml_optimized_rust']),
        ('Go v2.0.0 (Bronze)', ['./fixml_optimized_go']),
    ]
    
    # Test files with focus on scaling analysis
    test_files = [
        ('samples/test-none-update.csproj', 0.6),      # Tiny
        ('samples/sample-with-duplicates.csproj', 1.2), # Small
        ('samples/Sodexo.BackOffice.Api.csproj', 11.0), # Medium
        ('samples/a.csproj', 940.9)                     # Large
    ]
    
    print("🚀 Lua Ultra-Optimization Benchmark")
    print("=" * 65)
    print("🎯 Focus: Lua performance optimization analysis")
    print(f"🔧 Testing {len(implementations)} implementations")
    print(f"📁 Files: {len(test_files)} test files")
    print(f"🔄 Iterations: 30 per test (with warm-up)")
    print()
    
    results = {}
    
    for test_file, file_size_kb in test_files:
        if not os.path.exists(test_file):
            continue
            
        print(f"📁 Testing {test_file} ({file_size_kb} KB)")
        print("-" * 60)
        
        file_results = []
        
        for name, command in implementations:
            print(f"  {name:25}... ", end='', flush=True)
            
            result = benchmark_impl(name, command, test_file, 35)  # Extra iterations for precision
            
            if result:
                print(f"{result['mean']:6.2f}ms (med: {result['median']:5.2f}, σ: {result['stddev']:4.2f})")
                file_results.append((name, result['mean'], result['median'], result['stddev']))
            else:
                print("FAILED")
                file_results.append((name, float('inf'), float('inf'), 0))
        
        # Sort by median performance (more stable than mean)
        file_results.sort(key=lambda x: x[2])
        
        print("\n  🏆 Rankings by median performance:")
        for rank, (name, mean_time, median_time, stddev) in enumerate(file_results, 1):
            if median_time == float('inf'):
                print(f"    {rank}. {name:25} FAILED")
            else:
                speedup = file_results[0][2] / median_time if median_time > 0 else 1
                print(f"    {rank}. {name:25} {median_time:6.2f}ms  ({speedup:4.2f}x)")
        
        results[test_file] = file_results
        print()
    
    print("🏆 LUA OPTIMIZATION ANALYSIS")
    print("=" * 65)
    
    # Compare Lua versions specifically
    lua_optimized_times = []
    lua_ultra_times = []
    
    for file_results in results.values():
        for name, mean_time, median_time, stddev in file_results:
            if 'Lua v4.0.0' in name and median_time != float('inf'):
                lua_optimized_times.append(median_time)
            elif 'Lua v5.0.0' in name and median_time != float('inf'):
                lua_ultra_times.append(median_time)
    
    if lua_optimized_times and lua_ultra_times:
        optimized_avg = statistics.mean(lua_optimized_times)
        ultra_avg = statistics.mean(lua_ultra_times)
        improvement = (optimized_avg / ultra_avg) if ultra_avg > 0 else 0
        
        print("📊 Lua Optimization Results:")
        print(f"  v4.0.0 (Optimized):  {optimized_avg:6.2f}ms average")
        print(f"  v5.0.0 (Ultra):      {ultra_avg:6.2f}ms average")
        print(f"  📈 Improvement:      {improvement:4.2f}x faster ({((improvement-1)*100):+.1f}%)")
        print()
    
    # Scaling analysis for Lua versions
    print("🔬 SCALING ANALYSIS:")
    print("-" * 40)
    
    tiny_file = 'test-none-update.csproj'
    large_file = 'a.csproj'
    
    if tiny_file in results and large_file in results:
        tiny_results = {name: median for name, _, median, _ in results[tiny_file]}
        large_results = {name: median for name, _, median, _ in results[large_file]}
        
        print("File size scaling (0.6KB → 940KB = 1567x larger):")
        print("Ideal O(n): 1567x slower | Actual:")
        
        for name in ['Lua v4.0.0 (Optimized)', 'Lua v5.0.0 (Ultra)', 'Zig v2.0.0 (Champion)', 'Rust v2.0.0 (Runner-up)']:
            if name in tiny_results and name in large_results:
                tiny_time = tiny_results[name]
                large_time = large_results[name]
                if tiny_time > 0 and large_time != float('inf'):
                    scale_factor = large_time / tiny_time
                    efficiency = 1567 / scale_factor if scale_factor > 0 else 0
                    
                    if scale_factor < 20:
                        status = "🟢 EXCELLENT"
                    elif scale_factor < 50:
                        status = "🟡 GOOD"
                    elif scale_factor < 100:
                        status = "🟠 FAIR"
                    else:
                        status = "🔴 NEEDS WORK"
                    
                    print(f"  {name:25} {scale_factor:5.1f}x ({efficiency:5.1f}% eff) {status}")
    
    print("\n💡 OPTIMIZATION TECHNIQUES APPLIED:")
    print("=" * 50)
    print("Lua v5.0.0 Ultra Optimizations:")
    print("• ⚡ Byte-level operations instead of regex patterns")
    print("• 🧠 Pre-allocated buffers with capacity hints")  
    print("• 🔄 Single-pass algorithms eliminate O(n²) operations")
    print("• 📦 Chunked I/O for large files")
    print("• 🗃️  Cached indentation strings")
    print("• 🎯 Plain text search instead of pattern matching")
    print("• 🚀 Custom line iterator avoiding gmatch overhead")
    
    print(f"\n✅ Lua Ultra-Optimization Analysis Complete!")

if __name__ == "__main__":
    main()