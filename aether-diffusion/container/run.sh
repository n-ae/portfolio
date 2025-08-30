#!/bin/bash

# Master container management script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Configuration
IMAGE_NAME="${IMAGE_NAME:-yahoo-fantasy-api}"
TAG="${TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-yahoo-fantasy-api}"
PORT="${PORT:-8080}"

# Detect container runtime
if command -v podman &> /dev/null; then
    RUNTIME="podman"
elif command -v docker &> /dev/null; then
    RUNTIME="docker"
else
    echo "Error: Neither podman nor docker found"
    exit 1
fi

show_help() {
    cat << EOF
Yahoo Fantasy API Container Manager

Usage: $0 <command> [options]

Commands:
  build-dev     Build development container (fast, requires local Zig)
  build-prod    Build production container (slow, self-contained)
  run           Run container with demo credentials
  run-env       Run container with .env file
  stop          Stop and remove container
  logs          Show container logs
  test          Test container endpoints
  shell         Open shell in running container
  compose-up    Start with docker-compose
  compose-down  Stop docker-compose services
  clean         Remove container and images

Environment Variables:
  IMAGE_NAME          Container image name (default: yahoo-fantasy-api)
  TAG                 Container tag (default: latest)
  CONTAINER_NAME      Container name (default: yahoo-fantasy-api)
  PORT                Host port (default: 8080)
  YAHOO_CONSUMER_KEY  Yahoo API consumer key
  YAHOO_CONSUMER_SECRET Yahoo API consumer secret

Examples:
  $0 build-dev                          # Quick development build
  $0 run                                # Run with demo credentials
  $0 run-env                            # Run with .env file
  PORT=8081 $0 run                      # Run on different port
  $0 test                               # Test all endpoints
  
EOF
}

build_dev() {
    echo "Building development container..."
    cd "$PROJECT_ROOT"
    exec "$SCRIPT_DIR/build-simple.sh"
}

build_prod() {
    echo "Building production container..."
    cd "$PROJECT_ROOT"
    exec "$SCRIPT_DIR/build.sh"
}

run_container() {
    stop_container 2>/dev/null || true
    
    echo "Starting container: $CONTAINER_NAME"
    echo "Port mapping: $PORT:8080"
    echo "Runtime: $RUNTIME"
    
    $RUNTIME run -d \
        -p "$PORT:8080" \
        --name "$CONTAINER_NAME" \
        -e YAHOO_CONSUMER_KEY="${YAHOO_CONSUMER_KEY:-demo_key}" \
        -e YAHOO_CONSUMER_SECRET="${YAHOO_CONSUMER_SECRET:-demo_secret}" \
        -e YAHOO_ACCESS_TOKEN="${YAHOO_ACCESS_TOKEN:-}" \
        -e YAHOO_ACCESS_TOKEN_SECRET="${YAHOO_ACCESS_TOKEN_SECRET:-}" \
        "$IMAGE_NAME:$TAG"
    
    echo "Container started successfully!"
    echo "Test with: curl http://localhost:$PORT/health"
}

run_with_env() {
    if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
        echo "Error: .env file not found at $PROJECT_ROOT/.env"
        echo "Copy .env.example to .env and configure your credentials"
        exit 1
    fi
    
    stop_container 2>/dev/null || true
    
    echo "Starting container with .env file..."
    echo "Port mapping: $PORT:8080"
    echo "Runtime: $RUNTIME"
    
    $RUNTIME run -d \
        -p "$PORT:8080" \
        --name "$CONTAINER_NAME" \
        --env-file "$PROJECT_ROOT/.env" \
        "$IMAGE_NAME:$TAG"
    
    echo "Container started successfully!"
    echo "Test with: curl http://localhost:$PORT/health"
}

stop_container() {
    echo "Stopping container: $CONTAINER_NAME"
    $RUNTIME rm -f "$CONTAINER_NAME"
}

show_logs() {
    echo "Container logs for: $CONTAINER_NAME"
    $RUNTIME logs "$CONTAINER_NAME"
}

test_endpoints() {
    echo "Testing container endpoints..."
    
    # Check if container is running
    if ! $RUNTIME ps --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
        echo "Error: Container $CONTAINER_NAME is not running"
        echo "Start it with: $0 run"
        exit 1
    fi
    
    BASE_URL="http://localhost:$PORT"
    
    echo "Testing $BASE_URL/health..."
    if curl -sf "$BASE_URL/health" > /dev/null; then
        echo "✓ Health check passed"
        curl -s "$BASE_URL/health" | jq 2>/dev/null || curl -s "$BASE_URL/health"
    else
        echo "✗ Health check failed"
        return 1
    fi
    
    echo
    echo "Testing $BASE_URL/status..."
    if curl -sf "$BASE_URL/status" > /dev/null; then
        echo "✓ Status endpoint passed"
        curl -s "$BASE_URL/status" | jq 2>/dev/null || curl -s "$BASE_URL/status"
    else
        echo "✗ Status endpoint failed"
        return 1
    fi
    
    echo
    echo "Testing $BASE_URL/demo..."
    if curl -sf "$BASE_URL/demo" > /dev/null; then
        echo "✓ Demo endpoint passed"
        curl -s "$BASE_URL/demo" | jq 2>/dev/null || curl -s "$BASE_URL/demo"
    else
        echo "✗ Demo endpoint failed"
        return 1
    fi
    
    echo
    echo "All tests passed! 🎉"
}

open_shell() {
    echo "Opening shell in container: $CONTAINER_NAME"
    $RUNTIME exec -it "$CONTAINER_NAME" /bin/sh
}

compose_up() {
    echo "Starting with docker-compose..."
    cd "$SCRIPT_DIR"
    docker-compose up -d
}

compose_down() {
    echo "Stopping docker-compose services..."
    cd "$SCRIPT_DIR"
    docker-compose down
}

clean_all() {
    echo "Cleaning up containers and images..."
    
    # Stop and remove container
    $RUNTIME rm -f "$CONTAINER_NAME" 2>/dev/null || true
    
    # Remove images
    $RUNTIME rmi "$IMAGE_NAME:$TAG" 2>/dev/null || true
    $RUNTIME rmi "$IMAGE_NAME:latest" 2>/dev/null || true
    
    # Remove dangling images
    $RUNTIME image prune -f
    
    echo "Cleanup completed"
}

# Main command processing
case "${1:-}" in
    build-dev)
        build_dev
        ;;
    build-prod)
        build_prod
        ;;
    run)
        run_container
        ;;
    run-env)
        run_with_env
        ;;
    stop)
        stop_container
        ;;
    logs)
        show_logs
        ;;
    test)
        test_endpoints
        ;;
    shell)
        open_shell
        ;;
    compose-up)
        compose_up
        ;;
    compose-down)
        compose_down
        ;;
    clean)
        clean_all
        ;;
    help|-h|--help)
        show_help
        ;;
    "")
        echo "Error: No command specified"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac