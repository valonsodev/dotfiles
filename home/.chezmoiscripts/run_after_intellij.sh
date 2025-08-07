#!/bin/sh

set -e

SRC="$HOME/.config/jetbrains/intellij"
DST_BASE="$HOME/.config/JetBrains"

# Check if source exists
if [ -d "$SRC" ] && [ -d "$DST_BASE" ]; then
    for dir in "$DST_BASE"/IntelliJ*/; do
        if [ -d "$dir" ]; then
            cp -r "$SRC/." "$dir"
        fi
    done
fi

echo "Done copying IntelliJ config"