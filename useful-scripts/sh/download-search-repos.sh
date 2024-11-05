#!/bin/sh

owner="freight-hub"
gh repo list ${owner} --no-archived --limit 4000 | while read -r repo _; do
  gh repo clone "$repo" "$repo"
done

string1="transport-network.api"
string2="depots"

# list the files involving the strings
rg -l ${string1} > results1.txt
rg -l ${string2} > results2.txt

# extract prefix (i.e repo name) and write it to different file
awk -F'/' '{print $1}' results1.txt | sort | uniq > repos1.txt
awk -F'/' '{print $1}' results2.txt | sort | uniq > repos2.txt

# list common ones
comm -12 repos1.txt repos2.txt
