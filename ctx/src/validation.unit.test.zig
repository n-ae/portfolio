const std = @import("std");
const testing = std.testing;
const validation = @import("validation.zig");
const EnvVar = validation.EnvVar;

test "validation context name valid" {
    try validation.validateContextName("test");
    try validation.validateContextName("test-feature");
    try validation.validateContextName("test_branch");
    try validation.validateContextName("test.env");
    try validation.validateContextName("feature123");
    try validation.validateContextName("a"); // Minimum length

    // Maximum length test
    const max_name = "a" ** validation.MAX_CONTEXT_NAME_LENGTH;
    try validation.validateContextName(max_name);
}

test "validation context name invalid" {
    // Too short (empty)
    try testing.expectError(error.InvalidName, validation.validateContextName(""));

    // Too long
    const too_long = "a" ** (validation.MAX_CONTEXT_NAME_LENGTH + 1);
    try testing.expectError(error.InvalidName, validation.validateContextName(too_long));

    // Invalid characters
    try testing.expectError(error.InvalidName, validation.validateContextName("test/feature"));
    try testing.expectError(error.InvalidName, validation.validateContextName("test feature"));
    try testing.expectError(error.InvalidName, validation.validateContextName("test@feature"));
}

test "validation env var valid" {
    const valid_env_vars = [_]EnvVar{
        EnvVar{ .key = "NODE_ENV", .value = "production" },
        EnvVar{ .key = "PATH", .value = "/usr/bin:/bin" },
        EnvVar{ .key = "DEBUG", .value = "" }, // Empty value is valid
        EnvVar{ .key = "A", .value = "B" }, // Minimum key length
    };

    for (valid_env_vars) |env_var| {
        try testing.expect(validation.isEnvVarValid(env_var));
    }
}

test "validation env var invalid" {
    const invalid_env_vars = [_]EnvVar{
        EnvVar{ .key = "", .value = "value" }, // Empty key
        EnvVar{ .key = "KEY=WITH=EQUALS", .value = "value" }, // Key with equals
        EnvVar{ .key = "KEY WITH SPACE", .value = "value" }, // Key with space
    };

    for (invalid_env_vars) |env_var| {
        try testing.expect(!validation.isEnvVarValid(env_var));
    }
}