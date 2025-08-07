#!/bin/sh

set -e

SRC="$HOME/.config/jetbrains/android-studio"
DST_BASE="$HOME/.config/Google"

# Check if source exists
if [ -d "$SRC" ] && [ -d "$DST_BASE" ]; then
    for dir in "$DST_BASE"/*/; do
        if [ -d "$dir" ]; then
            cp -r "$SRC/." "$dir"
        fi
    done
fi

echo "Done copying android-studio config"