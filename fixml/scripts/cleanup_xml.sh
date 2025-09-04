#!/bin/bash

# This script cleans up unnecessary whitespace in XML files using 'fd' and 'perl'.
# It intelligently ignores XML comments.
#
# It performs two main operations:
#  1. Removes whitespace immediately following an opening tag bracket (e.g., '<  tag>' becomes '<tag>').
#  2. Removes whitespace immediately preceding a closing tag bracket (e.g., '<tag  >' becomes '<tag>').

echo "Starting XML whitespace cleanup (comment-aware)" 

# Use fd to find all .xml files and execute the perl command on each one.
fd --extension f.expected.xml \
   --type f \
   --hidden \
   --exclude .claude \
   --exclude .git \
   --exec perl -i -0777 -pe 's{(<!--.*?-->)|<([[:space:]]+)|([[:space:]]+)(/?>)|([[:space:]]+=[[:space:]]+)}{ if (defined $1) { $1 } elsif (defined $2) { "<" } elsif (defined $3) { $4 } else { "=" } }gex' {}

echo "Cleanup complete."


   # --exec perl -i -0777 -pe 's{(<!--.*?-->)|<([[:space:]]+)|([[:space:]]+)(/?>)}{ if (defined $1) { $1 } elsif (defined $2) { "<" } else { $4 } }gex' {} 
