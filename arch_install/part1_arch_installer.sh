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
msg "Prefix for install disk partition, if the disk name ends in a number, eg disk is called '/dev/nvme0n1'"
msg "Then disk partitions will be called '/dev/nvme0n1px', where 'x' denotes the partition number"
read -rp "please specify the prefix: " INSTALL_DISK_PREFIX
read -rp "root partition size in gb [integer]: " ROOT_PART_SIZE
msg "Specify CPU vendor, must be exact string, will install appropriate ucode."
read -rp "CPU vendor [amd/intel]: " CPU_VENDOR
msg "Specify GPU vendor, must be exact string, will install appropriate drivers."
read -rp "GPU vendor [amd/intel/none(for headless)]: " GPU_VENDOR
read -rp "Would you like to install packages for a graphical desktop ? [yes/no]: " INSTALL_GUI

msg
msg "Summary: "
msg "username: $USERNAME"
msg "hostname: $HOSTNAME"
msg "install disk: $INSTALL_DISK"
msg "install disk part prefix $INSTALL_DISK_PREFIX"
msg "root partition size: $ROOT_PART_SIZE gb"
msg "cpu vendor: $CPU_VENDOR"
msg "gpu vendor: $GPU_VENDOR"
msg "install gui desktop: $INSTALL_GUI"
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
mkfs.fat -F32 "${INSTALL_DISK_PREFIX}1"

pmsg "Formatting boot partition ..."
mkfs.ext4 "${INSTALL_DISK_PREFIX}2"

pmsg "Enabling full disk encryption ..."
pmsg "You will be prompted to input the disk encryption password."
cryptsetup luksFormat "${INSTALL_DISK_PREFIX}3"

pmsg "Unlocking new encrypted disk ..."
cryptsetup open --type luks "${INSTALL_DISK_PREFIX}3" lvm

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
mount "${INSTALL_DISK_PREFIX}2" /mnt/boot

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

# pmsg "Catting generated fstab ..."
# cat /mnt/etc/fstab

# msg "Does fstab file look good? [y/n]"
# read -n 1 -r ; echo
# [[ $REPLY != "y" ]] && errmsg "aboring ..." && exit

# ====================================================================================
# install arch
# ====================================================================================
pmsg "Installing base arch system ..."
pacstrap /mnt base

# ====================================================================================
# execute part 2 of the script inside the newly created filesystem
# ====================================================================================
pmsg "Copying part2 script into new filesystem ..."
cp /root/part2_arch_installer.sh /mnt/part2_arch_installer.sh

pmsg "Executing part2 script in new arch system ..."
arch-chroot /mnt bash part2_arch_installer.sh \
  "$USERNAME" \
  "$HOSTNAME" \
  "$INSTALL_DISK" \
  "$INSTALL_DISK_PREFIX" \
  "$ROOT_PART_SIZE" \
  "$CPU_VENDOR" \
  "$GPU_VENDOR" \
  "$INSTALL_GUI"

# ====================================================================================
# end of the sub system shell
# ====================================================================================

pmsg "Unmounting ..."
umount -a

msg
smsg "Arch has been installed, you should now reboot."
msg
