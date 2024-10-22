find . -path './.git' -prune -o -type f -exec sh -c 'LC_CTYPE=C sed -i "" "s/\xEF\xBB\xBF//g" "$0"' {} \;
