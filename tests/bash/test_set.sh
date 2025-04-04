#!/bin/bash


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../.." && pwd)"
. "$uws/lib/test.sh"
. "$uws/lib/uws/set.sh"


test_eq "$(playbook)" "$uws/playbook/main.yml" \
  "Default playbook must be main."

test_eq "$(playbook app)" "$uws/playbook/app.yml" \
  "Hight level playbook."

test_eq "$(playbook app/vim)" "$uws/playbook/app/vim.yml" \
  "Nested playbook."

test_eq "$(playbook roles/role)" "$uws/playbook/role.yml" \
  "Playbook for a local role."

test_eq "$(playbook roles/namespace.collection.role)" "$uws/playbook/role.yml" \
  "Playbook for a collection role."

test_eq "$(playbook $uws/playbook/main.yml)" "$uws/playbook/main.yml" \
  "Playbook file abs path."

test_eq "$(playbook playbook/main.yml)" "$uws/playbook/main.yml" \
  "Playbook file relative path."

test_eq "$(playbook main.yml)" "$uws/playbook/main.yml" \
  "Playbook file."


test_eq "$(role play)" "" \
  "No role for a playbook."

test_eq "$(role app/play)" "" \
  "No role for a nested playbook."

test_eq "$(role roles/role)" "role" \
  "Local role."

test_eq "$(role roles/namespace.collection.role)" "namespace.collection.role" \
  "Role from a collection."
