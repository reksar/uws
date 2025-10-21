#!/bin/bash

uws="$(cd "$(dirname $(readlink -f "$BASH_SOURCE[0]"))/../.." && pwd)"

[[ `type -t ERR` != "function" ]] && . "$uws/lib/log.sh"
[[ `type -t is_exe` != "function" ]] && . "$uws/lib/check.sh"

is_cygwin && exit 0
is_exe sudo && _is_sudoer && exit 0

user=`whoami`

[[ $user == "root" ]] \
  && ERR "Ensuring sudo as root!" \
  && exit 1

add_sudoer="usermod -a -G sudo $user"

install_sudo=""

is_exe sudo \
  || install_sudo="apt-get -y update && apt-get -y install sudo"

# NOTE: The `_is_sudoer` check is not suitable here!
[[ `groups $user` =~ "sudo" ]] || {
  [[ -n $install_sudo ]] \
    && install_sudo="$add_sudoer && $install_sudo" \
    || install_sudo="$add_sudoer"
}

[[ -n $install_sudo ]] \
  && INFO "Ensuring sudo for $user as root" \
  && su - -c "$install_sudo" \
  && OK "sudo has been installed for $user" \
  && exit 0

[[ -n $install_sudo ]] \
  && ERR "Can't install sudo for $user" \
  && exit 2

exit 0
