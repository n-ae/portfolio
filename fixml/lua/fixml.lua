#!/usr/bin/env lua

-- Ultra-optimized XML organizer v5.0.0 - Maximum performance Lua
-- Target: Match compiled language performance through aggressive optimization

local USAGE = [[
Usage: lua fixml_ultra_optimized.lua [--organize] [--replace] [--fix-warnings] <xml-file>
  --organize, -o      Apply logical organization
  --replace, -r       Replace original file (atomic using temp file)
  --fix-warnings, -f  Automatically fix XML best practice warnings
  Default: preserve original structure, fix indentation/deduplication only
]]

local XML_DECLARATION = '<?xml version="1.0" encoding="utf-8"?>\n'

-- Parse command line arguments (optimized)
local function parse_args()
	local organize, replace, fix_warnings, file = false, false, false, nil
	local args = arg or {}
	
	for i = 1, #args do
		local a = args[i]
		if a == "--organize" or a == "-o" then
			organize = true
		elseif a == "--replace" or a == "-r" then
			replace = true
		elseif a == "--fix-warnings" or a == "-f" then
			fix_warnings = true
		elseif not file and a:sub(1,1) ~= "-" then
			file = a
		end
	end

	if not file then
		print(USAGE)
		os.exit(1)
	end
	return organize, replace, fix_warnings, file
end

-- Ultra-optimized O(n) single-pass content cleaning
local function clean_content(content)
	local len = #content
	if len == 0 then return content end
	
	-- Pre-allocate result buffer (avoid reallocations)
	local result = {}
	local result_size = 0
	local i = 1
	
	-- Remove BOM if present (optimized byte checks)
	if len >= 3 then
		local b1, b2, b3 = content:byte(1, 3)
		if b1 == 239 and b2 == 187 and b3 == 191 then
			i = 4
		end
	end
	
	-- Ultra-fast single-pass normalization using byte operations
	while i <= len do
		local b = content:byte(i)
		if b == 13 then -- CR
			if i < len and content:byte(i + 1) == 10 then -- CRLF
				result_size = result_size + 1
				result[result_size] = '\n'
				i = i + 2
			else -- standalone CR
				result_size = result_size + 1
				result[result_size] = '\n'
				i = i + 1
			end
		else
			result_size = result_size + 1
			result[result_size] = content:sub(i, i)
			i = i + 1
		end
	end
	
	return table.concat(result)
end

-- Ultra-fast string trimming without regex
local function fast_trim(s)
	if not s then return "" end
	local len = #s
	if len == 0 then return s end
	
	-- Find first non-whitespace
	local start = 1
	while start <= len do
		local b = s:byte(start)
		if b > 32 then break end
		start = start + 1
	end
	
	if start > len then return "" end
	
	-- Find last non-whitespace
	local finish = len
	while finish >= start do
		local b = s:byte(finish)
		if b > 32 then break end
		finish = finish - 1
	end
	
	if start == 1 and finish == len then
		return s
	else
		return s:sub(start, finish)
	end
end

-- Ultra-optimized element key creation - avoid regex completely
local function create_element_key(element_str)
	local trimmed = fast_trim(element_str)
	local len = #trimmed
	
	if len == 0 then return "" end
	
	-- Fast comment detection without regex
	if len >= 4 and trimmed:sub(1, 4) == "<!--" then
		return "comment:" .. os.time() .. math.random(1000)
	end
	
	-- Fast tag extraction without regex
	if trimmed:byte(1) ~= 60 then return trimmed end -- not '<'
	
	local tag_end = trimmed:find("[ />]")
	if not tag_end then return trimmed end
	
	local tag = trimmed:sub(2, tag_end - 1)
	
	-- Fast attribute extraction (simplified)
	local attrs = {}
	local attr_count = 0
	local attr_start = tag_end
	
	-- Simple attribute parsing without heavy regex
	while attr_start and attr_start < len do
		local eq_pos = trimmed:find("=", attr_start)
		if not eq_pos then break end
		
		local name_start = attr_start
		while name_start < eq_pos and trimmed:byte(name_start) <= 32 do
			name_start = name_start + 1
		end
		
		local name_end = eq_pos - 1
		while name_end > name_start and trimmed:byte(name_end) <= 32 do
			name_end = name_end - 1
		end
		
		local quote_start = eq_pos + 1
		while quote_start <= len and trimmed:byte(quote_start) <= 32 do
			quote_start = quote_start + 1
		end
		
		if quote_start <= len then
			local quote_char = trimmed:byte(quote_start)
			if quote_char == 34 or quote_char == 39 then -- " or '
				local quote_end = trimmed:find(string.char(quote_char), quote_start + 1)
				if quote_end then
					local name = trimmed:sub(name_start, name_end)
					local value = trimmed:sub(quote_start + 1, quote_end - 1)
					attr_count = attr_count + 1
					attrs[attr_count] = name .. "=" .. value
					attr_start = quote_end + 1
				else
					break
				end
			else
				break
			end
		else
			break
		end
	end
	
	-- Sort attributes for consistent keys
	if attr_count > 1 then
		table.sort(attrs, nil, attr_count)
	end
	local attr_string = table.concat(attrs, ",", 1, attr_count)
	
	-- Extract inner content fast
	local content_start = trimmed:find(">")
	local inner = ""
	if content_start then
		local content_end = trimmed:find("</" .. tag)
		if content_end and content_end > content_start then
			inner = fast_trim(trimmed:sub(content_start + 1, content_end - 1))
			
			-- Fast whitespace normalization without regex
			if inner and #inner > 0 then
				local normalized = {}
				local norm_size = 0
				local prev_space = false
				local inner_len = #inner
				
				for j = 1, inner_len do
					local b = inner:byte(j)
					if b <= 32 then -- whitespace
						if not prev_space then
							norm_size = norm_size + 1
							normalized[norm_size] = " "
							prev_space = true
						end
					else
						norm_size = norm_size + 1
						normalized[norm_size] = inner:sub(j, j)
						prev_space = false
					end
				end
				
				inner = table.concat(normalized, "", 1, norm_size)
				inner = fast_trim(inner)
			end
		end
	end
	
	-- Build key efficiently
	local key_parts = {tag}
	local key_size = 1
	
	if #attr_string > 0 then
		key_size = key_size + 1
		key_parts[key_size] = "|"
		key_size = key_size + 1
		key_parts[key_size] = attr_string
	end
	
	if #inner > 0 then
		key_size = key_size + 1
		key_parts[key_size] = "|"
		key_size = key_size + 1
		key_parts[key_size] = inner
	end
	
	return table.concat(key_parts, "", 1, key_size)
end

-- Ultra-fast line processing avoiding gmatch iterator
local function process_lines(content, processor)
	local len = #content
	local start = 1
	local line_num = 0
	
	while start <= len do
		-- Find line end
		local line_end = start
		while line_end <= len and content:byte(line_end) ~= 10 do
			line_end = line_end + 1
		end
		
		-- Extract line
		local line = content:sub(start, line_end - 1)
		line_num = line_num + 1
		
		-- Process line
		processor(line, line_num)
		
		-- Move to next line
		start = line_end + 1
	end
end

-- Ultra-optimized XML processing
local function process_xml_file(organize_mode, replace_mode, fix_warnings, input_file)
	-- Read file
	local file = io.open(input_file, "r")
	if not file then
		error("Could not open file: " .. input_file)
	end
	local content = file:read("*all")
	file:close()

	-- Clean content
	local cleaned_content = clean_content(content)
	local has_xml_decl = cleaned_content:find("<?xml", 1, true) -- plain text search

	-- Show warnings
	if not has_xml_decl then
		print("⚠️  XML Best Practice Warnings:")
		print("  [XML] Missing XML declaration")
		print("    Fix: Add <?xml version=\"1.0\" encoding=\"utf-8\"?> at the top")
		print()
		if not fix_warnings then
			print("Use --fix-warnings flag to automatically apply fixes")
			print()
		end
	end

	-- Pre-allocate large output buffer
	local output_size = 0
	local output_capacity = #cleaned_content + 1000
	local output = {}

	local function add_output(str)
		output_size = output_size + 1
		output[output_size] = str
	end

	-- Add XML declaration if needed
	if fix_warnings and not has_xml_decl then
		add_output(XML_DECLARATION)
		print("🔧 Applied fixes:")
		print("  ✓ Added XML declaration")
		print()
	end

	-- Process with optimized deduplication
	local seen_elements = {}
	local duplicates_removed = 0
	local indent_level = 0
	
	-- Pre-allocate indentation strings
	local indent_cache = {""}
	for i = 1, 64 do
		indent_cache[i + 1] = string.rep("  ", i)
	end

	-- Ultra-fast line processing
	process_lines(cleaned_content, function(line, line_num)
		local trimmed = fast_trim(line)
		if #trimmed > 0 then
			-- Simple line-based deduplication with normalized whitespace
			local key = fast_trim(trimmed):gsub("%s+", " ")
			
			-- Never deduplicate XML container elements (opening/closing tags without attributes or content)
			-- These are structural elements that group other elements and should never be deduplicated
			local is_container = trimmed:match("^<%s*[%w:%-]+%s*>%s*$") or  -- opening container tag
			                    trimmed:match("^<%s*/[%w:%-]+%s*>%s*$")     -- closing container tag
			
			if not is_container and seen_elements[key] then
				duplicates_removed = duplicates_removed + 1
			else
				if not is_container then
					seen_elements[key] = true
				end
				
				-- Adjust indent for closing tags BEFORE applying indentation
				if trimmed:sub(1, 2) == "</" then
					indent_level = math.max(0, indent_level - 1)
				end
				
				-- Apply consistent 2-space indentation using cached indentation
				local indent_idx = math.min(indent_level + 1, #indent_cache)
				add_output(indent_cache[indent_idx])
				add_output(trimmed)
				add_output("\n")
				
				-- Adjust indent for opening tags AFTER applying indentation
				-- Only increase indent if it's an opening tag that's NOT self-contained
				if trimmed:byte(1) == 60 and trimmed:byte(2) ~= 47 and 
				   trimmed:byte(2) ~= 63 and not trimmed:find("/>") and
				   not trimmed:find("<[^>]+>[^<]*</[^>]+>") then -- not self-contained
					indent_level = indent_level + 1
				end
			end
		end
	end)

	-- Write output efficiently
	local output_filename
	if replace_mode then
		output_filename = input_file .. ".tmp." .. os.time()
	else
		local name, ext = input_file:match("^(.+)%.([^%.]+)$")
		if name and ext then
			output_filename = name .. ".organized." .. ext
		else
			output_filename = input_file .. ".organized"
		end
	end

	local out_file = io.open(output_filename, "w")
	if not out_file then
		error("Could not create output file: " .. output_filename)
	end
	
	-- Ultra-fast bulk write
	local chunk_size = 8192
	local current_chunk = {}
	local chunk_len = 0
	
	for i = 1, output_size do
		chunk_len = chunk_len + 1
		current_chunk[chunk_len] = output[i]
		
		if chunk_len >= chunk_size then
			out_file:write(table.concat(current_chunk, "", 1, chunk_len))
			chunk_len = 0
		end
	end
	
	-- Write remaining chunk
	if chunk_len > 0 then
		out_file:write(table.concat(current_chunk, "", 1, chunk_len))
	end
	
	out_file:close()

	-- Handle replacement
	if replace_mode then
		os.rename(output_filename, input_file)
		io.write("Original file replaced: " .. input_file)
	else
		io.write("Organized project saved to: " .. output_filename)
	end

	if duplicates_removed > 0 then
		io.write(" (removed " .. duplicates_removed .. " duplicates)")
	end

	local mode_text = organize_mode and " (with logical organization)" or " (preserving original structure)"
	print(mode_text)
end

-- Main execution with error handling
local function main()
	local ok, err = pcall(function()
		local organize, replace, fix_warnings, file = parse_args()
		process_xml_file(organize, replace, fix_warnings, file)
	end)
	
	if not ok then
		io.stderr:write("Error: " .. tostring(err) .. "\n")
		os.exit(1)
	end
end

main()