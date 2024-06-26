#!/bin/bash
# Author: chatgpt
# Date: 19/03/2024
# Modified: 19/03/2024
# Description: Script to delete tap interface using ip command

# Function to display help menu
function display_help {
    echo "Usage: $0 -int tapX"
    echo "Options:"
    echo "  -int tapX        Specify the interface name to delete"
}

# Check if script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Function to check if interface exists
function interface_exists {
    local int="$1"
    ip link show "$int" >/dev/null 2>&1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
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

# Check if required argument is provided
if [[ -z "$INT" ]]; then
    echo "Error: Missing interface name."
    display_help
    exit 1
fi

# Check if the interface exists before attempting to delete
if interface_exists "$INT"; then
    # Delete the tap interface
    ip link delete "$INT" type dummy
    echo "Tap interface $INT deleted."
else
    echo "Error: Interface $INT does not exist."
fi

