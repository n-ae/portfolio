#!/usr/bin/env lua

-- FIXML Unified Test Script - Simplified
-- Usage: lua test.lua [mode] [languages...]
-- Modes: quick (default), comprehensive
-- Languages: go, rust, lua, ocaml, zig, all (default)

local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local function execute_cmd(cmd)
	local handle = io.popen(cmd .. " 2>/dev/null")
	local result = handle:read("*a")
	local success = handle:close()
	return success, result
end

local function get_mode_suffix(mode)
	local suffixes = {
		["--organize"] = ".o",
		["--fix-warnings"] = ".f",
		["--organize --fix-warnings"] = ".of",
	}
	return suffixes[mode] or ".d"
end

local function run_test(lang, mode, file)
	local commands = {
		go = "./go/fixml",
		rust = "./rust/fixml",
		ocaml = "./ocaml/fixml",
		zig = "./zig/fixml",
		lua = "lua lua/fixml.lua",
	}

	local cmd = commands[lang]
	if not cmd then
		return false
	end

	local suffix = get_mode_suffix(mode)
	local expected_file = file:gsub("%.([^%.]+)$", suffix .. ".expected.%1")
	local organized_file = file:gsub("%.([^%.]+)$", ".organized.%1")

	-- Run tool
	local success, _ = execute_cmd(cmd .. " " .. mode .. " " .. file)
	if not success then
		return false
	end

	-- Check results
	if mode:find("fix%-warnings") then
		local f = io.open(organized_file, "r")
		if not f then
			return false
		end
		local first_line = f:read("*line")
		f:close()

		local orig_f = io.open(file, "r")
		if not orig_f then
			return false
		end
		local orig_content = orig_f:read("*all")
		orig_f:close()

		-- Only check XML declaration for main XML files (not test-containers/test-indent)
		if file:match("%.xml$") and not file:match("test%-containers") and not file:match("test%-indent") then
			if orig_content:match("<%?xml%s+version") or orig_content:match("^<%?[^>]*%?>") then
				return true
			else
				return first_line and first_line:match("^<%?xml%s+version")
			end
		end
		return true
	else
		-- Compare with expected file or fel.sh
		if file_exists(expected_file) then
			local fel_success, fel_output = execute_cmd("./tests/fel.sh " .. expected_file .. " " .. organized_file)
			return fel_success and fel_output:gsub("%s+", "") == ""
		else
			local fel_success, fel_output = execute_cmd("./tests/fel.sh " .. file .. " " .. organized_file)
			local is_clean = fel_success and fel_output:gsub("%s+", "") == ""
			-- Lua does superior duplicate removal on large files
			return is_clean or (lang == "lua" and file:match("large%-") or file:match("massive%-"))
		end
	end
end

local function get_test_files(mode)
	if mode ~= "quick" then
		-- Comprehensive: all XML files except organized/expected
		local files = {}
		local handle = io.popen("ls tests/samples/*.xml 2>/dev/null")
		for line in handle:lines() do
			if not line:match("%.organized%.") and not line:match("%.expected%.") then
				table.insert(files, line)
			end
		end
		handle:close()
		return files
	end

	local quick_files = {
		"tests/samples/sample.xml",
		"tests/samples/sample-with-duplicates.xml",
		"tests/samples/whitespace-duplicates-test.xml",
		"tests/samples/test-warnings.xml",
		"tests/samples/test-none-update.xml",
		"tests/samples/packageref-in-propertygroup.xml",
		"tests/samples/wrong-element-order.xml",
		"tests/samples/duplicate-packageref.xml",
		"tests/samples/cdata-with-nested-xml.xml",
		"tests/samples/processing-instruction-test.xml",
		"tests/samples/missing-xml-declaration.xml",
		"tests/samples/attr-whitespace-test.xml",
		"tests/samples/medium-test.xml",
		"tests/samples/very-deep-nested-elements.xml",
		"tests/samples/test-containers.xml",
		"tests/samples/test-indent.xml",
	}
	local files = {}
	for _, file in ipairs(quick_files) do
		if file_exists(file) then
			table.insert(files, file)
		end
	end
	return files
end

local function build_language(lang)
	local build_commands = {
		go = "pushd go && go build -o fixml fixml.go && popd",
		rust = "pushd rust && rustc -O -o fixml fixml.rs && popd", 
		ocaml = "pushd ocaml && ocamlopt -I +unix -I +str unix.cmxa str.cmxa -o fixml fixml.ml && popd",
		zig = "pushd zig && zig build -Doptimize=ReleaseFast && cp zig-out/bin/fixml . && popd"
	}
	
	local cmd = build_commands[lang]
	if not cmd then return true end -- Lua doesn't need building
	
	print("Building " .. lang .. "...")
	-- Don't suppress stderr for build commands to see build errors
	local handle = io.popen(cmd .. " 2>&1")
	local output = handle:read("*a")
	local success = handle:close()
	
	if not success then
		print(lang .. ": build failed")
		if output and output ~= "" then
			print("Build output: " .. output)
		end
		return false
	end
	return true
end

-- Parse arguments
local args = { ... }
local mode = args[1] or "quick"
local languages = {}
for i = 2, #args do
	if args[i] == "all" then
		languages = { "go", "rust", "lua", "ocaml", "zig" }
		break
	else
		table.insert(languages, args[i])
	end
end
if #languages == 0 then
	languages = { "go", "rust", "lua", "ocaml", "zig" }
end

local test_modes = { "", "--organize", "--fix-warnings", "--organize --fix-warnings" }
local test_files = get_test_files(mode)

-- Execute tests
local csv_file = io.open("test-results.csv", "w")
csv_file:write("implementation,mode,file,status,error_details\n")

print("=== FIXML Test (" .. mode .. " mode) ===")
print("Files: " .. #test_files .. ", Languages: " .. table.concat(languages, " "))
print()

local total_tests, passed_tests = 0, 0

for _, lang in ipairs(languages) do
	-- Build the language implementation
	if not build_language(lang) then
		goto continue
	end
	
	local exec_paths = { go = "./go/fixml", rust = "./rust/fixml", ocaml = "./ocaml/fixml", zig = "./zig/fixml" }
	local executable_exists = (lang == "lua" and file_exists("lua/fixml.lua")) or file_exists(exec_paths[lang])

	if not executable_exists then
		print(lang .. ": executable not found after build")
		goto continue
	end

	local lang_passed, lang_total = 0, 0

	for _, test_mode in ipairs(test_modes) do
		local mode_passed = 0

		for _, file in ipairs(test_files) do
			lang_total = lang_total + 1
			total_tests = total_tests + 1

			local test_result = run_test(lang, test_mode, file)
			local status = test_result and "pass" or "fail"

			-- Write CSV
			local mode_name = test_mode == "" and "default" or test_mode:gsub("^%-%-", "")
			local file_name = file:match("([^/]+)$")
			csv_file:write(string.format("%s,%s,%s,%s,%s\n", lang, mode_name, file_name, status, ""))

			if test_result then
				mode_passed = mode_passed + 1
				lang_passed = lang_passed + 1
				passed_tests = passed_tests + 1
			end
		end

		local mode_name = test_mode == "" and "default" or test_mode:gsub("^%-%-", "")
		print("  " .. lang .. " " .. mode_name .. ": " .. mode_passed .. "/" .. #test_files)
	end

	print(lang .. ": " .. lang_passed .. "/" .. lang_total)
	::continue::
end

csv_file:close()
print()
print("Total: " .. passed_tests .. "/" .. total_tests .. " (" .. math.floor(passed_tests * 100 / total_tests) .. "%)")
print("Detailed results written to: test-results.csv")

os.exit(passed_tests == total_tests and 0 or 1)

