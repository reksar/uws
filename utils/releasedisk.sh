#!/bin/bash

# Allows to release a block $disk device, e.g. to manage partitions, etc:
# * disables a swap
# * unmounts all partitions
# * deactivates all LVM partitions
# * closes LUKS encrypted containers


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/.." && pwd)"
. "$uws/lib/notifications.sh" || exit 1
notification_title="[RELEASEDISK]"


[[ -z ${1:-} ]] && {
  ERR "Specify a block disk device to release"
  exit 1
}

disk=${1#/dev/}

ls /sys/block/$disk &> /dev/null || {
  ERR "Cannot find the \"$disk\" block device!"
  exit 2
}


INFO "Releasing disk /dev/$disk"

swap=$(
  lsblk --filter "mountpoint=='[SWAP]'" --output path --noheadings /dev/$disk
)
[[ -n $swap ]] && {
  INFO "Disabling swap: $swap"
  swapoff "$swap" || exit 3
}

mountpoints=$(
  lsblk --filter "mountpoint=~'/'" --output mountpoint --noheadings /dev/$disk 
)
[[ -n $mountpoints ]] && {
  INFO "Unmounting $mountpoints"
  umount --recursive $mountpoints || exit 4
}

lvm_partitions=$(
  lsblk --filter "type=='lvm'" --output path --noheadings /dev/$disk
)
for lvm in $lvm_partitions
do
  INFO "Deactivating LVM partition $lvm"
  lvchange -an $lvm || exit 5
done

encrypted_volumes=$(
  lsblk --filter "type=='crypt'" --output name --noheadings /dev/$disk
)
for crypt in $encrypted_volumes
do
  INFO "Close LUKS encrypted volume $crypt"
  cryptsetup close $crypt || exit 6
done

# TODO: check there are no mountpoints, crypt, lvm partitions.
OK "Done!"
