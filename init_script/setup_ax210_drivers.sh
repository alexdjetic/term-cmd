#!/bin/sh
# Author: Djetic Alexandre
# Date: 22/01/2024
# Modified: 22/01/2024
# Description: This script will set up the ax210 driver on any Linux system

if [ "$(id -u)" -ne 0 ]; then
    echo "Require sudo/root access"
    exit 1
fi

options="iwlmvm power_scheme=1 power_disable=1"
file="/etc/modprobe.d/iwlmvm_power.conf"

echo "Adding options: $options to $file"

if [ -e "$file" ]; then
    echo "Appending to existing file"
    echo "options $options" | sudo tee -a $file
else
    echo "Creating a new file"
    echo "options $options" | sudo tee $file
fi

