You are an AI assistant helping manage a dotfiles repository. This repository uses Chezmoi (https://www.chezmoi.io/) to manage configuration files across different machines.

Key characteristics of this codebase:

1. **Dotfiles Repository:** Contains personal configuration files (dotfiles) for various applications (like alacritty, hyprland, git, etc.).
2. **Chezmoi:** The primary tool used for managing these dotfiles. Files are stored in a source directory structure that mirrors the target `$HOME` directory.
3. **Go Templating:** Some configuration files use Go's `text/template` syntax (often with a `.tmpl` extension, like [home/dot_config/alacritty/alacritty.toml.tmpl](home/dot_config/alacritty/alacritty.toml.tmpl) or [home/dot_gitconfig.tmpl](home/dot_gitconfig.tmpl)). These templates allow for dynamic configuration generation based on variables or functions provided by Chezmoi.
4. **Material Design Theming:** The visual theme is based on Material Design color roles. The core theme definition is located in [home/dot_config/theming/theme.json](home/dot_config/theming/theme.json). Other configuration files (like [home/dot_config/hypr/material.conf](home/dot_config/hypr/material.conf), [home/dot_config/alacritty/alacritty.toml.tmpl](home/dot_config/alacritty/alacritty.toml.tmpl), [home/dot_config/flameshot/flameshot.ini](home/dot_config/flameshot/flameshot.ini)) consume these theme values, often via Chezmoi's templating.

Here is the content of the Material theme definition file ([home/dot_config/theming/theme.json](home/dot_config/theming/theme.json)):

```json
{
  "primary": "#FFB4A8",
  "surface_tint": "#FFB4A8",
  "on_primary": "#561E16",
  "primary_container": "#73342A",
  "on_primary_container": "#FFDAD4",
  "secondary": "#E7BDB6",
  "on_secondary": "#442925",
  "secondary_container": "#5D3F3B",
  "on_secondary_container": "#FFDAD4",
  "tertiary": "#DEC48C",
  "on_tertiary": "#3E2E04",
  "tertiary_container": "#564419",
  "on_tertiary_container": "#FBDFA6",
  "error": "#FFB4AB",
  "on_error": "#690005",
  "error_container": "#93000A",
  "on_error_container": "#FFDAD6",
  "background": "#1A1110",
  "on_background": "#F1DFDC",
  "surface": "#1A1110",
  "on_surface": "#F1DFDC",
  "surface_variant": "#534341",
  "on_surface_variant": "#D8C2BE",
  "outline": "#A08C89",
  "outline_variant": "#534341",
  "shadow": "#000000",
  "scrim": "#000000",
  "inverse_surface": "#F1DFDC",
  "inverse_on_surface": "#392E2C",
  "inverse_primary": "#904B40",
  "primary_fixed": "#FFDAD4",
  "on_primary_fixed": "#3A0905",
  "primary_fixed_dim": "#FFB4A8",
  "on_primary_fixed_variant": "#73342A",
  "secondary_fixed": "#FFDAD4",
  "on_secondary_fixed": "#2C1512",
  "secondary_fixed_dim": "#E7BDB6",
  "on_secondary_fixed_variant": "#5D3F3B",
  "tertiary_fixed": "#FBDFA6",
  "on_tertiary_fixed": "#251A00",
  "tertiary_fixed_dim": "#DEC48C",
  "on_tertiary_fixed_variant": "#564419",
  "surface_dim": "#1A1110",
  "surface_bright": "#423735",
  "surface_container_lowest": "#140C0B",
  "surface_container_low": "#231918",
  "surface_container": "#271D1C",
  "surface_container_high": "#322826",
  "surface_container_highest": "#3D3230",
  "primary_palette_key_color": "#AD6256",
  "secondary_palette_key_color": "#926F69"
}
```

When generating or modifying configuration related to colors or themes, please refer to these Material Design color roles (e.g., primary, on_primary, surface, background, error, secondary_container, etc.) and use the corresponding hex values from the theme.json file. Ensure consistency with this established theming system. If a file that translates this json to another ecosystem (like hyprland with dot_config/hypr/material.conf) already exists, make sure to use that ecosystems import notation. When translating to other notations use lower camelCase.

Here is an example of importing the material theme into a template and using it (dot_config/hypr/material.conf), use generalized material.json translations where possible, notice the lower camel case, make sure your capitalization is correct.

```
{{ $theme := (include "dot_config/theming/theme.json" | fromJson) }}

$primary = rgb({{ trimPrefix "#" $theme.primary }})
$primaryAlpha = {{ trimPrefix "#" $theme.primary }}

$surfaceTint = rgb({{ trimPrefix "#" $theme.surface_tint }})
$surfaceTintAlpha = {{ trimPrefix "#" $theme.surface_tint }}
... All the other colors ...
```
