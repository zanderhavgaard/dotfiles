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
read -p "Install i3-wm and xorg? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $xorg_windomanager
fi

amd_cpu_gpu_specific="
amd-ucode
xf86-video-amdgpu
vulkan-radeon
opencl-mesa
"
read -p "Install packages for AMD CPU + GPU ? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $amd_cpu_gpu_specific
fi

audio="
alsa-utils
alsa-plugins
alsa-lib
pulseaudio
pulseaudio-alsa
"
read -p "Install alsa and pulseaudio packages? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $audio
fi

bluetooth="
bluez
bluez-utils
blueman
pulseaudio-bluetooth
libldac
"
read -p "Install bluetooth packages? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $bluetooth
fi

bspwn="
bspwm
sxhkd
"
read -p "Install bspwm packages? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $bspwn
fi

awesome="
awesome
luarocks
vicious
"
read -p "Install awesomewm packages? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $awesome
fi

qtile="
qtile
python-iwlib
"
read -p "Install qtile packages? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $qtile
fi

xfce="
xfce4
"
read -p "Install xfce packages? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $xfce
fi

gnome_shell="
gnome-shell
gnome-tweaks
gnome-control-center
"
read -p "Install gnome shell packages? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $gnome_shell
fi

system_libs_utils_misc="
volumeicon
network-manager-applet
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
i3lock
cronie
qt5ct
gtk-engine-murrine
gtk-engines
net-tools
lxappearance
arandr
wmctrl
wireguard-tools
trayer
nextcloud-client
libsecret
gnome-keyring
"
read -p "Install misc system libs/utils/backends? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $system_libs_utils_misc
fi

read -p "Setup defaults for UFW? [y/n] " -n 1 -r
echo
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
dmidecode
"
read -p "Install virtualization packages? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $virtualization
    sudo usermod -aG libvirt $USER
    sudo systemctl enable libvirtd
fi

cli_tools="
wget
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
ueberzug
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
github-cli
keynav
calcurse
bind
moreutils
nnn
skim
clusterssh
glances
picocom
sysstat
bpytop
tree
tokei
pwgen
"
read -p "Install cli_tools? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $cli_tools
fi

vim_related="
neovim
neovim-qt
vim
ctags
xsel
"
read -p "Install vim packages? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $vim_related
fi

applications="
zsh
git
alacritty
firefox
chromium
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
tumbler
zathura
zathura-pdf-poppler
mpv
mps-youtube
graphicsmagick
imagemagick
flameshot
sxiv
gnome-disk-utility
signal-desktop
falkon
guvcview
"
read -p "Install assorted applications, eg. browser/terminal/email? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $applications
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
fi

development="
base-devel
python
python-pip
pyenv
clang
terraform
kubectl
kubectx
minikube
helm
nodejs
npm
shellcheck
yamllint
python-cookiecutter
ansible
ansible-lint
shfmt
prettier
"
read -p "Install development packags? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $development
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
read -p "Install fonts? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $fonts
fi

themes="
arc-gtk-theme
arc-icon-theme
capitaine-cursors
materia-gtk-theme
"
read -p "Install themes? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo pacman --needed -S $themes
fi

read -p "Install paru AUR-helper? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p ~/Applications
    git clone https://aur.archlinux.org/paru.git ~/Applications/paru
    cd ~/Applications/paru
    makepkg -si
    cd
fi

aur_bluetooth="
pulseaudio-modules-bt
"
read -p "Install bluetooth-specific AUR packages using paru? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    paru -S $aur_bluetooth
fi

aur="
librewolf-bin
antigen-git
bonsai.sh-git
cava
cli-visualizer
figlet-fonts
gotop-bin
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
glow
ncspot
duf
ctop
lain-git
awesome-freedesktop-git
neovim-git
flashfocus-git
caffeine-ng
papirus-icon-theme-git
kind
hadolint
tflint
tfsec
goneovim-bin
luacheck
dive
"
read -p "Install AUR packages using paru? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    paru -S $aur
fi

read -p "Create directories for Applications/python venvs? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # create dir for virtualenvs
    mkdir ~/.virtualenvs

    # Create Applications dir and clone some usefull stuff
    mkdir ~/Applications
fi
