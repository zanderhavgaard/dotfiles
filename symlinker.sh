#!/bin/sh

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

echo -e "\nSymlinking termite config ..."
rm -r $cfd/termite/*
ln -sv $dfd/termite/config $cfd/termite/config

echo -e "\nSymlinking kitty config ..."
rm $cfd/kitty/kitty.conf
ln -sv $dfd/kitty/kitty.conf $cfd/kitty/kitty.conf

echo -e "\nSymlinking alacritty config ..."
rm $cfd/alacritty/alacritty.yml
ln -sv $dfd/alacritty $cfd/alacritty
ln -sv $cfd/alacritty/alacritty_dark.yml $cfd/alacritty.yml

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
ln -sv $dfd/rofi/config $cfd/rofi/config

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

echo -e "\n symlinking qutebrowser config ..."
rm -rf $cfd/qutebrowser
ln -sv $dfd/qutebrowser $cfd/qutebrowser

echo -e "\n symlinking bspwm config ..."
rm -rf $cfd/bspwm
rm -rf $cfd/sxhkd
ln -sv $dfd/bspwm $cfd/bspwm
ln -sv $dfd/sxhkd $cfd/sxhkd

echo -e "\n symlinking ncspot config ..."
rm $cfd/ncspot/config.toml
ln -sv $dfd/ncspot/config.toml $cfd/ncspot/config.toml
