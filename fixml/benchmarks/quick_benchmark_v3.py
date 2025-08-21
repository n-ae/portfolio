#!/usr/bin/env python3

import subprocess
import time
import statistics
import os

def benchmark_impl(name, command, test_file, iterations=25):
    """Benchmark a single implementation."""
    times = []
    success_count = 0
    
    for i in range(iterations):
        # Clean up previous output
        output_file = test_file.replace('.csproj', '.organized.csproj')
        if os.path.exists(output_file):
            os.remove(output_file)
        
        start_time = time.time()
        try:
            result = subprocess.run(
                command + [test_file],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                timeout=10
            )
            end_time = time.time()
            
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
        'success_rate': (success_count / iterations) * 100
    }

def main():
    # Test implementations
    implementations = [
        ('Lua (Reference)', ['lua', 'fixml.lua']),
        ('Go (Simple)', ['./fixml_simple_go']),
        ('OCaml (Simple)', ['./fixml_simple_ocaml']),
        ('Rust (Simple)', ['./fixml_simple_rust']),
        ('Zig (Original)', ['./fixml_simple']),
        ('Zig (Optimized)', ['./fixml_simple_optimized']),
    ]
    
    # Test files
    test_files = [
        'sample-with-duplicates.csproj',
        'a.csproj',
        'test-none-update.csproj',
        'csprojs/Sodexo.BackOffice.Api.csproj'
    ]
    
    print("🚀 Quick XML Processor Benchmark v3.2.0 - Optimized")
    print("=" * 65)
    print(f"Testing {len(implementations)} implementations")
    print(f"Files: {len(test_files)} test files")
    print(f"Iterations: 25 per test")
    print()
    
    results = {}
    
    for test_file in test_files:
        if not os.path.exists(test_file):
            continue
            
        file_size = os.path.getsize(test_file) / 1024
        print(f"📁 Testing {test_file} ({file_size:.1f} KB)")
        print("-" * 40)
        
        file_results = []
        
        for name, command in implementations:
            print(f"  {name:15}... ", end='', flush=True)
            
            result = benchmark_impl(name, command, test_file)
            
            if result:
                print(f"{result['mean']:6.2f}ms avg ({result['success_rate']:3.0f}% success)")
                file_results.append((name, result['mean'], result['success_rate']))
            else:
                print("FAILED")
                file_results.append((name, float('inf'), 0))
        
        # Sort by performance
        file_results.sort(key=lambda x: x[1])
        
        print("\n  Rankings:")
        for rank, (name, avg_time, success_rate) in enumerate(file_results, 1):
            if avg_time == float('inf'):
                print(f"    {rank}. {name:15} FAILED")
            else:
                speedup = file_results[0][1] / avg_time if avg_time > 0 else 1
                print(f"    {rank}. {name:15} {avg_time:6.2f}ms  ({speedup:4.2f}x)")
        
        results[test_file] = file_results
        print()
    
    print("🏆 OVERALL SUMMARY")
    print("=" * 50)
    
    # Calculate overall averages
    overall_results = {}
    for name, _ in implementations:
        all_times = []
        for file_results in results.values():
            for impl_name, avg_time, success_rate in file_results:
                if impl_name == name and avg_time != float('inf'):
                    all_times.append(avg_time)
        
        if all_times:
            overall_results[name] = {
                'avg': statistics.mean(all_times),
                'files': len(all_times)
            }
    
    # Sort by overall performance
    sorted_overall = sorted(overall_results.items(), key=lambda x: x[1]['avg'])
    
    print("Final Rankings (overall average):")
    for rank, (name, stats) in enumerate(sorted_overall, 1):
        speedup = sorted_overall[0][1]['avg'] / stats['avg'] if stats['avg'] > 0 else 1
        print(f"  {rank}. {name:15} {stats['avg']:6.2f}ms avg  ({speedup:4.2f}x)")
    
    print(f"\n✅ Benchmark complete!")

if __name__ == "__main__":
    main()