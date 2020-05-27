#!/bin/bash

set -e

echo -e "
░█▀█░█▀▀░█░█░░░▀█▀░█▀█░█▀▀░▀█▀░█▀█░█░░░█░░
░█░█░█▀▀░█▄█░░░░█░░█░█░▀▀█░░█░░█▀█░█░░░█░░
░▀░▀░▀▀▀░▀░▀░░░▀▀▀░▀░▀░▀▀▀░░▀░░▀░▀░▀▀▀░▀▀▀
"

echo -e "\nInstall utils ...?\n"


xorg_windomanager="
i3-gaps
lightdm
lightdm-gtk-greeter
lightdm-webkit-theme-litarvan
mesa
xorg-server
xorg-apps
xorg-xinit
xorg-xrandr
"
read -p "Install i3-wm and xorg? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $xorg_windomanager
fi

amd_cpu_gpu_specific="
amd-ucode
xf86-video-amdgpu
"
read -p "Install packages for AMD CPU + GPU ? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $amd_cpu_gpu_specific
fi

audio="
alsa-utils
alsa-plugins
alsa-lib
pulseaudio
pulseaudio-alsa
"
read -p "Install alsa and pulseaudio packages? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $audio
fi

system_libs_utils_misc="
xwallpaper
inetutils
lvm2
openssh
ntp
pandoc
ufw
w3m
xautolock
playerctl
usbutils
pavucontrol
flameshot
dunst
i3lock-color
cronie
qt5ct
gtk-engine-murrine
gtk-engines
net-tools
lxappearance
arandr
wmctrl
"
read -p "Install misc system libs/utils/backends? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $system_libs_utils_misc
fi

read -p "Setup defaults for UFW? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # setup ufw
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw enable
    sudo systemctl enable ufw
fi

virtualization="
qemu
virt-manager
virt-viewer
dnsmasq
vde2
bridge-utils
openbsd-netcat
ebtables
iptables
"
read -p "Install virtualization packages? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $virtualization
fi


cli_tools="
diff-so-fancy
exa
bat
prettyping
fzf
fd
ncdu
tldr
the_silver_searcher
ripgrep
ranger
tmux
jq
nmap
arp-scan
figlet
htop
neofetch
nload
zip
unzip
tldr
speedtest-cli
lolcat
cowsay
fortune-mod
xclip
autossh
bashtop
hub
keynav
calcurse
"
read -p "Install cli_tools? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $cli_tools
fi

vim_related="
neovim
neovim-qt
vim
ctags
xsel
"
read -p "Install vim packages? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $vim_related
fi

applications="
zsh
git
alacritty
firefox
qutebrowser
vimb
thunderbird
docker
docker-compose
python-pywal
discord
rofi
dmenu
feh
picom
thunar
zathura
zathura-pdf-poppler
mpv
mps-youtube
graphicsmagick
imagemagick
flameshot
sxiv
gnome-disk-utility
"
read -p "Install assorted applications, eg. browser/terminal/email? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $applications
fi

development="
base-devel
python
python-pip
pyenv
clang
terraform
kubectl
minikube
helm
nodejs
npm
shellcheck
yamllint
python-cookiecutter
"
read -p "Install development packags? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $development
fi

fonts="
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra
gnu-free-fonts
noto-fonts
ttf-bitstream-vera
ttf-droid
ttf-liberation
"
read -p "Install fonts? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $fonts
fi

themes="
arc-gtk-theme
arc-icon-theme
capitaine-cursors
"
read -p "Install themes? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman -S $themes
fi

read -p "Install yay AUR-helper? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p ~/Applications
    git clone https://aur.archlinux.org/yay.git ~/Applications/yay
    cd ~/Applications/yay
    makepkg -si
    cd
fi

aur="
antigen-git
bitwarden-bin
bonsai.sh-git
cava
cli-visualizer
dropbox
figlet-fonts
gotop-bin
insync
lazygit
magic-wormhole
pfetch-git
polybar
slack-desktop
spotify
tty-clock
zoom
nerd-fonts-complete
ly
git-delta
circleci-cli-bin
"
read -p "Install AUR packages using yay? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    yay -S $aur
fi

read -p "Create directories for Applications/python venvs? [y/n] " -n 1 -r ; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # create dir for virtualenvs
    mkdir ~/.virtualenvs

    # Create Applications dir and clone some usefull stuff
    mkdir ~/Applications
fi
