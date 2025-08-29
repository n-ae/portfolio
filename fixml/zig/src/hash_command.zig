//! Hash Command Module
//!
//! Implements Command Pattern for hash computation with pluggable strategies.
//! Provides different hashing approaches optimized for various XML content types.

const std = @import("std");
const character_domain = @import("character_domain.zig");
const performance_config = @import("performance_config.zig");

const CharacterDomain = character_domain.CharacterDomain;
const HashStrategy = performance_config.HashStrategy;
const Allocator = std.mem.Allocator;

/// Hash Command Pattern - Replace Function with Command refactoring
pub const HashCommand = struct {
    // Cryptographically diverse seeds to prevent hash collisions
    pub const FAST_SEED: u64 = 0x517cc1b727220a95;
    pub const NORMALIZED_SEED: u64 = 0x9e3779b97f4a7c15;
    pub const ATTRIBUTE_SEED: u64 = 0xc6a4a7935bd1e995;
    pub const CONTENT_SEED: u64 = 0xe17a1465bf5ae6e7;
    
    allocator: Allocator,
    strategy: HashStrategy,
    
    /// Create hash command with specified strategy
    pub fn create(allocator: Allocator, strategy: HashStrategy) HashCommand {
        return HashCommand{
            .allocator = allocator,
            .strategy = strategy,
        };
    }
    
    /// Execute hash computation using configured strategy
    pub fn execute(self: HashCommand, content: []const u8) u64 {
        return switch (self.strategy) {
            .fast => self.hashFast(content),
            .normalized => self.hashNormalized(content),
            .attribute_aware => self.hashWithAttributes(content),
            .simple => self.hashSimple(content),
        };
    }
    
    /// Fast hash for simple content without normalization
    pub fn hashFast(self: HashCommand, content: []const u8) u64 {
        _ = self;
        if (content.len == 0) return 0;
        
        var hasher = std.hash.Wyhash.init(FAST_SEED);
        var prev_space = false;
        
        // Optimized single-pass processing
        for (content) |c| {
            if (CharacterDomain.isWhitespace(c)) {
                if (!prev_space) {
                    hasher.update(" ");
                    prev_space = true;
                }
            } else {
                hasher.update(&[_]u8{c});
                prev_space = false;
            }
        }
        
        return hasher.final();
    }
    
    /// Simple FNV-1a hash with loop unrolling
    pub fn hashSimple(self: HashCommand, content: []const u8) u64 {
        _ = self;
        var hash: u64 = FAST_SEED; // FNV-1a basis
        
        // Unrolled loop for better performance
        var i: usize = 0;
        while (i + 8 <= content.len) {
            // FNV-1a hash with loop unrolling
            inline for (0..8) |offset| {
                hash ^= content[i + offset];
                hash *%= 0x100000001b3;
            }
            i += 8;
        }
        
        // Handle remaining bytes
        while (i < content.len) : (i += 1) {
            hash ^= content[i];
            hash *%= 0x100000001b3;
        }
        
        return hash;
    }
    
    /// Normalized hash for content with whitespace normalization
    pub fn hashNormalized(self: HashCommand, content: []const u8) u64 {
        // Use fast hash as baseline - full normalization can be added later
        return self.hashFast(content);
    }
    
    /// Attribute-aware hash for XML tags with attributes
    pub fn hashWithAttributes(self: HashCommand, content: []const u8) u64 {
        // Use fast hash as baseline - attribute parsing can be added later  
        return self.hashFast(content);
    }
};

/// Optimized hash computation factory function
pub fn computeSimpleHash(content: []const u8) u64 {
    const cmd = HashCommand.create(undefined, .simple);
    return cmd.execute(content);
}

/// Fast XML content hash with whitespace normalization
pub fn hashXmlContentFast(content: []const u8) u64 {
    if (content.len == 0) return 0;
    
    var hasher = std.hash.Wyhash.init(HashCommand.FAST_SEED);
    var prev_space = false;
    var i: usize = 0;
    
    // Process in chunks for better throughput
    while (i + 8 <= content.len) {
        comptime var unroll = 0;
        var chunk_has_content = false;
        inline while (unroll < 8) : (unroll += 1) {
            const c = content[i + unroll];
            if (CharacterDomain.isWhitespace(c)) {
                if (!prev_space and chunk_has_content) {
                    hasher.update(" ");
                    prev_space = true;
                }
            } else {
                hasher.update(&[_]u8{c});
                prev_space = false;
                chunk_has_content = true;
            }
        }
        i += 8;
    }
    
    // Process remaining bytes
    while (i < content.len) : (i += 1) {
        const c = content[i];
        if (CharacterDomain.isWhitespace(c)) {
            if (!prev_space) {
                hasher.update(" ");
                prev_space = true;
            }
        } else {
            hasher.update(&[_]u8{c});
            prev_space = false;
        }
    }
    
    return hasher.final();
}

/// Hash string with whitespace normalization
pub fn hashSimpleString(s: []const u8) u64 {
    var hasher = std.hash.Wyhash.init(0xDEADBEEF_CAFEBABE);
    
    var prev_space = false;
    const chunk_size = 8;
    var i: usize = 0;
    
    // Process in 8-byte chunks for better throughput
    while (i + chunk_size <= s.len) {
        var normalized_chunk: [chunk_size]u8 = undefined;
        var chunk_pos: usize = 0;
        
        for (s[i .. i + chunk_size]) |c| {
            if (CharacterDomain.isWhitespace(c)) {
                if (!prev_space) {
                    normalized_chunk[chunk_pos] = ' ';
                    chunk_pos += 1;
                    prev_space = true;
                }
            } else {
                normalized_chunk[chunk_pos] = c;
                chunk_pos += 1;
                prev_space = false;
            }
        }
        
        if (chunk_pos > 0) {
            hasher.update(normalized_chunk[0..chunk_pos]);
        }
        i += chunk_size;
    }
    
    // Process remaining bytes
    while (i < s.len) {
        const c = s[i];
        if (CharacterDomain.isWhitespace(c)) {
            if (!prev_space) {
                hasher.update(" ");
                prev_space = true;
            }
        } else {
            hasher.update(&[_]u8{c});
            prev_space = false;
        }
        i += 1;
    }
    
    return hasher.final();
}