#!/bin/bash

LOCALNAME="[Arch setup]"
INFO="[INFO]$LOCALNAME"

install="$(cd "$(dirname "$BASH_SOURCE[0]")" && pwd)"
. "$install/settings.sh"

sed -i 's/\(^HOOKS=(.*\<block\>\)/\1 encrypt lvm2/' /etc/mkinitcpio.conf
mkinitcpio -P

sed -i 's/^#\(en_US\.UTF-8.*\)/\1/' /etc/locale.gen
sed -i 's/^#\(ru_RU\.UTF-8.*\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_MESSAGES=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc

echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1\tlocalhost" >> /etc/hosts
echo "::1\t\tlocalhost" >> /etc/hosts
echo "127.0.1.1\t$HOSTNAME.localdomain\t$HOSTNAME" >> /etc/hosts

echo "$INFO Set password for root"
passwd

echo "$INFO Adding sudo group"
groupadd sudo
echo "$INFO Adding user $USER"
useradd -m -s /bin/bash -G users,sudo $USER
echo "$INFO Set password for $USER"
passwd $USER

pacman -Q | grep dhcpcd && {
  echo "$INFO Enabling DHCP"
  systemctl enable dhcpcd
}

pacman -Q | grep iwd && {
  echo "$INFO Enabling IWD service"
  systemctl enable iwd.service
}
