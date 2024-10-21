find . -type f -exec sh -c 'LC_CTYPE=C sed -i "" "s/Facilitys/Facilities/g" "$0"' {} \;
