# Yahoo Fantasy Sports API Endpoints

## Base URL
`https://fantasysports.yahooapis.com/fantasy/v2`

## Authentication
- OAuth 2.0 required for all endpoints
- Scopes: (Yahoo Fantasy Sports specific scopes)
- Rate limit: 1000 requests per hour

## Implemented Endpoints

### NBA Players
- **Endpoint**: `/game/nba/players`
- **Method**: `GetNBAPlayers(ctx context.Context) ([]Player, error)`
- **Pagination**: Automatic (25 players per page)
- **Returns**: All active NBA players with team and position info

### NBA Teams  
- **Endpoint**: `/game/nba/teams`
- **Method**: `GetNBATeams(ctx context.Context) ([]Team, error)`
- **Returns**: All NBA teams with conference/division data

### Player Stats
- **Endpoint**: `/player/{player_key}/stats`
- **Method**: `GetPlayerStats(ctx context.Context, playerKey string) (*Player, error)`
- **Returns**: Detailed statistics for specific player

### Team Roster
- **Endpoint**: `/team/{team_key}/roster`  
- **Method**: `GetTeamRoster(ctx context.Context, teamKey string) (*Roster, error)`
- **Returns**: Current roster for specific team

## Data Models

### Player
```go
type Player struct {
    YahooPlayerKey   string `xml:"player_key"`
    PlayerID         string `xml:"player_id"`
    FullName         string `xml:"name>full"`
    FirstName        string `xml:"name>first"`
    LastName         string `xml:"name>last"`
    TeamAbbreviation string `xml:"editorial_team_abbr"`
    UniformNumber    string `xml:"uniform_number"`
    Position         string `xml:"display_position"`
    IsActive         bool   `xml:"status"`
}
```

### Team
```go
type Team struct {
    YahooTeamKey string `xml:"team_key"`
    TeamID       string `xml:"team_id"`
    FullName     string `xml:"name"`
    City         string `xml:"city"`
    Abbreviation string `xml:"team_abbrev"`
    Conference   string `xml:"conference"`
    Division     string `xml:"division"`
}
```

### Roster
```go
type Roster struct {
    TeamKey string  `xml:"team_key"`
    Players *struct {
        Count  int      `xml:"count,attr"`
        Player []Player `xml:"player"`
    } `xml:"players"`
}
```

## Error Responses

### Rate Limit Error
```go
type RateLimitError struct {
    RetryAfter time.Duration
    Message    string
}
```

### Authentication Error  
```go
type AuthError struct {
    Type    string // "no_token", "expired", "invalid"
    Message string
    Err     error
}
```

## Request/Response Flow

1. **Rate Limiting**: Check rate limiter before each request
2. **Authentication**: Attach OAuth bearer token to request headers
3. **HTTP Request**: Make GET request to Yahoo API endpoint
4. **XML Parsing**: Parse Yahoo's XML response into Go structs
5. **Normalization**: Clean/normalize data fields
6. **Error Handling**: Convert HTTP/API errors to typed Go errors

## Yahoo API Quirks

- Responses are in XML format (not JSON)
- Player keys format: `{game_key}.p.{player_id}`
- Team keys format: `{game_key}.t.{team_id}`
- Game key for current NBA season: `"nba"`
- Some fields may be empty/missing in responses
- Rate limiting is strictly enforced