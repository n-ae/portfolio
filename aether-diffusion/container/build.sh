#!/bin/bash

# Build script for Yahoo Fantasy API container
# Supports both Docker and Podman

set -e

# Configuration
IMAGE_NAME="yahoo-fantasy-api"
TAG="${TAG:-latest}"
REGISTRY="${REGISTRY:-}"
PLATFORM="${PLATFORM:-linux/amd64}"

# Detect container runtime
if command -v podman &> /dev/null; then
    RUNTIME="podman"
    BUILD_CMD="podman build"
elif command -v docker &> /dev/null; then
    RUNTIME="docker"
    BUILD_CMD="docker build"
else
    echo "Error: Neither podman nor docker found"
    exit 1
fi

echo "Using container runtime: $RUNTIME"
echo "Building image: $IMAGE_NAME:$TAG"
echo "Platform: $PLATFORM"

# Build the image
$BUILD_CMD \
    --platform="$PLATFORM" \
    --tag="$IMAGE_NAME:$TAG" \
    --file="container/Containerfile" \
    .

# Tag with registry if specified
if [[ -n "$REGISTRY" ]]; then
    FULL_TAG="$REGISTRY/$IMAGE_NAME:$TAG"
    echo "Tagging image as: $FULL_TAG"
    $RUNTIME tag "$IMAGE_NAME:$TAG" "$FULL_TAG"
fi

echo "Build completed successfully!"
echo ""
echo "To run the container:"
echo "  $RUNTIME run -d -p 8080:8080 --name yahoo-fantasy-api $IMAGE_NAME:$TAG"
echo ""
echo "To run with environment variables:"
echo "  $RUNTIME run -d -p 8080:8080 --env-file .env --name yahoo-fantasy-api $IMAGE_NAME:$TAG"
echo ""
echo "To use Docker Compose:"
echo "  docker-compose up -d"