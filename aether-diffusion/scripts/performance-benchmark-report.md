# Performance Benchmark Report

Generated: Sun Aug 31 02:27:53 2025

## Test Configuration

- Iterations per implementation: 100
- Warmup runs: 10
- Test timeout: 60 seconds

## Performance Results Summary

**Rust** has the best average performance

### Execution Time Comparison

| Implementation | Mean | Median | Min | Max | Std Dev | P95 | P99 | Success Rate |
|---------------|------|--------|-----|-----|---------|-----|-----|-------------|
| **Zig** | 0.0001s | 0.0001s | 0.0001s | 0.0001s | 0.0000s | 0.0001s | 0.0001s | 100.0% |
| **Go** | 0.0001s | 0.0001s | 0.0001s | 0.0002s | 0.0000s | 0.0001s | 0.0002s | 100.0% |
| **Rust** | 0.0001s | 0.0001s | 0.0001s | 0.0001s | 0.0000s | 0.0001s | 0.0001s | 100.0% |

### Memory Usage Estimates

| Implementation | Avg Memory | Peak Memory | Samples |
|---------------|------------|-------------|---------|
| **Zig** | 0 KB | 0 KB | 0 |
| **Go** | 0 KB | 0 KB | 0 |
| **Rust** | 0 KB | 0 KB | 0 |

## Detailed Analysis

### Performance Characteristics

- **Zig** shows more consistent performance (lower standard deviation)
- **Zig** has better worst-case performance (lower P99 latency)

### Memory Characteristics

- **Go** uses less average memory

## Recommendations

- Consider **Rust** for performance-critical applications
- Use these benchmarks as baseline for optimization efforts
- Consider real-world usage patterns when making technology choices

## Raw Performance Data

### Zig Execution Times (first 10 samples)
```
0.000112
0.000114
0.000116
0.000113
0.000112
0.000113
0.000115
0.000105
0.000104
0.000102
```

### Go Execution Times (first 10 samples)
```
0.000105
0.000119
0.000123
0.000122
0.000111
0.000114
0.000111
0.000110
0.000102
0.000103
```

### Rust Execution Times (first 10 samples)
```
0.000100
0.000098
0.000103
0.000109
0.000119
0.000102
0.000108
0.000102
0.000109
0.000097
```