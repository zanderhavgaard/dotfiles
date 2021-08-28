# stop script if anything goes wrong
set -e

# ====================================================================================
# utils
# ====================================================================================

# terminal espace codes for a rainy day
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
YELLOW='\033[01;33m'
PURPLE='\033[01;35m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

# for displaying progress
function pmsg {
  echo -e "${PURPLE}-->${NONE} ${BOLD}$1${NONE}"
}

# for errers
function errmsg {
 echo -e "${RED}${BOLD}--> $1${NONE}"
}

# general messages
function msg {
  echo -e "${BOLD}$1${NONE}"
}

# success message
function smsg {
echo -e "${BOLD}${GREEN}--> $1${NONE}"
}

# ====================================================================================
# load variables from part 1
# ====================================================================================

USERNAME=$1
HOSTNAME=$2
INSTALL_DISK=$3
INSTALL_DISK_PREFIX=$4
ROOT_PART_SIZE=$5
CPU_VENDOR=$6
GPU_VENDOR=$7
INSTALL_GUI=$8

msg
msg "Start of part 2 script"
msg
msg "Variables recieved from part 1:"
msg
msg "username: $USERNAME"
msg "hostname: $HOSTNAME"
msg "install disk: $INSTALL_DISK"
msg "install disk part prefix $INSTALL_DISK_PREFIX"
msg "root partition size: $ROOT_PART_SIZE gb"
msg "cpu vendor: $CPU_VENDOR"
msg "gpu vendor: $GPU_VENDOR"
msg "install gui desktop: $INSTALL_GUI"
msg

# ====================================================================================
# install kernels and base packages
# ====================================================================================

pmsg "Updating pacman repositories"
pacman -Syyy

pmsg "Installing mainline and lts kernel + headers ..."
pacman --noconfirm -S linux linux-lts linux-headers linux-lts-headers

pmsg "Installing neccesary packages for the system, networking, ssh, a text editor ..."
pacman --noconfirm -S vim neovim base-devel openssh networkmanager network-manager-applet wpa_supplicant wireless_tools netctl dialog lvm2 grub efibootmgr dosfstools os-prober mtools ufw linux-firmware

pmsg "Enabling NetworkManager ..."
systemctl enable NetworkManager

# ====================================================================================
# Install ucode
# ====================================================================================

if [ "$CPU_VENDOR" = "intel" ] ; then
  pmsg "Installing intel ucode ..."
  pacman --noconfirm -S intel-ucode
elif [ "$CPU_VENDOR" = "amd" ] ; then
  pmsg "Installing amd ucode ..."
  pacman --noconfirm -S amd-ucode
else
  errmsg "Could not determine CPU vendor, skipping ucode installation."
fi

# ====================================================================================
# setup mkinitcpio
# ====================================================================================

pmsg "Editing kernel modules ..."
sed 's/block/& encrypt lvm2/' -i /etc/mkinitcpio.conf

pmsg "Creating initial ramdisk for mainline kernel ..."
mkinitcpio -p linux

pmsg "Creating initial ramdisk for lts kernel"
mkinitcpio -p linux-lts

# ====================================================================================
# generate locale
# ====================================================================================

# TODO make argument
pmsg "Setting up locale.gen file ..."
sed '/#en_US.UTF-8/s/^#//g' -i /etc/locale.gen

pmsg "Generating locale ..."
locale-gen

# ====================================================================================
# setup grub
# ====================================================================================
pmsg "Enabling disk encryption in grub config ..."
sed '/#GRUB_ENABLE_CRYPTODISK=y/s/^#//g' -i /etc/default/grub
sed 's,GRUB_CMDLINE_LINUX_DEFAULT=",&cryptdevice='"${INSTALL_DISK_PREFIX}"'3:volgroup0:allow-discards ,' -i /etc/default/grub

# ====================================================================================
# setup EFI + grub
# ====================================================================================
pmsg "Creating mount point for EFI partition ..."
mkdir /boot/EFI

pmsg "Mounting EFI partition ..."
mount "${INSTALL_DISK_PREFIX}1" /boot/EFI

pmsg "Installing grub ..."
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

pmsg "Creating locale directory for grub"
[ ! -d /boot/grub/locale ] && mkdir /boot/grub/locale || msg "Directory already exists."

pmsg "Copying grub locale file ..."
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

pmsg "Generating the grub config file"
grub-mkconfig -o /boot/grub/grub.cfg

# ====================================================================================
# Setup swapfile
# ====================================================================================

pmsg "Creating swapfile ..."
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile

pmsg "Backing up fstab ..."
cp /etc/fstab /etc/fstab.bak

pmsg "Adding swapfile to fstab ..."
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# ====================================================================================
# Setup network time
# ====================================================================================
pmsg "Enabling network time ..."
timedatectl set-ntp true

# TODO make argument
pmsg "Linking zoneinfo file to Copenhagen ..."
ln -sf /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime

pmsg "Synchonizing hardware clock ..."
hwclock --systohc

# ====================================================================================
# configure network
# ====================================================================================

pmsg "Setting hostname ..."
echo "$HOSTNAME" > /etc/hostname

pmsg "Creating hosts file ..."
rm /etc/hosts > /dev/null 2>&1
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# ====================================================================================
# setup users
# ====================================================================================

pmsg "Enter the root user password ..."
passwd

pmsg "Creating new user ..."
useradd -m -g users -G wheel "$USERNAME"

pmsg "Adding new user to system groups ..."
usermod -aG wheel,audio,video,optical,storage "$USERNAME"

pmsg "Enter password for user $USERNAME ..."
passwd "$USERNAME"

pmsg "Allowing wheel group to use sude ..."
# TODO experimental, verify that it works
echo -e "%wheel ALL=(ALL) ALL\nDefaults rootpw" > /etc/sudoers.d/99_wheel

# ====================================================================================
# install xorg, display manager and i3wm
# ====================================================================================

if [ "$INSTALL_GUI" = "yes" ] ; then
  pmsg "Installing packages for graphical environment ..."

  if [ "$GPU_VENDOR" = "intel" ] ; then
    pmsg "Installing intel video drivers ..."
    pacman --noconfirm -S xf86-video-intel libgl mesa
  elif [ "$GPU_VENDOR" = "amd" ] ; then
    pmsg "Installing amd video drivers ..."
    pacman --noconfirm -S xf86-video-amdgpu mesa
  else
    errmsg "Could not determine GPU vendor, skipping driver installation ..."
  fi

  pmsg "Installing xorg ..."
  pacman --noconfirm -S xorg xorg-server xorg-apps xorg-xinit xorg-xrandr arandr

  pmsg "Installing i3 window manager ..."
  pacman --noconfirm -S i3-gaps i3lock i3status rxvt-unicode alacritty

  pmsg "Instlling audio alsa and pulseaudio ..."
  pacman --noconfirm -S alsa-utils alsa-plugins alsa-lib pulseaudio pulseaudio-alsa

  pmsg "Installing lightdm display manager ..."
  pacman --noconfirm -S lightdm lightdm-gtk-greeter lightdm-webkit-theme-litarvan lightdm-webkit2-greeter

  pmsg "Enabling lightdm ..."
  systemctl enable lightdm
fi
