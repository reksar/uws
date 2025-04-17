#!/bin/bash


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../../.." && pwd)"
disk=${1#/dev/}
notification_title="[Arch Setup]"

. "$uws/lib/notifications.sh"
. "$uws/util/arch/install/settings.sh"


"$uws/util/arch/install/initramfs.sh" $disk || exit 1
"$uws/util/grub.sh" --luks-keyfile="$LUKS_KEYFILE" $disk || exit 1


INFO "Default locale"
sed -i 's/^#\(en_US\.UTF-8.*\)/\1/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_MESSAGES=en_US.UTF-8" >> /etc/locale.conf


ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc


echo "$HOSTNAME" > /etc/hostname
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.1.1\t$HOSTNAME.localdomain\t$HOSTNAME" >> /etc/hosts


INFO "Set password for 'root'"
passwd

# TODO: Uncomment %sudo group in /etc/suders. 
# TODO: Check if `sudo` installed.
INFO "Adding sudo group"
groupadd sudo

INFO "Adding user '$USER' user"

# TODO: Check if 'sudo' group exists.
useradd -m -s /bin/bash -G users,sudo $USER

INFO "Set password for '$USER' user"
passwd $USER


pacman -Q | grep dhcpcd > /dev/null && {
  INFO "Enabling DHCP"
  systemctl enable dhcpcd
}

pacman -Q | grep iwd > /dev/null && {
  INFO "Enabling IWD service"
  systemctl enable iwd.service
}
