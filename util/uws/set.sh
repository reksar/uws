#!/bin/bash

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"

. "$uws/lib/uws/ansible.sh"
. "$uws/lib/uws/set.sh"


# -- Parse arg {{{

arg="${1:-main}"

playbook="$(playbook "$arg")"

[[ -z "$playbook" ]] && {
  ERR "Playbook is not found: '$arg'!"
  exit 1
}

INFO "Using the playbook '$playbook'."

role="$(role "$arg")"

[[ -n "$role" ]] && INFO "Using the role '$role'."

# -- Parse arg }}}


# -- Extra vars {{{

[[ -z "${XDG_CONFIG_HOME:-}" ]] && {
  WARN "\$XDG_CONFIG_HOME is not set, using the '$HOME/.config'."
  XDG_CONFIG_HOME="$HOME/.config"
}

# TODO: Make persistent when no XDG utils.
XDG_APP_DIR="$(xdg-user-dir APP)"

xdg_vars="$(set | grep XDG_ | tr '\n' ' ')"
role_var="${role:+role=\'${role}\'}"
extra_vars="uws='$uws' $xdg_vars $role_var"

# -- Extra vars }}}


ensure_ansible && ansible-playbook \
  --inventory=localhost, \
  --connection=local \
  --ask-become-pass \
  --extra-vars="$extra_vars" \
  "$playbook"
