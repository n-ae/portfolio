//! Processing Strategy Module
//!
//! Implements advanced Strategy Pattern with polymorphic processing modes.
//! Replaces Type Code with Strategy (Martin Fowler refactoring).

const std = @import("std");
const xml_domain = @import("xml_domain.zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

/// Processing Strategy Interface - Replace Type Code with Strategy
pub const ProcessingStrategy = struct {
    const Self = @This();
    
    // Strategy function pointers for polymorphic behavior
    shouldAddXmlDeclarationFn: *const fn (self: *const Self, has_xml_decl: bool) bool,
    shouldNormalizeContentFn: *const fn (self: *const Self) bool,
    processContentFn: *const fn (self: *const Self, allocator: Allocator, content: []const u8) anyerror![]u8,
    getModeNameFn: *const fn (self: *const Self) []const u8,
    
    // Strategy-specific data
    context: StrategyContext,
    
    /// Context data for different strategies
    const StrategyContext = union(enum) {
        default: DefaultContext,
        fix_warnings: FixWarningsContext,
        performance_optimized: PerformanceContext,
        
        const DefaultContext = struct {
            preserve_formatting: bool = true,
        };
        
        const FixWarningsContext = struct {
            add_missing_declarations: bool = true,
            normalize_whitespace: bool = true,
            fix_attribute_quoting: bool = true,
        };
        
        const PerformanceContext = struct {
            use_fast_path: bool = true,
            skip_validation: bool = true,
        };
    };
    
    /// Factory method for creating strategies
    pub fn createDefault() ProcessingStrategy {
        return ProcessingStrategy{
            .shouldAddXmlDeclarationFn = &defaultShouldAddXmlDeclaration,
            .shouldNormalizeContentFn = &defaultShouldNormalizeContent,
            .processContentFn = &defaultProcessContent,
            .getModeNameFn = &defaultGetModeName,
            .context = .{ .default = .{} },
        };
    }
    
    pub fn createFixWarnings() ProcessingStrategy {
        return ProcessingStrategy{
            .shouldAddXmlDeclarationFn = &fixWarningsShouldAddXmlDeclaration,
            .shouldNormalizeContentFn = &fixWarningsShouldNormalizeContent,
            .processContentFn = &fixWarningsProcessContent,
            .getModeNameFn = &fixWarningsGetModeName,
            .context = .{ .fix_warnings = .{} },
        };
    }
    
    pub fn createPerformanceOptimized() ProcessingStrategy {
        return ProcessingStrategy{
            .shouldAddXmlDeclarationFn = &performanceShouldAddXmlDeclaration,
            .shouldNormalizeContentFn = &performanceShouldNormalizeContent,
            .processContentFn = &performanceProcessContent,
            .getModeNameFn = &performanceGetModeName,
            .context = .{ .performance_optimized = .{} },
        };
    }
    
    // Polymorphic interface methods
    pub fn shouldAddXmlDeclaration(self: *const Self, has_xml_decl: bool) bool {
        return self.shouldAddXmlDeclarationFn(self, has_xml_decl);
    }
    
    pub fn shouldNormalizeContent(self: *const Self) bool {
        return self.shouldNormalizeContentFn(self);
    }
    
    pub fn processContent(self: *const Self, allocator: Allocator, content: []const u8) ![]u8 {
        return self.processContentFn(self, allocator, content);
    }
    
    pub fn getModeName(self: *const Self) []const u8 {
        return self.getModeNameFn(self);
    }
};

// Strategy implementations - Default Mode
fn defaultShouldAddXmlDeclaration(self: *const ProcessingStrategy, has_xml_decl: bool) bool {
    _ = self;
    _ = has_xml_decl;
    return false; // Preserve original structure
}

fn defaultShouldNormalizeContent(self: *const ProcessingStrategy) bool {
    _ = self;
    return false; // Minimal changes
}

fn defaultProcessContent(self: *const ProcessingStrategy, allocator: Allocator, content: []const u8) ![]u8 {
    _ = self;
    // Default processing - just copy content
    return try allocator.dupe(u8, content);
}

fn defaultGetModeName(self: *const ProcessingStrategy) []const u8 {
    _ = self;
    return "default";
}

// Strategy implementations - Fix Warnings Mode
fn fixWarningsShouldAddXmlDeclaration(self: *const ProcessingStrategy, has_xml_decl: bool) bool {
    _ = self;
    return !has_xml_decl; // Add if missing
}

fn fixWarningsShouldNormalizeContent(self: *const ProcessingStrategy) bool {
    _ = self;
    return true; // Apply normalization
}

fn fixWarningsProcessContent(self: *const ProcessingStrategy, allocator: Allocator, content: []const u8) ![]u8 {
    _ = self;
    // Apply content normalization (placeholder implementation)
    return try allocator.dupe(u8, content);
}

fn fixWarningsGetModeName(self: *const ProcessingStrategy) []const u8 {
    _ = self;
    return "fix_warnings";
}

// Strategy implementations - Performance Mode
fn performanceShouldAddXmlDeclaration(self: *const ProcessingStrategy, has_xml_decl: bool) bool {
    _ = self;
    _ = has_xml_decl;
    return false; // Skip expensive operations
}

fn performanceShouldNormalizeContent(self: *const ProcessingStrategy) bool {
    _ = self;
    return false; // Skip normalization for speed
}

fn performanceProcessContent(self: *const ProcessingStrategy, allocator: Allocator, content: []const u8) ![]u8 {
    _ = self;
    // Fast path processing
    return try allocator.dupe(u8, content);
}

fn performanceGetModeName(self: *const ProcessingStrategy) []const u8 {
    _ = self;
    return "performance";
}

/// Strategy Factory - encapsulates strategy creation logic
pub const StrategyFactory = struct {
    pub fn createStrategy(mode: []const u8) ProcessingStrategy {
        if (std.mem.eql(u8, mode, "fix-warnings")) {
            return ProcessingStrategy.createFixWarnings();
        } else if (std.mem.eql(u8, mode, "performance")) {
            return ProcessingStrategy.createPerformanceOptimized();
        } else {
            return ProcessingStrategy.createDefault();
        }
    }
    
    pub fn createStrategyFromBool(fix_warnings: bool) ProcessingStrategy {
        return if (fix_warnings) 
            ProcessingStrategy.createFixWarnings() 
        else 
            ProcessingStrategy.createDefault();
    }
};