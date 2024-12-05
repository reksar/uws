#!/bin/bash

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"

. "$uws/lib/uws/env.sh"

xdg_vars="$(set | grep XDG_ | tr '\n' ' ')"
extra_vars="uws='$uws' $xdg_vars"

ansible-playbook \
  --inventory=localhost, \
  --connection=local \
  --ask-become-pass \
  --extra-vars="$extra_vars" \
  $uws/playbook/$1.yml
