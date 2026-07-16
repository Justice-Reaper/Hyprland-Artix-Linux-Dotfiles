# Oomox/Themix - Tokyo Night Dark User Presets

User presets for [Themix/Oomox](https://github.com/themix-project/themix-gui) that generate a complete Tokyo Night Dark theme for GTK3, GTK4, Qt5, Qt6 and Papirus icons

## Contents

```
presets/
  base16-project/tokyo-night-dark   ← Preset for GTK3 (BG/FG colors swapped)
  tokyo-night-dark-gtk4              ← Preset for GTK4 + Qt5 + Qt6 (real colors)
oomox-patches/
  gtk.scss                           ← Patch: $variant: "dark"
  change_color.sh                    ← Patch: fix symbolic directories in Papirus
```

## Requirements

- [themix-full-git](https://aur.archlinux.org/packages/themix-full-git) (AUR)

```bash
paru -S themix-full-git
```

## Oomox Patches (apply before exporting)

Oomox needs two modifications to its system files so that themes are generated correctly

### 1. Dark variant in SCSS (`gtk.scss`)

The GTK3 SCSS template compiles with `$variant: "light"` by default. This causes backdrop colors to use `darken()` instead of `lighten()`, producing incorrect results for dark themes

Replace the file:

```
/opt/oomox/plugins/theme_oomox/src/gtk-3.20/scss/gtk.scss
```

With the contents of `oomox-patches/gtk.scss` (or simply change the first line from `$variant: "light"` to `$variant: "dark"`)

### 2. Symbolic icons fix in Papirus (`change_color.sh`)

The icon generation script looks for the `Papirus/symbolic` directory which does not exist. Symbolic icons are located inside the size folders (`16x16`, `22x22`, `24x24`)

Replace the file:

```
/opt/oomox/plugins/icons_papirus/change_color.sh
```

With the contents of `oomox-patches/change_color.sh`. The change is on line 149:

```diff
- "$tmp_dir"/Papirus/symbolic
+ "$tmp_dir"/Papirus/{16x16,22x22,24x24}/symbolic
```

## Import the Presets

Copy the presets to the oomox configuration folder:

```bash
mkdir -p /home/justice-reaper/.config/oomox/colors/base16-project
cp /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-user-presets/presets/base16-project/tokyo-night-dark /home/justice-reaper/.config/oomox/colors/base16-project/
cp /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-user-presets/presets/tokyo-night-dark-gtk4 /home/justice-reaper/.config/oomox/colors/
```

When opening Themix, they will appear under **User Presets**:

- `base16-project: tokyo-night-dark`
- `tokyo-night-dark-gtk4`

## Export the Themes

### Preset `base16-project: tokyo-night-dark` (GTK3 only)

This preset has the BG/FG, TXT_BG/TXT_FG and BTN_BG/BTN_FG colors **swapped** because the SCSS template with `$variant: "dark"` inverts them during compilation. The remaining colors (HDR, SEL, MENU, ICONS, TERMINAL) use the real Tokyo Night values

Select the **`base16-project: tokyo-night-dark`** preset and export directly with the top buttons (no extra options to select):

1. **Theme** (GTK3): just click **Export theme** → installs to `~/.themes/oomox-tokyo-night-dark/`
2. **Icons** (Papirus): just click **Export icons** → installs to `~/.icons/oomox-tokyo-night-dark/`

### Preset `tokyo-night-dark-gtk4` (GTK4 + Qt5 + Qt6)

This preset has the **real colors without swap** because the Base16 plugin reads them directly without any variant logic

Select the **`tokyo-night-dark-gtk4`** preset and use **Multi-Export**. The dialog starts empty; add each target with **Add export target... > Base16-Based Templates...**:

1. **gtk4-oodwaita** → `~/.themes/oomox-tokyo-night-dark-gtk4/gtk-4.0/gtk.css` (GTK4/libadwaita CSS)
2. **qt5ct (fusion)** → `~/.config/qt5ct/colors/oomox-tokyo-night-dark-gtk4.conf`
3. **qt6ct (fusion)** → `~/.config/qt6ct/colors/oomox-tokyo-night-dark-gtk4.conf`

With the three targets added, click **Export All**.

## Copy the generated files into the repo and clean up

Themix writes the exports to your home (`~/.themes`, `~/.icons`, `~/.config`). Copy them into `oomox-themes/` (the single source of truth the install uses) and then delete the generated copies so they don't create duplicate themes in `qt5ct` / `nwg-look`

### Copy into the repo

```bash
# GTK3
rm -rf /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/gtk3/*
cp -r /home/justice-reaper/.themes/oomox-tokyo-night-dark/* /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/gtk3/

# GTK4
rm -rf /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/gtk4/*
cp /home/justice-reaper/.themes/oomox-tokyo-night-dark-gtk4/gtk-4.0/gtk.css /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/gtk4/gtk.css

# Icons
rm -rf /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/icons/*
cp -r /home/justice-reaper/.icons/oomox-tokyo-night-dark/* /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/icons/

# Qt5 / Qt6 (keep the -gtk4 name; the install step renames it)
rm -f /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/qt5ct/colors/*
cp /home/justice-reaper/.config/qt5ct/colors/oomox-tokyo-night-dark-gtk4.conf /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/qt5ct/colors/
rm -f /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/qt6ct/colors/*
cp /home/justice-reaper/.config/qt6ct/colors/oomox-tokyo-night-dark-gtk4.conf /home/justice-reaper/Downloads/Hyprland-Dotfiles/oomox-themes/qt6ct/colors/
```

### Remove the generated files

```bash
rm -rf /home/justice-reaper/.themes/oomox-tokyo-night-dark
rm -rf /home/justice-reaper/.themes/oomox-tokyo-night-dark-gtk4
rm -rf /home/justice-reaper/.icons/oomox-tokyo-night-dark
rm -f /home/justice-reaper/.config/qt5ct/colors/oomox-tokyo-night-dark-gtk4.conf
rm -f /home/justice-reaper/.config/qt6ct/colors/oomox-tokyo-night-dark-gtk4.conf
```

## Difference Between the Two Presets

| Field   | `tokyo-night-dark` (GTK3) | `tokyo-night-dark-gtk4` (GTK4/Qt) |
|---------|--------------------------|-----------------------------------|
| BG      | `d8e2ec` (swap)          | `171d23` (real)                   |
| FG      | `171d23` (swap)          | `d8e2ec` (real)                   |
| TXT_BG  | `f6f6f8` (swap)          | `1d252c` (real)                   |
| TXT_FG  | `1d252c` (swap)          | `f6f6f8` (real)                   |
| BTN_BG  | `fbfbfd` (swap)          | `1d252c` (real)                   |
| BTN_FG  | `1d252c` (swap)          | `fbfbfd` (real)                   |
| Rest    | real values              | real values                       |

The swap is necessary because the GTK3 SCSS with `$variant: "dark"` automatically inverts these pairs during compilation. The Base16 plugin (used for GTK4 and Qt) does not perform any inversion
