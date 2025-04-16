#!/bin/bash


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../../.." && pwd)"
settings="$uws/util/arch/install/settings.sh"
partition_maker="$uws/util/disk/system.sh"
notification_title="[Arch Install]"

. "$uws/lib/notifications.sh"
. "$settings"


lsb_release -i 2>/dev/null | grep Arch >/dev/null || {
  uname -r 2>/dev/null | grep -i Arch >/dev/null || {
    [[ -f /etc/arch-release ]] || {
      ERR "Must be run on Arch Linux!"
      exit 1
    }
  }
}


[[ -z ${1:-} || "$1" == "-h" || "$1" == "--help" ]] && {
  echo "Specify a system disk device for installing the Arch Linux,"
  echo "for example: 'sda' or '/dev/sdb'."
  echo
  echo "Will make disk partitions using the \`$partition_maker\`,"
  echo "then install the Arch Linux in according to \`$settings\`."
  exit 1
}

disk=${1#/dev/}

INFO "Installing Arch Linux to '/dev/$disk' disk."


root_mount_point="$(grep -Po -m1 "^ROOT_MOUNT_POINT=\K.*" "$partition_maker")"

[[ -z $root_mount_point ]] && {
  ERR "Unable to read 'ROOT_MOUNT_POINT' from '$partition_maker'."
  exit 1
}


"$partition_maker" $PARTITIONS_OPTIONS $disk || exit 1


INFO "Installing base system to '$root_mount_point'."
pacstrap -K "$root_mount_point" ${PACKAGES[@]} || exit 1
genfstab -U "$root_mount_point" >> "$root_mount_point/etc/fstab" || exit 1


INFO "Configure."

cp -r "$uws" "$root_mount_point/root" || exit 1

# NOTE: For the case when the $dir_name is not original 'uws'. Allows to invoke
#       a uws script with `arch-chroot`.
dir_name="$(basename "$uws")"

arch-chroot "$root_mount_point" \
  /root/$dir_name/util/arch/install/configure.sh $disk || exit 1


OK "Done!"
