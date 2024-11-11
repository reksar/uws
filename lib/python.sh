[[ `type -t OK` != function ]] \
  && . "$(cd "$(dirname $BASH_SOURCE[0])" && pwd)/notifications.sh"


is_venv() {
  local venv_path="${1:-}"
  [[ -z "${VIRTUAL_ENV:-}" ]] && return 1
  [[ -z "$venv_path" ]] && return 0
  [[ "$venv_path" == "$VIRTUAL_ENV" ]] && return 0
  [[ "$PWD/$venv_path" == "$VIRTUAL_ENV" ]] && return 0
  return 1
}


ensure_venv() {

  local venv_path="${1:-}"

  is_venv "$venv_path" \
    && OK "Python venv is already active." \
    && return 0

  [[ -z "$venv_path" ]] \
    && INFO "Setting the \$PWD/venv path." \
    && local venv_path="$(pwd)/venv"

  local venv_bin="$venv_path/bin"

  [[ ! -x "$venv_bin/python" ]] || [[ ! -f "$venv_bin/activate" ]] && {
    INFO "Creating Python venv in '$venv_path'."
    python -m venv "$venv_path" || return 1
  }

  INFO "Activating Python venv."
  . "$venv_bin/activate"

  is_venv "$venv_path" \
    && OK "Python venv is active." \
    && return 0

  ERR "Unable to activate Python venv in '$venv_path'!"
  return 1
}
