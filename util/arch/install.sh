#!/bin/bash

# Uses the entire specified disk device to make it the system disk using
# `util/sysdisk.sh`, then installs the Arch Linux on it.
#
# TODO: Skip the [disk] partitioning if not needed.
# TODO: Add option to skip the [disk] encryption.


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../.." && pwd)"
notification_title="[Arch Install]"
. "$uws/lib/notifications.sh"

lsb_release -i 2>/dev/null | grep Arch >/dev/null || {
  uname -r 2>/dev/null | grep -i Arch >/dev/null || {
    [[ -f /etc/arch-release ]] || {
      ERR "Must be run on Arch Linux!"
      exit 1
    }
  }
}

[[ -z ${1:-} ]] && {
  ERR "Specify a system disk device for installing the Arch Linux," \
      "e.g. '/dev/sda' or 'sda'."
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
