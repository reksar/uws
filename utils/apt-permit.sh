#!/bin/bash

# When APT is called from a shell script, it sometimes can't update due to repo
# security reasons.
#
# You can `apt-permit true` to downgrade APT permissions or `apt-permit false`
# to undo.


. "$(cd $(dirname $BASH_SOURCE[0]) && cd .. && pwd)/lib/log.sh"


CONFIG_NAME=99uwspermit
CONFIG=/etc/apt/apt.conf.d/$CONFIG_NAME


false() {

  INFO "Canceling APT permissions."

  [[ ! -f $CONFIG ]] \
    && WARN "APT config not found: $CONFIG_NAME" \
    && return 1

  rm $CONFIG && return 0

  ERR "Can't remove APT config: $CONFIG_NAME"
  return 1
}


true() {

  [[ -f $CONFIG ]] && {
    WARN "Old APT permissions config found: $CONFIG_NAME"
    false || return 1
  }

  INFO "Downgrading APT permissions to modify a repo."
  echo 'Acquire::AllowDowngradeToInsecureRepositories "true";' > $CONFIG \
    && echo 'Acquire::AllowInsecureRepositories "true";' >> $CONFIG \
    && echo 'Acquire::AllowReleaseInfoChange "true";' >> $CONFIG \
    && return 0

  ERR "Can't write APT config!"
  return 1
}


$1 || exit 1
