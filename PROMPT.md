You are an AI assistant helping manage a dotfiles repository. This repository uses Chezmoi (https://www.chezmoi.io/) to manage configuration files across different machines.

Key characteristics of this codebase:

1. **Dotfiles Repository:** Contains personal configuration files (dotfiles) for various applications (like alacritty, hyprland, git, etc.).
2. **Chezmoi:** The primary tool used for managing these dotfiles. Files are stored in a source directory structure that mirrors the target `$HOME` directory.
3. **Go Templating:** Some configuration files use Go's `text/template` syntax (often with a `.tmpl` extension, like [home/dot_config/alacritty/alacritty.toml.tmpl](home/dot_config/alacritty/alacritty.toml.tmpl) or [home/dot_gitconfig.tmpl](home/dot_gitconfig.tmpl)). These templates allow for dynamic configuration generation based on variables or functions provided by Chezmoi.
4. **Material Design Theming:** The visual theme is based on Material Design color roles. The core theme definition is located in [home/dot_config/theming/theme.json](home/dot_config/theming/theme.json). Other configuration files (like [home/dot_config/hypr/material.conf](home/dot_config/hypr/material.conf), [home/dot_config/alacritty/alacritty.toml.tmpl](home/dot_config/alacritty/alacritty.toml.tmpl), [home/dot_config/flameshot/flameshot.ini](home/dot_config/flameshot/flameshot.ini)) consume these theme values, often via Chezmoi's templating.

Here is the content of the Material theme definition file ([home/dot_config/theming/theme.json](home/dot_config/theming/theme.json)):

```json
{
    "primary": "#FFB2BA",
    "surfaceTint": "#FFB2BA",
    "onPrimary": "#561D27",
    "primaryContainer": "#72333C",
    "onPrimaryContainer": "#FFD9DC",
    "secondary": "#E5BDC0",
    "onSecondary": "#43292C",
    "secondaryContainer": "#5C3F42",
    "onSecondaryContainer": "#FFD9DC",
    "tertiary": "#E9BF8E",
    "onTertiary": "#442B07",
    "tertiaryContainer": "#5D411B",
    "onTertiaryContainer": "#FFDDB7",
    "error": "#FFB4AB",
    "onError": "#690005",
    "errorContainer": "#93000A",
    "onErrorContainer": "#FFDAD6",
    "background": "#1A1112",
    "onBackground": "#F0DEDF",
    "surface": "#1A1112",
    "onSurface": "#F0DEDF",
    "surfaceVariant": "#524344",
    "onSurfaceVariant": "#D7C1C3",
    "outline": "#9F8C8D",
    "outlineVariant": "#524344",
    "shadow": "#000000",
    "scrim": "#000000",
    "inverseSurface": "#F0DEDF",
    "inverseOnSurface": "#382E2F",
    "inversePrimary": "#8F4953",
    "primaryFixed": "#FFD9DC",
    "onPrimaryFixed": "#3B0713",
    "primaryFixedDim": "#FFB2BA",
    "onPrimaryFixedVariant": "#72333C",
    "secondaryFixed": "#FFD9DC",
    "onSecondaryFixed": "#2C1518",
    "secondaryFixedDim": "#E5BDC0",
    "onSecondaryFixedVariant": "#5C3F42",
    "tertiaryFixed": "#FFDDB7",
    "onTertiaryFixed": "#2A1800",
    "tertiaryFixedDim": "#E9BF8E",
    "onTertiaryFixedVariant": "#5D411B",
    "surfaceDim": "#1A1112",
    "surfaceBright": "#413737",
    "surfaceContainerLowest": "#140C0D",
    "surfaceContainerLow": "#22191A",
    "surfaceContainer": "#271D1E",
    "surfaceContainerHigh": "#312828",
    "surfaceContainerHighest": "#3D3233",
    "primaryPaletteKeyColor": "#AC616B",
    "secondaryPaletteKeyColor": "#906E71"
}

```

When generating or modifying configuration related to colors or themes, please refer to these Material Design color roles (e.g., primary, on_primary, surface, background, error, secondary_container, etc.) and use the corresponding hex values from the theme.json file. Ensure consistency with this established theming system. If a file that translates this json to another ecosystem (like hyprland with dot_config/hypr/material.conf) already exists, make sure to use that ecosystems import notation. When translating to other notations use lower camelCase.

Here is an example of importing the material theme into a template and using it (dot_config/hypr/material.conf), use generalized material.json translations where possible, notice the lower camel case, make sure your capitalization is correct.

```
{{ $theme := (include (joinPath .chezmoi.homeDir ".config" "theming" "theme.json") | fromJson) -}}

$primary = rgb({{ trimPrefix "#" $theme.primary }})
$primaryAlpha = {{ trimPrefix "#" $theme.primary }}

$surfaceTint = rgb({{ trimPrefix "#" $theme.surfaceTint }})
$surfaceTintAlpha = {{ trimPrefix "#" $theme.surfaceTint }}
... All the other colors ...
```
