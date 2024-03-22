grep -o '<a href="[^"]*' file.html | awk -F '"' '{print "https://leetcode.com"$2}' > links.txt
