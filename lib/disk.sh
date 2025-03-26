# Some util functions to work with disk devices.


_is_mkfs() {
  # Check if the specified FS is supported by `mk_fs`.
  echo $1 | grep -P "^(vfat)|(fat\d{2})|(ext\d)$" &> /dev/null && return 0
  return 1
}


_mkfs() {

  # Unified `mkfs` interface.

  local fs=$1
  local partition=$2
  local label=$3

  _is_mkfs $fs || return 1

  case "$fs" in
    vfat)
      local options="--type=vfat ${label:+-n $label}"
      ;;
    fat[[:digit:]][[:digit:]])
      local options="--type=vfat -F ${fs#fat} ${label:+-n $label}"
      ;;
    ext[[:digit:]])
      local options="--type=$fs ${label:+-L $label}"
      ;;
    *)
      ERR "Cannot generate \`mkfs\` options for $fs!"
      return 2
      ;;
  esac

  mkfs $options $partition
}


_mount_points() {
  # Outputs the mount points for the specified $disk if there are some.
  local disk=$1
  lsblk --noheadings --raw --output=mountpoint $disk \
    | grep --invert-match '^\s*$'
}


_crypt_name() {
  # Outputs the name of an encrypted container if there is active one on the
  # specified $disk.
  local disk=$1
  lsblk --noheadings --pairs --output=name,type $disk \
    | grep --ignore-case 'TYPE="crypt"' \
    | grep --only-matching --ignore-case --perl-regex '(?<=NAME=").*?(?=")'
}


_lvm_group() {
  local disk=$1
  local container=/dev/mapper/$(_crypt_name $disk)
  [[ -n $container ]] \
    && pvdisplay --columns --noheadings --options vg_name $container \
      | tr --delete ' '
}

