#!/bin/bash

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"

. "$uws/lib/uws/ansible.sh"
. "$uws/lib/uws/set.sh"


# -- Ansible playbook and target {{{

ansible_target="${1:-main}"

playbook="$(playbook_file "$ansible_target")"
target="$(playbook_target "$ansible_target")"

[[ -z "$playbook" ]] && {
  ERR "Playbook is not found: '$ansible_target'!"
  exit 1
}

INFO "Playbook: '$playbook'."

[[ -n "$target" ]] && INFO "Target: '$target'."

# -- Ansible playbook and target }}}


# -- Connection {{{

target_host="${2:-}"

if [[ -z $target_host ]]
then
  connection="--connection=local --inventory=localhost,"
else

  [[ "$target_host" == *@* ]] && user="${target_host%%@*}" || user=""

  [[ -z $user ]] && {
    ERR "No user for remote connection!"
    exit 1
  }

  host="${target_host##*@}"
  auth="${3:---ask-pass}"

  connection="--connection=ssh --inventory=$host, --user=$user $auth"

fi

# -- Connection }}}


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


# FIXME: extra vars are not supported for remote host!
ensure_ansible && ansible-playbook \
  $connection \
  --ask-become-pass \
  --extra-vars="$extra_vars" \
  "$playbook"
