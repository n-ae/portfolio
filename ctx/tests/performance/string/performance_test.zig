const std = @import("std");

// Simulate build options
const build_options = struct {
    pub const package = struct {
        pub const name = "ctx";
        pub const version = "0.1.0";
    };
};

const eol = "\n";

export fn method1_format_string() void {
    std.debug.print("{s}-v{s}" ++ eol, .{ build_options.package.name, build_options.package.version });
}

export fn method2_string_concat() void {
    std.debug.print(build_options.package.name ++ "-v" ++ build_options.package.version ++ eol, .{});
}

export fn method3_prebuilt_constant() void {
    const version_string = build_options.package.name ++ "-v" ++ build_options.package.version ++ eol;
    std.debug.print(version_string, .{});
}