#!/bin/bash
# Author: Djetic Alexandre
# Date: 22/01/2024
# Modified: 22/01/2024
# Description: This script will search for files using content

if [ $# -lt 1 ]; then
  echo "Usage: $0 <pattern> <dir>"
  exit 1
fi

# Color properties
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Search properties
dir="$2"
pattern="$1"

# Terminal properties
lines=$(tput lines)
columns=$(tput cols)

# This function finds all occurrences of a pattern in a file
explore_and_find() {
  local file="$1"
  local pattern="$2"

  grep "$pattern" "$file" >> /dev/null

  if [ $? -eq 0 ]; then
    echo -e "- ${GREEN}found!${NC} ${BLUE}$file${NC}"
  fi
}

#this fucntion show the info about search patren and directory
general_info() {
  printf '%*s\n' "${columns:-$(tput cols)}" '' | tr ' ' -
  echo -e "result for ${BLUE}$2${NC} in ${BLUE}$1${NC}: "
  printf '%*s\n' "${columns:-$(tput cols)}" '' | tr ' ' -
}

# This function is the main loop
main() {
  local directory="$1"
  local pattern="$2"

  find "$directory" -type f -print | while IFS= read -r file; do
    explore_and_find "$file" "$pattern"
  done
}

# Check if the directory is empty
if [ "$dir" == "" ]; then
  general_info $PWD "$pattern"
  main $PWD "$pattern"
elif [ -d "$dir" ]; then
  general_info "$dir" "$pattern"
  main "$dir" "$pattern"
else
  echo "Error: Directory '$dir' does not exist."
  exit 1
fi
