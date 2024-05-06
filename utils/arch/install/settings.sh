PACKAGES="linux linux-firmware sof-firmware acpi lvm2 efibootmgr grub mtools"
PACKAGES+=" dosfstools base sudo which networkmanager dhcpcd iwd ppp"
PACKAGES+=" bluez-tools man-db vim"

TIMEZONE="Europe/Kiev"
HOSTNAME="arch"
USER="reksarka"

# Will be created during setup and used to unlock the partition by initramfs.
# See https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#Avoiding_having_to_enter_the_passphrase_twice
LUKS_KEYFILE="/root/cryptlvm.keyfile"

