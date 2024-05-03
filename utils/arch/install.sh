#!/bin/bash


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../.." && pwd)"
notification_title="[Arch install]"
. "$uws/lib/notifications.sh"


lsb_release -i 2> /dev/null | grep Arch > /dev/null || {
  ERR "Running from outside Arch Linux!"
  exit 1
}

[[ -z ${1:-} ]] && {
  ERR "Specify a system disk for installing Arch Linux!"
  exit 1
}

disk=${1#/dev/}
INFO "Installing Arch Linux to /dev/$disk"


settings="$uws/utils/arch/install/settings.sh"
. "$settings"
INFO "Using $settings"


sysdisk="$uws/utils/sysdisk.sh"
INFO "Partitioning the /dev/$disk with $sysdisk"
"$sysdisk" $disk || exit 2


INFO "Installing base system to $ROOT_MOUNT_POINT"
pacstrap -K $ROOT_MOUNT_POINT $PACKAGES || exit 3
genfstab -U $ROOT_MOUNT_POINT >> $ROOT_MOUNT_POINT/etc/fstab || exit 3


INFO "Copying UWS to $ROOT_MOUNT_POINT/root"
cp -r "$uws" $ROOT_MOUNT_POINT/root || exit 4

INFO "Setup with arch-chroot"
arch-chroot $ROOT_MOUNT_POINT /root/uws/utils/grub.sh $disk || exit 4
arch-chroot $ROOT_MOUNT_POINT /root/uws/utils/arch/install/setup.sh || exit 4


OK "Done!"
