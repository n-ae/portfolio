# Development History

## Project Evolution

### Original Scope (Removed)
- CLI applications with command-line interface
- Interactive authentication with console prompts  
- Database adapter with SQLite synchronization
- Intelligent caching system with TTL
- Example applications and build system (Makefile)
- Complex configuration with environment variable loading
- Verbose logging and console output

### User Requirements & Refactoring
**User directive**: "The sdk should only depend on yahoo api and its keys. The user of the sdk is responsible for providing the keys/secrets required."

**Follow-up**: "As such it should not have any sql or print statements. It should just act as the go binding. Make it as thin as possible. It should have as little logic as possible."

### Transformation Process
1. **Removed CLI & Examples** - Deleted `cmd/`, `examples/`, `Makefile`
2. **Removed Database Logic** - Deleted `adapter.go` with all SQL operations
3. **Removed Caching** - Deleted `cache.go` and all cache calls
4. **Removed Interactive Auth** - No console I/O, user provides tokens
5. **Removed Print Statements** - No `fmt.Print*`, `log.*` calls
6. **Simplified Config** - No environment variable loading
7. **Cleaned Dependencies** - Only OAuth2 and rate limiting remain

## Key Design Decisions

### Why Minimal?
- SDK should be a thin wrapper around HTTP API calls
- Application logic (caching, storage, UI) belongs in consuming apps
- Easier to maintain and integrate
- Fewer dependencies and potential conflicts

### Why User-Managed OAuth?
- Different applications have different OAuth flow requirements
- Web apps vs CLI tools vs server-to-server have different needs
- SDK just provides helpers, user controls the flow
- No assumptions about where tokens are stored

### Why No Caching?
- Caching strategies vary by application
- Some apps need real-time data, others can cache longer
- Memory management and cache invalidation is application-specific
- Simpler to let applications handle caching externally

## Dependencies Rationale

### golang.org/x/oauth2
- **Why**: Standard OAuth 2.0 implementation for Go
- **Usage**: Token management, HTTP client creation, token refresh
- **Essential**: Required for Yahoo API authentication

### golang.org/x/time/rate  
- **Why**: Implements rate limiting algorithms
- **Usage**: Respect Yahoo's 1000 requests/hour limit
- **Essential**: Prevents API rate limit violations

## File Structure Evolution

### Before (Complex)
```
yahoo-sdk-go/
├── cmd/yahoo-nba-cli/          # CLI application
├── examples/                   # Example applications  
├── internal/cache/             # Internal caching
├── pkg/yahoo/
│   ├── adapter.go              # Database operations
│   ├── cache.go                # Caching logic
│   ├── client.go               # API client
│   └── ...
├── Makefile                    # Build system
└── README.md
```

### After (Minimal)
```
yahoo-sdk-go/
├── pkg/yahoo/
│   ├── auth.go                 # OAuth helpers only
│   ├── client.go               # Pure HTTP API calls
│   ├── config.go               # Simple config struct
│   └── models.go               # Data structures
├── go.mod                      # Minimal dependencies
└── README.md                   # Updated docs
```

## Integration Pattern

### For HTMX Applications
```go
// In your web server
client := yahoo.NewClient(config)
client.SetToken(userToken) // Token from session/database

// In your handlers
players, err := client.GetNBAPlayers(ctx)
// Render players in HTMX template
```

### For Background Jobs
```go  
// In your job runner
client := yahoo.NewClient(config)
client.SetToken(serviceToken) // Long-lived service token

// Periodic data sync
teams, err := client.GetNBATeams(ctx)
// Store in your database with your logic
```

## Lessons Learned

1. **Start Minimal** - It's easier to add features than remove them
2. **Separation of Concerns** - API bindings ≠ Application logic  
3. **User Control** - Let users decide caching, storage, auth flows
4. **Thin Wrappers** - Just provide typed access to HTTP APIs
5. **Clear Dependencies** - Only include what's absolutely necessary