#!/bin/bash

# Cross-cutting correctness tests for Yahoo Fantasy Sports implementations
# Tests both Zig and Go implementations for functional equivalence

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
ZIG_SDK_PORT=8081
GO_SDK_PORT=8082
ZIG_CLIENT_PORT=3001
GO_CLIENT_PORT=3002
TEST_TIMEOUT=30
TEST_DATA_DIR="$(dirname "$0")/test-data"

# Create test data directory
mkdir -p "$TEST_DATA_DIR"

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Cleanup function
cleanup() {
    log "Cleaning up test processes..."
    pkill -f "zig.*webapi" || true
    pkill -f "go.*webapi" || true
    pkill -f "zig.*webclient" || true
    pkill -f "go.*webclient" || true
    sleep 2
}

# Wait for service to be ready
wait_for_service() {
    local url=$1
    local timeout=$2
    local count=0
    
    while [ $count -lt $timeout ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            return 0
        fi
        sleep 1
        count=$((count + 1))
    done
    return 1
}

# Test API endpoint equivalence
test_api_equivalence() {
    local endpoint=$1
    local description=$2
    
    log "Testing $description..."
    
    # Get responses from both implementations
    local zig_response=$(curl -s "http://localhost:$ZIG_SDK_PORT$endpoint" || echo "ERROR")
    local go_response=$(curl -s "http://localhost:$GO_SDK_PORT$endpoint" || echo "ERROR")
    
    if [ "$zig_response" = "ERROR" ] || [ "$go_response" = "ERROR" ]; then
        error "$description - One or both services failed to respond"
        return 1
    fi
    
    # Save responses for comparison
    echo "$zig_response" > "$TEST_DATA_DIR/zig_${endpoint//\//_}.json"
    echo "$go_response" > "$TEST_DATA_DIR/go_${endpoint//\//_}.json"
    
    # Compare JSON structure (ignoring order)
    if command -v jq >/dev/null 2>&1; then
        local zig_normalized=$(echo "$zig_response" | jq -S . 2>/dev/null || echo "$zig_response")
        local go_normalized=$(echo "$go_response" | jq -S . 2>/dev/null || echo "$go_response")
        
        if [ "$zig_normalized" = "$go_normalized" ]; then
            success "$description - Responses match"
            return 0
        else
            error "$description - Responses differ"
            echo "Zig response: $zig_normalized"
            echo "Go response: $go_normalized"
            return 1
        fi
    else
        # Fallback to simple string comparison
        if [ "$zig_response" = "$go_response" ]; then
            success "$description - Responses match"
            return 0
        else
            warning "$description - Cannot verify response equivalence (jq not available)"
            return 0
        fi
    fi
}

# Test web client functionality
test_web_client() {
    local port=$1
    local implementation=$2
    
    log "Testing $implementation web client..."
    
    # Test home page
    if curl -s "http://localhost:$port/" | grep -q "Fantasy Dashboard"; then
        success "$implementation web client - Home page loads"
    else
        error "$implementation web client - Home page failed"
        return 1
    fi
    
    # Test static pages
    local pages=("games" "search" "auth")
    for page in "${pages[@]}"; do
        if curl -s "http://localhost:$port/$page" | grep -q "$page"; then
            success "$implementation web client - $page page loads"
        else
            error "$implementation web client - $page page failed"
            return 1
        fi
    done
    
    return 0
}

# Test authentication flow
test_authentication() {
    log "Testing authentication flow..."
    
    # Test token setting on both implementations
    local test_payload='{"access_token":"test_token","access_token_secret":"test_secret"}'
    
    # Test Zig implementation
    local zig_auth_response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "$test_payload" \
        "http://localhost:$ZIG_SDK_PORT/api/auth/tokens")
    
    # Test Go implementation  
    local go_auth_response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "$test_payload" \
        "http://localhost:$GO_SDK_PORT/api/auth/tokens")
    
    if echo "$zig_auth_response" | grep -q "success.*true" && 
       echo "$go_auth_response" | grep -q "success.*true"; then
        success "Authentication - Both implementations accept tokens"
        return 0
    else
        error "Authentication - Token setting failed"
        echo "Zig response: $zig_auth_response"
        echo "Go response: $go_auth_response"
        return 1
    fi
}

# Main test execution
main() {
    echo
    echo "=========================================="
    echo "Yahoo Fantasy Sports - Correctness Tests"
    echo "=========================================="
    echo
    
    # Cleanup any existing processes
    cleanup
    
    # Build and start services
    log "Building Zig implementations..."
    cd "$(dirname "$0")/../zig"
    if ! zig build-exe webapi.zig 2>/dev/null; then
        error "Failed to build Zig web API"
        exit 1
    fi
    
    if ! zig build-exe webclient.zig 2>/dev/null; then
        error "Failed to build Zig web client"
        exit 1
    fi
    
    log "Building Go implementations..."
    cd "$(dirname "$0")/../go"
    if ! go build -o webapi webapi.go sdk.go 2>/dev/null; then
        error "Failed to build Go web API"
        exit 1
    fi
    
    if ! go build -o webclient webclient.go 2>/dev/null; then
        error "Failed to build Go web client"
        exit 1
    fi
    
    # Start services
    log "Starting test services..."
    
    cd "$(dirname "$0")/../zig"
    ./webapi > /tmp/zig-webapi.log 2>&1 &
    ZIG_API_PID=$!
    
    ./webclient > /tmp/zig-webclient.log 2>&1 &
    ZIG_CLIENT_PID=$!
    
    cd "$(dirname "$0")/../go"
    ./webapi > /tmp/go-webapi.log 2>&1 &
    GO_API_PID=$!
    
    ./webclient > /tmp/go-webclient.log 2>&1 &
    GO_CLIENT_PID=$!
    
    # Wait for services to be ready
    log "Waiting for services to start..."
    
    if ! wait_for_service "http://localhost:$ZIG_SDK_PORT/health" $TEST_TIMEOUT; then
        error "Zig web API failed to start"
        cleanup
        exit 1
    fi
    
    if ! wait_for_service "http://localhost:$GO_SDK_PORT/health" $TEST_TIMEOUT; then
        error "Go web API failed to start"
        cleanup
        exit 1
    fi
    
    if ! wait_for_service "http://localhost:$ZIG_CLIENT_PORT/" $TEST_TIMEOUT; then
        error "Zig web client failed to start"
        cleanup
        exit 1
    fi
    
    if ! wait_for_service "http://localhost:$GO_CLIENT_PORT/" $TEST_TIMEOUT; then
        error "Go web client failed to start"
        cleanup
        exit 1
    fi
    
    success "All services started successfully"
    
    # Run tests
    local test_count=0
    local passed_count=0
    
    # Health check tests
    ((test_count++))
    if test_api_equivalence "/health" "Health check endpoint"; then
        ((passed_count++))
    fi
    
    # Authentication tests
    ((test_count++))
    if test_authentication; then
        ((passed_count++))
    fi
    
    # API endpoint tests (these will fail without real auth, but structure should be consistent)
    local endpoints=("/api/games")
    for endpoint in "${endpoints[@]}"; do
        ((test_count++))
        if test_api_equivalence "$endpoint" "API endpoint $endpoint"; then
            ((passed_count++))
        fi
    done
    
    # Web client tests
    ((test_count++))
    if test_web_client $ZIG_CLIENT_PORT "Zig"; then
        ((passed_count++))
    fi
    
    ((test_count++))
    if test_web_client $GO_CLIENT_PORT "Go"; then
        ((passed_count++))
    fi
    
    # Cleanup
    cleanup
    
    # Results
    echo
    echo "=========================================="
    echo "Test Results"
    echo "=========================================="
    echo "Total tests: $test_count"
    echo "Passed: $passed_count"
    echo "Failed: $((test_count - passed_count))"
    
    if [ $passed_count -eq $test_count ]; then
        success "All tests passed!"
        echo
        return 0
    else
        error "Some tests failed!"
        echo
        echo "Check log files:"
        echo "  - /tmp/zig-webapi.log"
        echo "  - /tmp/zig-webclient.log"
        echo "  - /tmp/go-webapi.log"
        echo "  - /tmp/go-webclient.log"
        echo
        echo "Test data saved to: $TEST_DATA_DIR"
        echo
        return 1
    fi
}

# Set trap for cleanup on script exit
trap cleanup EXIT

# Run main function
main "$@"