#!/bin/bash

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"

. "$uws/lib/python.sh"
. "$uws/lib/uws/env.sh"
. "$uws/lib/uws/ansible.sh"

ensure_venv "$uws/venv" || exit 1
ensure_ansible || exit 1

xdg_vars="$(set | grep XDG_ | tr '\n' ' ')"
extra_vars="uws='$uws' $xdg_vars"

ansible-playbook \
  --inventory=localhost, \
  --connection=local \
  --ask-become-pass \
  --extra-vars="$extra_vars" \
  $uws/playbook/$1.yml
