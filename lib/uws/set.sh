uws="$(cd "$(dirname $(readlink -f "$BASH_SOURCE[0]"))/../.." && pwd)"


playbook_name() {
  # Shows a playbook file base name (can be prepended by nested dirs) from the
  # specified `uws set <alias>`.

  local alias="${1:-}"

  local prefix

  for prefix in "roles" "tasks"
  do
    [[ "$alias" =~ ^$prefix/ ]] && echo "$prefix" && return
  done

  echo "$alias"
}


playbook_target() {
  local alias="${1:-}"
  local name="$(playbook_name "$alias")"
  [[ "$name" == "$alias" ]] || echo "${alias#$name/}"
}


playbook_file() {
  # Shows a playbook file path (if found) from the specified `uws set <alias>`.

  local alias="${1:-}"

  local collection="$uws/lib/ansible_collections/local/uws"
  local playbooks="$collection/playbooks"

  [[ -f "$alias" ]] && echo "$alias" && return
  [[ -f "$collection/$alias" ]] && echo "$collection/$alias" && return
  [[ -f "$playbooks/$alias" ]] && echo "$playbooks/$alias" && return

  local name="$(playbook_name "$alias")"
  local file="$playbooks/$name.yml"
  [[ -f "$file" ]] && echo "$file"
}

