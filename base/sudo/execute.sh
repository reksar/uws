#!/bin/bash

uws=${uws:-$(cd $(dirname $BASH_SOURCE[0]) && cd .. && cd .. && pwd)}

[[ `type -t ERR` != "function" ]] && . "$uws/lib/log.sh"
[[ `type -t is_exe` != "function" ]] && . "$uws/lib/check.sh"

if is_sudoer || is_cygwin
then
  "$1" ${2:-}
else

  WARN "Probably the sudo group membership has not been updated!"

  is_exe sg || {
    ERR "Can't run as sudoer: sg not found!"
    return 1
  }

  INFO "Running as a member of the sudo group."
  sg - sudo -c "$1 ${2:-}"
fi
