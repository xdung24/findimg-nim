@echo off
REM Build script for findimg_nim

echo Building findimg_nim...

REM Install dependencies
echo Installing dependencies...
nimble install -y pixie

REM Build the main executable
echo Compiling main executable...
nim c -d:release --opt:speed main.nim

REM Build the example
echo Compiling example...
nim c -d:release example.nim

REM Run tests
echo Running tests...
nim c -r test_findimage.nim

echo.
echo Build complete!
echo.
echo Usage examples:
echo   findimg_nim.exe haystack.jpg needle.jpg
echo   findimg_nim.exe -k 10 -o json image1.png image2.png
echo   nim r example.nim haystack.jpg needle.jpg 0.8
echo.
pause
