#!/bin/bash

# Define the directory containing the images
IMAGE_DIR="~/.config/theming/bgs"

# Define the output file
OUTPUT_FILE="~/.config/theming/current.png"

# Select a random image
RANDOM_IMAGE=$(find "$IMAGE_DIR" -type f | shuf -n 1)

# Copy the selected image to the output file location
cp "$RANDOM_IMAGE" "$OUTPUT_FILE"
