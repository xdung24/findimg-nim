import std/[math, algorithm, sequtils, sugar, strformat]
import pixie

type
  Point* = object
    x*, y*: int

  Rectangle* = object
    min*, max*: Point

  Match* = object
    bounds*: Rectangle
    confident*: float64

  Opts* = object
    imgMinWidth*: int
    imgMaxWidth*: int
    subMinArea*: int
    subMaxDiv*: int
    k*: int
    verbose*: bool

const
  DEFAULT_OPTS* = Opts(
    k: 1,
    imgMinWidth: 8,
    imgMaxWidth: 256,
    subMaxDiv: 64,
    subMinArea: 25,
    verbose: false
  )

proc newRectangle*(minX, minY, maxX, maxY: int): Rectangle =
  Rectangle(min: Point(x: minX, y: minY), max: Point(x: maxX, y: maxY))

proc width*(r: Rectangle): int = r.max.x - r.min.x
proc height*(r: Rectangle): int = r.max.y - r.min.y

proc centerX*(m: Match): int =
  m.bounds.min.x + (m.bounds.width div 2)

proc centerY*(m: Match): int =
  m.bounds.min.y + (m.bounds.height div 2)

proc scale*(m: Match, scale: float64): Match =
  result = m
  result.bounds.min.x = int(float64(m.bounds.min.x) * scale)
  result.bounds.min.y = int(float64(m.bounds.min.y) * scale)
  result.bounds.max.x = int(float64(m.bounds.max.x) * scale)
  result.bounds.max.y = int(float64(m.bounds.max.y) * scale)

proc scale*(matches: seq[Match], scale: float64): seq[Match] =
  matches.map(m => m.scale(scale))

proc rgbAbsDiff*(r1, g1, b1, r2, g2, b2: uint8): uint32 =
  ## Calculate absolute difference between two RGB pixels
  let dr = if r1 > r2: r1 - r2 else: r2 - r1
  let dg = if g1 > g2: g1 - g2 else: g2 - g1
  let db = if b1 > b2: b1 - b2 else: b2 - b1
  uint32(dr) + uint32(dg) + uint32(db)

proc sumOfAbsDiff*(img: Image, x, y: int, subimg: Image): uint32 =
  ## Calculate sum of absolute differences for a subimage at position (x,y)
  var sum: uint32 = 0
  let subWidth = subimg.width
  let subHeight = subimg.height
  
  for ny in 0..<subHeight:
    for nx in 0..<subWidth:
      if x + nx < img.width and y + ny < img.height:
        let imgPixel = img[x + nx, y + ny]
        let subPixel = subimg[nx, ny]
        sum += rgbAbsDiff(imgPixel.r, imgPixel.g, imgPixel.b,
                         subPixel.r, subPixel.g, subPixel.b)
  
  sum

proc resizeImage*(img: Image, width, height: int): Image =
  ## Resize image maintaining aspect ratio if one dimension is 0
  var newWidth = width
  var newHeight = height
  
  if newWidth == 0:
    newWidth = int(float64(newHeight) * float64(img.width) / float64(img.height))
  elif newHeight == 0:
    newHeight = int(float64(newWidth) * float64(img.height) / float64(img.width))
  
  if newWidth < 1: newWidth = 1
  if newHeight < 1: newHeight = 1
  
  img.resize(newWidth, newHeight)

proc convolutionTopK*(img: Image, subimg: Image, k: int): seq[Match] =
  ## Find top k matches using convolution
  let imgWidth = img.width
  let imgHeight = img.height
  let subWidth = subimg.width
  let subHeight = subimg.height
  
  # Calculate search area
  let maxX = imgWidth - subWidth
  let maxY = imgHeight - subHeight
  
  if maxX <= 0 or maxY <= 0:
    return @[]
  
  var matches: seq[Match] = @[]
  var minSums: seq[uint32] = @[]
  
  for y in 0..<maxY:
    for x in 0..<maxX:
      let sum = sumOfAbsDiff(img, x, y, subimg)
      let bounds = newRectangle(x, y, x + subWidth, y + subHeight)
      
      # Keep top k matches with lowest sum (best matches)
      if matches.len < k:
        matches.add(Match(bounds: bounds, confident: float64(sum)))
        minSums.add(sum)
      else:
        # Find index with highest sum (worst match)
        var maxDiffIndex = 0
        for i in 1..<k:
          if minSums[i] > minSums[maxDiffIndex]:
            maxDiffIndex = i
        
        if sum < minSums[maxDiffIndex]:
          matches[maxDiffIndex] = Match(bounds: bounds, confident: float64(sum))
          minSums[maxDiffIndex] = sum
  
  # Normalize confidence scores (convert sum to confidence 0-1)
  let norm = 1.0 / float64(subWidth * subHeight * 255 * 3)
  for i in 0..<matches.len:
    matches[i].confident = 1.0 - matches[i].confident * norm
  
  # Sort by confidence (highest first)
  matches.sort((a, b) => cmp(b.confident, a.confident))
  
  matches

proc findImage*(imgSrc: Image, subSrc: Image, opts: Opts = DEFAULT_OPTS): seq[Match] =
  ## Main function to find subimage in larger image
  var options = opts
  
  # Apply default values
  if options.imgMinWidth == 0: options.imgMinWidth = DEFAULT_OPTS.imgMinWidth
  if options.imgMaxWidth == 0: options.imgMaxWidth = DEFAULT_OPTS.imgMaxWidth
  if options.subMinArea == 0: options.subMinArea = DEFAULT_OPTS.subMinArea
  if options.subMaxDiv == 0: options.subMaxDiv = DEFAULT_OPTS.subMaxDiv
  if options.k == 0: options.k = DEFAULT_OPTS.k
  
  if imgSrc.width < options.imgMaxWidth:
    options.imgMaxWidth = imgSrc.width
  
  var matches: seq[Match] = @[]
  var lastTopMatch = 0.0
  var done = false
  
  # Try different image scales
  var imgWidth = options.imgMinWidth
  while imgWidth <= options.imgMaxWidth and not done:
    let img = resizeImage(imgSrc, imgWidth, 0)
    let imgHeight = img.height
    let imgScale = float64(imgWidth) / float64(imgSrc.width)
    
    # Try different subimage scales
    var divFactor = 1
    while divFactor <= options.subMaxDiv:
      let sscale = 1.0 / float64(divFactor)
      let sw = int(round(float64(subSrc.width) * sscale * imgScale))
      let sh = int(round(float64(subSrc.height) * sscale * imgScale))
      let sarea = sw * sh
      
      if sarea < options.subMinArea or sw >= imgWidth or sh >= imgHeight:
        if options.verbose:
          echo fmt"image size: {imgWidth}x{imgHeight}, subimage size: {sw}x{sh}, div: {divFactor}, skipping"
        break
      
      let subimg = resizeImage(subSrc, sw, sh)
      let divMatches = convolutionTopK(img, subimg, options.k)
      
      if divMatches.len == 0:
        break
      
      let divTopMatch = divMatches[0]
      if options.verbose:
        echo fmt"image size: {imgWidth}x{imgHeight}, subimage size: {sw}x{sh}, div: {divFactor}, match: {divTopMatch.confident:.6f}"
      
      let scaledMatches = divMatches.scale(1.0 / imgScale)
      
      if divTopMatch.confident < lastTopMatch:
        done = true
        break
      
      lastTopMatch = divTopMatch.confident
      matches = scaledMatches
      
      divFactor *= 2
    
    imgWidth *= 2
  
  # Sort final matches by confidence (highest first)
  matches.sort((a, b) => cmp(b.confident, a.confident))
  
  matches

proc compareImage*(largeImage: Image, smallImagePath: string, threshold: float64): tuple[found: bool, confidence: float64, position: Point] =
  ## Simple wrapper similar to Python OpenCV matchTemplate
  try:
    let smallImage = readImage(smallImagePath)
    let matches = findImage(largeImage, smallImage, Opts(k: 1, verbose: false))
    
    if matches.len > 0:
      let bestMatch = matches[0]
      if bestMatch.confident >= threshold:
        return (true, bestMatch.confident, Point(x: bestMatch.centerX, y: bestMatch.centerY))
      else:
        return (false, bestMatch.confident, Point(x: 0, y: 0))
    else:
      return (false, 0.0, Point(x: 0, y: 0))
  except:
    return (false, 0.0, Point(x: 0, y: 0))

# Export main functions
export Point, Rectangle, Match, Opts, DEFAULT_OPTS
export findImage, compareImage, resizeImage
export centerX, centerY, scale
