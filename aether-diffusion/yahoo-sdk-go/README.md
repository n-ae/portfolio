# Yahoo Fantasy Sports SDK for Go

A minimal, thin Go binding for the Yahoo Fantasy Sports API. This SDK provides direct access to Yahoo API endpoints with OAuth 2.0 authentication and basic rate limiting.

## Features

- **Thin API Binding** - Direct HTTP calls to Yahoo API endpoints
- **OAuth 2.0 Support** - Token management and authentication helpers  
- **Rate Limiting** - Built-in rate limiting to respect API limits
- **NBA Data Access** - Retrieve players, teams, and statistics
- **Minimal Dependencies** - Only essential OAuth2 and rate limiting packages
- **Pure Library** - No console output, caching, or database logic

## Quick Start

```go
package main

import (
    "context"
    "fmt"
    "log"
    
    "golang.org/x/oauth2"
    "github.com/nba-fantasy/yahoo-sdk-go/pkg/yahoo"
)

func main() {
    // Initialize the SDK
    config := yahoo.Config{
        ClientID:     "your_client_id",
        ClientSecret: "your_client_secret",
        RedirectURL:  "oob", // for desktop apps
    }
    
    client, err := yahoo.NewClient(config)
    if err != nil {
        log.Fatal(err)
    }
    
    // User must handle OAuth flow externally and provide token
    token := &oauth2.Token{
        AccessToken:  "your_access_token",
        RefreshToken: "your_refresh_token", 
        // ... token details from your OAuth flow
    }
    client.SetToken(token)
    
    // Get NBA players
    players, err := client.GetNBAPlayers(ctx)
    if err != nil {
        log.Fatal(err)
    }
    
    fmt.Printf("Found %d NBA players\n", len(players))
}
```

## Installation

```bash
go get github.com/nba-fantasy/yahoo-sdk-go
```

## Configuration

The SDK supports multiple configuration methods:

### Environment Variables
```bash
export YAHOO_CLIENT_ID="your_client_id"
export YAHOO_CLIENT_SECRET="your_client_secret"  
export YAHOO_REDIRECT_URL="oob"
```

### Configuration File
```yaml
# ~/.yahoo-sdk.yaml
client_id: "your_client_id"
client_secret: "your_client_secret"
redirect_url: "oob"
cache_ttl: "1h"
rate_limit: 1000
```

### Programmatic Configuration
```go
config := yahoo.Config{
    ClientID:     "your_client_id",
    ClientSecret: "your_client_secret",
    RedirectURL:  "oob",
    CacheTTL:     time.Hour,
    RateLimit:    1000,
}
```

## Usage Examples

### Get All NBA Players
```go
players, err := client.GetNBAPlayers(ctx)
if err != nil {
    return err
}

for _, player := range players {
    fmt.Printf("%s - %s (%s)\n", player.Name, player.Team, player.Position)
}
```

### Get Specific Team Roster
```go
roster, err := client.GetTeamRoster(ctx, "nba.t.5") // Lakers
if err != nil {
    return err
}

fmt.Printf("Lakers Roster (%d players):\n", len(roster.Players))
for _, player := range roster.Players {
    fmt.Printf("  %s (#%s) - %s\n", player.Name, player.UniformNumber, player.Position)
}
```

### Get Player Statistics
```go
stats, err := client.GetPlayerStats(ctx, "466.p.5352") // Specific player
if err != nil {
    return err
}

fmt.Printf("Stats for %s:\n", stats.Player.Name)
fmt.Printf("  Points: %.1f\n", stats.Points)
fmt.Printf("  Assists: %.1f\n", stats.Assists)
fmt.Printf("  Rebounds: %.1f\n", stats.Rebounds)
```

## Error Handling

The SDK provides structured error handling:

```go
players, err := client.GetNBAPlayers(ctx)
if err != nil {
    switch e := err.(type) {
    case *yahoo.AuthError:
        // Handle authentication errors
        log.Printf("Auth error: %v", e)
    case *yahoo.RateLimitError:
        // Handle rate limiting
        log.Printf("Rate limited, retry after: %v", e.RetryAfter)
    case *yahoo.APIError:
        // Handle API errors
        log.Printf("API error %d: %s", e.StatusCode, e.Message)
    default:
        // Handle other errors
        log.Printf("Unknown error: %v", err)
    }
}
```

## Caching

The SDK includes intelligent caching to minimize API calls:

```go
config := yahoo.Config{
    // ... other config
    CacheTTL: time.Hour * 2, // Cache responses for 2 hours
    CacheSize: 1000,         // Keep up to 1000 cached responses
}
```

## Rate Limiting

Built-in rate limiting respects Yahoo's API limits:

```go
config := yahoo.Config{
    // ... other config
    RateLimit: 1000,           // 1000 requests per hour
    BurstLimit: 10,           // Allow bursts of 10 requests
}
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- 📧 Email: support@nba-fantasy-sdk.com
- 🐛 Issues: [GitHub Issues](https://github.com/nba-fantasy/yahoo-sdk-go/issues)
- 📖 Docs: [Documentation](https://docs.nba-fantasy-sdk.com)
- 💬 Discord: [Community Server](https://discord.gg/nba-fantasy-sdk)