#!/bin/bash

echo -e "\nInstall utils ...?\n"

utils="
exa
bat
prettyping
fzf
fd
ncdu
tldr
the_silver_searcher
ripgrep

ctags

ranger
fff

pavucontrol

gtk-engine-murrine
gtk-engines
"

sudo pacman -S $utils
