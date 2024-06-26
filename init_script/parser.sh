#!/bin/sh

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dir)
            shift
            custom_dir="$1"
            ;;
        -f|--file)
            shift
            custom_name="$1"
            ;;
        --audio)
            audio_only=true
            ;;
        --video)
            video_only=true
            ;;
        -p|--open)
            open_now=true
            ;;
        *)
            video_url="$1"
            ;;
    esac
    shift
done
