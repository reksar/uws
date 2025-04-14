#!/bin/bash

# See https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Encrypted_boot_partition_(GRUB)


# -- Defaults {{{

PARTITION_TABLE=GPT
DEFAULT_GRUB_SZ=1MiB
DEFAULT_GRUB_FS=vfat
DEFAULT_EFI_SZ=550MiB
DEFAULT_EFI_FS=fat32
LUKS_CONTAINER_NAME=luks
LVM_GROUP=lvm
DEFAULT_SWAP_SZ=4GiB
DEFAULT_ROOT_FS=ext4

# Reserved free space at the end of the root volume for `ext*` filesystem on a
# LVM logical volume.
# See https://man.archlinux.org/man/e2scrub.8
E2SCRUB_SZ=256MiB

# Will be used when unable to read a [disk] info.
# NOTE: No unit suffix here!
DEFAULT_BLOCK_SIZE=512
DEFAULT_SPACER_SECTORS=2048

# System disk will be mounted here after all partitions are created.
ROOT_MOUNT_POINT=/mnt/sysroot

# Uppercased recommended!
GRUB_LABEL=GRUB
EFI_LABEL=EFI
SWAP_LABEL=SWAP
ROOT_LABEL=ROOT

# -- Defaults }}}


# -- Includes {{{
lib="$(cd "$(dirname "$BASH_SOURCE[0]")/../../lib" && pwd)"
notification_title="[SYSDISK]"
. "$lib/notifications.sh" || exit 1
. "$lib/check.sh" || exit 1
. "$lib/disk.sh" || exit 1
. "$lib/units.sh" || exit 1
# -- Includes }}}


# -- Functions {{{

list_blockdev_fs() {
  cat /proc/filesystems | grep -v nodev
}


is_blockdev_fs() {

  fs=$(list_blockdev_fs | grep -Pio "(?<=\W)$1(\W|$)")

  [[ -z $fs ]] \
    && [[ $1 =~ ^fat[0-9]{0,2}$ ]] \
    && list_blockdev_fs | grep -i vfat &> /dev/null \
    && fs=$1

  [[ -z $fs ]] && return 1

  return 0
}


convert_fs_for_parted() {
  # Some FS type is not supported by parted, so there it will be
  # converted to another type just to be the `parted` option.

  case $1 in
    vfat)
      echo fat32
      return
      ;;
  esac

  echo $1
}


memsize() {

  # NOTE: Useless spaces will be trimmed by `_to_bytes`.
  size="$(cat /proc/meminfo | grep -Pio "(?<=MemTotal:)\s*\d+\s*\w*")"

  size="${size^^}"  # Uppercased
  size="${size%B}"  # Without "B" suffix

  # Usually the $size is shown in "kB" (SI units), but really is "KiB"
  # (IEC units). So here are the SI -> IEC units converted.
  [[ "$size" =~ [KMGT]$ ]] && size="${size}i"

  _to_bytes "$size"
}

# -- Functions }}}


# -- Parse args {{{

# -- -- Help {{{
[[ -z ${1:-} || "${1:-}" == "-h" ]] && {
GF=$DEFAULT_GRUB_FS
GS=$DEFAULT_GRUB_SZ
EF___=$DEFAULT_EFI_FS
ES____=$DEFAULT_EFI_SZ
SS_=$DEFAULT_SWAP_SZ
RF_=$DEFAULT_ROOT_FS
cat << EOF
Using:
  util/disk/system.sh {options} [disk]
Options:
  --grub-sz=<size>
  --grub-fs=<FS>
  --efi-sz=<size>
  --efi-fs=<FS>
  --swap-sz=<size>
  --root-fs=<FS>
  --encrypt
Writes a $PARTITION_TABLE partition table to [disk]:
+------+--------+-------------------------------------+
| GRUB | EFI    | LUKS encrypted container            |
| for  |        +----------+--------------------------+
| BIOS |        | LVM swap | LVM root, all rest space |
+------+--------+----------+--------------------------+
Default:
+------+--------+----------+--------------------------+
| $GF | $EF___  | swap     | $RF_                     |
| $GS | $ES____ | $SS_     | All rest [disk] space    |
+------+--------+----------+--------------------------+
When the '--encrypt' option is provided, then swap and
root will be logical LVM volumes inside the encrypted
LUKS container instead of separate regular partitions.
EOF
exit 1
}
# -- -- Help }}}


_is_root || {
  ERR "Run it as root!"
  exit 1
}


for i in $@
do
  case $i in
    --grub-sz=*)
      __grub_sz=${i#*=}
      shift
      ;;
    --grub-fs=*)
      __grub_fs=${i#*=}
      shift
      ;;
    --efi-sz=*)
      __efi_sz=${i#*=}
      shift
      ;;
    --efi-fs=*)
      __efi_fs=${i#*=}
      shift
      ;;
    --swap-sz=*)
      __swap_sz=${i#*=}
      shift
      ;;
    --root-fs=*)
      __root_fs=${i#*=}
      shift
      ;;
    --encrypt)
      __encrypt=y
      shift
      ;;
    *)
      ;;
  esac
done

disk=${1#/dev/}

# -- Parse args }}}


# -- Process args {{{

[[ -z $disk ]] && {
  ERR "Destination disk is not specified!"
  INFO "Specify a disk block device, e.g. '/dev/sda' or 'sda'."
  exit 1
}

ls /sys/block/$disk &> /dev/null || {
  ERR "Cannot find the '$disk' block device!"
  exit 1
}

ro=$(cat /sys/block/$disk/ro 2> /dev/null)

[[ $ro != 0 ]] && {
  [[ $ro == 1 ]] && {
    ERR "The '$disk' disk is readonly!"
    exit 1
  }
  WARN "Unable to check the '$disk' is readonly!"
}


grub_sz=$(_to_bytes "${__grub_sz:-$DEFAULT_GRUB_SZ}")

[[ -z $grub_sz ]] && {
  ERR "Unable to set the bytesize of GRUB partition for BIOS boot!"
  exit 1
}


grub_fs=${__grub_fs:-$DEFAULT_GRUB_FS}

is_blockdev_fs $grub_fs || {
  WARN "GRUB partition FS '$grub_fs' is not set for a block device!"
}

_is_mkfs $grub_fs || {
  ERR "GRUB partition FS '$grub_fs' is not supported by \`_mkfs\`!"
  exit 1
}


efi_sz=$(_to_bytes "${__efi_sz:-$DEFAULT_EFI_SZ}")

[[ -z $efi_sz ]] && {
  ERR "Cannot set EFI boot partition bytesize!"
  exit 1
}


efi_fs=${__efi_fs:-$DEFAULT_EFI_FS}

is_blockdev_fs $efi_fs || {
  WARN "EFI partition FS '$efi_fs' is not set for a block device!"
}

_is_mkfs $efi_fs || {
  ERR "EFI partition FS '$efi_fs' is not supported by \`_mkfs\`!"
  exit 1
}


root_fs=${__root_fs:-$DEFAULT_ROOT_FS}

is_blockdev_fs $root_fs || {
  WARN "ROOT partition FS '$root_fs' is not set for a block device!"
}

_is_mkfs $root_fs || {
  ERR "ROOT partition FS '$root_fs' is not supported by \`_mkfs\`!"
  exit 1
}


swap_sz=$(_to_bytes "${__swap_sz:-$DEFAULT_SWAP_SZ}")

[[ -z $swap_sz ]] && {
  ERR "Cannot set swap partition bytesize!"
  exit 1
}

mem_sz=$(memsize)

[[ $swap_sz -lt $mem_sz ]] && WARN "$swap_sz SWAP < $mem_sz RAM"


encrypt=${__encrypt:-}

# -- Process args }}}


# -- Disk size {{{

sectors_total=$(cat /sys/block/$disk/size 2> /dev/null)

_is_natural $sectors_total || {
  ERR "Unable to read the '$disk' sectors count!"
  exit 1
}

sector_sz=$(cat /sys/block/$disk/queue/hw_sector_size 2> /dev/null)

_is_natural $sector_sz || {
  ERR "Unable to read the '$disk' sector size!"
  exit 1
}

disk_sz=$(($sector_sz * $sectors_total))

# -- Disk size }}}


# -- Spacer size for optimal alignment of disk partitions {{{

optimal_io_size=$(cat /sys/block/$disk/queue/optimal_io_size 2> /dev/null)

_is_int_negative $optimal_io_size && {
  WARN "Unable to read the '$disk' optimal IO size!"
  optimal_io_size=0
}

[[ $optimal_io_size -le 0 ]] && {

  block_size=$(cat /sys/block/$disk/queue/physical_block_size 2> /dev/null)

  _is_natural $block_size || {
    block_size=$DEFAULT_BLOCK_SIZE
    WARN "Cannot read the '$disk' block size, using default: $block_size."
  }

  optimal_io_size=$(($DEFAULT_SPACER_SECTORS * $block_size))
  WARN "Cannot read the optimal IO size, using default: $optimal_io_size."
}

alignment_offset=$(cat /sys/block/$disk/alignment_offset 2> /dev/null)

_is_int_negative "$alignment_offset" && {
  WARN "Unable to read the '$disk' alignment!"
  alignment_offset=0
}

spacer_sz=$(($alignment_offset + $optimal_io_size))

# -- Spacer size for optimal alignment of disk partitions }}}


# -- Partitions {{{

grub_n=1
grub_part=/dev/${disk}$grub_n
grub_start=$spacer_sz
grub_end=$(($grub_start + $grub_sz))

efi_n=2
efi_part=/dev/${disk}$efi_n
efi_start=$(($spacer_sz + $grub_end))
efi_end=$(($efi_start + $efi_sz))

grub_fs_parted=$(convert_fs_for_parted $grub_fs)
efi_fs_parted=$(convert_fs_for_parted $efi_fs)
parted_mkpart="mkpart "$GRUB_LABEL" $grub_fs_parted $grub_start $grub_end"
parted_mkpart+=" mkpart "$EFI_LABEL" $efi_fs_parted $efi_start $efi_end"
parted_set="set $grub_n bios_grub on"
parted_set+=" set $efi_n boot on"


[[ -n $encrypt ]] && {
  # swap and root logical LVM volumes inside the encrypted LUKS.


  # -- -- Reserve free space after the root volume {{{
  #
  # The LVM volume group must have at least 256MiB of unallocated space to
  # dedicate to the snapshot or the logical volume will be skipped.
  #
  # See https://man.archlinux.org/man/e2scrub.8

  [[ $root_fs =~ ^ext[2-4]$ ]] && {

    lvm_reserved_sz=$(_to_bytes "$E2SCRUB_SZ")

    _is_natural $lvm_reserved_sz && {
      INFO "Reserving $(_to_iec $lvm_reserved_sz) of LVM for \`e2scrub\`."
    } || {
      WARN "Unable to evaluate LVM reserved space for \`e2scrub\`!"
      lvm_reserved_sz=0
    }
  }

  # -- -- Reserve free space after the root volume }}}


  luks_n=3
  luks_part=/dev/${disk}$luks_n
  luks_start=$(($spacer_sz + $efi_end))
  luks_sz=$(($disk_sz - $luks_start - $spacer_sz))
  luks_end=$(($luks_start + $luks_sz))

  root_part=/dev/$LVM_GROUP/$ROOT_LABEL
  root_sz=$(($luks_sz - $swap_sz - $lvm_reserved_sz))

  swap_part=/dev/$LVM_GROUP/SWAP_LABEL

  parted_mkpart+=" mkpart 'LUKS' $luks_start $luks_end"
  parted_set+=" set $luks_n lvm on"

  info="+ $luks_part $(_to_iec $luks_sz) -> LUKS encrypted\n"
  info+="  + LVM ~$(_to_iec $swap_sz) -> $SWAP_LABEL\n"
  info+="  + LVM ~$(_to_iec $root_sz) -> $ROOT_LABEL\n"
  lvm_note="LVM sizes will be slightly different due to PE units."

} || {
  # Unencrypted swap and root partitions.

  swap_n=3
  swap_part=/dev/${disk}$swap_n
  swap_start=$(($spacer_sz + $efi_end))
  swap_end=$(($swap_start + $swap_sz))

  root_n=4
  root_part=/dev/${disk}$root_n
  root_start=$(($spacer_sz + $swap_end))
  root_sz=$(($disk_sz - $root_start - $spacer_sz))
  root_end=$(($root_start + $root_sz))

  root_fs_parted=$(convert_fs_for_parted $root_fs)
  parted_mkpart+=" mkpart '$SWAP_LABEL' linux-swap $swap_start $swap_end"
  parted_mkpart+=" mkpart '$ROOT_LABEL' $root_fs_parted $root_start $root_end"
  parted_set+=" set $swap_n swap on"

  info="+ $swap_part $(_to_iec $swap_sz) -> $SWAP_LABEL\n"
  info+="+ $root_part $(_to_iec $root_sz) -> $ROOT_LABEL\n"
  lvm_note=""
}


cat << EOF
Create $PARTITION_TABLE partition table:
/dev/$disk $(_to_iec $disk_sz)
+ $grub_part $(_to_iec $grub_sz) -> GRUB for BIOS boot
+ $efi_part $(_to_iec $efi_sz) -> EFI
$(echo -e $info)
Partitions will be aligned using the $(_to_iec $spacer_sz) spacer.
$lvm_note
EOF

read -r -p "Enter Y to proceed: " answer

[[ "$answer" =~ ^[Yy] ]] || {
  echo Aborted!
  exit 1
}


parted --script --fix --align=optimal /dev/$disk \
  mktable $PARTITION_TABLE \
  unit B \
  $parted_mkpart \
  $parted_set \
  || exit 1

# -- Partitions }}}


# -- Encrypted volumes {{{
[[ -n $encrypt ]] && {

  INFO "Creating the encrypted LUKS container on $luks_part."

  # NOTE: GRUB's support for LUKS2 is limited, so using the LUKS1.
  cryptsetup luksFormat --batch-mode --type luks1 $luks_part || exit 1

  cryptsetup open $luks_part $LUKS_CONTAINER_NAME
  pvcreate /dev/mapper/$LUKS_CONTAINER_NAME
  vgcreate $LVM_GROUP /dev/mapper/$LUKS_CONTAINER_NAME

  # NOTE: `lvcreate --size` may work incorrect! Using the physical extents (PE).

  pe_sz=$(_to_bytes $(vgdisplay | grep -Pio "(?<=PE Size).*" | tr -d " "))

  [[ -z $pe_sz ]] && {
    ERR "Cannot read the LVM PE size!"
    exit 1
  }

  swap_pe=$(($swap_sz / $pe_sz))
  lvcreate --extents $swap_pe $LVM_GROUP -n $SWAP_LABEL || exit 1


  # -- -- All remaining space is for the root volume {{{

  # NOTE: Avoid the `pvdisplay` here, when the physical LUKS volume has more
  # than just the current $LVM_GROUP!
  free_pe=$(_to_bytes $(pvdisplay | grep -Pio "(?<=Free PE).*" | tr -d " "))

  [[ -z $free_pe ]] && {
    ERR "Cannot read the free PE count!"
    exit 1
  }

  reserved_pe=$((1 + $lvm_reserved_sz / $pe_sz))
  root_pe=$(($free_pe - $reserved_pe))
  root_sz_diff=$(($root_sz - $(($root_pe * $pe_sz))))

  # If |diff| > 16 MiB
  [[ ${root_sz_diff#-} -gt 16777216 ]] \
    && WARN "$ROOT_LABEL size delta $(_to_iec $root_sz_diff)"

  lvcreate --extents $root_pe $LVM_GROUP -n "$ROOT_LABEL" || exit 1

  # -- -- All remaining space is for the root volume }}}
}
# -- Encrypted volumes }}}


mkswap $swap_part
swapon $swap_part

echo -n "$GRUB_LABEL: "
_mkfs $grub_fs $grub_part $GRUB_LABEL
echo -n "$EFI_LABEL: "
_mkfs $efi_fs $efi_part $EFI_LABEL
echo -n "$ROOT_LABEL: "
_mkfs $root_fs $root_part $ROOT_LABEL

mount --mkdir $root_part "$ROOT_MOUNT_POINT"
mount --mkdir $efi_part "$ROOT_MOUNT_POINT/efi"
