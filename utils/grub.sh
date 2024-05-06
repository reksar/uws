#!/bin/bash

# GRUB setup on a system disk. Allows hybrid boot with EFI/BIOS.
#
# Requires a disk partitioned with `utils/sysdisk.sh` or similar way.
#
# See https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Configuring_GRUB_2


ETCGRUB="/etc/default/grub"

uws="$(cd "$(dirname "$BASH_SOURCE[0]")/.." && pwd)"
notification_title="[GRUB]"
. "$uws/lib/notifications.sh"

for i in $@
do
  case $i in
    --efi-dir=*)
      efi_dir=${i#*=}
      shift
      ;;
    --luks-keyfile=*)
      luks_keyfile=${i#*=}
      shift
      ;;
    *)
      ;;
  esac
done

# Separate partition for EFI boot when /boot is encrypted.
efi_dir=${efi_dir:-/efi}


which grub-install &> /dev/null || {
  ERR "grub-install not found!"
  exit 1
}

[[ ! -f $ETCGRUB ]] && {
  ERR "$ETCGRUB not found!"
  exit 1
}


# System disk checking {{{

[[ -z $1 ]] && {
  ERR "No system disk specified for installing GRUB!"
  exit 2
}

disk=${1#/dev/}

lsblk --filter "type=='disk'" /dev/$disk &> /dev/null || {
  ERR "There is no $disk disk!"
  exit 2
}

lsblk \
  --output mountpoint \
  --noheadings \
  /dev/$disk \
| grep $efi_dir &> /dev/null \
|| {
  ERR "The $disk disk has no partition mounted as $efi_dir !"
  exit 2
}

crypt_parts=$(
  lsblk \
    --filter "type=='crypt'" \
    --output pkname \
    --noheadings \
    /dev/$disk \
  | sort \
  | uniq
)

crypt_count=$(echo $crypt_parts | wc -w)

[[ $crypt_count -eq 1 ]] || {
  WARN "Exacly 1 encrypted partition on $disk is expected!"
}

# }}}


# Configuring GRUB {{{

INFO "Configuring GRUB for EFI/BIOS boot from /dev/$disk"

[[ $crypt_count -gt 0 ]] && {

  CRYPTODISK=GRUB_ENABLE_CRYPTODISK
  INFO "$CRYPTODISK"
  grep $CRYPTODISK $ETCGRUB > /dev/null || {
    ERR "$CRYPTODISK option not found!"
    exit 3
  }
  sed -i "s/.*$CRYPTODISK.*/$CRYPTODISK=y/" $ETCGRUB

  CMDLINE=GRUB_CMDLINE_LINUX
  grep "^$CMDLINE=\".*\"" $ETCGRUB > /dev/null || {
    ERR "$CMDLINE option not found!"
    exit 3
  }

  for part in $crypt_parts
  do
    # NOTE: `lsblk` may not work properly with UUID in chrooted mode!
    uuid=$(blkid --match-tag UUID --output value /dev/$part)
    INFO "Adding cryptlvm for $part $uuid to $CMDLINE"
    [[ $(echo $uuid | wc -w) -ne 1 ]] && {
      ERR "Invalid $part UUID: '$uuid'"
      exit 3
    }

    grep "$CMDLINE=.*$uuid" $ETCGRUB > /dev/null && {
      ERR "$CMDLINE already has $uuid UUID!"
      exit 3
    }

    sed -i \
      "s/\(^$CMDLINE=\".*\)\"/\1 cryptdevice=UUID=$uuid:cryptlvm\"/" \
      $ETCGRUB

    grep "$CMDLINE=.*$uuid" $ETCGRUB > /dev/null || {
      ERR "Unable to add the cryptdevice $uuid to $CMDLINE"
      exit 3
    }
  done


  [[ -n ${luks_keyfile:-} ]] && {

    INFO "Adding LUKS keyfile $luks_keyfile for rootfs to $CMDLINE"

    [[ -f $luks_keyfile ]] || {
      ERR "LUKS keyfile not found: \"$luks_keyfile\""
      exit 4
    }

    grep "$CMDLINE=\".*$luks_keyfile\"" $ETCGRUB > /dev/null && {
      ERR "$CMDLINE already has $luks_keyfile keyfile"
      exit 4
    }

    path_escaped="$(echo "$luks_keyfile" | sed "s/\//\\\\\//g")"

    sed -i \
      "s/\(^$CMDLINE=\".*\)\"/\1 cryptkey=rootfs:$path_escaped\"/" \
      $ETCGRUB

    grep "$CMDLINE=\".*$luks_keyfile\"" $ETCGRUB > /dev/null || {
      ERR "Unable to add the $luks_keyfile to $CMDLINE"
      exit 4
    }
  }
}

# }}}


grub-install --target=x86_64-efi --efi-directory=$efi_dir --recheck || exit 5
grub-install --target=i386-pc --recheck /dev/$disk || exit 5
grub-mkconfig --output=/boot/grub/grub.cfg || exit 5
OK "Installed!"
