uws=${uws:-$(cd $(dirname $(dirname $BASH_SOURCE[0])) && pwd)}

. "$uws/lib/log.sh"
. "$uws/lib/check.sh"


is_sudoer() {
  [[ `groups` =~ "sudo" ]] && return 0 || return 1
}


as_sudoer() {

  WARN "The user's sudo group membership has not been updated!"

  is_exe sg || {
    ERR "Can't run as sudoer: sg not found!"
    return 1
  }

  INFO "Run as a member of the sudo group."
  sg - sudo -c "$1 ${2:-}"
}


ensure_sudo() {

  is_exe sudo && is_sudoer \
    && return 0

  local user=`whoami`

  [[ $user == "root" ]] \
    && ERR "Ensuring sudo as root!" \
    && return 1

  local install_sudo=""

  is_exe sudo \
    || install_sudo="apt-get -y update && apt-get -y install sudo"

  local add_sudoer="usermod -a -G sudo $user"

  # NOTE: The `is_sudoer` check is not suitable here!
  [[ `groups $user` =~ "sudo" ]] || {
    [[ -n $install_sudo ]] \
      && install_sudo="$add_sudoer && $install_sudo" \
      || install_sudo="$add_sudoer"
  }

  [[ -n $install_sudo ]] \
    && INFO "Ensuring sudo for $user as root" \
    && su - -c "$install_sudo" \
    && OK "sudo has been installed for $user" \
    && return 0

  [[ -n $install_sudo ]] \
    && ERR "Can't install sudo for $user" \
    && return 2

  return 0
}
