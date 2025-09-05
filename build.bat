@echo off
REM Build script for findimg_nim

echo Building findimg_nim...

REM Install dependencies
echo Installing dependencies...
nimble install -y pixie

REM Run tests
echo Running tests...
nim c -r test_findimage.nim

if errorlevel 1 (
    echo Tests failed. Aborting build.
    exit /b 1
)

REM Build the main executable
echo Compiling main executable...
nimble build -d:release --opt:speed --app:console --verbose --gc:orc findimg.nim

echo.
echo Build complete!
echo.
echo Usage examples:
echo   findimg.exe assets/haystack.jpg assets/needle.jpg
echo   findimg.exe -k 10 -o json image1.png image2.png
echo   nim r example.nim assets/haystack.jpg assets/needle.jpg 0.8
echo.
pause
