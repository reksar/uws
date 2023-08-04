# Boolean checks.


is_exe() {
  which $1 > /dev/null 2>&1 && return 0 || return 1
}


is_cygwin() {
  uname | grep -i "^CYGWIN" > /dev/null && return 0 || return 1
}


is_venv() {
  [[ -n ${VIRTUAL_ENV:-} ]] && return 0 || return 1
}


is_sudoer() {
  [[ `groups` =~ "sudo" ]] && return 0 || return 1
}


has_ansible() {
  is_exe ansible && is_exe ansible-playbook && return 0
  return 1
}
