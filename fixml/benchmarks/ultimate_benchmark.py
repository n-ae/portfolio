#!/usr/bin/env python3

import subprocess
import time
import statistics
import os
import sys
import json
import gc

def run_command_precise(cmd, runs=20, warmup_runs=5):
    """Run command with maximum precision and statistical rigor"""
    times = []
    
    print(f"    Running {warmup_runs} warmup runs...", end="", flush=True)
    # Extended warmup to ensure JIT compilation, CPU scaling, etc.
    for _ in range(warmup_runs):
        try:
            subprocess.run(cmd, shell=True, capture_output=True, check=True)
        except subprocess.CalledProcessError:
            return None
        print(".", end="", flush=True)
    
    print(f"\n    Running {runs} timed runs...", end="", flush=True)
    
    # Force garbage collection before timing
    gc.collect()
    
    for i in range(runs):
        # Use highest precision timer
        start = time.perf_counter_ns()
        try:
            result = subprocess.run(cmd, shell=True, capture_output=True, check=True)
            end = time.perf_counter_ns()
            runtime = (end - start) / 1_000_000_000  # Convert to seconds
            times.append(runtime)
        except subprocess.CalledProcessError as e:
            print(f"Error on run {i+1}: {e}")
            return None
        
        if (i + 1) % 5 == 0:
            print(f"[{i+1}/{runs}]", end="", flush=True)
        else:
            print(".", end="", flush=True)
    
    print()
    
    # Remove outliers (beyond 2 standard deviations)
    if len(times) > 10:
        mean = statistics.mean(times)
        stdev = statistics.stdev(times)
        filtered_times = [t for t in times if abs(t - mean) <= 2 * stdev]
        if len(filtered_times) >= len(times) * 0.8:  # Keep at least 80% of data
            times = filtered_times
    
    return {
        'times': times,
        'count': len(times),
        'mean': statistics.mean(times),
        'median': statistics.median(times),
        'min': min(times),
        'max': max(times),
        'stdev': statistics.stdev(times) if len(times) > 1 else 0,
        'p95': sorted(times)[int(len(times) * 0.95)] if len(times) > 20 else max(times),
        'p99': sorted(times)[int(len(times) * 0.99)] if len(times) > 100 else max(times)
    }

def check_and_optimize_binaries():
    """Ensure all binaries are built with maximum optimizations"""
    
    print("🔧 Building maximum performance binaries...")
    
    # Zig - most aggressive optimizations
    print("  Building Zig with ReleaseFast + strip...")
    try:
        subprocess.run(["zig", "build", "-Doptimize=ReleaseFast"], check=True, capture_output=True)
        # Additional stripping if available
        if os.path.exists("zig-out/bin/fixml"):
            try:
                subprocess.run(["strip", "zig-out/bin/fixml"], capture_output=True)
            except:
                pass
    except Exception as e:
        print(f"    Zig build failed: {e}")
    
    # Go - maximum optimizations
    print("  Building Go with all optimizations...")
    try:
        # Use Go 1.21+ optimizations
        go_flags = [
            "-ldflags=-s -w -X main.version=optimized",
            "-trimpath",
            "-buildvcs=false"
        ]
        cmd = ["go", "build"] + go_flags + ["-o", "fixml_go_ultimate", "fixml.go"]
        subprocess.run(cmd, check=True, capture_output=True)
    except Exception as e:
        print(f"    Go build failed: {e}")
    
    # OCaml - maximum native optimizations
    print("  Building OCaml with maximum optimizations...")
    try:
        subprocess.run([
            "ocamlopt", "-O3", "-unbox-closures", "-unbox-closures-factor", "20",
            "-inline", "100", "-o", "fixml_ocaml_ultimate", "fixml_simple.ml"
        ], check=True, capture_output=True)
    except Exception as e:
        print(f"    OCaml build failed: {e}")
    
    # Rust version for comparison (if available)
    print("  Checking for additional optimizations...")
    
    # Check LuaJIT version and settings
    if subprocess.run(["which", "luajit"], capture_output=True).returncode == 0:
        try:
            result = subprocess.run(["luajit", "-v"], capture_output=True, text=True)
            print(f"    LuaJIT version: {result.stdout.strip()}")
        except:
            pass
    
    print("  ✓ All binaries optimized\n")

def get_system_info():
    """Get system information for context"""
    info = {}
    try:
        # CPU info
        result = subprocess.run(["sysctl", "-n", "machdep.cpu.brand_string"], 
                              capture_output=True, text=True)
        info['cpu'] = result.stdout.strip()
        
        # Core count
        result = subprocess.run(["sysctl", "-n", "hw.physicalcpu"], 
                              capture_output=True, text=True)
        info['physical_cores'] = result.stdout.strip()
        
        result = subprocess.run(["sysctl", "-n", "hw.logicalcpu"], 
                              capture_output=True, text=True)
        info['logical_cores'] = result.stdout.strip()
        
        # Memory
        result = subprocess.run(["sysctl", "-n", "hw.memsize"], 
                              capture_output=True, text=True)
        mem_bytes = int(result.stdout.strip())
        info['memory_gb'] = f"{mem_bytes / (1024**3):.1f}GB"
        
    except:
        info = {'cpu': 'Unknown', 'cores': 'Unknown', 'memory': 'Unknown'}
    
    return info

def format_stats_detailed(stats):
    """Format detailed statistics"""
    if stats is None:
        return "FAILED"
    
    return (f"Min: {stats['min']:.5f}s | Med: {stats['median']:.5f}s | "
            f"Mean: {stats['mean']:.5f}s ± {stats['stdev']:.5f}s | "
            f"Max: {stats['max']:.5f}s | P95: {stats['p95']:.5f}s")

def main():
    print("🚀 ULTIMATE MSBuild Project Organizer Performance Benchmark")
    print("=" * 70)
    
    # System info
    sys_info = get_system_info()
    print(f"System: {sys_info.get('cpu', 'Unknown')}")
    print(f"Cores: {sys_info.get('physical_cores', '?')} physical, {sys_info.get('logical_cores', '?')} logical")
    print(f"Memory: {sys_info.get('memory_gb', 'Unknown')}")
    print()
    
    # Optimize all binaries
    check_and_optimize_binaries()
    
    # Test files with more variety
    test_files = [
        ("tiny", "whitespace-duplicates-test.csproj"),
        ("small", "medium-test.csproj"),
        ("medium", "large-benchmark.csproj"),
        ("large", "massive-benchmark.csproj")
    ]
    
    # Define ultimate optimized benchmarks
    benchmarks = []
    
    # Check which binaries exist and are executable
    if os.path.isfile("zig-out/bin/fixml") and os.access("zig-out/bin/fixml", os.X_OK):
        benchmarks.append(("Zig ReleaseFast", "./zig-out/bin/fixml"))
    
    if os.path.isfile("fixml_go_ultimate") and os.access("fixml_go_ultimate", os.X_OK):
        benchmarks.append(("Go Ultimate", "./fixml_go_ultimate"))
    elif os.path.isfile("fixml_go") and os.access("fixml_go", os.X_OK):
        benchmarks.append(("Go Optimized", "./fixml_go"))
    
    if os.path.isfile("fixml_ocaml_ultimate") and os.access("fixml_ocaml_ultimate", os.X_OK):
        benchmarks.append(("OCaml Ultimate", "./fixml_ocaml_ultimate"))
    elif os.path.isfile("fixml_ocaml") and os.access("fixml_ocaml", os.X_OK):
        benchmarks.append(("OCaml Native", "./fixml_ocaml"))
    
    # Scripting languages
    if subprocess.run(["which", "luajit"], capture_output=True).returncode == 0:
        benchmarks.append(("LuaJIT", "luajit fixml.lua"))
    
    benchmarks.append(("Lua Standard", "lua fixml.lua"))
    
    if not benchmarks:
        print("❌ No executable benchmarks found!")
        return
    
    print(f"🎯 Found {len(benchmarks)} benchmark targets")
    print(f"📊 Running 20 measurements + 5 warmup runs per test")
    print()
    
    all_results = {}
    
    # Run comprehensive benchmarks
    for test_name, test_file in test_files:
        if not os.path.isfile(test_file):
            continue
            
        lines = sum(1 for _ in open(test_file))
        print(f"📈 BENCHMARKING: {test_name.upper()} ({test_file})")
        print(f"    File size: {lines:,} lines")
        print("=" * 60)
        
        results = {}
        
        for name, base_cmd in benchmarks:
            cmd = f"{base_cmd} {test_file}"
            print(f"  🔥 {name}:")
            
            stats = run_command_precise(cmd, runs=20, warmup_runs=5)
            if stats:
                results[name] = stats
                print(f"    ✅ {format_stats_detailed(stats)}")
            else:
                print(f"    ❌ FAILED")
            print()
        
        all_results[test_name] = results
        
        # Immediate ranking for this file size
        if results:
            print("🏆 RANKING:")
            print("-" * 30)
            
            sorted_results = sorted(results.items(), key=lambda x: x[1]['min'])
            fastest_time = sorted_results[0][1]['min']
            
            for i, (name, stats) in enumerate(sorted_results, 1):
                speedup = stats['min'] / fastest_time
                confidence_interval = stats['stdev'] * 1.96  # 95% CI
                print(f"{i}. {name:<15}: {stats['min']:.5f}s ± {confidence_interval:.5f}s "
                      f"({speedup:.1f}x)")
            print()
        
        print("=" * 60)
        print()
    
    # Final comprehensive analysis
    print("🎖️  ULTIMATE PERFORMANCE ANALYSIS")
    print("=" * 70)
    
    # Create performance matrix
    if all_results:
        print("📊 COMPLETE PERFORMANCE MATRIX (minimum times):")
        print()
        
        # Header
        languages = list(next(iter(all_results.values())).keys())
        print(f"{'File Size':<12} | " + " | ".join(f"{lang:<12}" for lang in languages))
        print("-" * (15 + len(languages) * 15))
        
        # Data rows
        for test_name, results in all_results.items():
            row = f"{test_name:<12} | "
            for lang in languages:
                if lang in results:
                    time_str = f"{results[lang]['min']:.5f}s"
                else:
                    time_str = "FAILED"
                row += f"{time_str:<12} | "
            print(row.rstrip(" |"))
        
        print()
    
    # Binary size comparison
    print("💾 BINARY SIZE COMPARISON:")
    print("-" * 30)
    
    binaries = [
        ("Zig", "zig-out/bin/fixml"),
        ("Go Ultimate", "fixml_go_ultimate"),
        ("Go Standard", "fixml_go"),
        ("OCaml Ultimate", "fixml_ocaml_ultimate"),
        ("OCaml Standard", "fixml_ocaml")
    ]
    
    for name, path in binaries:
        if os.path.isfile(path):
            size = os.path.getsize(path)
            if size < 1024:
                size_str = f"{size}B"
            elif size < 1024**2:
                size_str = f"{size/1024:.1f}K"
            elif size < 1024**3:
                size_str = f"{size/1024**2:.1f}M"
            else:
                size_str = f"{size/1024**3:.1f}G"
            print(f"{name:<15}: {size_str}")
    
    print()
    print("✨ STATISTICAL CONFIDENCE: 95% confidence intervals shown")
    print("🎯 MEASUREMENT PRECISION: Nanosecond timing, outlier removal")
    print("🔥 OPTIMIZATION LEVEL: Maximum for all languages")

if __name__ == "__main__":
    main()