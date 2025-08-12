import findimage
import pixie
import std/[times, strformat, os, tables, sequtils]

type
  ComparisonResult = object
    name: string
    avgTime: float64
    minTime: float64
    maxTime: float64
    confidence: float64

proc benchmarkConfiguration(name: string, largePath, smallPath: string, opts: Opts, runs: int = 5): ComparisonResult =
  if not (fileExists(largePath) and fileExists(smallPath)):
    echo fmt"Skipping {name}: files not found"
    return ComparisonResult(name: name)
  
  let largeImg = readImage(largePath)
  let smallImg = readImage(smallPath)
  var times: seq[float64] = @[]
  var bestConfidence = 0.0
  
  for i in 0..<runs:
    GC_fullCollect()
    let startTime = cpuTime()
    let matches = findImage(largeImg, smallImg, opts)
    let endTime = cpuTime()
    
    let duration = (endTime - startTime) * 1000.0
    times.add(duration)
    
    if matches.len > 0 and matches[0].confident > bestConfidence:
      bestConfidence = matches[0].confident
  
  if times.len == 0:
    return ComparisonResult(name: name)
  
  times.sort()
  result = ComparisonResult(
    name: name,
    avgTime: times.sum() / float64(times.len),
    minTime: times[0],
    maxTime: times[^1],
    confidence: bestConfidence
  )

proc runComparisonBenchmarks() =
  let largePath = "test_images/haystack.jpg"
  let smallPath = "test_images/needle.jpg"
  
  echo "=== FindImg Nim Configuration Comparison ==="
  echo fmt"Testing: {extractFilename(largePath)} -> {extractFilename(smallPath)}"
  echo ""
  
  let configurations = [
    ("Default", DEFAULT_OPTS),
    ("Fast (k=1)", Opts(k: 1, imgMaxWidth: 256, subMaxDiv: 32, imgMinWidth: 8, subMinArea: 25, verbose: false)),
    ("Accurate (k=10)", Opts(k: 10, imgMaxWidth: 512, subMaxDiv: 128, imgMinWidth: 8, subMinArea: 25, verbose: false)),
    ("Low Memory", Opts(k: 3, imgMaxWidth: 128, subMaxDiv: 32, imgMinWidth: 8, subMinArea: 25, verbose: false)),
    ("High Quality", Opts(k: 6, imgMaxWidth: 1024, subMaxDiv: 256, imgMinWidth: 8, subMinArea: 16, verbose: false)),
  ]
  
  var results: seq[ComparisonResult] = @[]
  
  for (name, opts) in configurations:
    echo fmt"Testing {name}..."
    let result = benchmarkConfiguration(name, largePath, smallPath, opts)
    results.add(result)
  
  echo ""
  echo "=== Results ==="
  echo fmt"{'Configuration':<15} {'Avg Time':<10} {'Min Time':<10} {'Max Time':<10} {'Confidence':<12}"
  echo repeat("-", 65)
  
  for result in results:
    if result.avgTime > 0:
      echo fmt"{result.name:<15} {result.avgTime:<10.2f} {result.minTime:<10.2f} {result.maxTime:<10.2f} {result.confidence:<12.4f}"
    else:
      echo fmt"{result.name:<15} {'N/A':<10} {'N/A':<10} {'N/A':<10} {'N/A':<12}"
  
  echo ""
  
  # Find fastest and most accurate configurations
  let validResults = results.filter(r => r.avgTime > 0)
  if validResults.len > 0:
    let fastest = validResults.minBy(r => r.avgTime)
    let mostAccurate = validResults.maxBy(r => r.confidence)
    
    echo "=== Recommendations ==="
    echo fmt"Fastest configuration: {fastest.name} ({fastest.avgTime:.2f} ms)"
    echo fmt"Most accurate configuration: {mostAccurate.name} (confidence: {mostAccurate.confidence:.4f})"
    
    if fastest.name != mostAccurate.name:
      echo ""
      echo "Speed vs Accuracy trade-off detected:"
      echo fmt"- Choose '{fastest.name}' for real-time applications"
      echo fmt"- Choose '{mostAccurate.name}' for best match quality"

when isMainModule:
  runComparisonBenchmarks()
