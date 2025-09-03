@echo off
REM Build script for findimg

echo Building findimg...

REM Install dependencies
echo Installing dependencies...
nimble install -y pixie

REM Build the main executable
echo Compiling main executable...
nim c -d:release --opt:speed main.nim

echo.
echo Build complete!
echo.
echo Usage examples:
echo   findimg.exe haystack.jpg needle.jpg
echo   findimg.exe -k 10 -o json image1.png image2.png
echo.
pause
