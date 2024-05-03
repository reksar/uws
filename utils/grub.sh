#!/bin/bash

# GRUB setup on a system disk. Allows hybrid boot with EFI/BIOS.
#
# Requires a disk partitioned with `utils/sysdisk.sh` or similar.
#
# See https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Configuring_GRUB_2


ETCGRUB="/etc/default/grub"
BOOT_DIR="/boot"

# Separated partition for EFI boot when /boot is encrypted.
EFI_DIR="/efi"

notification_title="[GRUB]"
uws="$(cd "$(dirname "$BASH_SOURCE[0]")/.." && pwd)"
. "$uws/lib/notifications.sh"


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
  | grep $EFI_DIR &> /dev/null \
  || {
    ERR "The $disk disk has no partition mounted as $EFI_DIR !"
    exit 2
  }

crypt_parts=$(lsblk \
  --filter "type=='crypt'" \
  --output pkname \
  --noheadings \
  /dev/$disk \
  | sort \
  | uniq)

crypt_count=$(echo $crypt_parts | wc -w)

[[ $crypt_count -eq 1 ]] || {
  WARN "Exacly 1 encrypted partition on $disk is expected!"
}

# }}}


INFO "Installing GRUB for system disk /dev/$disk"


# Configuring GRUB {{{

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
    [[ $(echo $uuid | wc -w) -ne 1 ]] && {
      ERR "Invalid $part UUID: '$uuid'"
      exit 3
    }
    grep "$CMDLINE=.*$uuid" $ETCGRUB && {
      ERR "$CMDLINE already has $uuid UUID!"
      exit 3
    }
    INFO "Adding cryptlvm for $part $uuid to $CMDLINE"
    sed -i \
      "s/\(^$CMDLINE=\".*\)\"/\1 cryptdevice=UUID=$uuid:cryptlvm\"/" \
      $ETCGRUB
  done

}

# }}}


grub-install --target=x86_64-efi --efi-directory=$EFI_DIR --recheck || exit 4
grub-install --target=i386-pc --recheck /dev/$disk || exit 4
grub-mkconfig --output=$BOOT_DIR/grub/grub.cfg || exit 4


OK "Installed!"
