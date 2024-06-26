#!/bin/bash
# Author: Djetic Alexandre
# Date: 04/02/2024
# Modified: 04/02/2024
# Description: this script convert file.ova to file.qcow2

set -e

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <ova_file>"
    exit 1
fi

# Define OVA file
OVA_FILE="$1"

# Extract the base name of the OVA file (without the extension)
BASE_NAME=$(basename -s .ova "$OVA_FILE")

# Define the extraction directory
EXTRACT_DIR="$BASE_NAME"

# Create the extraction directory if it doesn't exist
mkdir -p "$EXTRACT_DIR"

# Extract the contents of the OVA file
tar xvf "$OVA_FILE" -C "$EXTRACT_DIR"

# Identify the VMDK disk file
VMDK_FILE=$(ls "$EXTRACT_DIR"/*.vmdk)

# Convert the VMDK disk file to QCOW2
QCOW2_FILE="$EXTRACT_DIR/$BASE_NAME.qcow2"
qemu-img convert -f vmdk -O qcow2 "$VMDK_FILE" "$QCOW2_FILE"

echo "Conversion completed. QCOW2 file: $QCOW2_FILE"
