#!/bin/bash


uws="$(cd "$(dirname $(readlink -f "$BASH_SOURCE[0]"))/../../.." && pwd)"
notification_title="[Arch initramfs]"

. "$uws/lib/notifications.sh"
. "$uws/util/arch/install/settings.sh"


# NOTE: Expected exists.
disk=${1#/dev/}


[[ -f /etc/mkinitcpio.conf ]] || {
  ERR "/etc/mkinitcpio.conf not found!"
  exit 1
}

grep "^HOOKS=(.*)" /etc/mkinitcpio.conf > /dev/null || {
  ERR "There are no HOOKS in /etc/mkinitcpio.conf"
  exit 1
}

grep "^FILES=(.*)" /etc/mkinitcpio.conf > /dev/null || {
  ERR "There are no FILES in /etc/mkinitcpio.conf"
  exit 1
}


encrypted_volumes=$(
  lsblk --filter "type=='crypt'" --output pkname --noheadings /dev/$disk
)

[[ -n $encrypted_volumes ]] && {


  [[ "$PARTITIONS_OPTIONS" =~ --encrypt ]] || \
    WARN "Unexpected encrypted volumes!"

  INFO "Adding the 'encrypt lvm2' to HOOKS"
  sed -i "s/\(^HOOKS=(.*\<block\>\)/\1 encrypt lvm2/" /etc/mkinitcpio.conf

  grep "^HOOKS=(.*\<block encrypt lvm2\>.*)" /etc/mkinitcpio.conf > /dev/null \
  || {
    ERR "Unable to add the encryption HOOKS!"
    exit 1
  }


  luks_keyfile="${LUKS_KEYFILE:-}"

  [[ -n "$luks_keyfile" ]] && {

    [[ -f "$luks_keyfile" ]] && {
      WARN "LUKS keyfile '$luks_keyfile' already exists!"
    } || {
      INFO "Generating LUKS keyfile '$luks_keyfile'"
      dd bs=512 count=4 iflag=fullblock if=/dev/random of="$luks_keyfile"
      chmod 000 "$luks_keyfile" || exit 1
    }

    INFO "Adding LUKS keyfile to initramfs image"

    grep "^FILES=(.*\<$luks_keyfile\>.*)" /etc/mkinitcpio.conf > /dev/null || {

      path_escaped="$(echo "$luks_keyfile" | sed "s/\//\\\\\//g")"
      sed -i "s/^FILES=(\(.*)\)/FILES=($path_escaped \1/" /etc/mkinitcpio.conf

      grep "^FILES=(.*$luks_keyfile .*)" /etc/mkinitcpio.conf > /dev/null || {
        ERR "Unable to add LUKS keyfile!"
        exit 1
      }

    } || WARN "LUKS keyfile is already in '/etc/mkinitcpio.conf'!"

    for crypt in $encrypted_volumes
    do
      INFO "Adding LUKS keyfile for '/dev/$crypt'"
      cryptsetup luksAddKey /dev/$crypt "$luks_keyfile" || exit 1
    done
  }

} || {
  [[ "$PARTITIONS_OPTIONS" =~ --encrypt ]] && \
    WARN "Encryption is enabled, but no encrypted volumes found!"
}


INFO "Generating initramfs"
mkinitcpio -P || exit 1
chmod 600 /boot/initramfs-linux* || exit 1
OK "Done!"
