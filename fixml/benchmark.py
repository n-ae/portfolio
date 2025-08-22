#!/usr/bin/env python3

import subprocess
import time
import statistics
import os

def benchmark_impl(name, command, test_file, iterations=10):
    """Benchmark a single implementation."""
    times = []
    
    for i in range(iterations):
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
        except:
            pass
    
    if not times:
        return None
    
    return {
        'mean': statistics.mean(times),
        'min': min(times),
        'max': max(times)
    }

def main():
    implementations = [
        ('Go', ['go/fixml']),
        ('Rust', ['rust/fixml']), 
        ('Lua', ['lua', 'lua/fixml.lua']),
        ('OCaml', ['ocaml/fixml']),
        ('Zig', ['zig/fixml'])
    ]
    
    test_files = [
        'tests/samples/sample.xml',
        'tests/samples/medium-test.xml',
        'tests/samples/large-test.xml'
    ]
    
    print("FIXML Performance Benchmark")
    print("=" * 40)
    
    for test_file in test_files:
        if not os.path.exists(test_file):
            continue
            
        file_size = os.path.getsize(test_file) / 1024
        print(f"\n{test_file} ({file_size:.1f} KB)")
        print("-" * 30)
        
        results = []
        for name, command in implementations:
            print(f"{name:8}... ", end='', flush=True)
            
            result = benchmark_impl(name, command, test_file)
            
            if result:
                print(f"{result['mean']:6.1f}ms")
                results.append((name, result['mean']))
            else:
                print("FAILED")
        
        # Show rankings for this file
        if results:
            results.sort(key=lambda x: x[1])
            print("\nRankings:")
            for rank, (name, time_ms) in enumerate(results, 1):
                speedup = results[0][1] / time_ms
                print(f"  {rank}. {name:8} {time_ms:6.1f}ms ({speedup:4.1f}x)")

if __name__ == "__main__":
    main()