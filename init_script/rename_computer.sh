#!/bin/bash
# Author: Djetic Alexandre
# Date: 22/01/2024
# Modified: 22/01/024
# Description: this script will change the hostname a pc

if [ ! $EUID -eq 0 ]; then
	echo "require sudo/root access"
	exit 1
fi

if [ $# -ne 1 ]; then
	echo "Usage: $0 <name>"
	exit 1
fi

name="$1"

echo "changing computer name: $(hostname) to $name"
echo $name > /etc/hostname
hostname -F /etc/hostname
