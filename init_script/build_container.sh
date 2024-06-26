#!/bin/bash

# Script to build a Docker container

# Check if Dockerfile path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_dockerfile> <image_name>"
    exit 1
fi

# Set the Dockerfile path
DOCKERFILE_PATH=$1

# Check if image name is provided
if [ -z "$2" ]; then
    echo "Usage: $0 <path_to_dockerfile> <image_name>"
    exit 1
fi

# Set the image name
IMAGE_NAME=$2

# Build the Docker container
docker build -t $IMAGE_NAME $DOCKERFILE_PATH

echo "Docker container $IMAGE_NAME built successfully"

