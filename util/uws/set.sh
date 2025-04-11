#!/bin/bash

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"

. "$uws/lib/uws/ansible.sh"
. "$uws/lib/uws/set.sh"


arg="${1:-main}"

playbook="$(playbook_file "$arg")"
target="$(playbook_target "$arg")"

[[ -z "$playbook" ]] && {
  ERR "Playbook is not found: '$arg'!"
  exit 1
}

INFO "Playbook: '$playbook'."

[[ -n "$target" ]] && INFO "Target: '$target'."


# -- Extra vars {{{

[[ -z "${XDG_CONFIG_HOME:-}" ]] && {
  WARN "\$XDG_CONFIG_HOME is not set, using the '$HOME/.config'."
  XDG_CONFIG_HOME="$HOME/.config"
}

# TODO: Make persistent when no XDG utils.
XDG_APP_DIR="$(xdg-user-dir APP)"

xdg_vars="$(set | grep XDG_ | tr '\n' ' ')"
playbook_target="${target:+playbook_target=\'${target}\'}"
extra_vars="uws='$uws' $playbook_target $xdg_vars"

# -- Extra vars }}}


ensure_ansible && ansible-playbook \
  --inventory=localhost, \
  --connection=local \
  --ask-become-pass \
  --extra-vars="$extra_vars" \
  "$playbook"
