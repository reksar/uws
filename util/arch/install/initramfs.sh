#!/bin/bash


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../../.." && pwd)"
. "$uws/lib/notifications.sh"
. "$uws/util/arch/install/settings.sh"

disk=${1#/dev/}
notification_title="[Arch initramfs]"
luks_keyfile="${LUKS_KEYFILE:-}"


[[ -f /etc/mkinitcpio.conf ]] || {
  ERR "/etc/mkinitcpio.conf not found"
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

  INFO "Adding \`encrypt lvm2\` to HOOKS"
  sed -i "s/\(^HOOKS=(.*\<block\>\)/\1 encrypt lvm2/" /etc/mkinitcpio.conf

  grep "^HOOKS=(.*\<block encrypt lvm2\>.*)" /etc/mkinitcpio.conf > /dev/null \
  || {
    ERR "Unable to add HOOKS"
    exit 2
  }

  [[ -n "$luks_keyfile" ]] && {

    [[ -f "$luks_keyfile" ]] \
    && WARN "LUKS keyfile $luks_keyfile already exists!" \
    || {
      INFO "Creating LUKS keyfile $luks_keyfile"
      dd bs=512 count=4 iflag=fullblock if=/dev/random of="$luks_keyfile"
      chmod 000 "$luks_keyfile" || exit 3
    }

    INFO "Adding LUKS keyfile to initramfs image"
    grep "^FILES=(.*\<$luks_keyfile\>.*)" /etc/mkinitcpio.conf > /dev/null \
    || {
      path_escaped="$(echo "$luks_keyfile" | sed "s/\//\\\\\//g")"
      sed -i "s/^FILES=(\(.*)\)/FILES=($path_escaped \1/" /etc/mkinitcpio.conf
      grep "^FILES=(.*$luks_keyfile .*)" /etc/mkinitcpio.conf > /dev/null \
      || {
        ERR "Unable to add LUKS keyfile!"
        exit 3
      }
    } || WARN "/etc/mkinitcpio.conf already contains $luks_keyfile"

    for crypt in $encrypted_volumes
    do
      INFO "Adding LUKS keyfile for /dev/$crypt"
      cryptsetup luksAddKey /dev/$crypt "$luks_keyfile" || exit 3
    done
  }
} || {
  [[ -n "$luks_keyfile" ]] \
  && WARN "LUKS keyfile is set, but no encrypted volumes found!"
}


INFO "Generating initramfs"
mkinitcpio -P || exit 4
chmod 600 /boot/initramfs-linux* || exit 4
OK "Done!"
