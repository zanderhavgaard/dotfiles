#!/usr/bin/env bash

echo -e "
░█▀▀░█░█░█▄█░█░░░▀█▀░█▀█░█░█░█▀▀░█▀▄
░▀▀█░░█░░█░█░█░░░░█░░█░█░█▀▄░█▀▀░█▀▄
░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀░▀░▀
"

# user
user="zander"
# dotfiles directory
dfd="/home/$user/dotfiles"
# config files directory
cfd="/home/$user/.config"
# .local directory
ldf="/home/$user/.local"

echo -e "\nSymlinking .aliases ..."
rm ~/.aliases
ln -sv $dfd/.aliases /home/$user/.aliases

echo -e "\nSymlinking .env ..."
rm ~/.env
ln -sv $dfd/.env /home/$user/.env

echo -e "\nSymlinking .zshrc ..."
rm ~/.zshrc
ln -sv $dfd/.zshrc /home/$user/.zshrc

echo -e "\nSymlinking tmux config ..."
rm ~/.tmux.conf
ln -sv $dfd/.tmux.conf /home/$user/.tmux.conf

echo -e "\nSymlinking alacritty config ..."
rm $cfd/alacritty/alacritty.toml
ln -sv $dfd/alacritty/alacritty.toml $cfd/alacritty/alacritty.toml

echo -e "\nSymlinking i3 config ..."
rm -r $cfd/i3/*
ln -sv $dfd/i3/config $cfd/i3/config

echo -e "\nSymlinking polybar config ..."
rm -r $cfd/polybar
ln -sv $dfd/polybar $cfd/polybar

echo -e "\nSymlinking neofetch config ..."
rm $cfd/neofetch/config.conf
ln -sv $dfd/neofetch/config.conf $cfd/neofetch/config.conf

echo -e "\nSymlinking rofi config ..."
rm $cfd/rofi/config
rm $cfd/rofi/config.rasi
rm $ldf/share/rofi/themes/onedark.rasi
ln -sv $dfd/rofi/config.rasi $cfd/rofi/config.rasi
ln -sv $dfd/rofi/onedark.rasi $ldf/share/rofi/themes/onedark.rasi

echo -e "\nSymlinking git congfig ..."
rm ~/.gitconfig
ln -sv $dfd/.gitconfig /home/$user/.gitconfig

echo -e "\nSymlinking zathura config ..."
rm $cfd/zathura/zathurarc
ln -sv $dfd/zathura/zathurarc $cfd/zathura/zathurarc

echo -e "\n symlinking ranger config ...."
rm $cfd/ranger/rc.conf
ln -sv $dfd/ranger/rc.conf $cfd/ranger/rc.conf

echo -e "\n symlinking cli-vis config ..."
rm -r $cfd/vis
ln -sv $dfd/vis $cfd/vis

echo -e "\n symlinking dunst config ..."
rm $cfd/dunst/dunstrc
ln -sv $dfd/dunst/dunstrc $cfd/dunst/dunstrc

echo -e "\n symlinking bspwm config ..."
rm -rf $cfd/bspwm
rm -rf $cfd/sxhkd
ln -sv $dfd/bspwm $cfd/bspwm
ln -sv $dfd/sxhkd $cfd/sxhkd

echo -e "\n symlinking lf config ..."
rm $cfd/lf/lfrc
ln -sv $dfd/lf/lfrc $cfd/lf/lfrc

echo -e "\n symlinking awesomewm config ..."
rm -rf $cfd/awesome
ln -sv $dfd/awesome $cfd/awesome

echo -e "\n symlinking starship config ..."
rm $cfd/starship.toml
ln -sv $dfd/starship.toml $cfd/starship.toml

echo -e "\n symlinking hyprland config ..."
rm $cfd/hypr/hyprland.conf
ln -sv $dfd/hypr/hyprland.conf $cfd/hypr/hyprland.conf

echo -e "\n symlinking wezterm config ..."
rm $cfd/wezterm/wezterm.lua
ln -sv $dfd/wezterm/wezterm.lua $cfd/wezterm/wezterm.lua

echo -e "\n symlinking zellij config ..."
rm $cfd/zellij/config.kdl
ln -sv $dfd/zellij/config.kdl $cfd/zellij/config.kdl

echo -e "\n symlinking river config ..."
rm $cfd/river/init
ln -sv $dfd/river/init $cfd/river/init

echo -e "\n symlinking waybar config ..."
rm $cfd/waybar/config
rm $cfd/waybar/style.css
ln -sv $dfd/waybar/config.json $cfd/waybar/config
ln -sv $dfd/waybar/style.css $cfd/waybar/style.css

echo -e "\n symlinking wofi config ..."
rm $cfd/wofi/config
rm $cfd/wofi/style.css
ln -sv $dfd/wofi/config $cfd/wofi/config
ln -sv $dfd/wofi/style.css $cfd/wofi/style.css

echo -e "\n symlinking mako config ..."
rm $cfd/mako/config
ln -sv $dfd/mako/config $cfd/mako/config

echo -e "\n symlinking k9s config ..."
rm $cfd/k9s/aliases.yaml
rm $cfd/k9s/config.yaml
rm -rf $cfd/k9s/skins
ln -sv $dfd/k9s/aliases.yaml $cfd/k9s/aliases.yaml
ln -sv $dfd/k9s/config.yaml $cfd/k9s/config.yaml
ln -sv $dfd/k9s/skins $cfd/k9s/skins

echo -e "\n symlinking zed config ..."
rm $cfd/zed/settings.json
ln -sv $dfd/zed/settings.json $cfd/zed/settings.json
