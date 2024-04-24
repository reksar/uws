#!/bin/bash


LOCALNAME="[Arch install]"
OK="[OK]$LOCALNAME"
ERR="[ERR]$LOCALNAME"
INFO="[INFO]$LOCALNAME"


lsb_release -i | grep Arch > /dev/null || {
  echo "$ERR Running from outside Arch Linux!"
  exit 1
}

[[ -z $1 ]] && {
  echo "$ERR Specify a system disk for installing Arch Linux!"
  exit 1
}

disk=${1#/dev/}
echo "$INFO Installing Arch Linux to /dev/$disk"


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../.." && pwd)"


settings="$uws/utils/arch/install/settings.sh"
. "$settings"
echo "$INFO Using $settings"


sysdisk="$uws/utils/sysdisk.sh"
echo "$INFO Partitioning the /dev/$disk with $sysdisk"
"$sysdisk" $disk || exit 2


echo "$INFO Installing base system to $ROOT_MOUNT_POINT"
pacstrap -K $ROOT_MOUNT_POINT $PACKAGES || exit 3
genfstab -U $ROOT_MOUNT_POINT >> $ROOT_MOUNT_POINT/etc/fstab


echo "$INFO Proceeding installation with arch-chroot"

cp -r "$uws/utils/arch/install" $ROOT_MOUNT_POINT/root
chmod +x $ROOT_MOUNT_POINT/root/install/setup.sh
arch-chroot $ROOT_MOUNT_POINT /root/install/setup.sh || exit 4

cp "$uws/utils/grub.sh" $ROOT_MOUNT_POINT/root/install
chmod +x $ROOT_MOUNT_POINT/root/install/grub.sh
arch-chroot $ROOT_MOUNT_POINT /root/install/grub.sh $disk || exit 5


echo "$OK Done!"
