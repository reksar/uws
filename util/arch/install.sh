#!/bin/bash
# TODO: skip the [disk] partitioning if not needed.


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../.." && pwd)"

. "$uws/lib/notifications.sh"
notification_title="[Arch install]"


lsb_release -i 2> /dev/null | grep Arch > /dev/null || {
  ERR "Running from outside Arch Linux!"
  exit 1
}

[[ -z ${1:-} ]] && {
  ERR "Specify a system disk for installing Arch Linux!"
  INFO "E.g. '/dev/sda' or 'sda'."
  exit 1
}

disk=${1#/dev/}
INFO "Using the entire system disk '/dev/$disk'."

settings="$uws/util/arch/install/settings.sh"
INFO "Using '$settings'."
. "$settings"


sysdisk="$uws/util/sysdisk.sh"
INFO "Using '$sysdisk' to partitioning the '/dev/$disk'."

[[ $(grep "ROOT_MOUNT_POINT=" "$sysdisk" | wc -l) -eq 1 ]] || {
  ERR "ROOT_MOUNT_POINT in '$sysdisk'!"
  exit 2
}

root_mount_point=$(
  grep "ROOT_MOUNT_POINT=" "$sysdisk" | sed "s/ROOT_MOUNT_POINT=//"
)

[[ -z $root_mount_point ]] && {
  ERR "Unable to read ROOT_MOUNT_POINT from '$sysdisk'."
  exit 2
}

"$sysdisk" $disk || exit 2


INFO "Installing base system to '$root_mount_point'"
pacstrap -K $root_mount_point ${PACKAGES[@]} || exit 3
genfstab -U $root_mount_point >> $root_mount_point/etc/fstab || exit 3


INFO "Copying UWS to '$root_mount_point/root'"
cp -r "$uws" $root_mount_point/root || exit 4

INFO "Setup with arch-chroot to '$root_mount_point'"
arch-chroot $root_mount_point /root/uws/util/arch/install/setup.sh $disk \
|| exit 5


OK "Done!"
