#!/bin/bash

uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../../.." && pwd)"
. "$uws/lib/test.sh"
. "$uws/lib/uws/set.sh"


test_eq "$(playbook_name simple_alias)" "simple_alias" \
  "Playbook name for a simple alias is the same."

test_eq "$(playbook_name some/nested/playbook)" "some/nested/playbook" \
  "Playbook name for nested alias is the same."

test_eq "$(playbook_name roles/role_name)" "roles" \
  "Playbook name for a role."

test_eq "$(playbook_name roles/namespace.collection.role)" "roles" \
  "Playbook name for a role from a collection."

test_eq "$(playbook_name tasks/some_tasks)" "tasks" \
  "Playbook name for a tasks from roles."

test_eq "$(playbook_name tasks/subdir/some_tasks)" "tasks" \
  "Playbook name for a nested tasks."


test_eq "$(playbook_target simple_alias)" "" \
  "No playbook target for a simple alias."

test_eq "$(playbook_target some/nested/playbook)" "" \
  "No playbook target for a nested alias."

test_eq "$(playbook_target roles/some_role)" "some_role" \
  "Playbook target for a role."

test_eq "$(playbook_target roles/local.uws.role)" "local.uws.role" \
  "Playbook target for a role from a collection."

test_eq "$(playbook_target tasks/app/tmux)" "app/tmux" \
  "Playbook target for a tasks."


playbooks="$uws/lib/ansible_collections/local/uws/playbooks"

test_eq "$(playbook_file)" "" \
  "Empty playbook by default."

test_eq "$(playbook_file not/existing)" "" \
  "Empty playbook when not found."

test_eq "$(playbook_file main)" "$playbooks/main.yml" \
  "High level playbook."

test_eq "$(playbook_file main.yml)" "$playbooks/main.yml" \
  "High level playbook file."

test_eq "$(playbook_file app/vim)" "$playbooks/app/vim.yml" \
  "Nested playbook path."

test_eq "$(playbook_file roles/role)" "$playbooks/roles.yml" \
  "Playbook for a role."

test_eq "$(playbook_file roles/local.uws.role)" "$playbooks/roles.yml" \
  "Playbook for a role from the specified collection."

test_eq "$(playbook_file "$playbooks/main.yml")" "$playbooks/main.yml" \
  "Playbook abs path."

test_eq "$(playbook_file playbooks/main.yml)" "$playbooks/main.yml" \
  "Playbook file relative path."

test_eq "$(playbook_file tasks/app/tmux)" "$playbooks/tasks.yml" \
  "Playbook for a tasks from roles."
