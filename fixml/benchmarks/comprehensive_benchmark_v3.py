#!/usr/bin/env python3

import os
import subprocess
import time
import statistics
import json
from pathlib import Path

def run_benchmark(command, file_path, iterations=100):
    """Run benchmark for a specific command and file."""
    times = []
    success_count = 0
    
    for i in range(iterations):
        # Clean up previous output file
        output_file = file_path.replace('.csproj', '.organized.csproj')
        if os.path.exists(output_file):
            os.remove(output_file)
        
        start_time = time.time()
        try:
            result = subprocess.run(
                command + [file_path], 
                stdout=subprocess.DEVNULL, 
                stderr=subprocess.DEVNULL, 
                timeout=30
            )
            end_time = time.time()
            
            if result.returncode == 0:
                times.append((end_time - start_time) * 1000)  # Convert to milliseconds
                success_count += 1
                
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
            pass
    
    if not times:
        return None
    
    return {
        'mean': statistics.mean(times),
        'median': statistics.median(times), 
        'min': min(times),
        'max': max(times),
        'std_dev': statistics.stdev(times) if len(times) > 1 else 0,
        'success_rate': (success_count / iterations) * 100,
        'iterations': len(times)
    }

def get_file_size(file_path):
    """Get file size in KB."""
    return os.path.getsize(file_path) / 1024

def main():
    # Define implementations
    implementations = [
        {
            'name': 'Lua (Reference)',
            'command': ['lua', 'fixml.lua'],
            'version': 'v3.0.0'
        },
        {
            'name': 'Go',
            'command': ['./fixml_go_v3'],
            'version': 'v3.0.0'
        },
        {
            'name': 'OCaml', 
            'command': ['./fixml_ocaml_v3'],
            'version': 'v3.0.0'
        },
        {
            'name': 'Rust',
            'command': ['./target/release/fixml_rust'],
            'version': 'v3.0.0'
        }
    ]
    
    # Test files with different sizes
    test_files = []
    for csproj_file in Path('csprojs').glob('*.csproj'):
        if csproj_file.name.endswith('.organized.csproj'):
            continue
        size_kb = get_file_size(csproj_file)
        test_files.append({
            'path': str(csproj_file),
            'name': csproj_file.name,
            'size_kb': size_kb
        })
    
    # Add sample files
    sample_files = ['sample-with-duplicates.csproj', 'a.csproj']
    for sample in sample_files:
        if os.path.exists(sample):
            test_files.append({
                'path': sample,
                'name': sample,
                'size_kb': get_file_size(sample)
            })
    
    # Sort by file size
    test_files.sort(key=lambda x: x['size_kb'])
    
    print("🚀 Comprehensive XML Processor Benchmark v3.0.0")
    print("=" * 60)
    print(f"Testing {len(implementations)} implementations on {len(test_files)} files")
    print(f"Iterations per test: 100")
    print()
    
    results = {}
    
    for impl in implementations:
        print(f"📊 Testing {impl['name']} {impl['version']}...")
        impl_results = {}
        
        for test_file in test_files:
            print(f"  Processing {test_file['name']} ({test_file['size_kb']:.1f} KB)...", end=' ')
            
            result = run_benchmark(impl['command'], test_file['path'])
            
            if result:
                impl_results[test_file['name']] = {
                    **result,
                    'file_size_kb': test_file['size_kb']
                }
                print(f"✓ {result['mean']:.2f}ms avg ({result['success_rate']:.0f}% success)")
            else:
                print("❌ Failed")
                impl_results[test_file['name']] = {
                    'mean': float('inf'),
                    'success_rate': 0,
                    'file_size_kb': test_file['size_kb']
                }
        
        results[impl['name']] = impl_results
        print()
    
    # Summary analysis
    print("📈 PERFORMANCE SUMMARY")
    print("=" * 60)
    
    # Calculate averages for each implementation
    averages = {}
    for impl_name, impl_results in results.items():
        valid_results = [r for r in impl_results.values() if r['mean'] != float('inf')]
        if valid_results:
            avg_time = statistics.mean([r['mean'] for r in valid_results])
            avg_success = statistics.mean([r['success_rate'] for r in valid_results])
            averages[impl_name] = {
                'avg_time': avg_time,
                'avg_success': avg_success,
                'files_processed': len(valid_results)
            }
    
    # Sort by performance
    sorted_impls = sorted(averages.items(), key=lambda x: x[1]['avg_time'])
    
    print("Overall Rankings (by average execution time):")
    print()
    for rank, (impl_name, stats) in enumerate(sorted_impls, 1):
        success_indicator = "🟢" if stats['avg_success'] > 95 else "🟡" if stats['avg_success'] > 80 else "🔴"
        print(f"{rank}. {impl_name:15} {stats['avg_time']:8.2f}ms avg  {success_indicator} {stats['avg_success']:5.1f}% success  ({stats['files_processed']} files)")
    
    print("\n📊 FILE SIZE PERFORMANCE ANALYSIS")
    print("=" * 60)
    
    # Group files by size categories
    size_categories = {
        'Small (< 10 KB)': [f for f in test_files if f['size_kb'] < 10],
        'Medium (10-50 KB)': [f for f in test_files if 10 <= f['size_kb'] < 50], 
        'Large (50+ KB)': [f for f in test_files if f['size_kb'] >= 50]
    }
    
    for category, files in size_categories.items():
        if not files:
            continue
            
        print(f"\n{category}:")
        category_results = {}
        
        for impl_name, impl_results in results.items():
            category_times = []
            for file_info in files:
                if file_info['name'] in impl_results and impl_results[file_info['name']]['mean'] != float('inf'):
                    category_times.append(impl_results[file_info['name']]['mean'])
            
            if category_times:
                category_results[impl_name] = statistics.mean(category_times)
        
        # Sort by performance in this category
        sorted_category = sorted(category_results.items(), key=lambda x: x[1])
        for rank, (impl_name, avg_time) in enumerate(sorted_category, 1):
            print(f"  {rank}. {impl_name:15} {avg_time:8.2f}ms avg")
    
    # Save detailed results to JSON
    with open('benchmark_results_v3.json', 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"\n💾 Detailed results saved to benchmark_results_v3.json")
    print("\n🎯 BENCHMARK COMPLETE!")

if __name__ == "__main__":
    main()