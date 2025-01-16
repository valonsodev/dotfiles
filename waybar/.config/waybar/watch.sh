#!/bin/bash

# Define the files to monitor
FILE1="~/.config/waybar/config.jsonc"
FILE2="~/.config/waybar/style.css"

# Define the command to run on file change

# Use inotifywait to monitor file changes
inotifywait -m -e modify "$FILE1" "$FILE2" | while read -r filename; do
    echo "Change detected in $filename"
    # Run the command
    killall -SIGUSR2 waybar
    sleep 0.1
done
