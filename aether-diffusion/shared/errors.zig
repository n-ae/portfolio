//! Shared error handling for Yahoo Fantasy Sports implementations
//! Provides consistent error codes and messages across all implementations

const std = @import(\"std\");
const json = std.json;

// Unified error codes matching config.json
pub const ErrorCode = enum(u16) {
    NOT_AUTHENTICATED = 1001,
    RATE_LIMITED = 1002,
    NETWORK_ERROR = 1003,
    PARSE_ERROR = 1004,
    INVALID_REQUEST = 1005,
    NOT_FOUND = 1006,
    INTERNAL_ERROR = 1007,
};

// HTTP status code mapping
pub fn getHttpStatus(error_code: ErrorCode) u16 {
    return switch (error_code) {
        .NOT_AUTHENTICATED => 401,
        .RATE_LIMITED => 429,
        .NETWORK_ERROR => 502,
        .PARSE_ERROR => 500,
        .INVALID_REQUEST => 400,
        .NOT_FOUND => 404,
        .INTERNAL_ERROR => 500,
    };
}

// Error message mapping
pub fn getMessage(error_code: ErrorCode) []const u8 {
    return switch (error_code) {
        .NOT_AUTHENTICATED => \"Not authenticated. Please set OAuth tokens.\",
        .RATE_LIMITED => \"Rate limit exceeded. Please try again later.\",
        .NETWORK_ERROR => \"Network error occurred. Please try again.\",
        .PARSE_ERROR => \"Failed to parse API response.\",
        .INVALID_REQUEST => \"Invalid request parameters.\",
        .NOT_FOUND => \"Requested resource not found.\",
        .INTERNAL_ERROR => \"Internal server error occurred.\",
    };
}

// Structured error response
pub const ErrorResponse = struct {
    code: u16,
    message: []const u8,
    http_status: u16,
    timestamp: i64,
    
    pub fn init(error_code: ErrorCode) ErrorResponse {
        return ErrorResponse{
            .code = @intFromEnum(error_code),
            .message = getMessage(error_code),
            .http_status = getHttpStatus(error_code),
            .timestamp = std.time.timestamp(),
        };
    }
};