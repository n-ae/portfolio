# Yahoo Fantasy Sports - Multi-Language Implementation

A comprehensive 3-layer architecture demonstrating Yahoo Fantasy Sports API integration with implementations in both Zig and Go, featuring shared configuration, unified error handling, and automated testing.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐
│  Zig Web Client │    │  Go Web Client  │
│  (Frontend)     │    │  (Frontend)     │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          ▼                      ▼
┌─────────────────┐    ┌─────────────────┐
│  Zig Web API    │    │  Go Web API     │
│  (HTTP Server)  │    │  (HTTP Server)  │
└─────────┬───────┘    └─────────┬───────┘
          │                      │
          ▼                      ▼
┌─────────────────┐    ┌─────────────────┐
│   Zig SDK       │    │    Go SDK       │
│ (Yahoo API)     │    │ (Yahoo API)     │
└─────────────────┘    └─────────────────┘
          │                      │
          └──────────┬───────────┘
                     ▼
           ┌─────────────────┐
           │  Shared Config  │
           │  Mock Data      │
           │  Error Codes    │
           └─────────────────┘
```

## Key Features

### 🎯 **Configuration-Driven Development**
- **Single Source of Truth**: `shared/config.json` controls all system behavior
- **Mock/Real API Toggle**: Switch between development and production with one config change
- **Schema Validation**: JSON schemas ensure configuration consistency

### 🔄 **Dual-Language Implementation**
- **Identical Functionality**: Both Zig and Go implementations provide the same API
- **Consistent Behavior**: Shared configuration ensures identical responses
- **Performance Comparison**: Built-in benchmarking tools

### 🛠️ **Unified Build System** 
- **Lua-Only Build**: Single `build.lua` script handles everything
- **Cross-Platform**: Works on macOS, Linux, and Windows
- **Comprehensive CI**: 7-step pipeline with validation and testing

### ⚡ **Mock Adapter Pattern**
- **Development Velocity**: Work offline with consistent mock data
- **Testing Reliability**: Predictable data eliminates flaky tests
- **Easy Switching**: Change `api_mode` from `"mock"` to `"real"` in config

## Quick Start

### Prerequisites
```bash
# Install dependencies (macOS with Homebrew)
brew install zig go lua curl

# Or check what you have
lua build.lua status
```

### Build and Test
```bash
# Build everything
lua build.lua build

# Run all tests
lua build.lua test

# Run full CI pipeline
lua build.lua ci

# Performance comparison
lua build.lua benchmark
```

### Configuration

Edit `shared/config.json` to customize behavior:

```json
{
  "api_mode": "mock",           // Switch to "real" for production
  "yahoo_api": {
    "consumer_key": "${YAHOO_CONSUMER_KEY}",
    "consumer_secret": "${YAHOO_CONSUMER_SECRET}"
  },
  "mock_api": {
    "simulate_delays": true,     // Realistic response times
    "delay_ms": 100
  }
}
```

## Available Commands

| Command | Description |
|---------|-------------|
| `lua build.lua build [release]` | Build all components |
| `lua build.lua validate` | Validate schemas and config |
| `lua build.lua validate_contracts` | Check API consistency |
| `lua build.lua test` | Run integration tests |
| `lua build.lua benchmark` | Performance comparison |
| `lua build.lua docs` | Generate API documentation |
| `lua build.lua ci` | Full CI pipeline |
| `lua build.lua clean` | Clean build artifacts |

## Project Structure

```
├── shared/                    # Shared configuration and data
│   ├── config.json           # Main configuration file
│   ├── config-schema.json    # Configuration validation schema
│   ├── mock-data.json        # Shared test data
│   ├── mock-data-schema.json # Mock data validation schema
│   ├── errors.zig           # Unified error handling (Zig)
│   ├── errors.go            # Unified error handling (Go)
│   ├── adapter.zig          # Mock/Real API adapter (Zig)
│   └── adapter.go           # Mock/Real API adapter (Go)
├── zig/                      # Zig implementation
│   ├── sdk.zig              # Yahoo Fantasy API SDK
│   ├── webapi.zig           # HTTP REST API server
│   └── webclient.zig        # Frontend web application
├── go/                       # Go implementation  
│   ├── sdk.go               # Yahoo Fantasy API SDK
│   ├── webapi.go            # HTTP REST API server
│   └── webclient.go         # Frontend web application
├── scripts/                  # Build and test automation
│   ├── utils.lua            # Shared utilities
│   ├── test-runner.lua      # Main test runner
│   └── integration-tests.lua # Cross-implementation tests
└── build.lua                 # Main build system
```

## API Endpoints

All implementations expose identical REST APIs:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Service health check |
| `/api/games` | GET | Available fantasy games |
| `/api/leagues/{game_key}` | GET | Leagues for game |
| `/api/teams/{league_key}` | GET | Teams in league |
| `/api/players/search?game={game}&q={query}` | GET | Search players |
| `/api/roster/{team_key}` | GET | Team roster |
| `/api/auth/tokens` | POST | Set OAuth tokens |

## Error Handling

Unified error codes across both implementations:

| Code | HTTP Status | Description |
|------|-------------|-------------|
| 1001 | 401 | Not authenticated |
| 1002 | 429 | Rate limited |
| 1003 | 502 | Network error |
| 1004 | 500 | Parse error |
| 1005 | 400 | Invalid request |
| 1006 | 404 | Not found |
| 1007 | 500 | Internal error |

## Development Workflow

### 1. Development Mode (Mock API)
```bash
# Use mock data for development
# Default config.json has "api_mode": "mock"
lua build.lua build
```

### 2. Production Mode (Real API)
```bash
# Switch to real Yahoo API
# Edit shared/config.json: "api_mode": "real"
export YAHOO_CONSUMER_KEY="your_key"
export YAHOO_CONSUMER_SECRET="your_secret"
lua build.lua build release
```

### 3. Testing and Validation
```bash
# Validate configuration
lua build.lua validate

# Check API consistency between implementations  
lua build.lua validate_contracts

# Run integration tests
lua build.lua test
```

### 4. Performance Analysis
```bash
# Compare Zig vs Go performance
lua build.lua benchmark

# View results in benchmark-report.md
```

## CI Pipeline

The comprehensive CI pipeline includes:

1. **Schema Validation** - Validate all JSON files against schemas
2. **Clean Build** - Remove previous build artifacts  
3. **Release Build** - Build optimized binaries
4. **Contract Validation** - Ensure API consistency between implementations
5. **Integration Tests** - Cross-implementation testing
6. **Performance Benchmarks** - Language comparison metrics
7. **Documentation Generation** - Auto-generate API docs

```bash
lua build.lua ci
```

## Contributing

### Adding New Features
1. Update shared configuration schemas if needed
2. Implement in both Zig and Go
3. Add test cases to integration tests
4. Update documentation

### Modifying Configuration
1. Update `shared/config.json`
2. Update corresponding schema files
3. Run `lua build.lua validate`

### Adding Test Data
1. Update `shared/mock-data.json`
2. Ensure it follows `shared/mock-data-schema.json`
3. Run validation to check consistency

## Maintainability Features

- **Single Build System**: Lua-only build eliminates complexity
- **Schema Validation**: Catch configuration errors early
- **Contract Testing**: Ensure implementation consistency
- **Automated Documentation**: Always up-to-date API docs
- **Performance Monitoring**: Track performance differences over time

## License

MIT License - See LICENSE file for details.

## Support

For questions or issues:
1. Check the auto-generated `API-Documentation.md`
2. Review test reports in generated markdown files
3. Run `lua build.lua help` for command reference