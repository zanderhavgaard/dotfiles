# Install arch
Heavily inspired by the excellent guide @ https://wiki.learnlinux.tv/index.php/How_to_Install_Arch_Linux_on_Encrypted_LVM

## Prepare

* Boot the Arch iso on the target machine.
* Connect to the internet and get an ip
* If using wifi use `wifi-menu`
* edit the mirrorlist `/etc/pacman.d/mirrorlist`
* update repositoryy index `pacman -Syyy`

## Partition disk

Setup will use LVM and full disk encryption.

### Create parition table

Show disks
```bash
fdisk -l
```

Start partitioner
```bash
fdisk /dev/<disk-name>
```
Press `p` to show current partitions
Press `g` to create new parition table

Create EFI partition
```
n
enter
enter
+500M
t
1 (For EFI)
```

Create boot partition
```
n
enter
enter
+500M
```

Create LVM partition
```
n
enter
enter
enter
t
enter
30
```

Verify that pertitions look good with `p`
Accept changes with `w`

### Format partitions / setup encryption / setup LVM

Format EFI partition
```bash
mkfs.fat -F32 /dev/<DEVICE PARTITION 1>
```

Format boot partition
```bash
mkfs.ext4 /dev/<DEVICE PARTITION 2> (for example: /dev/sda2)
```

Enable full disk encryption
```bash
cryptsetup luksFormat /dev/<DEVICE PARTITION 3>
cryptsetup open --type luks /dev/<DEVICE PARTITION 3> lvm

```

Setup LVM
```bash
pvcreate --dataalignment 1m /dev/mapper/lvm
vgcreate volgroup0 /dev/mapper/lvm
lvcreate -L 30GB volgroup0 -n lv_root
lvcreate -L 250GB volgroup0 -n lv_home (or instead of "-L 250GB", use "-l 100%FREE" to use all the remaining space).
modprobe dm_mod
vgscan
vgchange -ay
```

Format the root partition
```bash
mkfs.ext4 /dev/volgroup0/lv_root
```

Mount the root partition
```bash
mount /dev/volgroup0/lv_root /mnt
```

Create the boot partition mount point
```bash
mkdir /mnt/boot
```

Mount the boot partition
```bash
mount /dev/<DEVICE PARTITION 2> /mnt/boot
```

Format the home partition
```bash
mkfs.ext4 /dev/volgroup0/lv_home
```

Create the home volume mount point
```bash
mkdir /mnt/home
```

Mount the home volume
```bash
mount /dev/volgroup0/lv_home /mnt/home
```

Create the /etc directory
```bash
mkdir /mnt/etc
```

Create the fstab file
```bash
genfstab -U -p /mnt >> /mnt/etc/fstab
```

Check that the fstab file looks good
```bash
cat /mnt/etc/fstab
```

## Install Arch

Install the base system
```bash
pacstrap -i /mnt base
```

Change to a shell in the new system
```bash
arch-chroot /mnt
```

Install mainline and lts kernels and headers
```bash
pacman -S linux linux-lts linux-headers linux-lts-headers
```

Install packages for the system, networking, ssh and a text editor
```bash
pacman -S vim neovim base-devel openssh networkmanager network-manager-applet wpa_supplicant wireless_tools netctl dialog lvm2 grub efibootmgr dosfstools os-prober mtools ufw linux-firmware
```

Enable NetworkManager
```bash
systemctl enable NetworkManager
```

(Optional) Install ucode for platform

For AMD:
```bash
pacman -S amd-ucode
```

For Intel:
```bash
pacman -S intel-ucode
```

## Setup mkinitcpio

Edit the `mkinitcpio.conf` file
```bash
nvim /etc/mkinitcpio.conf
```

On the "HOOKS" line (line #52 or thereabouts), add "encrypt lvm2" in between "block" and "filesystems"

It should look similar to the following (don't copy this line in case they change it, but just add the two new items):
```
HOOKS=(base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck)
```

Create the initial ramdisk for the main kernel
```bash
mkinitcpio -p linux
```

Creat the initial ramdisk for the lts kernel
```bash
mkinitcpio -p linux-lts
```
## Generate Locale

Uncomment approprate line in locale list file
```bash
nvim /etc/locale.gen (uncomment en_US.UTF-8)
```

generate locale(s)
```bash
locale-gen
```

## Setup grub

Edit the grub config file
```bash
nvim /etc/default/grub
```
Uncomment the line
```
GRUB_ENABLE_CRYPTODISK=y
```

Comment the line
```
GRUB_DEFAULT=0
```
add the lines
```
# automatically select the last booted kernel
GRUB_SAVEDEFAULT=true
GRUB_DEFAULT=saved
```

Add cryptdevice=<PARTUUID>:volgroup0 to the GRUB_CMDLINE_LINUX_DEFAULT line If using standard device naming, the option will look like this:
```
cryptdevice=/dev/sda3:volgroup0:allow-discards quiet
```

Create the mount point for EFI boot
```bash
mkdir /boot/EFI
```

Mount the EFI partition
```bash
mount /dev/<DEVICE PARTITION 1> /boot/EFI
```

Install grub
```bash
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
```

Create the locale directory for grub
```bash
mkdir /boot/grub/locale
```

Copy the locale file to locale directory
```bash
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
```

Generate grub config file

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

## SWAP

Using SWAP is optional on most modern systems.

Create a swap file
```bash
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
```

Backup the fstab file
```bash
cp /etc/fstab /etc/fstab.bak
```

Add the swapfile to the fstab file
```bash
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
```

Verify that the fstab file contains the correct mounts
```bash
cat /etc/fstab
```
(You should have a mountpoint for the root filesystem, boot partition, home partition, and swap file )

## Setup network time

Setup ntp
```bash
timedatectl set-ntp true
```

Link zoneinfo file
```bash
ln -sf /usr/share/zoneinfo/<region>/<city> /etc/localtime
```

Synchronize hardware clock
```bash
hwclock --systohc
```

## Configure network

Set your hostname
```bash
nvim /etc/hostname
```
(file should only contain the hostname, all in lower case)

Edit hosts file
```bash
nvim /etc/hosts
```
should contain
```
127.0.0.1 localhost
::1       localhost
127.0.1.1 <hostname>.localdomain <hostname>
```

## User management

Set the root user password
```bash
passwd
```

Create a new user for yourself
```bash
useradd -m -g users -G wheel <username>
```

Set password for new user
```bash
passwd <username>
```
Allow new user to use sudo
```bash
visudo
```
Then uncomment
```
%wheel ALL=(ALL) ALL
```

Add new user to groups
```bash
usermod -aG wheel,audio,video,optical,storage <username>
```

## Install xorg

Install drivers for intel GPUs
```bash
pacman -S xf86-video-intel libgl mesa
```

Install drivers for AMD GPUs
```bash
pacman -S mesa xf86-video-amdgpu
```

For virtualbox guests
```bash
pacman -S virtualbox-guest-utils virtualbox-guest-modules-arch mesa mesa-libgl
```

(Optional) Install xorg server and utils
```bash
pacman -S xorg
```

(Optional) Install a window manager
```bash
pacman -S i3-gaps
```

(Optional) install a display manager and themes
```bash
pacman -S lightdm lightdm-gtk-greeter lightdm-webkit-theme-litarvan lightdm-webkit2-greeter
```
Enable lightdm

```bash
systemctl enable lightdm
```

# Done

Exit from the new system back to the live iso session
```bash
exit
```

Unmount everything (ignore errors)
```bash
umount -a
```

Finally reboot
```bash
reboot
```
