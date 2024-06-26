#!/bin/bash

default_dir=~/music/youtube
video_url=""
custom_dir=""
custom_name=""
audio_only=false
video_only=false
open_now=false

source parser.sh
source lib_music.sh

help() {
    echo "Usage: $0 <YouTube Video URL> [options]"
    echo "Options:"
    echo "  -d, --dir       Specify custom directory for downloads"
    echo "  --audio         Download only audio"
    echo "  --video         Download only video"
    echo "  -p, --open      Open the downloaded file using mpv"
}

### Main script

if [ -z "$video_url" ]; then
    help 
    exit 1
fi

check_ytdlp

download_dir="${custom_dir:-$default_dir}"

if [ ! -e "$download_dir" ]; then
    mkdir -p "$download_dir"
fi

cd "$download_dir" || exit 1
download_video

if [ -n "$custom_name" ]; then
    video_title=$(yt-dlp --get-title "$video_url")
    sanitized_title=$(echo "$video_title" | tr ' ' '_')
    new_name="$custom_name"
    rename_file "$sanitized_title" "$new_name"
fi

echo "Download and (optional) rename completed."

if [ $open_now ]; then
  mpv "$download_dir/$new_name"
fi
