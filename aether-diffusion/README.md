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

# NBA Fantasy Sports Database System

A comprehensive, production-ready NBA Fantasy Sports database with Yahoo API integration, configurable data modes, and CSV export functionality.

## 🎯 System Overview

This system provides a complete NBA Fantasy Sports database with:
- **200+ NBA players** across all 30 teams
- **Player-position relationship management**
- **Database-first SDK** with configurable local/API modes
- **Yahoo Fantasy Sports API integration**
- **CSV export functionality**
- **Complete migration system**

## 📊 Database Statistics

| Metric | Count |
|--------|-------|
| NBA Teams | 30 |
| NBA Players | 200+ |
| Players with Position Assignments | 24+ |
| Total Position Relationships | 40+ |
| Database Migrations | 11 |

## 🗄️ Database Architecture

### Core Tables

1. **`teams`** - All 30 NBA teams with conference/division data
2. **`players`** - Complete NBA player roster with personal/professional info
3. **`positions`** - NBA positions (PG, SG, SF, PF, C) + fantasy positions (G, F, UTIL)
4. **`player_positions`** - Many-to-many relationship between players and positions
5. **`position_categories`** - Position category groupings (Guard, Forward, Center)
6. **`position_category_mapping`** - Maps positions to categories
7. **`app_config`** - Sport-specific configuration (replaces sports table)

### Key Features

- ✅ **Foreign Key Relationships**: Proper relational design
- ✅ **Position Flexibility**: Players can have multiple positions (primary/secondary)
- ✅ **Sport-Agnostic Design**: Extensible to NFL, MLB, NHL via environment variables
- ✅ **Data Integrity**: Constraints and triggers ensure data consistency
- ✅ **Performance Optimized**: Comprehensive indexes for fast queries

## 🚀 SDK Configuration

### Database-First Approach

The SDK always depends on the database as the primary data source:

```go
// LOCAL DATA MODE - Never calls Yahoo API
config := &DatabaseConfig{
    LocalDataMode: true,      // Only use database data
    MaxStaleHours: 6,         // Not used in local mode
    AutoRefresh:   false,     // Not used in local mode
}

// API + LOCAL MODE - Intelligent staleness checking
config := &DatabaseConfig{
    LocalDataMode: false,     // Allow Yahoo API calls
    MaxStaleHours: 6,         // Hours before data is stale
    AutoRefresh:   true,      // Auto-refresh stale data
}
```

### Key Methods

- `GetPlayers(forceRefresh)` - Database-first with optional API refresh
- `isDataStale()` - Checks if local data needs updating
- `refreshPlayersFromAPI()` - Fetches fresh data from Yahoo API
- `GetTeams()` - Returns all NBA teams
- `GetPositions()` - Returns position data

## 📈 Export Functionality

### CSV Export Features

- **Complete player data** including teams, positions, stats
- **Automatic filename generation** with timestamps
- **Web interface integration** - replaced download with export button
- **Comprehensive field mapping**:
  - Player info (name, team, uniform number)
  - Position data (primary/secondary)
  - Professional details (height, weight, college, etc.)
  - Yahoo API metadata (image URLs, player keys)

### Usage

```bash
# Via web interface
http://localhost:8080/api/export-csv

# Direct API call
curl -o nba_players.csv "http://localhost:8080/api/export-csv"
```

## 🔑 Yahoo API Integration

### Setup Requirements

1. **Create Yahoo Developer App**:
   - Go to https://developer.yahoo.com/apps/
   - Create app with Fantasy Sports API access
   - Note Consumer Key and Consumer Secret

2. **OAuth Authentication**:
   - Complete OAuth flow for access token
   - Token expires after 1 hour

3. **Environment Variables**:
   ```bash
   export YAHOO_CONSUMER_KEY="your_consumer_key"
   export YAHOO_CONSUMER_SECRET="your_consumer_secret"  
   export YAHOO_ACCESS_TOKEN="your_access_token"
   ```

### API Integration Script

The `setup_yahoo_api.go` script provides:
- ✅ Credential validation
- ✅ Connection testing
- ✅ NBA player fetching (up to 500 players)
- ✅ Rate limiting and error handling
- ✅ Yahoo response parsing

## 🏃‍♂️ Quick Start

### 1. Run Migrations

```bash
go run migrate.go migrate
```

### 2. Start Web Server

```bash
go run nba_server.go
```

### 3. Access Interface

- **Web UI**: http://localhost:8080
- **Players API**: http://localhost:8080/api/players
- **Teams API**: http://localhost:8080/api/teams
- **CSV Export**: http://localhost:8080/api/export-csv

### 4. Configure for Different Sports

```bash
export SPORT_TYPE=nhl  # or nfl, mlb
go run migrate.go migrate  # Creates nhl.db, nfl.db, etc.
```

## 📁 File Structure

```
/go/
├── nba_server.go          # Main web server application  
├── migrate.go             # Migration runner
├── setup_yahoo_api.go     # Yahoo API integration
└── test_*.go             # Test scripts

/migrations/
├── 001_initial_schema.sql    # Core database structure
├── 002_seed_data.sql         # Sport-specific seeding
├── 007_simplify_schema.sql   # Remove redundant tables
├── 009_remove_sports_table.sql # Move to app_config
├── 010_add_nba_players.sql   # Star players
└── 011_complete_nba_rosters.sql # Full rosters (200+ players)
```

## 🎯 Player-Position Relationships

### Structure
```sql
CREATE TABLE player_positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    position_id INTEGER NOT NULL,
    is_primary BOOLEAN DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES players (id),
    FOREIGN KEY (position_id) REFERENCES positions (id)
);
```

### Example Data
| Player | Primary Position | Secondary Positions |
|--------|-----------------|-------------------|
| LeBron James | SF ★ | PF |
| Luka Dončić | PG ★ | SG |
| Anthony Davis | PF ★ | C |
| Jayson Tatum | SF ★ | PF |

## 🔧 Advanced Features

### Data Staleness Detection
- Configurable staleness threshold (default: 6 hours)
- Automatic refresh based on `last_sync_at` timestamps
- Graceful fallback to local data on API failures

### Sport Extensibility
- Environment-driven database naming (`nba.db`, `nhl.db`)
- Sport-specific configuration in `app_config` table
- Extensible migration system for different sports

### Performance Optimization
- Comprehensive database indexes
- Efficient query patterns
- Connection pooling and rate limiting

## 📊 Sample Queries

### Get Player Positions
```sql
SELECT 
    p.full_name,
    pos.code as position,
    CASE WHEN pp.is_primary = 1 THEN 'PRIMARY' ELSE 'SECONDARY' END as type
FROM players p
JOIN player_positions pp ON p.id = pp.player_id
JOIN positions pos ON pp.position_id = pos.id
ORDER BY p.full_name;
```

### Team Roster Summary
```sql
SELECT 
    t.full_name as team,
    COUNT(p.id) as player_count,
    GROUP_CONCAT(p.full_name, ', ') as players
FROM teams t
LEFT JOIN players p ON t.id = p.team_id
GROUP BY t.id;
```

## 🎉 Production Ready

This system is production-ready with:
- ✅ Complete NBA rosters (200+ players)
- ✅ Proper relational database design
- ✅ Yahoo API integration capabilities
- ✅ CSV export functionality  
- ✅ Configurable data modes
- ✅ Migration system for reproducible deployments
- ✅ Error handling and graceful degradation
- ✅ Rate limiting and API best practices

## ✅ Working Examples

### Local Development

```bash
# Start the server
go run nba_server.go
# Output: 🚀 NBA Database server starting on http://localhost:8080

# Test CSV export
curl -o players.csv "http://localhost:8080/api/export-csv"
# Downloads: nba_players_2025-08-31.csv (200 players)

# Test JSON API
curl "http://localhost:8080/api/players" | head -c 200
# Returns: {"players": [{"id": 114, "name": "Bogdan Bogdanovic"...
```

## 🚀 Next Steps

To fetch live NBA data from Yahoo API:
1. Set up Yahoo Developer credentials
2. Run `go run setup_yahoo_api.go` to test connection
3. Use the main application to import live player data
4. Export updated rosters to CSV

The system is designed to seamlessly handle both static data and live API data, making it perfect for fantasy sports applications.
