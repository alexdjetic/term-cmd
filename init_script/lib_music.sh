#!/bin/sh

# Function to check if yt-dlp is installed
check_ytdlp() {
    if ! command -v yt-dlp &> /dev/null; then
        echo "yt-dlp is not installed. Please install it first."
        exit 1
    fi
}

# Function to download the video
download_video() {
    local video_identifier="$1"
    local audio_only="$2"
    #local video_url="https://www.youtube.com/watch?v=$video_identifier"
    local filename=$(yt-dlp --audio-format best --get-filename -o "%(title)s.%(ext)s" "$video_url")

    if [ -z "$filename" ]; then
        echo "Error: Invalid video identifier or unable to get video information. Check if the identifier is correct."
        exit 1
    fi

    echo "Downloading video..."
    yt-dlp --audio-format best "$video_url" -o "$filename"
}


# Function to rename the downloaded file
rename_file() {
    local old_name="$1"
    local new_name="$2"

    # Ensure the old name has the correct extension
    local old_name_with_ext="$old_name".*

    if [ -e "$old_name_with_ext" ]; then
        mv "$old_name_with_ext" "$new_name".*
        echo "File renamed to: $new_name"
    else
        echo "Error: Downloaded file not found."
    fi
}

