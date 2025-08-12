import findimage
import pixie
import std/[strformat, os]

proc main() =
  let largeImagePath = if paramCount() >= 1: paramStr(1) else: "test_images/haystack.jpg"
  let smallImagePath = if paramCount() >= 2: paramStr(2) else: "test_images/needle.jpg"
  let threshold = if paramCount() >= 3: parseFloat(paramStr(3)) else: 0.8
  
  if paramCount() == 0:
    echo "Using default test images: haystack.jpg and needle.jpg"
    echo "Usage: nim r example.nim [large_image] [small_image] [threshold]"
    echo "Example: nim r example.nim test_images/haystack.jpg test_images/needle.jpg 0.8"
    echo ""
  
  if not fileExists(largeImagePath):
    echo fmt"Error: Large image file '{largeImagePath}' not found"
    return
  
  if not fileExists(smallImagePath):
    echo fmt"Error: Small image file '{smallImagePath}' not found"
    return
  
  try:
    echo fmt"Loading images..."
    let largeImage = readImage(largeImagePath)
    let smallImage = readImage(smallImagePath)
    
    echo fmt"Large image: {largeImage.width}x{largeImage.height}"
    echo fmt"Small image: {smallImage.width}x{smallImage.height}"
    echo fmt"Threshold: {threshold}"
    echo ""
    
    # Method 1: Using compareImage (simple wrapper)
    echo "Method 1: Simple comparison"
    let (found, confidence, position) = compareImage(largeImage, smallImagePath, threshold)
    
    if found:
      echo fmt"✓ Match found! Confidence: {confidence:.6f} at position ({position.x}, {position.y})"
    else:
      echo fmt"✗ No match found. Best confidence: {confidence:.6f} (threshold: {threshold})"
    
    echo ""
    
    # Method 2: Using findImage (detailed results)
    echo "Method 2: Detailed search (top 5 matches)"
    let options = Opts(k: 5, verbose: false)
    let matches = findImage(largeImage, smallImage, options)
    
    echo fmt"Found {matches.len} matches:"
    for i, match in matches:
      echo fmt"  {i+1}. Confidence: {match.confident:.6f} at ({match.bounds.min.x}, {match.bounds.min.y}) size: {match.bounds.width}x{match.bounds.height} center: ({match.centerX}, {match.centerY})"
    
    echo ""
    
    # Method 3: Verbose search
    echo "Method 3: Verbose search"
    let verboseOptions = Opts(k: 1, verbose: true)
    let verboseMatches = findImage(largeImage, smallImage, verboseOptions)
    
    if verboseMatches.len > 0:
      let bestMatch = verboseMatches[0]
      echo fmt"Best match: {bestMatch.confident:.6f} at center ({bestMatch.centerX}, {bestMatch.centerY})"
    
  except Exception as e:
    echo fmt"Error: {e.msg}"

when isMainModule:
  main()
