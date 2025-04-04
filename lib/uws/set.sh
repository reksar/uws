# Utils to parse an <argument> passed to `uws set <argument>`.

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"


role() {
  local arg="${1:-}"
  [[ "$arg" =~ ^roles/ ]] && echo "${arg#roles/}"
}


playbook() {

  local arg="${1:-main}"

  [[ -f "$arg" ]] && echo "$arg" && return
  [[ -f "$uws/$arg" ]] && echo "$uws/$arg" && return
  [[ -f "$uws/playbook/$arg" ]] && echo "$uws/playbook/$arg" && return

  [[ -n $(role "$arg") ]] && local name="role" || local name="$arg"
  local file="$uws/playbook/$name.yml"
  [[ -f "$file" ]] && echo "$file"
}

