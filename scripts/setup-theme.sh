#!/usr/bin/env bash
set -euo pipefail

# Theme settings that can't live in a config file.
# Everything else is declarative and linked by symlink-configs.sh:
#   gtk-3.0/ and gtk-4.0/ (settings.ini + Kanagawa Wave CSS, gtk-4.0/kanagawa.css),
#   qt6ct/qt6ct.conf + qt6ct/colors/kanagawa.conf (Fusion style),
#   qt5ct/qt5ct.conf for the odd Qt5 app (applications/vlc.desktop)
# Cursor theme for niri clients is set in niri/config.kdl's cursor {} block.
#
# Requires: adw-gtk-theme papirus-icon-theme ttf-ibm-plex qt6ct qt5ct
#           colloid-cursors-git (AUR, cursors only)

GTK_THEME_NAME="adw-gtk3-dark"
ICON_THEME_NAME="Papirus-Dark"
FONT_NAME="IBM Plex Sans 11"
CURSOR_THEME_NAME="Colloid-dark-cursors"
CURSOR_SIZE=24

# gsettings is what xdg-desktop-portal serves to sandboxed/Flatpak apps,
# and libadwaita reads color-scheme from it to pick its dark variant.
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME_NAME"
gsettings set org.gnome.desktop.interface font-name "$FONT_NAME"
gsettings set org.gnome.desktop.interface document-font-name "$FONT_NAME"
gsettings set org.gnome.desktop.interface monospace-font-name "BlexMono Nerd Font 11"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME_NAME"
gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"

# GTK2 only reads ~/.gtkrc-2.0, outside ~/.config
echo "Symlinking ~/.gtkrc-2.0 ..."
rm -fv "$HOME/.gtkrc-2.0"
ln -sv "$HOME/dotfiles/dot-gtkrc-2.0" "$HOME/.gtkrc-2.0"

# Verification
echo "color-scheme:           $(gsettings get org.gnome.desktop.interface color-scheme)"
echo "gtk-theme:              $(gsettings get org.gnome.desktop.interface gtk-theme)"
echo "icon-theme:             $(gsettings get org.gnome.desktop.interface icon-theme)"
echo "font-name:              $(gsettings get org.gnome.desktop.interface font-name)"
echo "cursor-theme:           $(gsettings get org.gnome.desktop.interface cursor-theme)"
echo "cursor-size:            $(gsettings get org.gnome.desktop.interface cursor-size)"
