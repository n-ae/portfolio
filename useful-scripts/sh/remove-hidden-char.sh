#!/usr/bin/env bash

# ##############################################################################
#
# A script to recursively find and remove the UTF-8 Byte Order Mark (BOM)
# from all files within a specified directory.
#
# The UTF-8 BOM is a sequence of three bytes (EF BB BF) that is sometimes
# added to the beginning of a text file to signal its encoding. This updated
# script uses a robust byte-level check to ensure reliability.
#
# USAGE:
#   ./remove_bom.sh /path/to/your/directory
#
# Make the script executable first:
#   chmod +x remove_bom.sh
#
# ##############################################################################

# --- Configuration ---

# Set the target directory from the first command-line argument.
# If no argument is provided, default to the current directory (".").
TARGET_DIR="${1:-.}"

# --- Validation ---

# Check if the target directory exists. If not, print an error and exit.
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' not found."
  exit 1
fi

echo "Scanning for files with UTF-8 BOM in '$TARGET_DIR'..."

# --- Main Logic ---

# Use `find` to locate all files and pipe them to a `while` loop.
# Using -print0 and read -d $'\0' makes this safe for filenames
# containing spaces or special characters.
find "$TARGET_DIR" -type f -print0 | while IFS= read -r -d $'\0' file; do
  # Read the first 3 bytes of the file to check for the BOM.
  # This is more reliable than using grep/sed for binary sequences.
  BOM=$(head -c 3 "$file")

  # Check if the bytes match the UTF-8 BOM sequence.
  if [[ "$BOM" == $'\xef\xbb\xbf' ]]; then
    echo "Removing BOM from: $file"
    # Use `tail` to output the file starting from the 4th byte,
    # effectively skipping the 3-byte BOM.
    # A temporary file is used for a safe in-place edit.
    tail -c +4 "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  fi
done

echo "BOM removal process completed."
