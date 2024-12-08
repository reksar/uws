#!/bin/bash

# See https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Encrypted_boot_partition_(GRUB)

# -- Defaults -- {{{

PARTITION_TABLE=GPT
DEFAULT_GRUB_SZ=1MiB
DEFAULT_GRUB_FS=vfat
DEFAULT_EFI_SZ=550MiB
DEFAULT_EFI_FS=fat32
LUKS_CONTAINER_NAME=luks
LVM_GROUP=lvm
DEFAULT_SWAP_SZ=4GiB
DEFAULT_ROOT_FS=ext4

# Reserved free space at the end of the root volume for `ext*` filesystem.
# See https://man.archlinux.org/man/e2scrub.8
E2SCRUB_SZ=256MiB

# Will be used when unable to read a [disk] info. No unit suffix here!
DEFAULT_BLOCK_SIZE=512
DEFAULT_SPACER_SECTORS=2048

ROOT_MOUNT_POINT=/mnt/sysroot

# Uppercased recommended!
GRUB_LABEL=GRUB
EFI_LABEL=EFI
ROOT_LABEL=ROOT

# }}}


# -- Includes -- {{{
lib="$(cd "$(dirname "$BASH_SOURCE[0]")/../lib" && pwd)"
. "$lib/check.sh" || exit 2
. "$lib/units.sh" || exit 2
. "$lib/notifications.sh" || exit 2
notification_title="[SYSDISK]"
# }}}


# -- Functions -- {{{

list_blockdev_fs() {
  cat /proc/filesystems | grep -v nodev
}


is_blockdev_fs() {

  fs=$(list_blockdev_fs | grep -Pio "(?<=\W)$1(\W|$)")

  [[ -z $fs ]] && [[ "$1" =~ ^fat[0-9]{0,2}$ ]] \
    && list_blockdev_fs | grep -i vfat &> /dev/null && fs=$1

  [[ -z $fs ]] && return 1

  return 0
}


is_mkfs() {
  echo $1 | grep -P "^(vfat)|(fat\d{2})|(ext\d)$" &> /dev/null && return 0
  return 1
}


mk_fs() {

  # Unified mkfs interface.

  local type=$1
  local partition=$2
  local label=$3

  case "$type" in
    vfat)
      local options="--type=vfat ${label:+-n $label}"
      ;;
    fat[[:digit:]][[:digit:]])
      local options="--type=vfat -F ${type#fat} ${label:+-n $label}"
      ;;
    ext[[:digit:]])
      local options="--type=$type ${label:+-L $label}"
      ;;
    *)
      ERR "Cannot generate \`mkfs\` options for $type!"
      return 1
      ;;
  esac

  mkfs $options $partition
}


memsize() {

  # NOTE: Useless spaces will be trimmed by `to_bytes`.
  size=$(cat /proc/meminfo | grep -Pio "(?<=MemTotal:)\s*\d+\s*\w*")

  size=${size^^}  # Uppercased
  size=${size%B}  # Without "B" suffix

  # Usually the $size is shown in "kB" (SI units), but really is "KiB"
  # (IEC units). So here are the SI -> IEC units converted.
  [[ "$size" =~ [KMGT]$ ]] && size=${size}i

  to_bytes "$size"
}

# }}}


# -- Parse args -- {{{

# -- -- Help -- -- {{{
[[ -z ${1:-} || "${1:-}" == "-h" ]] && {
GF=$DEFAULT_GRUB_FS
GS=$DEFAULT_GRUB_SZ
EF___=$DEFAULT_EFI_FS
ES____=$DEFAULT_EFI_SZ
SS_=$DEFAULT_SWAP_SZ
RF_=$DEFAULT_ROOT_FS
cat << EOF
Writes a $PARTITION_TABLE partition table to [disk]:
+------+--------+-------------------------------------+
| GRUB | EFI    | LUKS encrypted container            |
| for  |        +----------+--------------------------+
| BIOS |        | LVM swap | LVM root, all rest space |
+------+--------+----------+--------------------------+
Defaults:
+------+--------+----------+--------------------------+
| $GF | $EF___  | swap     | $RF_                     |
| $GS | $ES____ | $SS_     | All rest [disk] space    |
+------+--------+----------+--------------------------+
Using:
  sysdisk.sh {options} [disk]
Options:
  --grub-sz
  --grub-fs
  --efi-sz
  --efi-fs
  --swap-sz
  --root-fs
EOF
exit 1
}
# }}}

for i in $@
do
  case $i in
    --grub-sz=*)
      _grub_sz=${i#*=}
      shift
      ;;
    --grub-fs=*)
      _grub_fs=${i#*=}
      shift
      ;;
    --efi-sz=*)
      _efi_sz=${i#*=}
      shift
      ;;
    --efi-fs=*)
      _efi_fs=${i#*=}
      shift
      ;;
    --swap-sz=*)
      _swap_sz=${i#*=}
      shift
      ;;
    --root-fs=*)
      _root_fs=${i#*=}
      shift
      ;;
    *)
      ;;
  esac
done

disk=${1#/dev/}

# }}}


# -- Process args -- {{{

[[ -z $disk ]] && {
  ERR "Destination disk is not specified!"
  INFO "Specify a disk block device, e.g. \"/dev/sda\" or \"sda\"."
  exit 3
}

ls /sys/block/$disk &> /dev/null || {
  ERR "Cannot find the \"$disk\" block device!"
  exit 3
}

ro=$(cat /sys/block/$disk/ro 2> /dev/null)

[[ $ro != 0 ]] && {
  [[ $ro == 1 ]] && {
    ERR "The \"$disk\" disk is readonly!"
    exit 5
  }
  WARN "Unable to check the \"$disk\" is readonly!"
}


grub_sz=$(to_bytes "${_grub_sz:-$DEFAULT_GRUB_SZ}")

[[ -z $grub_sz ]] && {
  ERR "Unable to set the bytesize of GRUB partition for BIOS boot!"
  exit 3
}


grub_fs=${_grub_fs:-$DEFAULT_GRUB_FS}

is_blockdev_fs $grub_fs || {
  WARN "GRUB partition FS $grub_fs is not set for a block device!"
}

is_mkfs $grub_fs || {
  ERR "GRUB partition FS $grub_fs is not supported by \`mk_fs\`!"
  exit 3
}


efi_sz=$(to_bytes "${_efi_sz:-$DEFAULT_EFI_SZ}")

[[ -z $efi_sz ]] && {
  ERR "Cannot set EFI boot partition bytesize!"
  exit 3
}


efi_fs=${_efi_fs:-$DEFAULT_EFI_FS}

is_blockdev_fs $efi_fs || {
  WARN "EFI partition FS $efi_fs is not set for a block device!"
}

is_mkfs $efi_fs || {
  ERR "EFI partition FS $efi_fs is not supported by \`mk_fs\`!"
  exit 3
}


root_fs=${_root_fs:-$DEFAULT_ROOT_FS}

is_blockdev_fs $root_fs || {
  WARN "ROOT partition FS $root_fs is not set for a block device!"
}

is_mkfs $root_fs || {
  ERR "ROOT partition FS $root_fs is not supported by \`mk_fs\`!"
  exit 3
}


swap_sz=$(to_bytes "${_swap_sz:-$DEFAULT_SWAP_SZ}")

[[ -z $swap_sz ]] && {
  ERR "Cannot set swap partition bytesize!"
  exit 3
}

mem_sz=$(memsize)

[[ $swap_sz -lt $mem_sz ]] && WARN "$swap_sz SWAP < $mem_sz RAM"

# }}}


# -- -- Reserve free space after the root volume -- -- {{{
#
# The LVM volume group must have at least 256MiB of unallocated space to
# dedicate to the snapshot or the logical volume will be skipped.
#
# See https://man.archlinux.org/man/e2scrub.8

[[ $root_fs =~ ^ext[2-4]$ ]] && {

  lvm_reserved_sz=$(to_bytes "$E2SCRUB_SZ")

  is_natural $lvm_reserved_sz \
    && INFO "Reserving $(to_iec $lvm_reserved_sz) of LVM for \`e2scrub\`." \
    || WARN "Unable to evaluate LVM reserved space for \`e2scrub\`!"
}

is_natural $lvm_reserved_sz || lvm_reserved_sz=0

# }}}


# -- Disk size -- {{{

sectors_total=$(cat /sys/block/$disk/size 2> /dev/null)

is_natural $sectors_total || {
  ERR "Unable to read the \"$disk\" sectors count!"
  exit 6
}

sector_sz=$(cat /sys/block/$disk/queue/hw_sector_size 2> /dev/null)

is_natural $sector_sz || {
  ERR "Unable to read the \"$disk\" sector size!"
  exit 6
}

disk_sz=$(($sector_sz * $sectors_total))

# }}}


# -- Spacer size for optimal alignment of disk partitions -- {{{

optimal_io_size=$(cat /sys/block/$disk/queue/optimal_io_size 2> /dev/null)

is_int_negative $optimal_io_size && {
  WARN "Unable to read the \"$disk\" optimal IO size!"
  optimal_io_size=0
}

[[ $optimal_io_size -le 0 ]] && {

  block_size=$(cat /sys/block/$disk/queue/physical_block_size 2> /dev/null)

  is_natural $block_size || {
    block_size=$DEFAULT_BLOCK_SIZE
    WARN "Cannot read the \"$disk\" block size, using default: $block_size."
  }

  optimal_io_size=$(($DEFAULT_SPACER_SECTORS * $block_size))
  WARN "Cannot read the optimal IO size, using default: $optimal_io_size."
}

alignment_offset=$(cat /sys/block/$disk/alignment_offset 2> /dev/null)

is_int_negative "$alignment_offset" && {
  WARN "Unable to read the \"$disk\" alignment!"
  alignment_offset=0
}

spacer_sz=$(($alignment_offset + $optimal_io_size))

# }}}


# -- Partitions -- {{{

grub_n=1
grub_part=/dev/${disk}$grub_n
grub_start=$spacer_sz
grub_end=$(($grub_start + $grub_sz))

efi_n=2
efi_part=/dev/${disk}$efi_n
efi_start=$(($spacer_sz + $grub_end))
efi_end=$(($efi_start + $efi_sz))

luks_n=3
luks_part=/dev/${disk}$luks_n
luks_start=$(($spacer_sz + $efi_end))
luks_sz=$(($disk_sz - $luks_start - $spacer_sz))
luks_end=$(($luks_start + $luks_sz))

root_part=/dev/$LVM_GROUP/$ROOT_LABEL
root_sz=$(($luks_sz - $swap_sz - $lvm_reserved_sz))

swap_part=/dev/$LVM_GROUP/SWAP

cat << EOF
Create $PARTITION_TABLE partition table:
/dev/$disk $(to_iec $disk_sz)
+ $grub_part $(to_iec $grub_sz) -> GRUB for BIOS boot
+ $efi_part $(to_iec $efi_sz) -> EFI
+ $luks_part $(to_iec $luks_sz) -> LUKS encrypted
  + LVM ~$(to_iec $swap_sz) -> SWAP
  + LVM ~$(to_iec $root_sz) -> ROOT
Partitions will be aligned using the $(to_iec $spacer_sz) spacer.
LVM sizes will be slightly different due to PE units.
EOF

read -r -p "Enter Y to proceed: " answer

[[ "$answer" =~ ^[Yy] ]] || {
  echo Aborted!
  exit 1
}

parted --script --fix --align=optimal /dev/$disk \
  mktable $PARTITION_TABLE \
  unit B \
  mkpart "$GRUB_LABEL" fat32 $grub_start $grub_end \
  mkpart "$EFI_LABEL" fat32 $efi_start $efi_end \
  mkpart "LUKS" $luks_start $luks_end \
  set $grub_n bios_grub on \
  set $efi_n boot on \
  set $luks_n lvm on \
  || exit 7

# }}}


# -- Encrypted volumes -- {{{

INFO "Creating the encrypted LUKS container on $luks_part."

# NOTE: GRUB's support for LUKS2 is limited!
cryptsetup luksFormat --batch-mode --type luks1 $luks_part || exit 8

cryptsetup open $luks_part $LUKS_CONTAINER_NAME
pvcreate /dev/mapper/$LUKS_CONTAINER_NAME
vgcreate $LVM_GROUP /dev/mapper/$LUKS_CONTAINER_NAME

# NOTE: `lvcreate --size` may work incorrect! Using the physical extents (PE).

pe_sz=$(to_bytes $(vgdisplay | grep -Pio "(?<=PE Size).*" | tr -d " "))

[[ -z $pe_sz ]] && {
  ERR "Cannot read the LVM PE size!"
  exit 9
}

swap_pe=$(($swap_sz / $pe_sz))
lvcreate --extents $swap_pe $LVM_GROUP -n SWAP || exit 9


# -- All remaining space is for the root volume -- {{{

# NOTE: Avoid the `pvdisplay` here, when the physical LUKS volume has more
# than just the current $LVM_GROUP!
free_pe=$(to_bytes $(pvdisplay | grep -Pio "(?<=Free PE).*" | tr -d " "))

[[ -z $free_pe ]] && {
  ERR "Cannot read the free PE count!"
  exit 9
}

reserved_pe=$((1 + $lvm_reserved_sz / $pe_sz))
root_pe=$(($free_pe - $reserved_pe))
root_sz_diff=$(($root_sz - $(($root_pe * $pe_sz))))

# If |diff| > 16 MiB
[[ ${root_sz_diff#-} -gt 16777216 ]] \
  && WARN "$ROOT_LABEL size delta $(to_iec $root_sz_diff)"

lvcreate --extents $root_pe $LVM_GROUP -n "$ROOT_LABEL" || exit 9

# }}}
# }}}


mkswap $swap_part
swapon $swap_part

echo -n "$GRUB_LABEL: "
mk_fs $grub_fs $grub_part $GRUB_LABEL
echo -n "$EFI_LABEL: "
mk_fs $efi_fs $efi_part $EFI_LABEL
echo -n "$ROOT_LABEL: "
mk_fs $root_fs $root_part $ROOT_LABEL

mount --mkdir $root_part "$ROOT_MOUNT_POINT"
mount --mkdir $efi_part "$ROOT_MOUNT_POINT/efi"
