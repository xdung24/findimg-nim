#!/bin/bash
# Test script for findimg_nim using the copied test images

echo "Testing findimg_nim with test images..."
echo ""

# Test 1: Basic functionality
echo "Test 1: Basic image matching"
echo "Command: nim r example.nim"
nim r example.nim
echo ""

# Test 2: Command line tool with text output
echo "Test 2: Command line tool - text output"
echo "Command: nim r main.nim test_images/haystack.jpg test_images/needle.jpg"
nim r main.nim test_images/haystack.jpg test_images/needle.jpg
echo ""

# Test 3: Command line tool with JSON output
echo "Test 3: Command line tool - JSON output"
echo "Command: nim r main.nim -o json -k 3 test_images/haystack.jpg test_images/needle.jpg"
nim r main.nim -o json -k 3 test_images/haystack.jpg test_images/needle.jpg
echo ""

# Test 4: Verbose output
echo "Test 4: Verbose output"
echo "Command: nim r main.nim -v -k 1 test_images/haystack.jpg test_images/needle.jpg"
nim r main.nim -v -k 1 test_images/haystack.jpg test_images/needle.jpg
echo ""

# Test 5: Unit tests
echo "Test 5: Unit tests"
echo "Command: nim c -r test_findimage.nim"
nim c -r test_findimage.nim
echo ""

echo "All tests completed!"
