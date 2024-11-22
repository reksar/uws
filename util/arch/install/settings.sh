PACKAGES=(
  linux linux-firmware sof-firmware acpi lvm2 efibootmgr grub mtools man-db 
  dosfstools base sudo which networkmanager dhcpcd iwd ppp bluez-tools vim
)
TIMEZONE="Europe/Kiev"
HOSTNAME="arch"
USER="user"

# Used to unlock the partition by initramfs.
# See https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Avoiding_having_to_enter_the_passphrase_twice
LUKS_KEYFILE="/root/cryptlvm.keyfile"

