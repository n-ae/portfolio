-- Shared build configuration for all test scripts
-- Ensures all implementations are built with optimizations

local function build_all_optimized()
    print("Building all implementations with optimizations...")
    
    -- Build Go (already optimized by default)
    print("  Building Go...")
    local go_result = os.execute("cd go && go build -o fixml fixml.go 2>/dev/null")
    if go_result ~= 0 and go_result ~= true then
        print("    Warning: Go build failed")
    end
    
    -- Build Rust in optimized mode
    print("  Building Rust (optimized)...")
    local rust_result = os.execute("cd rust && rustc -O -o fixml fixml.rs 2>/dev/null")
    if rust_result ~= 0 and rust_result ~= true then
        print("    Warning: Rust build failed")
    end
    
    -- Build OCaml with optimizations
    print("  Building OCaml (optimized)...")
    local ocaml_result = os.execute("cd ocaml && ocamlopt -I +unix -I +str unix.cmxa str.cmxa -o fixml fixml.ml 2>/dev/null")
    if ocaml_result ~= 0 and ocaml_result ~= true then
        print("    Warning: OCaml build failed")
    end
    
    -- Build Zig in ReleaseFast mode
    print("  Building Zig (ReleaseFast)...")
    local zig_result = os.execute("cd zig && zig build -Doptimize=ReleaseFast 2>/dev/null")
    if zig_result ~= 0 and zig_result ~= true then
        print("    Warning: Zig build failed")
    end
    
    print("Build complete!")
    print()
end

-- Implementation configurations with optimized paths
local function get_implementations()
    return {
        {"Go", "go/fixml"},
        {"Rust", "rust/fixml"},
        {"Lua", "lua lua/fixml.lua"},  -- Lua interpreter handles optimization
        {"OCaml", "ocaml/fixml"},
        {"Zig", "zig/zig-out/bin/fixml"}
    }
end

-- Check if implementations exist and are executable
local function verify_implementations()
    local implementations = get_implementations()
    local available = {}
    
    for _, impl in ipairs(implementations) do
        local name, command = impl[1], impl[2]
        
        -- For Lua, check if the script exists
        if name == "Lua" then
            local file = io.open("lua/fixml.lua", "r")
            if file then
                file:close()
                table.insert(available, impl)
            else
                print("Warning: " .. name .. " implementation not available")
            end
        else
            -- For compiled languages, check if executable exists
            local executable_path = command:match("^[^%s]+")  -- Extract first word (executable path)
            local file = io.open(executable_path, "r")
            if file then
                file:close()
                table.insert(available, impl)
            else
                print("Warning: " .. name .. " implementation not available at: " .. executable_path)
            end
        end
    end
    
    return available
end

-- Export functions
return {
    build_all_optimized = build_all_optimized,
    get_implementations = get_implementations,
    verify_implementations = verify_implementations
}