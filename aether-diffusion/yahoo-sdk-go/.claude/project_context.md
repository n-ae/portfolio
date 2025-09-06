# Yahoo Fantasy Sports SDK for Go - Project Context

## Project Purpose
A minimal, thin Go binding for the Yahoo Fantasy Sports API. This SDK is designed as a pure library dependency for Go applications that need to interact with Yahoo's Fantasy Sports API.

## Design Principles
1. **Thin Binding** - Direct HTTP calls to Yahoo API endpoints with minimal abstraction
2. **User Responsibility** - User handles OAuth flow externally and provides tokens
3. **No Side Effects** - No console output, file I/O, caching, or database operations
4. **Minimal Dependencies** - Only essential OAuth2 and rate limiting packages
5. **Pure Library** - No CLI tools, examples, or application logic

## Architecture Overview

```
yahoo-sdk-go/
├── pkg/yahoo/
│   ├── auth.go         # OAuth token management (no interactive flow)
│   ├── client.go       # HTTP client with Yahoo API methods
│   ├── config.go       # Minimal configuration struct
│   └── models.go       # Yahoo API response data structures
├── go.mod              # Module dependencies
├── go.sum              # Dependency checksums
└── README.md           # Usage documentation
```

## Key Components

### Client (`client.go`)
- Main API client with HTTP methods
- Rate limiting built-in (respects Yahoo's 1000 req/hour limit)
- Methods: `GetNBAPlayers()`, `GetNBATeams()`, `GetPlayerStats()`, `GetTeamRoster()`
- No caching - makes direct API calls each time

### Authentication (`auth.go`)
- OAuth 2.0 helper functions
- `SetToken()` - accepts pre-obtained tokens from user
- `GetAuthURL()` - returns authorization URL for user's OAuth flow
- `ExchangeCode()` - exchanges auth code for access token
- Automatic token refresh when near expiry

### Configuration (`config.go`)
- Simple config struct with Yahoo API credentials
- No environment variable loading - user provides values directly
- Minimal validation - just checks required fields

### Models (`models.go`)
- Go structs matching Yahoo API response formats
- Player, Team, Roster, and other Yahoo Fantasy Sports data types

## Dependencies
```go
require (
    golang.org/x/oauth2 v0.15.0  // OAuth 2.0 support
    golang.org/x/time v0.5.0     // Rate limiting
)
```

## Usage Pattern
```go
// 1. Create client with credentials
config := yahoo.DefaultConfig()
config.ClientID = "your_client_id"
config.ClientSecret = "your_client_secret"
client, err := yahoo.NewClient(config)

// 2. User handles OAuth externally, provides token
token := &oauth2.Token{
    AccessToken: "access_token_from_oauth_flow",
    // ... other token details
}
client.SetToken(token)

// 3. Make API calls
players, err := client.GetNBAPlayers(ctx)
```

## Integration Context
This SDK is designed to be used by:
- HTMX web applications needing Yahoo Fantasy Sports data
- Go backends that need to fetch NBA player/team information
- Applications that want to handle their own caching/storage logic

## What This SDK Does NOT Do
- ❌ Interactive authentication (no console prompts)
- ❌ Database operations or SQL queries
- ❌ Caching or data persistence
- ❌ Console output or logging
- ❌ File I/O operations
- ❌ Application-specific business logic

## Error Handling
- `AuthError` - OAuth/authentication failures
- `RateLimitError` - API rate limit exceeded
- `ConfigError` - Invalid configuration
- Standard HTTP errors for API failures

## Rate Limiting
- Respects Yahoo's 1000 requests/hour limit
- Built-in rate limiter prevents exceeding limits
- Configurable burst limit (default: 10 requests)

## Future Maintenance Notes
- Keep dependencies minimal
- Avoid adding caching, database, or UI logic
- User applications should handle OAuth flow
- Focus on being a thin HTTP API wrapper
- Maintain compatibility with oauth2.Token standard type