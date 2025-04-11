#!/bin/bash


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../.." && pwd)"
playbooks="$uws/lib/ansible_collections/local/uws/playbooks"
. "$uws/lib/test.sh"
. "$uws/lib/uws/set.sh"


test_eq "$(playbook)" "" \
  "Empty playbook by default."

test_eq "$(playbook not/existing)" "" \
  "Empty playbook when not found."

test_eq "$(playbook main)" "$playbooks/main.yml" \
  "High level playbook."

test_eq "$(playbook main.yml)" "$playbooks/main.yml" \
  "High level playbook file."

test_eq "$(playbook app/vim)" "$playbooks/app/vim.yml" \
  "Nested playbook path."

test_eq "$(playbook roles/role)" "$playbooks/role.yml" \
  "Playbook for a role from the 'local.uws' collection."

test_eq "$(playbook roles/namespace.collection.role)" "$playbooks/role.yml" \
  "Playbook for a role from the specified collection."

test_eq "$(playbook $playbooks/main.yml)" "$playbooks/main.yml" \
  "Playbook abs path."

test_eq "$(playbook playbooks/main.yml)" "$playbooks/main.yml" \
  "Playbook file relative path."


test_eq "$(role play)" "" \
  "No role for a playbook."

test_eq "$(role app/play)" "" \
  "No role for a nested playbook."

test_eq "$(role roles/role)" "role" \
  "Local role."

test_eq "$(role roles/namespace.collection.role)" "namespace.collection.role" \
  "Role from a collection."
