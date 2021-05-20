#!/bin/bash
# G7OS Installer Script 0.1
# This project installs G7OS!
# (C) 2021 Microlemur, Licensed under the GPLv3 License
# =======================================================
function changeKeyLayout(){
echo 'Key Layouts that you can use:'
ls /usr/share/kbd/keymaps/**/*.map.gz
echo 'Please select one.'
read keylayout
loadkeys $layout
echo 'Keyboard layout set to $layout'
} # I don't want to have two instances of this code!
echo 'G7OS Installer Script 0.1'
echo -e "\e[33mWarning! This script is not production ready and still may be unstable! You can still cause the script to break in many unexpected ways!\e[0m"
echo '(C) 2021 Microlemur, Licensed under the GPLv3 License'
echo '-------------------------------------------------------'
echo 'Ensuring Dependencies are statisfied...'
pacman -S lsblk --noconfirm
echo 'Do you want to change the keyboard layout? (Currently US) (Y/n)'
read keyYN
if [ keyYN = 'Y'] 
then
changeKeyLayout
elif [keyYN = 'y' ]
then
 changeKeyLayout
fi
echo 'Are you using a Wireless Connection? (Y/n)'
read connection
if [connection = 'Y']
then
wifi-menu
elif [connection = 'y']
then
wifi-menu
else
echo 'Using Hardwired Connection, Skipping Setup...'
fi
timedatectl set-ntp true
echo 'Listing Disks...'
lsblk -f
echo 'Which Disk should be selected?'
read disk
cfdisk $disk # This script is more of a 'guide' rather than an easy script sadly.
echo 'Which Partition is Home?'
read home
echo 'Which partition is EFI?'
read efi
echo 'Which Partition is Swap?'
read swap
mkfs.ext4 $home
mkswap $swap
mount $home /mnt
swapon $swap
echo 'Setting Mirror to US...'
pacman -Syy --noconfirm
pacman -S relector --noconfirm
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
reflector -c "US" -f 12 -l 10 -n 12 --save /etc/pacman.d/mirrorlist
echo 'Installing Arch...'
pacstrap /mnt base linux linux-firmware --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
echo 'What is the hostname you want to set?'
read host
echo $host > /mnt/etc/hostname
touch /mnt/etc/hosts
echo '127.0.0.1	localhost\n::1		localhost\n127.0.1.1	$host' > /mnt/etc/hosts
systemctl enable dhcpcd
echo 'Please set the root password.'
passwd
echo 'Installing GRUB...'
pacstrap /mnt grub efibootmgr --noconfirm
pacman -S grub efibootmgr git --noconfirm # Just in case ;) P.S. git is needed to setup G7OS part
mkdir /mnt/boot/efi
mount $efi /boot/efi
grub-install --target=x86_64-efi --bootloader-id=G7OS --efi-directory=/mnt/boot/efi
grub-mkconfig -o /mnt/boot/grub/grub.cfg
echo 'Installing G7Frontend (Main)...'
cd /mnt/
mkdir g7os
cd g7os
git clone https://github.com/G7-Project/G7Frontend.git
chmod +x install.sh
./install.sh
cd /
echo 'G7OS has been installed on your computer!'
