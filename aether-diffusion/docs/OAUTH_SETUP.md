# Yahoo Fantasy API OAuth Setup Guide

Complete guide to obtain access tokens for the Yahoo Fantasy Sports API.
Based on proven patterns from NBA Fantasy project implementation.

## Prerequisites

- [x] Yahoo Developer Account
- [x] Yahoo Fantasy App created with Consumer Key/Secret
- [x] ngrok installed ([download here](https://ngrok.com/download))
- [x] Go environment setup

## 🚀 Quick Start (Automated)

For fastest setup, use the automated Lua script:

```bash
cd scripts
lua setup-oauth.lua
```

This script will:
- ✅ Check all prerequisites  
- ✅ Start ngrok tunnel automatically
- ✅ Update configuration files
- ✅ Guide you through Yahoo Developer App setup
- ✅ Prepare OAuth server for token exchange

## 🔧 Manual Step-by-Step Setup

### 1. Install ngrok

```bash
# macOS with Homebrew
brew install ngrok/ngrok/ngrok

# Or download directly from https://ngrok.com/download
# Follow platform-specific installation instructions
```

### 2. Configure Your .env File

Ensure your `.env` file has your consumer credentials:

```bash
# Yahoo Fantasy Sports API Configuration
YAHOO_CONSUMER_KEY=your_consumer_key_here
YAHOO_CONSUMER_SECRET=your_consumer_secret_here
YAHOO_ACCESS_TOKEN=
YAHOO_ACCESS_TOKEN_SECRET=

# API Configuration  
YAHOO_API_MODE=mock
```

### 3. Start ngrok Tunnel

In a **separate terminal**, start ngrok to expose localhost:8080:

```bash
ngrok http 8080
```

You'll see output like:
```
Session Status                online
Account                       your-account
Version                       3.x.x
Region                        United States (us)
Latency                       -
Web Interface                 http://127.0.0.1:4040
Forwarding                    https://abc123def456.ngrok.io -> http://localhost:8080
```

**Copy the HTTPS forwarding URL** (e.g., `https://abc123def456.ngrok.io`)

### 4. Update OAuth Server Code

Edit `go/oauth_server.go` and replace the callback URL:

```go
// Replace this line:
callbackURL := "https://your-ngrok-url.ngrok.io/oauth/callback"

// With your actual ngrok URL:
callbackURL := "https://abc123def456.ngrok.io/oauth/callback"
```

### 5. Run OAuth Setup

```bash
cd go
go run oauth_server.go
```

### 6. Complete OAuth Flow

1. **Copy the authorization URL** from the terminal output
2. **Open it in your browser**
3. **Sign in to Yahoo** and authorize your app
4. **You'll be redirected** to your ngrok URL
5. **Access tokens will be automatically saved** to your `.env` file

### 7. Test with Real API

Update your `.env`:
```bash
YAHOO_API_MODE=real
```

Run your SDK:
```bash
go run sdk.go
```

## 🌐 CORS Handling (Optional)

If you encounter CORS issues when making API calls from a web frontend, you can use:

### Option 1: CORS Anywhere Proxy

Deploy the Terraform module you mentioned:
```hcl
module "cors_anywhere" {
  source = "n-ae/lambda-cors-anywhere/aws"
  version = "~> 1.0"
  
  # Configuration options
}
```

### Option 2: Built-in Proxy Server

Add to your Go application:

```go
// Add CORS middleware
func corsMiddleware(next http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
        
        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }
        
        next(w, r)
    }
}

// Proxy Yahoo API requests
func proxyYahooAPI(w http.ResponseWriter, r *http.Request) {
    // Forward request to Yahoo API with proper OAuth signing
    // Return response with CORS headers
}
```

## 🔍 Troubleshooting

### Common Issues

**1. "callback URL not found"**
- Ensure ngrok is running
- Verify the callback URL in oauth_server.go matches your ngrok URL
- Check that the OAuth server is listening on port 8080

**2. "Invalid signature"**
- Verify consumer key/secret are correct
- Ensure system time is accurate
- Check URL encoding in OAuth signature

**3. "CORS errors in browser"**
- Use the CORS proxy solutions above
- Or make API calls from server-side only

### Debug Mode

Enable verbose logging in your OAuth server:

```go
// Add debug flag
const DEBUG = true

// Log all OAuth parameters
if DEBUG {
    fmt.Printf("Base String: %s\n", baseString)
    fmt.Printf("Signing Key: %s\n", signingKey)
    fmt.Printf("Signature: %s\n", signature)
}
```

## 📋 Environment Variables Reference

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `YAHOO_CONSUMER_KEY` | OAuth consumer key from Yahoo Developer | ✅ | `dj0yJmk9...` |
| `YAHOO_CONSUMER_SECRET` | OAuth consumer secret | ✅ | `72eb471a...` |
| `YAHOO_ACCESS_TOKEN` | OAuth access token (obtained via flow) | ⚠️ (for real API) | `A=...` |
| `YAHOO_ACCESS_TOKEN_SECRET` | OAuth access token secret | ⚠️ (for real API) | `...` |
| `YAHOO_API_MODE` | `mock` or `real` | ✅ | `real` |
| `YAHOO_BASE_URL` | API base URL (optional) | ❌ | Custom URL |

## 🚀 Next Steps

Once you have access tokens:

1. **Set `YAHOO_API_MODE=real`** in your `.env`
2. **Run your SDK** to make real API calls
3. **Implement proper error handling** for rate limits
4. **Add token refresh logic** if needed
5. **Consider caching responses** to minimize API calls

## 🔐 Security Notes

- **Never commit access tokens** to version control
- **Use environment variables** in production
- **Implement token refresh** for long-running applications  
- **Respect Yahoo's rate limits** (3000 requests/hour)
- **Use HTTPS** for all OAuth flows