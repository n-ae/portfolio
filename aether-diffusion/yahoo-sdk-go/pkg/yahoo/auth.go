package yahoo

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"golang.org/x/oauth2"
)

// AuthManager handles OAuth 2.0 authentication with Yahoo
type AuthManager struct {
	config       *oauth2.Config
	token        *oauth2.Token
	clientConfig Config
}

// NewAuthManager creates a new authentication manager
func NewAuthManager(config Config) *AuthManager {
	oauthConfig := &oauth2.Config{
		ClientID:     config.ClientID,
		ClientSecret: config.ClientSecret,
		RedirectURL:  config.RedirectURL,
		Scopes:       []string{},
		Endpoint: oauth2.Endpoint{
			AuthURL:  "https://api.login.yahoo.com/oauth2/request_auth",
			TokenURL: "https://api.login.yahoo.com/oauth2/get_token",
		},
	}

	return &AuthManager{
		config:       oauthConfig,
		clientConfig: config,
	}
}

// SetToken sets the OAuth token directly (user provides this)
func (a *AuthManager) SetToken(token *oauth2.Token) {
	a.token = token
}

// GetAuthURL returns the OAuth authorization URL for the user to visit
func (a *AuthManager) GetAuthURL(state string) string {
	return a.config.AuthCodeURL(state, oauth2.AccessTypeOffline)
}

// ExchangeCode exchanges an authorization code for an access token
func (a *AuthManager) ExchangeCode(ctx context.Context, code string) (*oauth2.Token, error) {
	token, err := a.config.Exchange(ctx, code)
	if err != nil {
		return nil, &AuthError{
			Type:    "token_exchange",
			Message: "Failed to exchange authorization code for token",
			Err:     err,
		}
	}
	
	a.token = token
	return token, nil
}

// RefreshToken refreshes the access token using the refresh token
func (a *AuthManager) RefreshToken(ctx context.Context) error {
	if a.token == nil {
		return &AuthError{
			Type:    "no_token",
			Message: "No token available to refresh",
		}
	}

	if a.token.RefreshToken == "" {
		return &AuthError{
			Type:    "no_refresh_token", 
			Message: "No refresh token available",
		}
	}

	tokenSource := a.config.TokenSource(ctx, a.token)
	newToken, err := tokenSource.Token()
	if err != nil {
		return &AuthError{
			Type:    "refresh_failed",
			Message: "Failed to refresh token",
			Err:     err,
		}
	}

	a.token = newToken
	
	return nil
}

// GetHTTPClient returns an HTTP client configured with the OAuth token
func (a *AuthManager) GetHTTPClient(ctx context.Context) (*http.Client, error) {
	if a.token == nil {
		return nil, &AuthError{
			Type:    "no_token",
			Message: "No token available, authentication required",
		}
	}

	// Check if token needs refresh (refresh 5 minutes before expiry)
	if a.token.Expiry.Before(time.Now().Add(5 * time.Minute)) {
		if err := a.RefreshToken(ctx); err != nil {
			return nil, fmt.Errorf("failed to refresh token: %w", err)
		}
	}

	return a.config.Client(ctx, a.token), nil
}

// IsAuthenticated returns true if we have a valid token
func (a *AuthManager) IsAuthenticated() bool {
	return a.token != nil && a.token.Valid()
}

// GetToken returns the current token
func (a *AuthManager) GetToken() *oauth2.Token {
	return a.token
}

// AuthError represents an authentication error
type AuthError struct {
	Type    string
	Message string
	Err     error
}

func (e *AuthError) Error() string {
	if e.Err != nil {
		return fmt.Sprintf("auth error (%s): %s - %v", e.Type, e.Message, e.Err)
	}
	return fmt.Sprintf("auth error (%s): %s", e.Type, e.Message)
}

func (e *AuthError) Unwrap() error {
	return e.Err
}