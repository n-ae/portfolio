// Shared error handling for Yahoo Fantasy Sports implementations
// Provides consistent error codes and messages across all implementations

package main

import (
	"time"
)

// ErrorCode represents unified error codes matching config.json
type ErrorCode int

const (
	NotAuthenticated ErrorCode = 1001
	RateLimited      ErrorCode = 1002
	NetworkError     ErrorCode = 1003
	ParseError       ErrorCode = 1004
	InvalidRequest   ErrorCode = 1005
	NotFound         ErrorCode = 1006
	InternalError    ErrorCode = 1007
)

// GetHTTPStatus returns the HTTP status code for an error
func (e ErrorCode) GetHTTPStatus() int {
	switch e {
	case NotAuthenticated:
		return 401
	case RateLimited:
		return 429
	case NetworkError:
		return 502
	case ParseError:
		return 500
	case InvalidRequest:
		return 400
	case NotFound:
		return 404
	case InternalError:
		return 500
	default:
		return 500
	}
}

// GetMessage returns the error message for an error code
func (e ErrorCode) GetMessage() string {
	switch e {
	case NotAuthenticated:
		return "Not authenticated. Please set OAuth tokens."
	case RateLimited:
		return "Rate limit exceeded. Please try again later."
	case NetworkError:
		return "Network error occurred. Please try again."
	case ParseError:
		return "Failed to parse API response."
	case InvalidRequest:
		return "Invalid request parameters."
	case NotFound:
		return "Requested resource not found."
	case InternalError:
		return "Internal server error occurred."
	default:
		return "Unknown error occurred."
	}
}

// ErrorResponse represents a structured error response
type ErrorResponse struct {
	Code       int    `json:"code"`
	Message    string `json:"message"`
	HTTPStatus int    `json:"http_status"`
	Timestamp  int64  `json:"timestamp"`
}

// NewErrorResponse creates a new structured error response
func NewErrorResponse(errorCode ErrorCode) ErrorResponse {
	return ErrorResponse{
		Code:       int(errorCode),
		Message:    errorCode.GetMessage(),
		HTTPStatus: errorCode.GetHTTPStatus(),
		Timestamp:  time.Now().Unix(),
	}
}

// YahooFantasyError represents a custom error type
type YahooFantasyError struct {
	Code    ErrorCode
	Details string
}

func (e YahooFantasyError) Error() string {
	if e.Details != "" {
		return e.Code.GetMessage() + ": " + e.Details
	}
	return e.Code.GetMessage()
}

// NewYahooFantasyError creates a new custom error
func NewYahooFantasyError(code ErrorCode, details string) error {
	return YahooFantasyError{
		Code:    code,
		Details: details,
	}
}

// Helper functions to create specific errors
func NewNotAuthenticatedError() error {
	return NewYahooFantasyError(NotAuthenticated, "")
}

func NewRateLimitedError() error {
	return NewYahooFantasyError(RateLimited, "")
}

func NewNetworkError(details string) error {
	return NewYahooFantasyError(NetworkError, details)
}

func NewParseError(details string) error {
	return NewYahooFantasyError(ParseError, details)
}

func NewInvalidRequestError(details string) error {
	return NewYahooFantasyError(InvalidRequest, details)
}

func NewNotFoundError(resource string) error {
	return NewYahooFantasyError(NotFound, resource)
}

func NewInternalError(details string) error {
	return NewYahooFantasyError(InternalError, details)
}