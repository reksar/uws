#!/bin/bash

# GRUB setup on a system disk partitioned using `utils/sysdisk.sh` to allow 
# hybrid boot with EFI/BIOS.
#
# See https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Configuring_GRUB_2

ETCGRUB="/etc/default/grub"
BOOT_DIR="/boot"

# Separated partition for EFI boot when /boot is encrypted.
EFI_DIR="/efi"

LOCALNAME="[GRUB install]"
OK="[OK]$LOCALNAME"
ERR="[ERR]$LOCALNAME"
WARN="[WARN]$LOCALNAME"
INFO="[INFO]$LOCALNAME"


which grub-install &> /dev/null || {
  echo "$ERR grub-install not found!"
  exit 1
}

[[ ! -f $ETCGRUB ]] && {
  echo "$ERR $ETCGRUB not found!"
  exit 1
}


# System disk checking {{{

[[ -z $1 ]] && {
  echo "$ERR No system disk specified for installing GRUB!"
  exit 2
}

disk=${1#/dev/}

lsblk --filter "type=='disk'" /dev/$disk &> /dev/null || {
  echo "$ERR There is no $disk disk!"
  exit 2
}

lsblk \
  --output mountpoint \
  --noheadings \
  /dev/$disk \
  | grep $EFI_DIR &> /dev/null \
  || {
    echo "$ERR The $disk disk has no partition mounted as $EFI_DIR !"
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
  echo "$WARN Exacly 1 encrypted partition on $disk is expected!"
}

# }}}


echo "$INFO Installing GRUB for system disk /dev/$disk"


# Configuring GRUB {{{

[[ $crypt_count -gt 0 ]] && {

  CRYPTODISK=GRUB_ENABLE_CRYPTODISK
  echo "$INFO Enabling $CRYPTODISK option"
  grep $CRYPTODISK $ETCGRUB > /dev/null || {
    echo "$ERR $CRYPTODISK option not found!"
    exit 4
  }
  sed -i "s/.*$CRYPTODISK.*/$CRYPTODISK=y/" $ETCGRUB

  CMDLINE=GRUB_CMDLINE_LINUX
  grep "^$CMDLINE=\".*\"" $ETCGRUB > /dev/null || {
    echo "$ERR $CMDLINE option not found!"
    exit 4
  }

  for part in $crypt_parts
  do
    # NOTE: `lsblk` may not work properly with UUID in chrooted mode!
    uuid=$(blkid --match-tag UUID --output value /dev/$part)
    [[ $(echo $uuid | wc -w) -ne 1 ]] && {
      echo "$ERR Invalid $part UUID: '$uuid'"
      exit 4
    }
    grep "$CMDLINE=.*$uuid" $ETCGRUB && {
      echo "$ERR $CMDLINE already has $uuid UUID!"
      exit 4
    }
    echo "$INFO Adding cryptlvm $part UUID $uuid to $CMDLINE"
    sed -i \
      "s/\(^$CMDLINE=\".*\)\"/\1 cryptdevice=UUID=$uuid:cryptlvm\"/" \
      $ETCGRUB
  done

}

# }}}


echo "$INFO Installing to $EFI_DIR for EFI"
grub-install --target=x86_64-efi --efi-directory=$EFI_DIR --recheck

echo "$INFO Installing to /dev/$disk for BIOS"
grub-install --target=i386-pc --recheck /dev/$disk

echo "$INFO Generating configuration"
grub-mkconfig --output=$BOOT_DIR/grub/grub.cfg


echo "$OK Done!"
