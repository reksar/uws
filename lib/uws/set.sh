uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"


role() {
  # Shows a role name without the prefix.
  local alias="${1:-}"
  [[ "$alias" =~ ^roles/ ]] && echo "${alias#roles/}"
}


playbook() {
  # Shows a playbook file path by the specified playbook alias.

  local alias="${1:-}"

  local collection="$uws/lib/ansible_collections/local/uws"
  local playbooks="$collection/playbooks"

  [[ -f "$alias" ]] && echo "$alias" && return
  [[ -f "$collection/$alias" ]] && echo "$collection/$alias" && return
  [[ -f "$playbooks/$alias" ]] && echo "$playbooks/$alias" && return

  [[ -n $(role "$alias") ]] && local name="role" || local name="$alias"
  local file="$playbooks/$name.yml"
  [[ -f "$file" ]] && echo "$file"
}

