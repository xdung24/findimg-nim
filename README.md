# FindImg Nim

A pure Nim implementation of image template matching, providing functionality similar to OpenCV's `matchTemplate` and the Go `findimg` library.

## Features

- **Pure Nim**: No C/C++ dependencies or wrappers
- **Fast**: Optimized convolution-based matching algorithm
- **Simple API**: Easy-to-use functions similar to OpenCV
- **Multiple scales**: Searches at different image and template scales for better matches
- **Configurable**: Adjustable parameters for different use cases

## Dependencies

- Nim >= 1.6.0
- Pixie >= 5.0.0 (Pure Nim image library)

## Installation

1. Install Nim from [nim-lang.org](https://nim-lang.org)
2. Clone or download this library
3. Install dependencies:

```bash
nimble install pixie
```

## Quick Start

### Basic Usage

```nim
import findimage
import pixie

# Load images
let largeImage = readImage("haystack.jpg")
let smallImagePath = "needle.jpg"

# Simple comparison (similar to Python OpenCV)
let (found, confidence, position) = compareImage(largeImage, smallImagePath, 0.8)

if found:
  echo "Match found at position (", position.x, ", ", position.y, ") with confidence: ", confidence
else:
  echo "No match found"
```

### Advanced Usage

```nim
import findimage
import pixie

# Load images
let largeImage = readImage("haystack.jpg")
let smallImage = readImage("needle.jpg")

# Configure search options
let options = Opts(
  k: 5,           # Return top 5 matches
  verbose: true,  # Print debug information
  imgMaxWidth: 512, # Maximum image width for processing
  subMaxDiv: 32   # Maximum template division factor
)

# Find multiple matches
let matches = findImage(largeImage, smallImage, options)

for i, match in matches:
  echo "Match ", i+1, ": confidence=", match.confident, 
       " center=(", match.centerX, ",", match.centerY, ")"
```

## API Reference

### Types

```nim
type
  Point = object
    x, y: int

  Rectangle = object
    min, max: Point

  Match = object
    bounds: Rectangle
    confident: float64

  Opts = object
    imgMinWidth: int    # Minimum image width for processing (default: 8)
    imgMaxWidth: int    # Maximum image width for processing (default: 256)
    subMinArea: int     # Minimum template area (default: 25)
    subMaxDiv: int      # Maximum template division factor (default: 64)
    k: int              # Number of top matches to return (default: 6)
    verbose: bool       # Enable debug output (default: false)
```

### Functions

#### `findImage(imgSrc, subSrc: Image, opts: Opts): seq[Match]`

Main function to find template matches in an image.

- `imgSrc`: Large image to search in
- `subSrc`: Template image to find
- `opts`: Search options (optional, uses DEFAULT_OPTS if not provided)
- Returns: Sequence of matches sorted by confidence (highest first)

#### `compareImage(largeImage: Image, smallImagePath: string, threshold: float64): tuple[found: bool, confidence: float64, position: Point]`

Simple wrapper function similar to OpenCV's matchTemplate.

- `largeImage`: Large image to search in
- `smallImagePath`: Path to template image file
- `threshold`: Minimum confidence threshold (0.0 to 1.0)
- Returns: Tuple with match result, confidence, and center position

#### Utility Functions

- `centerX(match: Match): int` - Get center X coordinate of match
- `centerY(match: Match): int` - Get center Y coordinate of match
- `scale(match: Match, scale: float64): Match` - Scale match coordinates
- `resizeImage(img: Image, width, height: int): Image` - Resize image

## Comparison with Other Implementations

### Python OpenCV equivalent:
```python
# Python OpenCV
result = cv2.matchTemplate(large_image, small_image, cv2.TM_CCOEFF_NORMED)
_, max_val, _, max_loc = cv2.minMaxLoc(result)

# Nim equivalent
let (found, confidence, position) = compareImage(largeImage, "small_image.png", 0.8)
```

### Go findimg equivalent:
```go
// Go findimg
matches := findImage(imgSrc, subSrc, opts)

// Nim equivalent  
let matches = findImage(imgSrc, subSrc, opts)
```

## Performance

The algorithm uses a multi-scale approach similar to the Go implementation:

1. Resizes the source image to different scales (powers of 2)
2. For each scale, tries different template sizes (division factors)
3. Uses sum of absolute differences (SAD) for pixel comparison
4. Returns matches sorted by confidence

This approach provides good balance between accuracy and performance for most use cases.

## Examples

### Example 1: Find UI Elements

```nim
import findimage, pixie

let screenshot = readImage("screenshot.png")
let buttonTemplate = readImage("button.png")

let matches = findImage(screenshot, buttonTemplate, Opts(k: 1))

if matches.len > 0 and matches[0].confident > 0.9:
  echo "Button found at: (", matches[0].centerX, ", ", matches[0].centerY, ")"
  # Click at this position
```

### Example 2: Multiple Matches

```nim
import findimage, pixie

let gameScreen = readImage("game.png")
let coinTemplate = readImage("coin.png")

let matches = findImage(gameScreen, coinTemplate, Opts(k: 10))

echo "Found ", matches.len, " coins:"
for match in matches:
  if match.confident > 0.8:
    echo "  Coin at (", match.centerX, ", ", match.centerY, ") confidence: ", match.confident
```

## Running Tests

The project includes test images in the `test_images/` folder:
- `haystack.jpg` - Large test image
- `needle.jpg` - Small template image to find
- `logo.png` - Logo image
- `html.jpg` - Additional test image

```bash
# Run unit tests
nim c -r test_findimage.nim

# Run all tests with example images
test_all.bat      # Windows
./test_all.sh     # Linux/Mac
```

## Running Example

```bash
# Use default test images
nim r example.nim

# Use custom images
nim r example.nim test_images/haystack.jpg test_images/needle.jpg 0.8

# Command line tool
nim r main.nim test_images/haystack.jpg test_images/needle.jpg
```

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.
