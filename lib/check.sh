# Boolean checks.


_is_int_positive() {
  [[ "$1" =~ ^[0-9]+$ ]] && return 0
  return 1
}


_is_int_negative() {
  [[ "$1" =~ ^-[0-9]+$ ]] && return 0
  return 1
}


_is_natural() {
  _is_int_positive "$1" && [[ $1 -gt 0 ]] && return 0
  return 1
}


is_exe() {
  which $1 > /dev/null 2>&1 && return 0 || return 1
}


_is_cygwin() {
  uname | grep -i "^CYGWIN" > /dev/null && return 0 || return 1
}


_is_sudoer() {
  [[ `groups` =~ "sudo" ]] && return 0 || return 1
}

_is_root() {
  [[ $EUID -eq 0 ]] && return 0 || return 1
}


has_ansible() {
  is_exe ansible && is_exe ansible-playbook && return 0
  return 1
}
