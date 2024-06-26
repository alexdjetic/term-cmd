#!/bin/bash
# Author: chatgpt
# Date: 19/03/2024
# Modified: 19/03/2024
# Description: Script to create tap0 interface using nmcli

# Check if script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Check if NetworkManager is installed
if ! command -v nmcli &> /dev/null; then
    echo "NetworkManager (nmcli) is not installed. Please install NetworkManager to use this script."
    exit 1
fi

# Create the tap0 interface
nmcli connection add type tun ifname tap0 mode tap

# Bring up the tap0 interface
nmcli connection up tun-tap0

# Assign IP address to the tap0 interface
nmcli connection modify tun-tap0 ipv4.method manual ipv4.addresses 192.168.60.1/24

echo "tap0 interface created and configured with IP address 192.168.60.1/24."

