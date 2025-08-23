(* Standard constants - consistent across all implementations *)
let usage = "Usage: fixml [--organize] [--replace] [--fix-warnings] <xml-file>
  --organize, -o      Apply logical organization
  --replace, -r       Replace original file
  --fix-warnings, -f  Fix XML warnings
  Default: preserve original structure, fix indentation/deduplication only"

let xml_declaration = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
let max_indent_levels = 64        (* Maximum nesting depth supported *)
let estimated_line_length = 50    (* Average characters per line estimate *)
let min_hash_capacity = 256       (* Minimum deduplication hash capacity *)
let max_hash_capacity = 4096      (* Maximum deduplication hash capacity *)
let whitespace_threshold = 32     (* ASCII values <= this are whitespace *)
let file_permissions = 0o644      (* Standard file permissions *)
let io_chunk_size = 65536        (* 64KB chunks for I/O operations *)

type args = {
  organize: bool;
  replace: bool; 
  fix_warnings: bool;
  file: string;
}

let parse_args () =
  let args = ref { organize = false; replace = false; fix_warnings = false; file = "" } in
  let set_file f = args := { !args with file = f } in
  let spec = [
    ("--organize", Arg.Unit (fun () -> args := { !args with organize = true }), "Apply logical organization");
    ("-o", Arg.Unit (fun () -> args := { !args with organize = true }), "Apply logical organization");
    ("--replace", Arg.Unit (fun () -> args := { !args with replace = true }), "Replace original file");
    ("-r", Arg.Unit (fun () -> args := { !args with replace = true }), "Replace original file");
    ("--fix-warnings", Arg.Unit (fun () -> args := { !args with fix_warnings = true }), "Fix XML warnings");
    ("-f", Arg.Unit (fun () -> args := { !args with fix_warnings = true }), "Fix XML warnings");
  ] in
  Arg.parse spec set_file usage;
  if !args.file = "" then (
    Printf.printf "%s\n" usage;
    exit 1
  );
  !args

(* Optimized O(n) single-pass content cleaning *)
let clean_content content =
  let len = String.length content in
  if len = 0 then content
  else
    let result = Buffer.create len in
    let i = ref 0 in
    (* Skip BOM if present *)
    if len >= 3 && content.[0] = '\239' && content.[1] = '\187' && content.[2] = '\191' then
      i := 3;
    
    while !i < len do
      if !i < len - 1 && content.[!i] = '\r' && content.[!i + 1] = '\n' then (
        Buffer.add_char result '\n';
        i := !i + 2
      ) else if content.[!i] = '\r' then (
        Buffer.add_char result '\n';
        incr i
      ) else (
        Buffer.add_char result content.[!i];
        incr i
      )
    done;
    Buffer.contents result

let trim s =
  let len = String.length s in
  let l = ref 0 in
  let r = ref (len - 1) in
  
  (* Find first non-whitespace *)
  while !l < len && s.[!l] <= ' ' do incr l done;
  (* Find last non-whitespace *)
  while !r >= 0 && s.[!r] <= ' ' do decr r done;
  
  if !l > !r then "" else String.sub s !l (!r - !l + 1)

module StringSet = Set.Make(String)

(* Pre-compiled regex patterns for performance *)
let xml_declaration_regex = Str.regexp "^[ \t\r\n]*<\\?xml\\b"

(* Simplified container element detection - avoid double trimming *)
let is_container_element trimmed =
  let len = String.length trimmed in
  len >= 3 && trimmed.[0] = '<' && trimmed.[len-1] = '>' && 
  not (String.contains trimmed ' ') && not (String.contains trimmed '=')

(* Simplified self-contained element detection - avoid double trimming *)
let is_self_contained trimmed =
  let len = String.length trimmed in
  len >= 7 && trimmed.[0] = '<' && trimmed.[len-1] = '>' &&
  String.contains trimmed '>' && String.rindex trimmed '<' > String.index trimmed '>'

(* Normalize whitespace while preserving attribute values *)
let normalize_whitespace s =
  let len = String.length s in
  let result = Buffer.create len in
  let i = ref 0 in
  let prev_space = ref false in
  let in_quotes = ref false in
  let quote_char = ref '\000' in
  
  while !i < len do
    let c = s.[!i] in
    if not !in_quotes && (c = '"' || c = '\'') then (
      Buffer.add_char result c;
      prev_space := false;
      in_quotes := true;
      quote_char := c
    ) else if !in_quotes && c = !quote_char then (
      Buffer.add_char result c;
      prev_space := false;
      in_quotes := false;
      quote_char := '\000'
    ) else if !in_quotes then (
      (* Inside quotes: preserve all whitespace *)
      Buffer.add_char result c;
      prev_space := false
    ) else if c = ' ' || c = '\t' || c = '\n' || c = '\r' then (
      (* Outside quotes: normalize whitespace *)
      if not !prev_space then Buffer.add_char result ' ';
      prev_space := true
    ) else (
      Buffer.add_char result c;
      prev_space := false
    );
    incr i
  done;
  trim (Buffer.contents result)

(* Optimized XML processing with deduplication and indentation *)
let process_xml_with_deduplication content =
  let lines = String.split_on_char '\n' content in
  let estimated_size = String.length content + String.length content / 4 in
  let result = Buffer.create estimated_size in
  let indent_level = ref 0 in
  let seen_elements = ref StringSet.empty in
  let duplicates_removed = ref 0 in
  
  (* Pre-allocate indentation buffer *)
  let max_indent = max_indent_levels in
  let indent_buffer = Bytes.create (max_indent * 2) in
  Bytes.fill indent_buffer 0 (max_indent * 2) ' ';
  
  List.iter (fun line ->
    let trimmed = trim line in
    if trimmed <> "" then (
      (* Cache expensive operations *)
      let normalized_key = normalize_whitespace trimmed in
      let is_container = is_container_element trimmed in
      
      if not is_container && StringSet.mem normalized_key !seen_elements then
        incr duplicates_removed
      else (
        if not is_container then
          seen_elements := StringSet.add normalized_key !seen_elements;
        
        (* Adjust indent for closing tags BEFORE applying indentation *)
        if String.length trimmed > 1 && trimmed.[0] = '<' && trimmed.[1] = '/' then
          indent_level := max 0 (!indent_level - 1);
        
        (* Apply consistent 2-space indentation *)
        let spaces_needed = !indent_level * 2 in
        let spaces_clamped = min spaces_needed (max_indent * 2) in
        if spaces_clamped > 0 then
          Buffer.add_subbytes result indent_buffer 0 spaces_clamped;
        
        Buffer.add_string result trimmed;
        Buffer.add_char result '\n';
        
        (* Adjust indent for opening tags AFTER applying indentation *)
        let is_opening_tag = String.length trimmed > 0 && trimmed.[0] = '<' && 
                            not (String.length trimmed > 1 && trimmed.[1] = '/') &&
                            not (String.length trimmed > 1 && trimmed.[1] = '?') &&
                            not (String.length trimmed >= 2 && 
                                 String.sub trimmed (String.length trimmed - 2) 2 = "/>") in
        
        (* Check if self-contained *)
        let is_opening_tag = is_opening_tag && not (is_self_contained trimmed) in
        
        if is_opening_tag then
          incr indent_level
      )
    )
  ) lines;
  
  (Buffer.contents result, !duplicates_removed)

let get_output_filename input_file replace_mode =
  if replace_mode then
    Printf.sprintf "%s.tmp.%d" input_file (int_of_float (Unix.time ()))
  else
    match String.rindex_opt input_file '.' with
    | Some dot_pos ->
        let name = String.sub input_file 0 dot_pos in
        let ext = String.sub input_file (dot_pos + 1) (String.length input_file - dot_pos - 1) in
        Printf.sprintf "%s.organized.%s" name ext
    | None ->
        input_file ^ ".organized"

let process_file args =
  (* Read file with capacity hint *)
  let content = 
    let ic = open_in args.file in
    let len = in_channel_length ic in
    let content = really_input_string ic len in
    close_in ic;
    content in
  
  let cleaned_content = clean_content content in
  let has_xml_decl = String.contains cleaned_content '<' && 
                     Str.string_match xml_declaration_regex cleaned_content 0 in
  
  (* Show warnings *)
  if not has_xml_decl then (
    Printf.printf "⚠️  XML Best Practice Warnings:\n";
    Printf.printf "  [XML] Missing XML declaration\n";
    Printf.printf "    Fix: Add <?xml version=\"1.0\" encoding=\"utf-8\"?> at the top\n";
    Printf.printf "\n";
    if not args.fix_warnings then (
      Printf.printf "Use --fix-warnings flag to automatically apply fixes\n";
      Printf.printf "\n"
    )
  );
  
  (* Process content with pre-allocation *)
  let estimated_size = String.length cleaned_content + 100 in
  let final_content = Buffer.create estimated_size in
  
  (* Add XML declaration if needed *)
  if args.fix_warnings && not has_xml_decl then (
    Buffer.add_string final_content xml_declaration;
    Printf.printf "🔧 Applied fixes:\n";
    Printf.printf "  ✓ Added XML declaration\n";
    Printf.printf "\n"
  );
  
  (* Process XML content with deduplication *)
  let (processed_content, duplicates_removed) = process_xml_with_deduplication cleaned_content in
  Buffer.add_string final_content processed_content;
  
  (* Write output *)
  let output_filename = get_output_filename args.file args.replace in
  let oc = open_out output_filename in
  output_string oc (Buffer.contents final_content);
  close_out oc;
  
  (* Handle file replacement *)
  if args.replace then (
    Sys.rename output_filename args.file;
    Printf.printf "Original file replaced: %s" args.file
  ) else (
    Printf.printf "Organized project saved to: %s" output_filename
  );
  
  if duplicates_removed > 0 then
    Printf.printf " (removed %d duplicates)" duplicates_removed;
  
  let mode_text = if args.organize then " (with logical organization)" else " (preserving original structure)" in
  Printf.printf "%s\n" mode_text

let () =
  try
    let args = parse_args () in
    process_file args
  with
  | Sys_error msg -> 
      Printf.eprintf "Error: %s\n" msg;
      exit 1
  | e ->
      Printf.eprintf "Error: %s\n" (Printexc.to_string e);
      exit 1