#!/bin/bash

DEFAULT_FS=ext4
DEFAUTL_LABEL=CRYPT
LUKS_CONTAINER=luks
LVM_GROUP=lvm
notification_title="[CRYPTDISK]"


# -- Includes -- {{{
lib="$(cd "$(dirname "$BASH_SOURCE[0]")/../lib" && pwd)"
. "$lib/notifications.sh" || exit 1
. "$lib/disk.sh" || exit 1
. "$lib/misc.sh" || exit 1
# -- Includes -- }}}


# -- Process args -- {{{

# -- -- Help -- -- {{{
[[ -z ${1:-} || "${1:-}" == "-h" ]] && {
cat << EOF
Encrypt the specified [disk] with LUKS1, create the logical volume {label}
inside the encrypted container and format to the {fs} filesystem.
Requires the root permissions!
Usage:
  cryptdisk.sh {options} {/dev/}[disk]
Examples:
  cryptdisk.sh sda2
  cryptdisk.sh --fs=fat32 /dev/sda2
  cryptdisk.sh --label=SDCARD mmc0p1
Options:
  Filesystem of the logical volume inside the encrypted LUKS container.
  Default: "$DEFAULT_FS".
    --fs=[ext?|fat??|vfat]
  The {label} is the name of a volume in the LVM group. Also it is used when
  making the {fs}.
  Default: "$DEFAUTL_LABEL".
    --label=[name]
EOF
exit 1
}
# -- -- Help -- -- }}}


[[ $EUID -ne 0 ]] && {
  ERR "Run it as root!"
  exit 1
}


for i in $@
do
  case $i in
    --fs=*)
      __fs=${i#*=}
      shift
      ;;
    --label=*)
      __label=${i#*=}
      shift
      ;;
    *)
      ;;
  esac
done


disk=${1#/dev/}

ls /dev/$disk &> /dev/null || {
  ERR "The \"$disk\" disk is not found!"
  exit 1
}


fs=${__fs:-$DEFAULT_FS}

[[ -z $fs ]] && {
  ERR "No filesystem is specified for the \"$disk\" disk!"
  exit 1
}

_is_mkfs $fs || {
  ERR "The \"$fs\" filesystem is not supported by \`mk_fs\`!"
  exit 1
}


label=${__label:-$DEFAUTL_LABEL}

# -- Process args -- }}}


# -- Disk status -- {{{

mounts="$(_mount_points /dev/$disk)"
crypt="$(_crypt_name /dev/$disk)"
lvgroup="$(_lvm_group /dev/$disk)"

[[ -n $mounts ]] \
  && WARN "The '$disk' disk is mounted on: $mounts."

[[ -n $crypt ]] \
  && WARN "The '$disk' disk contains the encrypted container '$crypt'."

[[ -n $lvgroup ]] \
  && WARN "The '$crypt' encrypted containder has the '$lvgroup' volume group."

# -- Disk status -- {{{


# -- Decision -- {{{

lvm_group="$(_increment_filename /dev/$LVM_GROUP)"
luks_path="$(_increment_filename /dev/mapper/$LUKS_CONTAINER)"
luks_container="${luks_path#/dev/mapper/}"

todo="create LUKS '$luks_container', LVM '$lvm_group/$label'; format to $fs"

part=
proceed=
disk_type="$(lsblk --noheadings --nodeps --output type /dev/$disk)"

case $disk_type in
  disk)
    INFO "Create the partition on the entire disk '$disk'; then $todo?"
    read -r -p "Enter Y to proceed: " proceed
    ;;
  part)
    part=$disk
    INFO "Use the '$part' partition; $todo?"
    read -r -p "Enter Y to proceed: " proceed
    ;;
  *)
    ERR "Disk type \"$disk_type\" is not supported!"
    ;;
esac

[[ "$proceed" =~ ^[Yy] ]] || {
  WARN "Aborted!"
  exit 1
}

# -- Decision -- }}}


# -- Free disk -- {{{

for i in $mounts
do
  WARN "Unmounting '$i'."
  umount --lazy "$i" || exit 1
done

[[ -n $lvgroup ]] && {
  WARN "Deactivating LVM group '$lvgroup'."
  vgchange --activate n $lvgroup || exit 1
}

[[ -n $crypt ]] && {
  WARN "Closing the encrypted container '$crypt'."
  cryptsetup close $crypt || exit 1
}

# -- Free disk -- }}}


# -- Create partition -- {{{

[[ -z $part ]] && {
  WARN "TODO: Create a partition."
  exit 1
}

# -- Create partition -- }}}


INFO "Creating the encrypted LUKS container on $part."
cryptsetup luksFormat --batch-mode --type luks1 /dev/$part || exit 1
cryptsetup open /dev/$part $luks_container || exit 1
pvcreate $luks_path || exit 1

INFO "Creating LVM volume 100% of $part."
vgcreate $lvm_group $luks_path || exit 1
lvcreate --name "$label" --extents 100%FREE $lvm_group || exit 1

INFO "Formatting to $fs."
_mkfs $fs $lvm_group/$label $label || exit 1

# TODO: util/cryptdisk.sh open <partition>
# TODO: Use --options umask=<permissions>,uid=<user>,gid=<group>
OK "Done! Use \`mount --mkdir $lvm_group/$label <mount point>\` after the" \
  " \`cryptsetup open /dev/$part <container>\`."

