#!/bin/bash

# exit if anything goes wrong ...
set -e

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
# welcome
# ====================================================================================
msg
msg "    _    ____   ____ _   _  "
msg "   / \  |  _ \ / ___| | | | "
msg "  / _ \ | |_) | |   | |_| | "
msg " / ___ \|  _ <| |___|  _  | "
msg "/_/   \_\_| \_\\\\____|_| |_| "
msg "                            "
msg " ___ _   _ ____ _____  _    _     _     _____ ____   "
msg "|_ _| \ | / ___|_   _|/ \  | |   | |   | ____|  _ \  "
msg " | ||  \| \___ \ | | / _ \ | |   | |   |  _| | |_) | "
msg " | || |\  |___) || |/ ___ \| |___| |___| |___|  _ <  "
msg "|___|_| \_|____/ |_/_/   \_\_____|_____|_____|_| \_\ "
msg
msg "By github.com/zanderhavgaard"
msg

msg
msg "This script will install arch linux."
msg "The script will ask for a few variables at the beginning, otherwise the"
msg "only interaction required will be to type the desired passwords when prompted."
msg

# ====================================================================================
# read variables
# ====================================================================================
pmsg "Reading variables for install ..."

read -rp "username: " USERNAME
read -rp "hostname: " HOSTNAME
read -rp "disk to install to: " INSTALL_DISK
read -rp "root partition size in gb [integer]: " ROOT_PART_SIZE
msg "Specify CPU vendor, must be exact string, will install appropriate ucode."
read -rp "CPU vendor [amd/intel]: " CPU_VENDOR
msg "Specify GPU vendor, must be exact string, will install appropriate drivers."
read -rp "GPU vendor [amd/intel]: " GPU_VENDOR

msg
msg "Summary: "
msg "username: $USERNAME"
msg "hostname: $HOSTNAME"
msg "install disk: $INSTALL_DISK"
msg "root partition size: $ROOT_PART_SIZE gb"
msg "cpu vendor: $CPU_VENDOR"
msg "gpu vendor: $GPU_VENDOR"
msg

msg "Continue? [y/n]"
read -n 1 -r ; echo
[[ $REPLY != "y" ]] && errmsg "aboring ..." && exit
msg

# ====================================================================================
# format disk
# ====================================================================================

pmsg "Creating disk partition template file ..."
SFDISK_FILE="disk.sfdisk"
echo "start=        2048, size=     1024000, type=1" >> $SFDISK_FILE
echo "start=     1026048, size=     1024000, type=20" >> $SFDISK_FILE
echo "start=     2050048, type=30" >> $SFDISK_FILE
pmsg "Applying disk partioning using sfdisk ..."
sfdisk "$INSTALL_DISK" < "$SFDISK_FILE"

# ====================================================================================
# format partitions
# ====================================================================================

pmsg "Formatting EFI partition ..."
mkfs.fat -F32 "${INSTALL_DISK}1"

pmsg "Formatting boot partition ..."
mkfs.ext4 "${INSTALL_DISK}2"

pmsg "Enabling full disk encryption ..."
pmsg "You will be prompted to input the disk encryption password."
cryptsetup luksFormat "${INSTALL_DISK}3"
cryptsetup open --type luks "${INSTALL_DISK}3" lvm

# ====================================================================================
# configure LVM
# ====================================================================================
pmsg "Configuring LVM"
pvcreate --dataalignment 1m /dev/mapper/lvm
vgcreate volgroup0 /dev/mapper/lvm
lvcreate -L "${ROOT_PART_SIZE}GB" volgroup0 -n lv_root
lvcreate -l 100%FREE volgroup0 -n lv_home
modprobe dm_mod
vgscan
vgchange -ay

# ====================================================================================
# format and mount paritions
# ====================================================================================

pmsg "Formatting the root partition ..."
mkfs.ext4 /dev/volgroup0/lv_root

pmsg "Mounting the root parition ..."
mount /dev/volgroup0/lv_root /mnt

pmsg "Creating the boot parition mount point ..."
mkdir /mnt/boot

pmsg "Mounting the boot partiion ..."
mount "${INSTALL_DISK}2" /mnt/boot

pmsg "Formatting the home partition ..."
mkfs.ext4 /dev/volgroup0/lv_home

pmsg "Creating the home volume mount point .."
mkdir /mnt/home

pmsg "Mounting the home volume ..."
mount /dev/volgroup0/lv_home /mnt/home

pmsg "Creating the /etc directory ..."
mkdir /mnt/etc

# ====================================================================================
# create the fstab file
# ====================================================================================

pmsg "Creating the fstab file ..."
genfstab -U -p /mnt >> /mnt/etc/fstab

pmsg "Catting generated fstab ..."
cat /mnt/etc/fstab

msg "Does fstab file look good? [y/n]"
read -n 1 -r ; echo
[[ $REPLY != "y" ]] && errmsg "aboring ..." && exit

# ====================================================================================
# install arch
# ====================================================================================
pmsg "Installing base arch system ..."
pacstrap /mnt base

# ====================================================================================
# Everythin until EOF will run in the new shell in the new arch system
# ====================================================================================
cat <<EOF > /mnt/setup.sh

# ====================================================================================
# utils for chroot script
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
# end utils for chroot script
# ====================================================================================


pmsg "Updating pacman repositories"
pacman -Syyy

pmsg "Installing mainline and lts kernel + headers ..."
pacman --noconfirm -S linux linux-lts linux-headers linux-lts-headers

Install packages for the system, networking, ssh and a text editor
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
# format partitions
# ====================================================================================

# ====================================================================================
# format partitions
# ====================================================================================

# ====================================================================================
# format partitions
# ====================================================================================

# ====================================================================================
# format partitions
# ====================================================================================

# ====================================================================================
# format partitions
# ====================================================================================

# ====================================================================================
# format partitions
# ====================================================================================


EOF

# ====================================================================================
# end of the sub system shell
# ====================================================================================

pmsg "Starting to execute commands in the new arch system..."
arch-chroot /mnt bash setup.sh
