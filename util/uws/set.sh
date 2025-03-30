#!/bin/bash

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"

. "$uws/lib/uws/env.sh"
. "$uws/lib/uws/ansible.sh"

ensure_ansible || exit 1

# Playbook {{{
playbook="${1:-main}"

[[ -f "$playbook" ]] || {
  INFO "Determining the '$playbook' playbook path."
  playbook="$uws/playbook/$playbook.yml"

  [[ -f "$playbook" ]] || {
    ERR "Playbook is not found: '$playbook'!"
    exit 2
  }

  OK "Using the '$playbook'"
}
# Playbook }}}

# Extra vars {{{
xdg_vars="$(set | grep XDG_ | tr '\n' ' ')"
extra_vars="uws='$uws' $xdg_vars"
# Extra vars }}}

ansible-playbook \
  --inventory=localhost, \
  --connection=local \
  --ask-become-pass \
  --extra-vars="$extra_vars" \
  "$playbook"
