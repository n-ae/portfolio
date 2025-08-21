# Benchmarking Suite

Comprehensive performance benchmarking tools for all FIXML implementations.

## Main Benchmark Scripts

### `final_benchmark.py` ⭐ **Primary Benchmark**
Complete benchmark with O(n) complexity verification:
```bash
python3 final_benchmark.py
```
- Tests all 5 optimized implementations
- 30 iterations per test for statistical confidence
- Cross-file scaling analysis
- Performance rankings and efficiency metrics

### `lua_optimization_benchmark.py`
Focused Lua optimization analysis:
```bash  
python3 lua_optimization_benchmark.py
```
- Compares Lua v4.0.0 vs v5.0.0 (Ultra)
- Scaling efficiency analysis
- Optimization technique breakdown

### `quick_benchmark_v3.py`
Fast benchmark for development:
```bash
python3 quick_benchmark_v3.py
```
- 25 iterations, 4 test files
- Quick performance comparison

## Legacy Benchmarks
- `comprehensive_benchmark_v3.py` - Extended benchmark suite
- `benchmark_summary.py` - Summary statistics
- `robust_benchmark.py` - High-precision benchmarking
- `ultimate_benchmark.py` - Multi-iteration analysis

## Shell Scripts
- `benchmark.sh` - Simple shell benchmark
- `optimized_benchmark.sh` - Optimized configuration benchmark
- `precision_benchmark.sh` - High precision timing
- `compare_all.sh` - Cross-implementation comparison

## Results
- `result.csv` - Historical benchmark data

## Usage Notes
All benchmark scripts expect the new directory structure:
- Language binaries: `../lua/fixml`, `../go/fixml`, etc.
- Test files: `../tests/samples/*.csproj`

Run benchmarks from this directory for correct path resolution.