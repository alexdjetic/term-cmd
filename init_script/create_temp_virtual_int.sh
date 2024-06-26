#!/bin/bash
# Author: chatgpt
# Date: 19/03/2024
# Modified: 19/03/2024
# Description: Script to create and configure tap interface using ip command

# Function to display help menu
function display_help {
    echo "Usage: $0 -net x.x.x.x/y -int tapX"
    echo "Options:"
    echo "  -net x.x.x.x/y   Specify the network subnet in CIDR notation"
    echo "  -int tapX        Specify the interface name"
}

# Function to validate CIDR notation
function validate_cidr {
    local cidr="$1"
    if [[ ! "$cidr" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        echo "Error: Invalid CIDR notation: $cidr"
        exit 1
    fi
}

# Check if script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -net)
        NET="$2"
        validate_cidr "$NET"
        shift # past argument
        shift # past value
        ;;
        -int)
        INT="$2"
        shift # past argument
        shift # past value
        ;;
        -h|--help)
        display_help
        exit 0
        ;;
        *)    # unknown option
        echo "Unknown option: $1"
        display_help
        exit 1
        ;;
    esac
done

# Check if required arguments are provided
if [[ -z "$NET" || -z "$INT" ]]; then
    echo "Error: Missing arguments."
    display_help
    exit 1
fi

# Create the tap interface
ip tuntap add "$INT" mode tap

# Assign IP address to the tap interface
ip addr add "$NET" dev "$INT"

# Bring up the tap interface
ip link set dev "$INT" up

echo "tap interface $INT created and brought up with IP address $NET."

