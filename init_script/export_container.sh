#!/bin/bash

# Script to export a Docker container

# Check if container name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <container_name>"
    exit 1
fi

# Set the container name
CONTAINER_NAME=$1

# Set the export file name
EXPORT_FILE="${CONTAINER_NAME}_export.tar"

# Export the Docker container
docker export -o $EXPORT_FILE $CONTAINER_NAME

echo "Container $CONTAINER_NAME exported to $EXPORT_FILE"

