#!/usr/bin/env bash
set -euo pipefail

# Theme settings that can't live in a config file.
# Everything else is declarative and linked by symlink-configs.sh:
#   gtk-3.0/settings.ini, gtk-4.0/ (settings.ini + Colloid user CSS for libadwaita),
#   Kvantum/kvantum.kvconfig, qt6ct/qt6ct.conf
# Cursor theme for niri clients is set in niri/config.kdl's cursor {} block.
#
# Requires (AUR): colloid-gtk-theme-git colloid-icon-theme-git
#                 colloid-cursors-git plasma6-themes-colloid-git (Kvantum theme)

GTK_THEME_NAME="Colloid-Dark"
ICON_THEME_NAME="Colloid-Dark"
CURSOR_THEME_NAME="Colloid-dark-cursors"
CURSOR_SIZE=24

# gsettings is what xdg-desktop-portal serves to sandboxed/Flatpak apps,
# and libadwaita reads color-scheme from it to pick its dark variant.
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME_NAME"
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
echo "cursor-theme:           $(gsettings get org.gnome.desktop.interface cursor-theme)"
echo "cursor-size:            $(gsettings get org.gnome.desktop.interface cursor-size)"
