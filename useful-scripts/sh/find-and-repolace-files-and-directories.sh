# Find and rename directories
find . -depth -type d -name '*Depot*' | while IFS= read -r dir; do
  mv "$dir" "$(dirname "$dir")/$(basename "$dir" | sed 's/Depot/Facility/g')"
done

# Find and rename files
find . -type f -name '*Depot*' | while IFS= read -r file; do
  mv "$file" "$(dirname "$file")/$(basename "$file" | sed 's/Depot/Facility/g')"
done
