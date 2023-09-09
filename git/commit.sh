#!/bin/bash

# Add all changes to the staging area
git add .

# Commit the changes with the provided commit message
if [ -n "$1" ]; then
  git commit -m "$1"
else
  echo "Please provide a commit message."
  exit 1
fi

# Push the changes to the remote repository (optional)
git push origin main
