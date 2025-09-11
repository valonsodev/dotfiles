#!/bin/bash

rofi -no-lazy-grab -show drun -terminal foot \
-modi filebrowser,drun,window \
-run-shell-command '{terminal} -e fish -ic "{cmd} && read"' \
-theme ~/.config/rofi/launcher/launcher.rasi
