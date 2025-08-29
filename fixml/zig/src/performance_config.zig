//! Performance Configuration Domain Module
//!
//! Encapsulates performance tuning parameters and capacity calculations.
//! Provides adaptive configuration based on content characteristics.

const std = @import("std");

/// Performance Configuration Domain - encapsulates performance tuning
pub const PerformanceDomain = struct {
    pub const ESTIMATED_LINE_LENGTH = 50;
    pub const MIN_HASH_CAPACITY = 256;
    pub const MAX_HASH_CAPACITY = 4096;
    pub const LOAD_FACTOR_NUMERATOR = 4;
    pub const LOAD_FACTOR_DENOMINATOR = 3;
    pub const INDENT_OVERHEAD_PERCENT = 8;
    pub const SAFETY_MARGIN_PERCENT = 16;
    pub const MAX_SAFETY_MARGIN_KB = 1;
    pub const MAX_FILE_SIZE_MB = 100;
    pub const CHUNK_SIZE = 4;
    pub const UNROLL_FACTOR = 4;
    pub const LARGE_STRING_THRESHOLD = 16;
    pub const MEDIUM_STRING_THRESHOLD = 8;
    
    /// Calculate optimal hash capacity based on content size
    pub fn calculateHashCapacity(content_size: usize) u32 {
        const estimated_lines = content_size / ESTIMATED_LINE_LENGTH;
        return @as(u32, @intCast(@min(@max(
            estimated_lines * LOAD_FACTOR_NUMERATOR / LOAD_FACTOR_DENOMINATOR,
            MIN_HASH_CAPACITY
        ), MAX_HASH_CAPACITY)));
    }
    
    /// Calculate buffer capacity with overhead and safety margins
    pub fn calculateBufferCapacity(content_size: usize) usize {
        const indent_overhead = content_size >> INDENT_OVERHEAD_PERCENT;
        const safety_margin = @min(content_size >> SAFETY_MARGIN_PERCENT, MAX_SAFETY_MARGIN_KB * 1024);
        return content_size + indent_overhead + safety_margin;
    }
};

/// Hash Strategy Selection for different content types
pub const HashStrategy = enum {
    fast,
    normalized,
    attribute_aware,
    simple,
};

/// Processing Configuration Value Object - adaptive configuration
pub const ProcessingConfig = struct {
    strip_xml_declaration: bool,
    max_file_size: usize,
    estimated_capacity: usize,
    hash_capacity: u32,
    hash_strategy: HashStrategy,

    /// Create default configuration for given content size
    pub fn create(content_size: usize) ProcessingConfig {
        return ProcessingConfig{
            .strip_xml_declaration = false,
            .max_file_size = PerformanceDomain.MAX_FILE_SIZE_MB * 1024 * 1024,
            .estimated_capacity = PerformanceDomain.calculateBufferCapacity(content_size),
            .hash_capacity = PerformanceDomain.calculateHashCapacity(content_size),
            .hash_strategy = .fast, // Default to fastest strategy
        };
    }
    
    /// Create optimized configuration based on content characteristics
    pub fn createOptimizedFor(content_size: usize, has_attributes: bool) ProcessingConfig {
        var config = create(content_size);
        // Select optimal hash strategy based on content characteristics
        config.hash_strategy = if (has_attributes) .attribute_aware else .fast;
        return config;
    }
    
    /// Return new config with different hash strategy
    pub fn withHashStrategy(self: ProcessingConfig, strategy: HashStrategy) ProcessingConfig {
        var result = self;
        result.hash_strategy = strategy;
        return result;
    }
};