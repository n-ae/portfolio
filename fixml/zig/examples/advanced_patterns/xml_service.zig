//! XML Processing Service Layer
//!
//! Implements Service Layer pattern to coordinate between domain modules.
//! Provides high-level XML processing services with transaction-like semantics.

const std = @import("std");
const xml_domain = @import("xml_domain.zig");
const character_domain = @import("character_domain.zig");
const performance_config = @import("performance_config.zig");
const hash_command = @import("hash_command.zig");
const processing = @import("processing.zig");
const processing_strategy = @import("processing_strategy.zig");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const HashMap = std.AutoHashMap;
const XmlDomain = xml_domain.XmlDomain;
const ProcessingConfig = performance_config.ProcessingConfig;
const ProcessingStrategy = processing_strategy.ProcessingStrategy;
const ProcessingContext = processing.ProcessingContext;
const ProcessResult = processing.ProcessResult;

/// XML Processing Service - coordinates domain operations
pub const XmlProcessingService = struct {
    allocator: Allocator,
    strategy: ProcessingStrategy,
    config: ProcessingConfig,
    
    /// Service initialization
    pub fn init(allocator: Allocator, strategy: ProcessingStrategy, content_size: usize) XmlProcessingService {
        return XmlProcessingService{
            .allocator = allocator,
            .strategy = strategy,
            .config = ProcessingConfig.create(content_size),
        };
    }
    
    /// High-level XML processing service
    pub fn processXmlDocument(self: *XmlProcessingService, content: []const u8) !XmlProcessingResult {
        // Service-level transaction begin
        var transaction = try self.beginTransaction(content);
        defer self.endTransaction(&transaction);
        
        // Execute processing pipeline
        return try self.executeProcessingPipeline(&transaction, content);
    }
    
    /// Processing result with rich metadata
    pub const XmlProcessingResult = struct {
        content: []u8,
        statistics: ProcessingStatistics,
        warnings: []ProcessingWarning,
        
        pub const ProcessingStatistics = struct {
            lines_processed: u32,
            duplicates_removed: u32,
            elements_normalized: u32,
            processing_time_ms: f64,
            memory_used_bytes: usize,
        };
        
        pub const ProcessingWarning = struct {
            line_number: u32,
            column: u32,
            message: []const u8,
            severity: Severity,
            
            pub const Severity = enum {
                info,
                warning,
                err,
            };
        };
        
        pub fn deinit(self: *XmlProcessingResult, allocator: Allocator) void {
            allocator.free(self.content);
            allocator.free(self.warnings);
        }
    };
    
    /// Processing transaction for resource management
    const ProcessingTransaction = struct {
        result_buffer: ArrayList(u8),
        hash_set: HashMap(u64, void),
        statistics: XmlProcessingResult.ProcessingStatistics,
        warnings: ArrayList(XmlProcessingResult.ProcessingWarning),
        start_time: i64,
        
        fn init(allocator: Allocator, capacity: usize, hash_capacity: u32) !ProcessingTransaction {
            var result_buffer = ArrayList(u8){};
            try result_buffer.ensureTotalCapacity(allocator, capacity);
            
            var hash_set = HashMap(u64, void).init(allocator);
            try hash_set.ensureTotalCapacity(hash_capacity);
            
            return ProcessingTransaction{
                .result_buffer = result_buffer,
                .hash_set = hash_set,
                .statistics = std.mem.zeroes(XmlProcessingResult.ProcessingStatistics),
                .warnings = ArrayList(XmlProcessingResult.ProcessingWarning){},
                .start_time = std.time.milliTimestamp(),
            };
        }
        
        fn deinit(self: *ProcessingTransaction, allocator: Allocator) void {
            // result_buffer ownership transferred via toOwnedSlice(), so just deinit structure
            self.result_buffer.deinit(allocator);
            self.hash_set.deinit();
            self.warnings.deinit(allocator);
        }
        
        /// Clean up remaining transaction resources after content ownership transfer
        fn deinitAfterTransfer(self: *ProcessingTransaction, allocator: Allocator) void {
            // Don't deinit result_buffer as its content was transferred via toOwnedSlice()
            self.hash_set.deinit();
            self.warnings.deinit(allocator);
        }
    };
    
    /// Begin processing transaction
    fn beginTransaction(self: *XmlProcessingService, content: []const u8) !ProcessingTransaction {
        _ = content;
        return ProcessingTransaction.init(
            self.allocator, 
            self.config.estimated_capacity,
            self.config.hash_capacity
        );
    }
    
    /// End processing transaction
    fn endTransaction(self: *XmlProcessingService, transaction: *ProcessingTransaction) void {
        transaction.statistics.processing_time_ms = @floatFromInt(std.time.milliTimestamp() - transaction.start_time);
        transaction.statistics.memory_used_bytes = transaction.result_buffer.capacity;
        
        // Clean up transaction resources after content ownership was transferred
        transaction.deinitAfterTransfer(self.allocator);
    }
    
    /// Execute the complete processing pipeline
    fn executeProcessingPipeline(self: *XmlProcessingService, transaction: *ProcessingTransaction, content: []const u8) !XmlProcessingResult {
        // Pipeline stage 1: Content preprocessing
        const cleaned_content = try self.preprocessContent(content);
        defer if (cleaned_content.ptr != content.ptr) self.allocator.free(cleaned_content);
        
        // Pipeline stage 2: XML validation and analysis
        const analysis = try self.analyzeXmlStructure(cleaned_content, transaction);
        
        // Pipeline stage 3: Core processing
        const processed_content = try self.processContent(cleaned_content, transaction, analysis);
        
        // Pipeline stage 4: Post-processing and finalization
        return try self.finalizeResult(processed_content, transaction);
    }
    
    /// Content preprocessing stage
    fn preprocessContent(self: *XmlProcessingService, content: []const u8) ![]const u8 {
        _ = self;
        // Apply BOM removal and basic cleaning
        return XmlDomain.removeBomIfPresent(content);
    }
    
    /// XML structure analysis
    const XmlAnalysis = struct {
        has_xml_declaration: bool,
        element_count: u32,
        max_nesting_depth: u32,
        complexity_score: f32,
    };
    
    fn analyzeXmlStructure(self: *XmlProcessingService, content: []const u8, transaction: *ProcessingTransaction) !XmlAnalysis {
        _ = self;
        _ = transaction;
        
        return XmlAnalysis{
            .has_xml_declaration = XmlDomain.hasXmlDeclaration(content, 200),
            .element_count = 0, // Placeholder
            .max_nesting_depth = 0, // Placeholder  
            .complexity_score = 1.0, // Placeholder
        };
    }
    
    /// Core content processing
    fn processContent(self: *XmlProcessingService, content: []const u8, transaction: *ProcessingTransaction, analysis: XmlAnalysis) ![]u8 {
        _ = analysis;
        
        // Create processing context
        var duplicates_removed: u32 = 0;
        var indent_level: i32 = 0;
        
        const context = ProcessingContext{
            .allocator = self.allocator,
            .result = &transaction.result_buffer,
            .seen_hashes = &transaction.hash_set,
            .duplicates_removed = &duplicates_removed,
            .indent_level = &indent_level,
            .strip_xml_declaration = false,
        };
        
        // Execute processing using strategy
        try processing.processAllLines(context, content);
        transaction.statistics.duplicates_removed = duplicates_removed;
        
        return try transaction.result_buffer.toOwnedSlice(self.allocator);
    }
    
    /// Finalize processing result
    fn finalizeResult(self: *XmlProcessingService, content: []u8, transaction: *ProcessingTransaction) !XmlProcessingResult {
        // Finalize statistics
        transaction.statistics.lines_processed = @intCast(std.mem.count(u8, content, "\n"));
        
        return XmlProcessingResult{
            .content = content,
            .statistics = transaction.statistics,
            .warnings = try transaction.warnings.toOwnedSlice(self.allocator),
        };
    }
};