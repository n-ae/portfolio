#!/bin/sh
# relative_folder="platforms"

d=/
s3_root="translations"

relative_folder="${1}"
s3_folder="${s3_root}${d}${relative_folder}"
source_s3="s3://${s3_folder}"
repo_root=$(git rev-parse --show-toplevel)
local_path="${repo_root}"


while true; do
    printf "Download:\n${source_s3}\nto:\n${local_path}\n"
    read -p "Do you wish to download with this configuration?" yn
    case $yn in
        [Yy]* ) aws s3 sync $source_s3 $local_path --exclude "**/build/*" ; exit;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
