# Fixml Project Memory

## Directory Navigation
- Use `pushd` when changing directories temporarily
- Always use `popd` to return to original directory after commands
- Example: `pushd zig && ./fixml ../tests/samples/file.xml && popd`

## Project Structure
- Main Zig implementation: `/Users/username/dev/portfolio/fixml/zig/src/main.zig`
- Build file: `/Users/username/dev/portfolio/fixml/zig/build.zig` (configured for cross-compilation)
- Test samples: `/Users/username/dev/portfolio/fixml/tests/samples/originals/`
- Executable after build: `./fixml` (in zig directory)
- Cross-compiled binaries: `zig-out/bin/fixml-{target}` (aarch64-macos, x86_64-linux, x86_64-windows.exe)

## Build Commands
- Build for current platform: `zig build -Doptimize=ReleaseFast`
- Build for all targets: `zig build build-all -Doptimize=ReleaseFast`
- Build for specific target: 
  - `zig build build-aarch64-macos -Doptimize=ReleaseFast`
  - `zig build build-x86_64-linux -Doptimize=ReleaseFast` 
  - `zig build build-x86_64-windows -Doptimize=ReleaseFast`
- Copy executable: `cp zig-out/bin/fixml ./fixml`

## Testing
- Run functionality tests: `./test_zig.sh`
- Test single file: `./fixml <path-to-xml-file>`
- Comprehensive tests: `./comprehensive_test.sh`

## Performance Notes
- Zig implementation achieved champion performance: 3.33ms average
- Uses arena allocator for memory management
- Single-pass processing with bulk operations
- Proper XML indentation: 2 spaces per nesting level

## Common Mistakes to Avoid
- Don't assume current directory when using pushd/popd - always check with `pwd` first
- Use `fd` over `find` for file searching - example: `fd --glob "*.organized*" -x rm` instead of `find . -name "*.organized*" -delete`
- Use `rg` over `grep` for text searching
- Prefer pushd/popd for temporary directory changes, but use bare `cd` when necessary
- Avoid unnecessary directory changes - use direct paths when possible (e.g., `rustc -O rust/fixml.rs -o rust/fixml` instead of `cd rust && rustc -O fixml.rs -o fixml && cd ..`)
- Check if directories exist before attempting to change into directories
- Remove organized output files after testing to avoid confusion
- Always add format parameters when using `std.debug.print` in Zig - use `print("text", .{});` not `print("text");`
- **When can't find expected files, cd to project root immediately** - Many file path issues are caused by being in wrong directory

## Version Control
- All language folders now have appropriate `.gitignore` files
- Build artifacts, executables, and cache files are excluded from version control
- Each `.gitignore` is language-specific (Zig: zig-out/, Rust: target/, Go: *.o, OCaml: *.cmo, Lua: *.luac)