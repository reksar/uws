#!/bin/bash

# Wrapper for `ansible-doc` to be applied for a local Ansible collection.

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"
option="${1:-}"

. "$uws/lib/uws/ansible.sh" && ensure_ansible && ansible-doc "$option"
