//! XML Specification Module
//!
//! Implements Specification Pattern for complex XML validation rules.
//! Replaces complex conditional logic with composable specifications.

const std = @import("std");
const xml_domain = @import("xml_domain.zig");
const character_domain = @import("character_domain.zig");

const XmlDomain = xml_domain.XmlDomain;
const CharacterDomain = character_domain.CharacterDomain;
const ArrayList = std.ArrayList;

/// Specification interface for XML validation rules
pub const XmlSpecification = struct {
    const Self = @This();
    
    // Function pointer for the specification check
    isSatisfiedByFn: *const fn (self: *const Self, content: []const u8) bool,
    getDescriptionFn: *const fn (self: *const Self) []const u8,
    
    // Specification context data
    context: SpecificationContext,
    
    const SpecificationContext = union(enum) {
        xml_declaration: XmlDeclarationSpec,
        valid_structure: ValidStructureSpec,
        wellformed_tags: WellformedTagsSpec,
        composite: CompositeSpec,
        
        const XmlDeclarationSpec = struct {
            required: bool = true,
        };
        
        const ValidStructureSpec = struct {
            max_nesting_depth: u32 = 64,
            require_root_element: bool = true,
        };
        
        const WellformedTagsSpec = struct {
            allow_self_closing: bool = true,
            validate_attributes: bool = true,
        };
        
        const CompositeSpec = struct {
            operation: Operation,
            left: ?*const XmlSpecification = null,
            right: ?*const XmlSpecification = null,
            
            const Operation = enum {
                and_op,
                or_op,
                not_op,
            };
        };
    };
    
    /// Factory methods for creating specifications
    pub fn requiresXmlDeclaration() XmlSpecification {
        return XmlSpecification{
            .isSatisfiedByFn = &xmlDeclarationIsSatisfiedBy,
            .getDescriptionFn = &xmlDeclarationGetDescription,
            .context = .{ .xml_declaration = .{ .required = true } },
        };
    }
    
    pub fn hasValidStructure(max_depth: u32) XmlSpecification {
        return XmlSpecification{
            .isSatisfiedByFn = &validStructureIsSatisfiedBy,
            .getDescriptionFn = &validStructureGetDescription,
            .context = .{ .valid_structure = .{ .max_nesting_depth = max_depth } },
        };
    }
    
    pub fn hasWellformedTags() XmlSpecification {
        return XmlSpecification{
            .isSatisfiedByFn = &wellformedTagsIsSatisfiedBy,
            .getDescriptionFn = &wellformedTagsGetDescription,
            .context = .{ .wellformed_tags = .{} },
        };
    }
    
    /// Composite specification methods
    pub fn andWith(self: *const Self, other: *const Self) XmlSpecification {
        return XmlSpecification{
            .isSatisfiedByFn = &compositeIsSatisfiedBy,
            .getDescriptionFn = &compositeGetDescription,
            .context = .{ 
                .composite = .{
                    .operation = .and_op,
                    .left = self,
                    .right = other,
                }
            },
        };
    }
    
    pub fn orWith(self: *const Self, other: *const Self) XmlSpecification {
        return XmlSpecification{
            .isSatisfiedByFn = &compositeIsSatisfiedBy,
            .getDescriptionFn = &compositeGetDescription,
            .context = .{ 
                .composite = .{
                    .operation = .or_op,
                    .left = self,
                    .right = other,
                }
            },
        };
    }
    
    pub fn not(self: *const Self) XmlSpecification {
        return XmlSpecification{
            .isSatisfiedByFn = &compositeIsSatisfiedBy,
            .getDescriptionFn = &compositeGetDescription,
            .context = .{ 
                .composite = .{
                    .operation = .not_op,
                    .left = self,
                    .right = null,
                }
            },
        };
    }
    
    /// Interface methods
    pub fn isSatisfiedBy(self: *const Self, content: []const u8) bool {
        return self.isSatisfiedByFn(self, content);
    }
    
    pub fn getDescription(self: *const Self) []const u8 {
        return self.getDescriptionFn(self);
    }
};

// Specification implementations

// XML Declaration Specification
fn xmlDeclarationIsSatisfiedBy(spec: *const XmlSpecification, content: []const u8) bool {
    _ = spec;
    return XmlDomain.hasXmlDeclaration(content, 200);
}

fn xmlDeclarationGetDescription(spec: *const XmlSpecification) []const u8 {
    _ = spec;
    return "XML document must have declaration";
}

// Valid Structure Specification
fn validStructureIsSatisfiedBy(spec: *const XmlSpecification, content: []const u8) bool {
    _ = content;
    
    switch (spec.context) {
        .valid_structure => |ctx| {
            // Placeholder - would implement nesting depth validation
            _ = ctx.max_nesting_depth;
            return true;
        },
        else => return false,
    }
}

fn validStructureGetDescription(spec: *const XmlSpecification) []const u8 {
    _ = spec;
    return "XML document must have valid structure";
}

// Wellformed Tags Specification
fn wellformedTagsIsSatisfiedBy(spec: *const XmlSpecification, content: []const u8) bool {
    _ = spec;
    
    // Simple wellformedness check - all tags properly closed
    var open_tags: u32 = 0;
    var i: usize = 0;
    
    while (i < content.len) {
        if (content[i] == '<') {
            // Find end of tag
            const tag_end = std.mem.indexOfScalarPos(u8, content, i, '>') orelse return false;
            const tag = content[i..tag_end + 1];
            
            if (tag.len < 2) return false;
            
            if (tag[1] == '/') {
                // Closing tag
                if (open_tags == 0) return false; // Unmatched closing tag
                open_tags -= 1;
            } else if (tag[tag.len - 2] == '/') {
                // Self-closing tag - no change to open_tags
            } else if (tag[1] != '!' and tag[1] != '?') {
                // Opening tag
                open_tags += 1;
            }
            
            i = tag_end + 1;
        } else {
            i += 1;
        }
    }
    
    return open_tags == 0; // All tags should be closed
}

fn wellformedTagsGetDescription(spec: *const XmlSpecification) []const u8 {
    _ = spec;
    return "XML tags must be wellformed and properly nested";
}

// Composite Specification
fn compositeIsSatisfiedBy(spec: *const XmlSpecification, content: []const u8) bool {
    switch (spec.context) {
        .composite => |ctx| {
            switch (ctx.operation) {
                .and_op => {
                    if (ctx.left == null or ctx.right == null) return false;
                    return ctx.left.?.isSatisfiedBy(content) and ctx.right.?.isSatisfiedBy(content);
                },
                .or_op => {
                    if (ctx.left == null or ctx.right == null) return false;
                    return ctx.left.?.isSatisfiedBy(content) or ctx.right.?.isSatisfiedBy(content);
                },
                .not_op => {
                    if (ctx.left == null) return false;
                    return !ctx.left.?.isSatisfiedBy(content);
                },
            }
        },
        else => return false,
    }
}

fn compositeGetDescription(spec: *const XmlSpecification) []const u8 {
    switch (spec.context) {
        .composite => |ctx| {
            switch (ctx.operation) {
                .and_op => return "Composite AND specification",
                .or_op => return "Composite OR specification", 
                .not_op => return "Composite NOT specification",
            }
        },
        else => return "Unknown composite specification",
    }
}

/// Predefined specification combinations
pub const XmlSpecifications = struct {
    /// Standard XML compliance specification
    pub fn standardCompliance() XmlSpecification {
        const declaration_spec = XmlSpecification.requiresXmlDeclaration();
        const structure_spec = XmlSpecification.hasValidStructure(64);
        const wellformed_spec = XmlSpecification.hasWellformedTags();
        
        // Combine with AND logic
        const combined1 = declaration_spec.andWith(&structure_spec);
        return combined1.andWith(&wellformed_spec);
    }
    
    /// Lenient specification for processing flexibility
    pub fn lenientCompliance() XmlSpecification {
        const structure_spec = XmlSpecification.hasValidStructure(128);
        const wellformed_spec = XmlSpecification.hasWellformedTags();
        
        return structure_spec.andWith(&wellformed_spec);
    }
    
    /// Strict specification for production systems
    pub fn strictCompliance() XmlSpecification {
        return standardCompliance();
    }
};

/// Specification Validator Service
pub const SpecificationValidator = struct {
    const ValidationResult = struct {
        is_valid: bool,
        failed_specifications: []const []const u8,
        
        pub fn deinit(self: *ValidationResult, allocator: std.mem.Allocator) void {
            allocator.free(self.failed_specifications);
        }
    };
    
    pub fn validate(allocator: std.mem.Allocator, content: []const u8, specifications: []const XmlSpecification) !ValidationResult {
        var failed_specs = ArrayList([]const u8){};
        defer failed_specs.deinit(allocator);
        
        for (specifications) |spec| {
            if (!spec.isSatisfiedBy(content)) {
                try failed_specs.append(allocator, spec.getDescription());
            }
        }
        
        return ValidationResult{
            .is_valid = failed_specs.items.len == 0,
            .failed_specifications = try failed_specs.toOwnedSlice(allocator),
        };
    }
};