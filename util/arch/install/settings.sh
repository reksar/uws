PACKAGES=(
  linux linux-firmware sof-firmware acpi lvm2 efibootmgr grub mtools man-db 
  dosfstools base sudo which networkmanager dhcpcd iwd ppp bluez-tools vim
)

TIMEZONE="Europe/Kiev"
HOSTNAME="arch"
USER="user"

# Uptional arguments for `util/disk/system.sh`.
PARTITIONS_OPTIONS="--efi-sz=50M --swap-sz=2G"

# The path where the keyfile will be created and stored. Will be used to unlock
# the encrypted LUKS partition by initramfs when the '--encrypt' is set in the
# $PARTITIONS_OPTIONS. Will be ignored when no '--encrypt' is set.
#
# See https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Avoiding_having_to_enter_the_passphrase_twice
LUKS_KEYFILE="/root/cryptlvm.keyfile"
