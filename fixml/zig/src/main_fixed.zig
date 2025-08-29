/// Simplified processFile function that uses only working legacy logic
fn processFile(allocator: Allocator, args: Args) !void {
    // Create advanced processing strategy (for declarations only)
    const strategy = if (args.fix_warnings) AdvancedProcessingStrategy.createFixWarnings() else AdvancedProcessingStrategy.createDefault();

    // Read file with size limit
    const config = ProcessingConfig.create(0);
    const max_file_size = config.max_file_size;
    const content = std.fs.cwd().readFileAlloc(allocator, args.file, max_file_size) catch |err| {
        print("Could not read file '{s}': {s}\n", .{ args.file, @errorName(err) });
        std.process.exit(1);
    };
    defer allocator.free(content);

    // Remove BOM and detect XML declaration using domain functions
    const cleaned_content = XmlDomain.removeBomIfPresent(content);
    const has_xml_decl = XmlDomain.hasXmlDeclaration(cleaned_content, XML_DECLARATION_CHECK_LIMIT);

    // Handle warnings
    handleXmlDeclarationWarnings(has_xml_decl, args.fix_warnings);

    // Process content with legacy processing (proven to work)
    const should_strip_xml_declaration = false;
    const process_result = try processXmlWithDeduplication(allocator, cleaned_content, should_strip_xml_declaration, args.fix_warnings);
    defer allocator.free(process_result.content);

    // Build final content using strategy (simplified)
    var final_content = ArrayList(u8){};
    defer final_content.deinit(allocator);
    
    const should_add_declaration = strategy.shouldAddXmlDeclaration(has_xml_decl);
    const final_capacity = process_result.content.len + if (should_add_declaration) XmlDomain.DECLARATION.len else 0;
    try final_content.ensureTotalCapacity(allocator, final_capacity);

    if (should_add_declaration) {
        try final_content.appendSlice(allocator, XmlDomain.DECLARATION);
        print("🔧 Applied fixes ({s} strategy):\n", .{strategy.getModeName()});
        print("  ✓ Added XML declaration\n", .{});
        print("\n", .{});
    }

    try final_content.appendSlice(allocator, process_result.content);

    // Get output filename and write file
    const output_filename = try getOutputFilename(allocator, args.file, args.replace);
    defer allocator.free(output_filename);

    try writeOutputFile(final_content.items, output_filename);

    // Handle file replacement and status messages
    handleFileReplacement(output_filename, args.file, args.replace);

    if (process_result.duplicates > 0) {
        print(" (removed {} duplicates)", .{process_result.duplicates});
    }
    print(" (using legacy architecture)\n", .{});
}