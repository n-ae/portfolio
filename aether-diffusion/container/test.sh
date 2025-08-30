#!/bin/bash

# Quick test to see if the original container build works
set -e

echo "Testing container build - this may take several minutes..."

# Detect container runtime
if command -v podman &> /dev/null; then
    RUNTIME="podman"
elif command -v docker &> /dev/null; then
    RUNTIME="docker"
else
    echo "Error: Neither podman nor docker found"
    exit 1
fi

echo "Using container runtime: $RUNTIME"

# Build just the first stage to test Zig installation
echo "Building Zig installation layer..."
$RUNTIME build --target=builder --file=container/Containerfile .

if [ $? -eq 0 ]; then
    echo "✓ Zig installation successful!"
    echo "Now building full image..."
    $RUNTIME build --tag=yahoo-fantasy-api:test --file=container/Containerfile .
else
    echo "✗ Zig installation failed"
    exit 1
fi