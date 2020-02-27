#!/bin/sh

set -e

echo -e "
░█▀█░█▀▀░█░█░░░▀█▀░█▀█░█▀▀░▀█▀░█▀█░█░░░█░░
░█░█░█▀▀░█▄█░░░░█░░█░█░▀▀█░░█░░█▀█░█░░░█░░
░▀░▀░▀▀▀░▀░▀░░░▀▀▀░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀▀
"

# create dir for virtualenvs
mkdir ~/.virtualenvs

# Create Applications dir and clone some usefull stuff
mkdir ~/Applications

cd ~/Applications

git clone https://github.com/ryanoasis/nerd-fonts.git

cd ~/dotfiles
