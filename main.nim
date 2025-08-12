import findimage
import pixie
import std/[os, strformat, parseopt, json, strutils]

type
  OutputFormat = enum
    Text, Json

proc usage() =
  echo """
Usage: findimg_nim [options] <large_image> <small_image>

Options:
  -h, --help                Show this help message
  -k NUM                    Number of top matches to return (default: 6)
  -o FORMAT                 Output format: text, json (default: text)
  -v, --verbose             Verbose output
  --img-min-width NUM       Minimum image width for processing (default: 8)
  --img-max-width NUM       Maximum image width for processing (default: 256)
  --sub-min-area NUM        Minimum template area (default: 25)
  --sub-max-div NUM         Maximum template division factor (default: 64)

Examples:
  findimg_nim haystack.jpg needle.jpg
  findimg_nim -k 10 -o json screenshot.png button.png
  findimg_nim -v --img-max-width 512 large.png small.png
"""

proc main() =
  var
    outputFormat = Text
    opts = DEFAULT_OPTS
    largeImagePath = ""
    smallImagePath = ""
  
  # Parse command line arguments
  var parser = initOptParser()
  while true:
    parser.next()
    case parser.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case parser.key
      of "h", "help":
        usage()
        return
      of "k":
        if parser.val == "":
          echo "Error: -k requires a number"
          return
        try:
          opts.k = parseInt(parser.val)
        except ValueError:
          echo "Error: -k must be a valid number"
          return
      of "o":
        case parser.val.toLowerAscii()
        of "text":
          outputFormat = Text
        of "json":
          outputFormat = Json
        else:
          echo "Error: output format must be 'text' or 'json'"
          return
      of "v", "verbose":
        opts.verbose = true
      of "img-min-width":
        if parser.val == "":
          echo "Error: --img-min-width requires a number"
          return
        try:
          opts.imgMinWidth = parseInt(parser.val)
        except ValueError:
          echo "Error: --img-min-width must be a valid number"
          return
      of "img-max-width":
        if parser.val == "":
          echo "Error: --img-max-width requires a number"
          return
        try:
          opts.imgMaxWidth = parseInt(parser.val)
        except ValueError:
          echo "Error: --img-max-width must be a valid number"
          return
      of "sub-min-area":
        if parser.val == "":
          echo "Error: --sub-min-area requires a number"
          return
        try:
          opts.subMinArea = parseInt(parser.val)
        except ValueError:
          echo "Error: --sub-min-area must be a valid number"
          return
      of "sub-max-div":
        if parser.val == "":
          echo "Error: --sub-max-div requires a number"
          return
        try:
          opts.subMaxDiv = parseInt(parser.val)
        except ValueError:
          echo "Error: --sub-max-div must be a valid number"
          return
      else:
        echo fmt"Error: Unknown option: {parser.key}"
        return
    of cmdArgument:
      if largeImagePath == "":
        largeImagePath = parser.key
      elif smallImagePath == "":
        smallImagePath = parser.key
      else:
        echo "Error: Too many arguments"
        usage()
        return
  
  # Validate arguments
  if largeImagePath == "" or smallImagePath == "":
    echo "Error: Both large_image and small_image are required"
    usage()
    return
  
  if not fileExists(largeImagePath):
    echo fmt"Error: Large image file '{largeImagePath}' not found"
    return
  
  if not fileExists(smallImagePath):
    echo fmt"Error: Small image file '{smallImagePath}' not found"
    return
  
  try:
    # Load images
    let largeImage = readImage(largeImagePath)
    let smallImage = readImage(smallImagePath)
    
    # Find matches
    let matches = findImage(largeImage, smallImage, opts)
    
    # Output results
    case outputFormat
    of Text:
      for match in matches:
        echo fmt"{match.confident:>8.6f} {match.bounds.min.x:>4} {match.bounds.min.y:>4} {match.bounds.width:>4} {match.bounds.height:>4} {match.centerX:>4} {match.centerY:>4}"
    
    of Json:
      var jsonMatches = newJArray()
      for match in matches:
        var jsonMatch = newJObject()
        var bounds = newJObject()
        bounds["x"] = newJInt(match.bounds.min.x)
        bounds["y"] = newJInt(match.bounds.min.y)
        bounds["w"] = newJInt(match.bounds.width)
        bounds["h"] = newJInt(match.bounds.height)
        
        var center = newJObject()
        center["x"] = newJInt(match.centerX)
        center["y"] = newJInt(match.centerY)
        
        jsonMatch["bounds"] = bounds
        jsonMatch["center"] = center
        jsonMatch["confident"] = newJFloat(match.confident)
        
        jsonMatches.add(jsonMatch)
      
      var result = newJObject()
      result["matches"] = jsonMatches
      echo result.pretty()

  except Exception as e:
    echo fmt"Error: {e.msg}"

when isMainModule:
  main()
