grep -o 'href="[^"]*"' input.html | sed 's/href="//; s/"$//' | sed 's|/\?hl=tr$||' | sort -u | sed 's|^|https://www.instagram.com|'
