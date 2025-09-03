package yahoo

import (
	"time"
)

// Config holds configuration for the Yahoo Fantasy Sports SDK
type Config struct {
	// OAuth Configuration
	ClientID     string `yaml:"client_id" json:"client_id"`
	ClientSecret string `yaml:"client_secret" json:"client_secret"`
	RedirectURL  string `yaml:"redirect_url" json:"redirect_url"`

	// API Configuration
	BaseURL    string `yaml:"base_url" json:"base_url"`
	APIVersion string `yaml:"api_version" json:"api_version"`


	// Rate Limiting
	RateLimit  int           `yaml:"rate_limit" json:"rate_limit"`     // Requests per hour
	BurstLimit int           `yaml:"burst_limit" json:"burst_limit"`   // Burst requests
	Timeout    time.Duration `yaml:"timeout" json:"timeout"`

	// Retry Configuration
	MaxRetries    int           `yaml:"max_retries" json:"max_retries"`
	RetryDelay    time.Duration `yaml:"retry_delay" json:"retry_delay"`
	RetryMaxDelay time.Duration `yaml:"retry_max_delay" json:"retry_max_delay"`

	// Debug and Logging
	Debug   bool `yaml:"debug" json:"debug"`
	LogLevel string `yaml:"log_level" json:"log_level"`
}

// DefaultConfig returns a configuration with sensible defaults
func DefaultConfig() Config {
	return Config{
		// OAuth defaults
		RedirectURL: "oob", // Out-of-band for desktop apps

		// API defaults
		BaseURL:    "https://fantasysports.yahooapis.com/fantasy/v2",
		APIVersion: "v2",


		// Rate limiting defaults (Yahoo allows 1000 requests/hour)
		RateLimit:  1000,
		BurstLimit: 10,
		Timeout:    time.Second * 30,

		// Retry defaults
		MaxRetries:    3,
		RetryDelay:    time.Second * 2,
		RetryMaxDelay: time.Second * 30,

		// Logging defaults
		Debug:   false,
		LogLevel: "INFO",
	}
}


// Validate checks if the configuration is valid
func (c *Config) Validate() error {
	if c.ClientID == "" {
		return &ConfigError{Field: "ClientID", Message: "Client ID is required"}
	}
	if c.ClientSecret == "" {
		return &ConfigError{Field: "ClientSecret", Message: "Client Secret is required"}
	}
	if c.BaseURL == "" {
		return &ConfigError{Field: "BaseURL", Message: "Base URL is required"}
	}
	if c.RateLimit <= 0 {
		return &ConfigError{Field: "RateLimit", Message: "Rate limit must be positive"}
	}
	if c.Timeout <= 0 {
		return &ConfigError{Field: "Timeout", Message: "Timeout must be positive"}
	}
	return nil
}

// ConfigError represents a configuration validation error
type ConfigError struct {
	Field   string
	Message string
}

func (e *ConfigError) Error() string {
	return "config error in field '" + e.Field + "': " + e.Message
}