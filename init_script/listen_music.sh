#!/bin/bash

default_dir=~/music/youtube/
dir=${1:-$default_dir}

if [ -e "$dir" ]; then
  mpv --loop=inf --geometry=300x400 --playlist="$dir"
else
  echo "Specified directory: $dir does not exist"
  exit 1
fi

