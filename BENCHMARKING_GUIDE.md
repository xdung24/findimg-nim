# FindImg Nim Benchmarking Guide

This guide provides instructions for benchmarking the performance of the FindImg Nim library using the basic benchmark tool. You'll learn how to measure speed, test different parameters, and optimize performance.

## Table of Contents

1. [Overview](#overview)
2. [Basic Benchmark Setup](#basic-benchmark-setup)
3. [Running Benchmarks](#running-benchmarks)
4. [Understanding Results](#understanding-results)
5. [Performance Optimization](#performance-optimization)

## Overview

The FindImg Nim library's performance depends on several factors:
- **Image sizes** (both haystack and needle)
- **Image complexity** (color variations, patterns)
- **Search parameters** (k value, scale ranges)
- **Hardware** (CPU, memory bandwidth)

Key metrics measured by the basic benchmark:
- **Search time** - Total time to find matches
- **Memory usage** - Peak memory consumption during search
- **Match accuracy** - Match confidence and count
- **Parameter optimization** - Performance with different settings

## Basic Benchmark Setup

The `benchmark_basic.nim` script provides comprehensive testing with your existing test images. It will:

1. **Test multiple image combinations** from your `test_images/` folder
2. **Measure search performance** including time and memory usage
3. **Test different parameters** to find optimal settings
4. **Provide detailed results** for analysis

### Prerequisites

- Nim compiler installed
- Test images in `test_images/` directory
- At least `haystack.jpg` and `needle.jpg` for basic testing

## Running Benchmarks

### 1. Compile the Benchmark

```bash
nim c -d:release benchmark_basic.nim
```

### 2. Run Basic Performance Test

```bash
benchmark_basic.exe
```

The benchmark will automatically:
- Test available image combinations from `test_images/`
- Measure search time and memory usage
- Test different parameter values (k, imgMaxWidth)
- Display detailed results

### 3. Sample Output

```
=== FindImg Nim Basic Benchmarks ===

Testing: test_images/haystack.jpg -> test_images/needle.jpg
  Image: haystack.jpg (800x600)
  Template: needle.jpg (64x48)
  Search Time: 45.23 ms
  Memory Used: 12.50 MB
  Matches Found: 6
  Best Confidence: 0.8945

=== Parameter Optimization Benchmarks ===

Testing different k values:
  k=1: 38.12 ms, 1 matches, confidence: 0.8945
  k=3: 42.45 ms, 3 matches, confidence: 0.8945
  k=6: 45.23 ms, 6 matches, confidence: 0.8945
  k=10: 52.78 ms, 10 matches, confidence: 0.8945

Testing different max widths:
  maxWidth=128: 12.34 ms, confidence: 0.7821
  maxWidth=256: 28.91 ms, confidence: 0.8654
  maxWidth=512: 45.23 ms, confidence: 0.8945
```

## Understanding Results

### Performance Metrics

The benchmark provides several key metrics:

- **Search Time**: Time taken to find matches (lower is better)
- **Memory Used**: Peak memory during search operation
- **Matches Found**: Number of potential matches found
- **Best Confidence**: Quality score of the best match (0.0 to 1.0, higher is better)

### Parameter Impact

- **k value**: Number of top matches to find
  - `k=1`: Fastest, finds only the best match
  - `k=6`: Default, good balance of speed and options
  - `k=10+`: Slower, finds many alternatives

- **imgMaxWidth**: Maximum image width for processing
  - `128`: Very fast, lower accuracy
  - `256`: Good balance for most cases
  - `512+`: Slower, higher accuracy for large images

### Performance Categories

Based on search time:
- **Excellent**: < 20ms (suitable for 50+ FPS)
- **Good**: 20-50ms (suitable for 20+ FPS)
- **Moderate**: 50-100ms (suitable for 10+ FPS)
- **Slow**: > 100ms (batch processing only)

## Performance Optimization

### Quick Optimization Tips

1. **For speed**: Use `k=1` and `imgMaxWidth=256`
2. **For accuracy**: Use `k=6` and `imgMaxWidth=512`
3. **For real-time**: Aim for < 50ms search time
4. **For batch processing**: Use higher accuracy settings

### Compilation Optimization

Always compile with release flag for accurate benchmarks:

```bash
# Standard release build
nim c -d:release benchmark_basic.nim

# Maximum optimization
nim c -d:release -d:danger --opt:speed benchmark_basic.nim
```

### When to Re-benchmark

Re-run benchmarks when:
- Changing to different sized images
- Testing on different hardware
- After updating the Nim compiler
- When optimizing for specific use cases

## Troubleshooting

### Common Issues

1. **"Files not found"**: Ensure test images exist in `test_images/` folder
2. **Very slow performance**: Check if using debug build instead of release
3. **High memory usage**: Try reducing `imgMaxWidth` parameter
4. **No matches found**: Check image compatibility and confidence thresholds

### Getting Help

If benchmark results seem unexpected:
1. Verify test images are properly formatted
2. Try with different image combinations
3. Check system resources during benchmark
4. Compare with simple findImage test first

This basic benchmark provides essential performance insights for the FindImg Nim library. Use the results to optimize parameters for your specific use case.
