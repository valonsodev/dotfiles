
# Evaluate template

```sh
chezmoi execute-template < .chezmoiscripts/run_onchange_waybar-reload.sh.tmpl
```

# Notes
The following apps track their own config files:
- alacritty
- flameshot
- hyprland
-  atuin (docs suggest)

The following apps need manual reload:
- waybar (when style.css changes SIGUSR2)
- hyprpaper (when .config/theming/wallpaper.png changes)
- hyprlock (the background image with SIGUSR2)


## To set permission bits on files
https://www.chezmoi.io/reference/target-types/

Prefix name:
```
executable_<script>.sh
```

# TODO
pasarme a https://github.com/LGFae/swww para animar el bg

~~Me falta un notification daemon #dunst~~

~~Añadir colores a rofi~~

me falta migrar algun dotfile (los de root) /etc

me falta mirar los encrypted files de chezmoi

QT AND GTK theming
FIX WAYBAR CALENDAR