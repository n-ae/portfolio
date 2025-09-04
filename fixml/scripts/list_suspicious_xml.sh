#!/bin/sh

fd --type f -e expected.xml --exec-batch sh -c '
   for file in "$@"; do
       last_line=$(tail -n 1 "$file")
       if [ -n "$last_line" ] && echo "$last_line" | rg -q "^[[:space:]]"; then
           echo "$file"
       fi
   done' _ {} > suspicious_samples.txt


# rg '[[:space:]]+/?>' --glob '**/*.f.expected.xml'
