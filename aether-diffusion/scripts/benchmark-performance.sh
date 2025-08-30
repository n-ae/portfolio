#!/bin/bash

# Performance benchmark tests for Yahoo Fantasy Sports implementations
# Compares performance characteristics between Zig and Go implementations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
ZIG_SDK_PORT=8083
GO_SDK_PORT=8084
WARMUP_REQUESTS=50
BENCHMARK_REQUESTS=1000
CONCURRENT_CONNECTIONS=50
RESULTS_DIR="$(dirname "$0")/benchmark-results"

# Create results directory
mkdir -p "$RESULTS_DIR"

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
    log "Cleaning up benchmark processes..."
    pkill -f "zig.*webapi" || true
    pkill -f "go.*webapi" || true
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

# Run load test using curl or wrk if available
run_load_test() {
    local url=$1
    local implementation=$2
    local endpoint_name=$3
    local output_file=$4
    
    log "Running load test for $implementation $endpoint_name..."
    
    if command -v wrk >/dev/null 2>&1; then
        # Use wrk for more detailed benchmarks
        wrk -t4 -c$CONCURRENT_CONNECTIONS -d30s --timeout=10s "$url" > "$output_file" 2>&1
        
        # Extract key metrics
        local rps=$(grep "Requests/sec" "$output_file" | awk '{print $2}')
        local latency=$(grep "Latency" "$output_file" | awk '{print $2}')
        local transfer=$(grep "Transfer/sec" "$output_file" | awk '{print $2}')
        
        echo "Implementation: $implementation" >> "$output_file.summary"
        echo "Endpoint: $endpoint_name" >> "$output_file.summary"
        echo "Requests/sec: $rps" >> "$output_file.summary"
        echo "Avg Latency: $latency" >> "$output_file.summary"
        echo "Transfer/sec: $transfer" >> "$output_file.summary"
        echo "---" >> "$output_file.summary"
        
        success "$implementation $endpoint_name - $rps req/s, $latency avg latency"
        
    elif command -v ab >/dev/null 2>&1; then
        # Use Apache Bench as fallback
        ab -n $BENCHMARK_REQUESTS -c $CONCURRENT_CONNECTIONS "$url" > "$output_file" 2>&1
        
        # Extract key metrics
        local rps=$(grep "Requests per second" "$output_file" | awk '{print $4}')
        local time_per_request=$(grep "Time per request.*mean" "$output_file" | head -1 | awk '{print $4}')
        
        echo "Implementation: $implementation" >> "$output_file.summary"
        echo "Endpoint: $endpoint_name" >> "$output_file.summary"
        echo "Requests/sec: $rps" >> "$output_file.summary"
        echo "Time/request: ${time_per_request}ms" >> "$output_file.summary"
        echo "---" >> "$output_file.summary"
        
        success "$implementation $endpoint_name - $rps req/s, ${time_per_request}ms per request"
        
    else
        # Simple curl-based test
        log "No advanced benchmarking tools found, using simple curl test..."
        
        local start_time=$(date +%s.%N)
        local success_count=0
        
        for ((i=1; i<=100; i++)); do
            if curl -s "$url" >/dev/null 2>&1; then
                ((success_count++))
            fi
        done
        
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc -l)
        local rps=$(echo "scale=2; $success_count / $duration" | bc -l)
        
        echo "Implementation: $implementation" > "$output_file"
        echo "Endpoint: $endpoint_name" >> "$output_file"
        echo "Requests completed: $success_count/100" >> "$output_file"
        echo "Duration: ${duration}s" >> "$output_file"
        echo "Requests/sec: $rps" >> "$output_file"
        
        echo "Implementation: $implementation" >> "$output_file.summary"
        echo "Endpoint: $endpoint_name" >> "$output_file.summary"
        echo "Requests/sec: $rps" >> "$output_file.summary"
        echo "Success rate: $success_count%" >> "$output_file.summary"
        echo "---" >> "$output_file.summary"
        
        success "$implementation $endpoint_name - $rps req/s, $success_count% success rate"
    fi
}

# Measure memory usage
measure_memory_usage() {
    local pid=$1
    local implementation=$2
    local duration=$3
    local output_file="$RESULTS_DIR/${implementation}_memory.log"
    
    log "Monitoring memory usage for $implementation (PID: $pid)..."
    
    # Monitor for specified duration
    for ((i=0; i<$duration; i++)); do
        if kill -0 $pid 2>/dev/null; then
            # Get memory info (works on both Linux and macOS)
            if command -v ps >/dev/null 2>&1; then
                local mem_info=$(ps -p $pid -o pid,rss,vsz,pcpu,pmem --no-headers 2>/dev/null || echo "")
                if [ -n "$mem_info" ]; then
                    echo "$(date +%s) $mem_info" >> "$output_file"
                fi
            fi
        else
            warning "Process $pid ($implementation) is no longer running"
            break
        fi
        sleep 1
    done
    
    # Calculate averages
    if [ -f "$output_file" ]; then
        local avg_rss=$(awk '{sum+=$3; count++} END {if(count>0) print sum/count; else print 0}' "$output_file")
        local max_rss=$(awk '{if($3>max) max=$3} END {print max+0}' "$output_file")
        
        echo "Implementation: $implementation" >> "$output_file.summary"
        echo "Average RSS: ${avg_rss}KB" >> "$output_file.summary"
        echo "Peak RSS: ${max_rss}KB" >> "$output_file.summary"
        echo "---" >> "$output_file.summary"
        
        success "$implementation memory - Avg: ${avg_rss}KB, Peak: ${max_rss}KB"
    fi
}

# Generate performance report
generate_report() {
    local report_file="$RESULTS_DIR/performance_report.md"
    
    log "Generating performance report..."
    
    cat > "$report_file" << EOF
# Yahoo Fantasy Sports - Performance Benchmark Report

Generated: $(date)

## Test Configuration
- Benchmark Requests: $BENCHMARK_REQUESTS
- Concurrent Connections: $CONCURRENT_CONNECTIONS
- Warmup Requests: $WARMUP_REQUESTS

## Results Summary

EOF

    # Add results from summary files
    if [ -f "$RESULTS_DIR/zig_health.log.summary" ]; then
        echo "### Zig Implementation" >> "$report_file"
        echo '```' >> "$report_file"
        cat "$RESULTS_DIR"/zig_*.log.summary >> "$report_file"
        echo '```' >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    if [ -f "$RESULTS_DIR/go_health.log.summary" ]; then
        echo "### Go Implementation" >> "$report_file"
        echo '```' >> "$report_file"
        cat "$RESULTS_DIR"/go_*.log.summary >> "$report_file"
        echo '```' >> "$report_file"
        echo "" >> "$report_file"
    fi
    
    # Add recommendations
    cat >> "$report_file" << EOF

## Analysis

### Performance Characteristics
- Both implementations provide similar API functionality
- Actual performance will vary based on system resources and network conditions
- Memory usage patterns may differ between Zig and Go due to garbage collection

### Recommendations
1. Use these benchmarks as a baseline for optimization efforts
2. Consider real-world usage patterns when interpreting results
3. Monitor production performance and adjust configurations accordingly
4. Test with realistic data payloads and user scenarios

## Raw Data Files
EOF

    # List all result files
    find "$RESULTS_DIR" -name "*.log" -type f | sort | while read -r file; do
        echo "- $(basename "$file")" >> "$report_file"
    done
    
    success "Performance report generated: $report_file"
}

# Main benchmark execution
main() {
    echo
    echo "============================================="
    echo "Yahoo Fantasy Sports - Performance Benchmark"
    echo "============================================="
    echo
    
    # Check dependencies
    if ! command -v curl >/dev/null 2>&1; then
        error "curl is required for benchmarking"
        exit 1
    fi
    
    if command -v wrk >/dev/null 2>&1; then
        success "Using wrk for advanced benchmarking"
    elif command -v ab >/dev/null 2>&1; then
        success "Using Apache Bench for benchmarking"
    else
        warning "No advanced benchmarking tools found, using basic curl tests"
    fi
    
    # Cleanup any existing processes
    cleanup
    
    # Build services
    log "Building implementations for benchmarking..."
    
    cd "$(dirname "$0")/../zig"
    if ! zig build-exe webapi.zig -O ReleaseFast 2>/dev/null; then
        error "Failed to build optimized Zig web API"
        exit 1
    fi
    
    cd "$(dirname "$0")/../go"
    if ! go build -ldflags="-s -w" -o webapi webapi.go sdk.go 2>/dev/null; then
        error "Failed to build optimized Go web API"
        exit 1
    fi
    
    # Start services with custom ports for benchmarking
    log "Starting services for benchmarking..."
    
    cd "$(dirname "$0")/../zig"
    # Modify port in the binary or use environment variable if supported
    sed "s/8080/$ZIG_SDK_PORT/g" webapi.zig > webapi_bench.zig
    zig build-exe webapi_bench.zig -O ReleaseFast >/dev/null 2>&1
    ./webapi_bench > /tmp/zig-webapi-bench.log 2>&1 &
    ZIG_API_PID=$!
    
    cd "$(dirname "$0")/../go"
    # Similar approach for Go
    sed "s/8080/$GO_SDK_PORT/g" webapi.go > webapi_bench.go
    go build -ldflags="-s -w" -o webapi_bench webapi_bench.go sdk.go >/dev/null 2>&1
    ./webapi_bench > /tmp/go-webapi-bench.log 2>&1 &
    GO_API_PID=$!
    
    # Wait for services to be ready
    log "Waiting for services to start..."
    
    if ! wait_for_service "http://localhost:$ZIG_SDK_PORT/health" 30; then
        error "Zig web API failed to start on port $ZIG_SDK_PORT"
        cleanup
        exit 1
    fi
    
    if ! wait_for_service "http://localhost:$GO_SDK_PORT/health" 30; then
        error "Go web API failed to start on port $GO_SDK_PORT"
        cleanup
        exit 1
    fi
    
    success "Services ready for benchmarking"
    
    # Warmup requests
    log "Warming up services..."
    for ((i=1; i<=$WARMUP_REQUESTS; i++)); do
        curl -s "http://localhost:$ZIG_SDK_PORT/health" >/dev/null &
        curl -s "http://localhost:$GO_SDK_PORT/health" >/dev/null &
    done
    wait
    
    success "Warmup completed"
    
    # Start memory monitoring
    measure_memory_usage $ZIG_API_PID "zig" 60 &
    ZIG_MEM_PID=$!
    
    measure_memory_usage $GO_API_PID "go" 60 &
    GO_MEM_PID=$!
    
    # Run benchmarks
    log "Running benchmarks..."
    
    # Health endpoint benchmarks
    run_load_test "http://localhost:$ZIG_SDK_PORT/health" "zig" "health" "$RESULTS_DIR/zig_health.log"
    run_load_test "http://localhost:$GO_SDK_PORT/health" "go" "health" "$RESULTS_DIR/go_health.log"
    
    # API endpoint benchmarks (will show auth errors but test performance)
    run_load_test "http://localhost:$ZIG_SDK_PORT/api/games" "zig" "api_games" "$RESULTS_DIR/zig_api_games.log"
    run_load_test "http://localhost:$GO_SDK_PORT/api/games" "go" "api_games" "$RESULTS_DIR/go_api_games.log"
    
    # Wait for memory monitoring to complete
    wait $ZIG_MEM_PID $GO_MEM_PID || true
    
    # Generate report
    generate_report
    
    # Cleanup
    cleanup
    
    # Results summary
    echo
    echo "============================================="
    echo "Benchmark Complete"
    echo "============================================="
    success "Results saved to: $RESULTS_DIR"
    success "Performance report: $RESULTS_DIR/performance_report.md"
    echo
    
    # Quick comparison if we have numeric results
    if [ -f "$RESULTS_DIR/zig_health.log.summary" ] && [ -f "$RESULTS_DIR/go_health.log.summary" ]; then
        echo "Quick Comparison:"
        echo "Zig Health Endpoint:"
        grep "Requests/sec" "$RESULTS_DIR/zig_health.log.summary" | head -1
        echo "Go Health Endpoint:"
        grep "Requests/sec" "$RESULTS_DIR/go_health.log.summary" | head -1
        echo
    fi
}

# Set trap for cleanup on script exit
trap cleanup EXIT

# Run main function
main "$@"