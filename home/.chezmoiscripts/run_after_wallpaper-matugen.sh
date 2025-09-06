#!/usr/bin/env bash

# Runs after `chezmoi apply` to regenerate theme colors from the current wallpaper
# Expects a file named ~/.config/theming/wallpaper.<ext>
# Acceptable extensions: png jpg jpeg webp bmp gif

set -euo pipefail

if ! command -v matugen >/dev/null 2>&1; then
  echo "[matugen-wallpaper] matugen not found in PATH, skipping." >&2
  exit 0
fi

wallpaper_base="$HOME/.config/theming/wallpaper"

# Find first matching wallpaper with an allowed extension
wallpaper_file=""
for ext in png jpg jpeg webp bmp gif; do
  f="${wallpaper_base}.${ext}"
  if [ -f "$f" ]; then
    wallpaper_file="$f"
    break
  fi
done

if [ -z "$wallpaper_file" ]; then
  echo "[matugen-wallpaper] No wallpaper file found (expected ${wallpaper_base}.<png|jpg|...>). Skipping."
  exit 0
fi

echo "[matugen-wallpaper] Generating theme from: $wallpaper_file"
matugen image "$wallpaper_file"

echo "[matugen-wallpaper] Done."