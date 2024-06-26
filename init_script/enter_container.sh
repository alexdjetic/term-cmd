#!/bin/bash

# Script to enter a running Docker container

# Check if container name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <container_name>"
    exit 1
fi

# Set the container name
CONTAINER_NAME=$1

# Enter the Docker container
docker exec -it $CONTAINER_NAME /bin/bash

