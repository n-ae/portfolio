---
name: Performance Issue
about: Report slow performance or optimization opportunities
title: '[PERFORMANCE] '
labels: 'performance, enhancement'
assignees: ''
---

## ⚡ Performance Issue Description
A clear description of the performance problem you're experiencing.

## 📊 Current Performance
- **Processing Time**: [e.g., 2.5 seconds]
- **File Size**: [e.g., 1.2MB] 
- **Memory Usage**: [e.g., 250MB peak]
- **CPU Usage**: [e.g., 100% single core]

## 🎯 Expected Performance  
- **Target Processing Time**: [e.g., <100ms]
- **Comparison**: [e.g., "Other tool X processes this in 50ms"]

## 📄 Input Characteristics
- **File Size**: [e.g., 1.2MB]
- **Element Count**: [approximate number of XML elements]
- **Depth**: [maximum nesting level]
- **Complexity**: [attributes, comments, CDATA, etc.]

## 🔧 System Information
- **OS**: [e.g., Ubuntu 22.04 LTS]
- **CPU**: [e.g., Intel i7-12700K, Apple M2, AMD Ryzen 9]
- **Memory**: [e.g., 32GB DDR4]
- **Storage**: [e.g., NVMe SSD, HDD]

## 📋 Command & Configuration
```bash
# Exact command used
fixml --flags input.xml

# Build configuration (if compiled from source)
zig build -Doptimize=ReleaseFast
```

## 📈 Benchmark Results
If you've run benchmarks, please include results:
```bash
# Example benchmark command
time fixml large-file.xml

# Or if using our benchmark suite
lua benchmark.lua quick
```

## 🔍 Profiling Data
If you've done any profiling, please include relevant data:
- **CPU profiling**: [tool used and key findings]
- **Memory profiling**: [tool used and key findings]  
- **I/O analysis**: [if relevant]

## 💡 Potential Solutions
Any ideas for optimization or similar issues you've seen?

## 🎯 Performance Targets
Our current performance targets:
- **Small files** (<10KB): <20ms
- **Medium files** (10KB-1MB): <100ms  
- **Large files** (>1MB): Linear O(n) scaling

Current baseline: ~20ms average for typical XML files.

## ✅ Checklist
- [ ] I have measured actual performance (not just perceived)
- [ ] I have tested with ReleaseFast build optimizations
- [ ] I have compared with other tools/implementations if available
- [ ] I have included system specifications
- [ ] I have provided a reproducible test case