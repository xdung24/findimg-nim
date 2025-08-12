import findimage
import pixie
import std/[times, strformat, os, sequtils, math, stats]

type
  BenchmarkResult = object
    imageName: string
    templateName: string
    imageSize: tuple[w, h: int]
    templateSize: tuple[w, h: int]
    searchTime: float64  # in milliseconds
    memoryUsed: int64    # in bytes
    matchCount: int
    bestConfidence: float64
    opts: Opts

proc benchmarkSingleMatch(largePath, smallPath: string, opts: Opts = DEFAULT_OPTS): BenchmarkResult =
  let largeImg = readImage(largePath)
  let smallImg = readImage(smallPath)
  
  # Measure memory before
  GC_fullCollect()
  let memBefore = getOccupiedMem()
  
  # Time the search
  let startTime = cpuTime()
  let matches = findImage(largeImg, smallImg, opts)
  let endTime = cpuTime()
  
  # Measure memory after
  let memAfter = getOccupiedMem()
  
  result = BenchmarkResult(
    imageName: extractFilename(largePath),
    templateName: extractFilename(smallPath),
    imageSize: (largeImg.width, largeImg.height),
    templateSize: (smallImg.width, smallImg.height),
    searchTime: (endTime - startTime) * 1000.0,  # Convert to ms
    memoryUsed: memAfter - memBefore,
    matchCount: matches.len,
    bestConfidence: if matches.len > 0: matches[0].confident else: 0.0,
    opts: opts
  )

proc runBasicBenchmarks() =
  echo "=== FindImg Nim Basic Benchmarks ==="
  echo ""
  
  # Test with different image sizes - check what files are available
  let testCases = [
    ("test_images/haystack.jpg", "test_images/needle.jpg"),
    ("test_images/haystack.jpg", "test_images/logo.png"),
    ("test_images/html.jpg", "test_images/logo.png"),
  ]
  
  for (largePath, smallPath) in testCases:
    if fileExists(largePath) and fileExists(smallPath):
      echo fmt"Testing: {largePath} -> {smallPath}"
      let result = benchmarkSingleMatch(largePath, smallPath)
      
      echo fmt"  Image: {result.imageName} ({result.imageSize.w}x{result.imageSize.h})"
      echo fmt"  Template: {result.templateName} ({result.templateSize.w}x{result.templateSize.h})"
      echo fmt"  Search Time: {result.searchTime:.2f} ms"
      echo fmt"  Memory Used: {result.memoryUsed / 1024 / 1024:.2f} MB"
      echo fmt"  Matches Found: {result.matchCount}"
      echo fmt"  Best Confidence: {result.bestConfidence:.4f}"
      echo ""
    else:
      echo fmt"Skipping {largePath} -> {smallPath} (files not found)"

proc runParameterBenchmarks() =
  echo "=== Parameter Optimization Benchmarks ==="
  echo ""
  
  let largePath = "test_images/haystack.jpg"
  let smallPath = "test_images/needle.jpg"
  
  if not (fileExists(largePath) and fileExists(smallPath)):
    echo "Test images not found, skipping parameter benchmarks"
    return
  
  echo "Testing different k values:"
  for k in [1, 3, 6, 10]:
    let opts = Opts(k: k, verbose: false)
    let result = benchmarkSingleMatch(largePath, smallPath, opts)
    echo fmt"  k={k}: {result.searchTime:.2f} ms, {result.matchCount} matches, confidence: {result.bestConfidence:.4f}"
  
  echo ""
  echo "Testing different max widths:"
  for maxWidth in [128, 256, 512]:
    let opts = Opts(imgMaxWidth: maxWidth, k: 3, verbose: false)
    let result = benchmarkSingleMatch(largePath, smallPath, opts)
    echo fmt"  maxWidth={maxWidth}: {result.searchTime:.2f} ms, confidence: {result.bestConfidence:.4f}"

when isMainModule:
  runBasicBenchmarks()
  runParameterBenchmarks()
