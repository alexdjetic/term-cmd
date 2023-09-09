#!/bin/sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 <path/to/file.iso> </dev/sdb,/dev/sdc,...> [blockSize]"
    exit 1
fi

restoreFile="$1"
volume="$2"
blockSize="${3:-4M}"

sudo dd if="$restoreFile" of="$volume" bs="$blockSize" status=progress

