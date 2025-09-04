const std = @import("std");

/// Application configuration constants
pub const Config = struct {
    /// Maximum size for reading context files (1MB)
    pub const MAX_FILE_SIZE: u32 = 1024 * 1024;

    /// Maximum size for command output (1MB)
    pub const MAX_OUTPUT_SIZE: u32 = 1024 * 1024;

    /// Maximum size for git branch output
    pub const MAX_GIT_OUTPUT_SIZE: u32 = 1024;

    /// Maximum size for context listing preview
    pub const MAX_PREVIEW_SIZE: u32 = 1024;

    /// File extension for context files
    pub const CONTEXT_FILE_EXTENSION: []const u8 = ".json";

    /// Default contexts directory name (relative to home)
    pub const CONTEXTS_DIR_NAME: []const u8 = ".ctx";

    /// Fallback directory when HOME is not available
    pub const FALLBACK_HOME_DIR: []const u8 = "/tmp";

    /// Test directory prefix
    pub const TEST_DIR_PREFIX: []const u8 = "/tmp/ctx_test";

    /// Environment variables to save in contexts
    pub const DEV_ENV_VARS: []const []const u8 = &[_][]const u8{
        "NODE_ENV",
        "PYTHONPATH", 
        "GOPATH",
        "RUST_LOG",
        "DEBUG",
    };
};

/// Validation constants
pub const Validation = struct {
    /// Maximum length for environment variable keys
    pub const MAX_ENV_KEY_LENGTH: u32 = 1024;
};