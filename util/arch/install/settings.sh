PACKAGES=(
  linux linux-firmware sof-firmware acpi lvm2 efibootmgr grub mtools man-db 
  dosfstools base sudo which dhcpcd networkmanager iwd ppp bluez-tools vim
)

TIMEZONE="Europe/Kiev"
HOSTNAME="arch"
USER="user"

# Uptional arguments for `util/disk/system.sh`.
PARTITIONS_OPTIONS="--efi-sz=50M --swap-sz=2G"

# The keyfile will be created to be used for unlocking the encrypted LUKS
# partition by initramfs. Will be used when the '--encrypt' option is set in
# $PARTITIONS_OPTIONS.
#
# See https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Avoiding_having_to_enter_the_passphrase_twice
LUKS_KEYFILE="/root/cryptlvm.keyfile"
