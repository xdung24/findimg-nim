@echo off
echo ===================================================
echo FindImg Nim Benchmarking Suite
echo ===================================================
echo.

REM Check if Nim is available
nim --version >nul 2>&1
if errorlevel 1 (
    echo Error: Nim compiler not found. Please install Nim and add it to PATH.
    pause
    exit /b 1
)

echo Compiling benchmark executables...
echo.

REM Compile all benchmark programs
echo [1/4] Compiling basic benchmark...
nim c -d:release benchmark_basic.nim
if errorlevel 1 (
    echo Error compiling benchmark_basic.nim
    pause
    exit /b 1
)

echo [2/4] Compiling statistical benchmark...
nim c -d:release benchmark_stats.nim
if errorlevel 1 (
    echo Error compiling benchmark_stats.nim
    pause
    exit /b 1
)

echo [3/4] Compiling memory benchmark...
nim c -d:release benchmark_memory.nim
if errorlevel 1 (
    echo Error compiling benchmark_memory.nim
    pause
    exit /b 1
)

echo [4/4] Compiling throughput benchmark...
nim c -d:release benchmark_throughput.nim
if errorlevel 1 (
    echo Error compiling benchmark_throughput.nim
    pause
    exit /b 1
)

echo.
echo All benchmarks compiled successfully!
echo.

REM Check if test images exist
if not exist "test_images\haystack.jpg" (
    echo Warning: test_images\haystack.jpg not found
    echo Some benchmarks may not run properly
    echo.
)

echo ===================================================
echo Running Benchmarks
echo ===================================================
echo.

echo [1/4] Running basic performance benchmark...
echo.
benchmark_basic.exe
echo.

echo [2/4] Running statistical analysis (20 iterations)...
echo.
benchmark_stats.exe
echo.

echo [3/4] Running memory usage analysis...
echo.
benchmark_memory.exe
echo.

echo [4/4] Running throughput benchmark (10 seconds)...
echo.
benchmark_throughput.exe
echo.

echo ===================================================
echo Benchmark Suite Complete
echo ===================================================
echo.
echo Results summary:
echo - Basic benchmark: Tests different parameter combinations
echo - Statistical analysis: Provides mean, median, std dev over multiple runs
echo - Memory analysis: Shows memory usage during search operations
echo - Throughput test: Measures searches per second over time
echo.
echo For custom tests, run individual benchmarks with parameters:
echo   benchmark_stats.exe large_image.jpg small_image.jpg [iterations]
echo   benchmark_memory.exe large_image.jpg small_image.jpg
echo   benchmark_throughput.exe large_image.jpg small_image.jpg [duration_seconds]
echo.
pause
