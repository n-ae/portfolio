#!/bin/bash

# Simple container build script - builds locally first
set -e

echo "Building Yahoo Fantasy API container..."

# Build the Zig application for Linux (cross-compile)
echo "Step 1: Building Zig application for Linux (cross-compilation)..."
zig build -Doptimize=ReleaseFast -Dtarget=x86_64-linux

# Check if binary exists
if [[ ! -f "zig-out/bin/yahoo_fantasy_server" ]]; then
    echo "Error: Failed to build yahoo_fantasy_server binary"
    exit 1
fi

echo "✓ Local build completed"

# Detect container runtime
if command -v podman &> /dev/null; then
    RUNTIME="podman"
elif command -v docker &> /dev/null; then
    RUNTIME="docker"
else
    echo "Error: Neither podman nor docker found"
    exit 1
fi

echo "Step 2: Building container image with $RUNTIME..."

# Build the container
$RUNTIME build \
    --platform=linux/amd64 \
    --tag=yahoo-fantasy-api:latest \
    --file=container/Containerfile.simple \
    .

echo "✓ Container build completed successfully!"
echo ""
echo "To run the container:"
echo "  $RUNTIME run -d -p 8080:8080 --name yahoo-fantasy-api yahoo-fantasy-api:latest"
echo ""
echo "To test the container:"
echo "  curl http://localhost:8080/health"