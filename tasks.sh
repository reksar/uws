#!/bin/bash

uws="${uws:-$(cd $(dirname $BASH_SOURCE[0]) && pwd)}"
ansible-playbook \
  --inventory=localhost, \
  --connection=local \
  --ask-become-pass \
  --extra-vars="uws='$uws'" \
  $uws/tasks/$1.yml
