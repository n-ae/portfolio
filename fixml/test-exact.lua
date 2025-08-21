#!/usr/bin/env lua

-- Exact comparison test for FIXML implementations
-- Tests each language against expected results for specific test cases

local SAMPLES_DIR = "tests/samples"
local TEST_CASES = {
    "missing-xml-declaration", "wrong-element-order", "duplicate-packageref",
    "mixed-indent-cdata", "comment-empty-mixed", "unicode-special-mixed",
    "namespace-deep-mixed", "attrs-selfclose-mixed", "order-dup-mixed", 
    "minimal-mixed", "all-features-mixed"
}
local LANGUAGES = {"go", "rust", "lua", "ocaml", "zig"}
local MODES = {"", "--organize", "--fix-warnings", "--organize --fix-warnings"}
local MODES_SHORTHAND = {
    [""] = "d",
    ["--organize"] = "o", 
    ["--fix-warnings"] = "f",
    ["--organize --fix-warnings"] = "of",
}

-- Function to get language command
local function get_lang_cmd(lang)
    if lang == "go" then return "./go/fixml" end
    if lang == "rust" then return "./rust/fixml" end
    if lang == "ocaml" then return "./ocaml/fixml" end
    if lang == "zig" then return "./zig/fixml" end
    if lang == "lua" then return "lua ./lua/fixml.lua" end
    return ""
end

-- Open CSV file for writing
local csv_file = io.open("test-results.csv", "w")
csv_file:write("implementation,options,test_sample,status,description\n")

print("=== EXACT COMPARISON TEST ===")
print("Test cases: " .. table.concat(TEST_CASES, ", "))
print("Languages: " .. table.concat(LANGUAGES, ", "))
print("")

local total_tests = 0
local passed_tests = 0

for _, case in ipairs(TEST_CASES) do
    print("=== Testing " .. case .. " ===")

    for _, lang in ipairs(LANGUAGES) do
        local lang_cmd = get_lang_cmd(lang)
        local executable = lang_cmd:match("^([^ ]+)")

        -- Check if executable exists
        local file = io.open(executable)
        if not file then
            print("  " .. lang .. ": skip (not found)")
        else
            file:close()
            print("  " .. lang .. ":")
            local lang_passed = 0
            local lang_total = 0

            for _, mode in ipairs(MODES) do
                local mode_suffix = MODES_SHORTHAND[mode]
                local file_extension = ".csproj"
                -- Handle XML files for edge cases
                if case:find("mixed") or case:find("cdata") or case:find("comment") or case:find("unicode") or 
                   case:find("namespace") or case:find("attrs") or case:find("order-dup") or case:find("minimal") or case:find("all-features") then
                    file_extension = ".xml"
                end
                
                local expected_file = SAMPLES_DIR .. "/" .. case .. "." .. mode_suffix .. ".expected" .. file_extension
                local input_file = SAMPLES_DIR .. "/" .. case .. file_extension
                local actual_file = SAMPLES_DIR .. "/" .. case .. ".organized" .. file_extension

                lang_total = lang_total + 1
                total_tests = total_tests + 1

                -- Run the tool
                local command = lang_cmd .. " " .. mode .. " " .. input_file
                local success = os.execute(command)

                local status = "fail"
                local description = ""

                if success then
                    -- Compare with expected
                    local expected_content = ""
                    local actual_content = ""
                    local expected_file_handle = io.open(expected_file, "r")
                    if expected_file_handle then
                        expected_content = expected_file_handle:read("*a")
                        expected_file_handle:close()
                    end

                    local actual_file_handle = io.open(actual_file, "r")
                    if actual_file_handle then
                        actual_content = actual_file_handle:read("*a")
                        actual_file_handle:close()
                    end

                    if expected_content ~= "" and expected_content == actual_content then
                        print("    " .. mode_suffix .. ": ✓")
                        lang_passed = lang_passed + 1
                        passed_tests = passed_tests + 1
                        status = "pass"
                        os.remove(actual_file)
                    else
                        print("    " .. mode_suffix .. ": ✗ (differs from expected)")
                        if expected_content == "" then
                            description = "Missing expected file: " .. expected_file
                            print("      " .. description)
                        else
                            -- Show difference preview
                            local expected_lines = #expected_content:gsub("[^\n]", "")
                            local actual_lines = #actual_content:gsub("[^\n]", "")
                            description = "Expected lines: " .. expected_lines .. ", Actual lines: " .. actual_lines
                            print("      " .. description)
                        end
                    end
                else
                    description = "Execution failed"
                    print("    " .. mode_suffix .. ": ✗ ("..description.. ")")
                end

                -- Write to CSV
                csv_file:write(string.format("%s,%s,%s,%s,%s\n", lang, mode, case, status, description))

            end
            print("    Total: " .. lang_passed .. "/" .. lang_total)
        end
    end
    print("")
end

-- Close CSV file
csv_file:close()

print("=== FINAL RESULTS ===")
print("Total tests: " .. total_tests)
print("Passed tests: " .. passed_tests)
if total_tests > 0 then
    print("Success rate: " .. string.format("%.2f", passed_tests * 100 / total_tests) .. "%")
end

-- Exit with failure if any test failed
if passed_tests ~= total_tests then
    os.exit(1)
end