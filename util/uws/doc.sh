#!/bin/bash

# Wrapper for for the local `ansible-doc`.

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"

. "$uws/lib/uws/ansible.sh" && ensure_ansible && ansible-doc $@
