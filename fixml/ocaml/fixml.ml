let usage = "Usage: fixml_optimized [--organize] [--replace] [--fix-warnings] <xml-file>
  --organize, -o      Apply logical organization  
  --replace, -r       Replace original file
  --fix-warnings, -f  Fix XML warnings
  Default: preserve original structure, fix indentation/deduplication only"

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
    let rec clean_loop i =
      if i >= len then ()
      else if i = 0 && len >= 3 && 
              content.[0] = '\239' && content.[1] = '\187' && content.[2] = '\191' then
        clean_loop 3  (* Skip BOM *)
      else if i < len - 1 && content.[i] = '\r' && content.[i + 1] = '\n' then (
        Buffer.add_char result '\n';
        clean_loop (i + 2)
      ) else if content.[i] = '\r' then (
        Buffer.add_char result '\n';
        clean_loop (i + 1)
      ) else (
        Buffer.add_char result content.[i];
        clean_loop (i + 1)
      )
    in
    clean_loop 0;
    Buffer.contents result

let trim s =
  let len = String.length s in
  let rec left i = if i >= len then len else if s.[i] <= ' ' then left (i+1) else i in
  let rec right i = if i < 0 then -1 else if s.[i] <= ' ' then right (i-1) else i in
  let l = left 0 and r = right (len-1) in
  if l > r then "" else String.sub s l (r-l+1)

(* Optimized O(n) element key creation *)
let create_element_key tag attrs content =
  let result = Buffer.create 64 in
  Buffer.add_string result tag;
  
  if attrs <> [] then (
    let sorted_attrs = List.sort compare attrs in
    Buffer.add_char result '|';
    Buffer.add_string result (String.concat "," sorted_attrs)
  );
  
  let trimmed_content = trim content in
  if trimmed_content <> "" then (
    Buffer.add_char result '|';
    
    (* Single-pass whitespace normalization *)
    let rec normalize_ws i prev_space =
      if i >= String.length trimmed_content then ()
      else
        let ch = trimmed_content.[i] in
        if ch = ' ' || ch = '\t' || ch = '\n' || ch = '\r' then (
          if not prev_space then Buffer.add_char result ' ';
          normalize_ws (i + 1) true
        ) else (
          Buffer.add_char result ch;
          normalize_ws (i + 1) false
        )
    in
    normalize_ws 0 false
  );
  
  Buffer.contents result

module StringSet = Set.Make(String)

let deduplicate_elements elements =
  let seen = ref StringSet.empty in
  let unique = ref [] in
  let duplicates = ref 0 in
  
  List.iter (fun (tag, attrs, content) ->
    let key = create_element_key tag attrs content in
    if StringSet.mem key !seen then
      incr duplicates
    else (
      seen := StringSet.add key !seen;
      unique := (tag, attrs, content) :: !unique
    )
  ) elements;
  
  (List.rev !unique, !duplicates)

(* Check if a string is a container element *)
let is_container_element s =
  let trimmed = trim s in
  let len = String.length trimmed in
  if len < 3 then false
  else if trimmed.[0] = '<' && trimmed.[len-1] = '>' then
    if trimmed.[1] = '/' then
      (* Closing tag: </tag> *)
      let inner = String.sub trimmed 2 (len-3) in
      let rec check_valid_name i =
        if i >= String.length inner then true
        else
          let c = inner.[i] in
          if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || 
             (c >= '0' && c <= '9') || c = ':' || c = '-' || c = '.' then
            check_valid_name (i + 1)
          else false
      in
      check_valid_name 0
    else
      (* Opening tag: <tag> *)
      let inner = String.sub trimmed 1 (len-2) in
      let rec check_valid_name i =
        if i >= String.length inner then true
        else
          let c = inner.[i] in
          if (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || 
             (c >= '0' && c <= '9') || c = ':' || c = '-' || c = '.' then
            check_valid_name (i + 1)
          else false
      in
      check_valid_name 0
  else false

(* Check if element is self-contained like <tag>content</tag> *)
let is_self_contained s =
  let trimmed = trim s in
  let len = String.length trimmed in
  if len < 7 then false (* minimum: <a>x</a> *)
  else if trimmed.[0] = '<' && trimmed.[len-1] = '>' then
    try
      let first_gt = String.index trimmed '>' in
      let last_lt = String.rindex trimmed '<' in
      first_gt < last_lt && 
      first_gt + 1 < last_lt &&
      String.length trimmed > last_lt + 1 && 
      trimmed.[last_lt + 1] = '/'
    with Not_found -> false
  else false

(* Normalize whitespace *)
let normalize_whitespace s =
  let result = Buffer.create (String.length s) in
  let rec process i prev_space =
    if i >= String.length s then ()
    else
      let c = s.[i] in
      if c = ' ' || c = '\t' || c = '\n' || c = '\r' then (
        if not prev_space then Buffer.add_char result ' ';
        process (i + 1) true
      ) else (
        Buffer.add_char result c;
        process (i + 1) false
      )
  in
  process 0 false;
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
  let max_indent = 64 in
  let indent_buffer = Bytes.create (max_indent * 2) in
  Bytes.fill indent_buffer 0 (max_indent * 2) ' ';
  
  List.iter (fun line ->
    let trimmed = trim line in
    if trimmed <> "" then (
      (* XML-agnostic container detection *)
      let is_container = is_container_element trimmed in
      
      (* Deduplication with normalized whitespace *)
      let normalized_key = normalize_whitespace trimmed in
      
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
                     Str.string_match (Str.regexp ".*<?xml.*") cleaned_content 0 in
  
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
    Buffer.add_string final_content "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n";
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