# FIXML Benchmarking

Simple performance benchmarking for all FIXML implementations.

## Quick Benchmark

Run from project root:
```bash
python3 benchmark.py
```

## Detailed Benchmark

Run from benchmarks directory:
```bash
python3 final_benchmark.py
```

Features:
- Tests all 5 implementations (Go, Rust, Lua, OCaml, Zig)
- Multiple file sizes for scaling analysis  
- Statistical confidence with multiple iterations
- Performance rankings and efficiency metrics

## Results

Historical results stored in:
- `result.csv` - Performance data
- `benchmark_results_v3.json` - Detailed metrics