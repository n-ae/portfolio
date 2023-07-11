#!/bin/sh
# relative_folder="stg/platforms/{platform}"
relative_folder="${1}"
s3_root="translations"
d=/
s3_folder="${s3_root}${d}${relative_folder}"
source_s3="s3://${s3_folder}"
repo_root=$(git rev-parse --show-toplevel)

local_path="${repo_root}${d}${relative_folder}"

upload() {
    # if wanna delete first
    # aws s3 rm $source_s3 --recursive
    aws s3 cp $local_path $source_s3 \
        --acl public-read \
        --recursive \
        --exclude "*.DS_Store" \
        --exclude ".git/*" \
        --exclude "**/build/*"
}


while true; do
    printf "Overwrite:\n${source_s3}\nwith:\n${local_path}\n"
    read -p "Do you wish to upload with this configuration?" yn
    case $yn in
        [Yy]* ) upload; exit;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done


# backup
# cur_date=$(date +'%Y%m%d')
# dest_folder="${source_s3}_${cur_date}${d}"
# aws s3 cp $source_s3$d $dest_folder --recursive
# aws s3 rm $source_s3 --recursive
