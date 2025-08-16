const std = @import("std");
const process = std.process;
const build_options = @import("build_options");

const clap = @import("clap");

const context = @import("context.zig");
const ContextManager = context.ContextManager;
const validation = @import("validation.zig");
const eol = validation.eol;

const Command = enum {
    save,
    restore,
    list,
    delete,
    version,
};

const params = clap.parseParamsComptime(
    \\-h, --help             Display this help and exit.
    \\<command>
    \\
);

fn printHelp() void {
    std.debug.print(
        \\{0s} - Context Session Manager
        \\USAGE:
        \\  {0s} save <name>      Save current context
        \\  {0s} restore <name>   Restore a saved context
        \\  {0s} list             List all saved contexts
        \\  {0s} delete <name>    Delete a context
        \\  {0s} version          Show version information
        \\
        \\EXAMPLES:
        \\  {0s} save feature-auth
        \\  {0s} restore bugfix-payment
        \\  {0s} list
        \\  {0s} version
        \\
    , .{build_options.package.name});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const parsers = comptime .{
        .command = clap.parsers.enumeration(Command),
    };

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, parsers, .{
        .diagnostic = &diag,
        .allocator = allocator,
        .terminating_positional = 0,
    }) catch |err| switch (err) {
        error.NameNotPartOfEnum => {
            // Get the raw arguments to show the invalid command
            const args = try process.argsAlloc(allocator);
            defer process.argsFree(allocator, args);

            if (args.len > 1) {
                std.debug.print("❌ Unknown command: '{s}'" ++ eol, .{args[1]});
                std.debug.print("" ++ eol, .{});
                printHelp();
            } else {
                printHelp();
            }
            return;
        },
        else => {
            diag.report(std.io.getStdErr().writer(), err) catch {};
            return err;
        },
    };
    defer res.deinit();

    if (res.args.help != 0) {
        printHelp();
        return;
    }

    if (res.positionals.len == 0 or res.positionals[0] == null) {
        printHelp();
        return;
    }

    var ctx_manager = try ContextManager.init(allocator);
    defer ctx_manager.deinit();

    const subcommand = res.positionals[0].?;

    const args = try process.argsAlloc(allocator);
    defer process.argsFree(allocator, args);

    switch (subcommand) {
        .save => {
            const name = ctx_manager.parseName(args, "save") catch return;
            try ctx_manager.saveContext(name);
        },
        .restore => {
            const name = ctx_manager.parseName(args, "restore") catch return;
            try ctx_manager.restoreContext(name);
        },
        .list => {
            try ctx_manager.listContexts();
        },
        .delete => {
            const name = ctx_manager.parseName(args, "delete") catch return;
            try ctx_manager.deleteContext(name);
        },
        .version => {
            std.debug.print(build_options.package.name ++ " v" ++ build_options.package.version ++ eol, .{});
        },
    }
}
