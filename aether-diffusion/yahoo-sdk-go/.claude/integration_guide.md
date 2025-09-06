# Integration Guide

## Using Yahoo SDK in Your Go Applications

### Installation
```bash
go get github.com/nba-fantasy/yahoo-sdk-go
```

### Basic Setup
```go
import "github.com/nba-fantasy/yahoo-sdk-go/pkg/yahoo"

config := yahoo.DefaultConfig()
config.ClientID = "your_yahoo_client_id"
config.ClientSecret = "your_yahoo_client_secret"

client, err := yahoo.NewClient(config)
if err != nil {
    return err
}
```

## OAuth Integration Patterns

### Pattern 1: Web Application with Session Storage
```go
// During OAuth callback
token, err := client.ExchangeCode(ctx, authCode)
if err != nil {
    return err
}

// Store token in session/database
session.Set("yahoo_token", token)

// For subsequent requests
storedToken := session.Get("yahoo_token").(*oauth2.Token)
client.SetToken(storedToken)
players, err := client.GetNBAPlayers(ctx)
```

### Pattern 2: Server-to-Server with Stored Credentials
```go
// Load token from secure storage (database, vault, etc.)
token := &oauth2.Token{
    AccessToken:  loadFromVault("yahoo_access_token"),
    RefreshToken: loadFromVault("yahoo_refresh_token"),
    Expiry:       loadExpiryFromVault("yahoo_token_expiry"),
}

client.SetToken(token)
// SDK will automatically refresh if token is near expiry
teams, err := client.GetNBATeams(ctx)
```

### Pattern 3: CLI Tool with OAuth Flow
```go
// 1. Get authorization URL
authURL := client.GetAuthURL("random_state_string")
fmt.Printf("Visit this URL: %s\n", authURL)

// 2. User visits URL, gets code
var authCode string
fmt.Print("Enter authorization code: ")
fmt.Scanln(&authCode)

// 3. Exchange code for token
token, err := client.ExchangeCode(ctx, authCode)
if err != nil {
    return err
}

// 4. Save token for future use
saveTokenToFile(token)
```

## Error Handling Patterns

### Comprehensive Error Handling
```go
players, err := client.GetNBAPlayers(ctx)
if err != nil {
    switch e := err.(type) {
    case *yahoo.AuthError:
        if e.Type == "no_token" {
            // Redirect to OAuth flow
            http.Redirect(w, r, "/oauth/login", 302)
            return
        }
        // Handle other auth errors
        log.Printf("Auth error: %v", e)
        
    case *yahoo.RateLimitError:
        // Wait and retry
        time.Sleep(e.RetryAfter)
        return tryAgain()
        
    case *yahoo.ConfigError:
        // Fix configuration
        log.Printf("Config error: %v", e)
        
    default:
        // Handle other errors
        log.Printf("API error: %v", err)
    }
    return err
}
```

### Simple Error Handling
```go
players, err := client.GetNBAPlayers(ctx)
if err != nil {
    return fmt.Errorf("failed to get players: %w", err)
}
```

## Data Processing Patterns

### Filtering and Transformation
```go
players, err := client.GetNBAPlayers(ctx)
if err != nil {
    return err
}

// Filter active Lakers players
var lakersPlayers []yahoo.Player
for _, player := range players {
    if player.IsActive && player.TeamAbbreviation == "LAL" {
        lakersPlayers = append(lakersPlayers, player)
    }
}

// Transform for your UI
type UIPlayer struct {
    Name     string `json:"name"`
    Team     string `json:"team"`
    Position string `json:"position"`
}

var uiPlayers []UIPlayer
for _, p := range lakersPlayers {
    uiPlayers = append(uiPlayers, UIPlayer{
        Name:     p.FullName,
        Team:     p.TeamAbbreviation,
        Position: p.Position,
    })
}
```

### Caching Strategy (Your Responsibility)
```go
type PlayerCache struct {
    cache map[string][]yahoo.Player
    mu    sync.RWMutex
    ttl   time.Duration
}

func (pc *PlayerCache) GetPlayers(ctx context.Context, client *yahoo.Client) ([]yahoo.Player, error) {
    pc.mu.RLock()
    if cached, exists := pc.cache["players"]; exists {
        pc.mu.RUnlock()
        return cached, nil
    }
    pc.mu.RUnlock()
    
    // Cache miss - fetch from API
    players, err := client.GetNBAPlayers(ctx)
    if err != nil {
        return nil, err
    }
    
    // Cache for next time
    pc.mu.Lock()
    pc.cache["players"] = players
    pc.mu.Unlock()
    
    // Set expiry timer
    time.AfterFunc(pc.ttl, func() {
        pc.mu.Lock()
        delete(pc.cache, "players")
        pc.mu.Unlock()
    })
    
    return players, nil
}
```

## HTMX Integration Example

### Handler Function
```go
func playersHandler(w http.ResponseWriter, r *http.Request) {
    // Get token from session
    token := getTokenFromSession(r)
    if token == nil {
        http.Redirect(w, r, "/oauth/login", 302)
        return
    }
    
    // Setup client
    client.SetToken(token)
    
    // Fetch data
    players, err := client.GetNBAPlayers(r.Context())
    if err != nil {
        http.Error(w, "Failed to fetch players", 500)
        return
    }
    
    // Render HTMX partial
    tmpl.ExecuteTemplate(w, "players_table.html", players)
}
```

### Template (players_table.html)
```html
<table id="players-table">
    {{range .}}
    <tr>
        <td>{{.FullName}}</td>
        <td>{{.TeamAbbreviation}}</td>
        <td>{{.Position}}</td>
        <td>{{if .IsActive}}Active{{else}}Inactive{{end}}</td>
    </tr>
    {{end}}
</table>
```

## Testing Patterns

### Mocking the Client
```go
type MockYahooClient struct {
    players []yahoo.Player
    teams   []yahoo.Team
}

func (m *MockYahooClient) GetNBAPlayers(ctx context.Context) ([]yahoo.Player, error) {
    return m.players, nil
}

func (m *MockYahooClient) GetNBATeams(ctx context.Context) ([]yahoo.Team, error) {
    return m.teams, nil
}

// In tests
func TestPlayerHandler(t *testing.T) {
    mockClient := &MockYahooClient{
        players: []yahoo.Player{
            {FullName: "LeBron James", TeamAbbreviation: "LAL"},
        },
    }
    
    handler := &PlayerHandler{client: mockClient}
    // ... test the handler
}
```

## Performance Tips

1. **Reuse Client**: Create one client instance, don't recreate for each request
2. **Context Timeouts**: Use context with timeouts for API calls
3. **Rate Limiting**: SDK handles this, but be aware of the 1000/hour limit
4. **Batch Operations**: Make fewer, larger requests when possible
5. **Error Retry**: Implement exponential backoff for transient errors

## Security Considerations

1. **Token Storage**: Store OAuth tokens securely (encrypted database, vault)
2. **Token Rotation**: Implement automatic token refresh
3. **HTTPS Only**: Always use HTTPS for OAuth flows
4. **Scope Limiting**: Request minimum required OAuth scopes
5. **Rate Monitoring**: Monitor API usage to prevent abuse