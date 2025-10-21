#!/bin/bash

# Wrapper for for the local `ansible-doc`.

uws="$(cd "$(dirname $(readlink -f "$BASH_SOURCE[0]"))/../.." && pwd)"

. "$uws/lib/uws/ansible.sh" && ensure_ansible && ansible-doc $@
