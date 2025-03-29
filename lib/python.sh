[[ `type -t OK` != function ]] \
  && . "$(cd "$(dirname $BASH_SOURCE[0])" && pwd)/notifications.sh"


is_venv() {

  local venv_path="${1:-}"

  [[ -z "${VIRTUAL_ENV:-}" ]] && return 1

  # If this arg is not provided, then only the $VIRTUAL_ENV needs to be set
  # and we done after checking the previous condition.
  [[ -z "$venv_path" ]] && return 0

  # The $venv_path is provided, so we need to check additional conditions.
  [[ "$venv_path" == "$VIRTUAL_ENV" ]] && return 0
  [[ "$PWD/$venv_path" == "$VIRTUAL_ENV" ]] && return 0

  return 1
}


# Usage:
#
#   ensure_venv [venv options] [path]
#
ensure_venv() {

  [[ $# -gt 0 ]] && {
    local options="${@:1:$#-1}"  # All but the last arg
    local venv_path="${@: -1}"  # The last arg
  } || {
    local options=""
    local venv_path=""
  }

  is_venv "$venv_path" \
    && OK "Python venv is already active." \
    && return 0

  [[ -z "$venv_path" ]] \
    && INFO "Using the '$(pwd)/venv' path." \
    && local venv_path="$(pwd)/venv"

  local venv_bin="$venv_path/bin"

  [[ -x "$venv_bin/python" ]] || [[ -f "$venv_bin/activate" ]] && {

    INFO "Activating the existing venv '$venv_path'."
    . "$venv_bin/activate"

    is_venv "$venv_path" \
      && OK "Python venv is active." \
      && return 0

    WARN "Something wrong with the existing venv!"
  }

  [[ -d "$venv_path" ]] \
    && WARN "Removing the existing venv '$venv_path'!" \
    && rm -rf "$venv_path"

  INFO "Creating Python venv in '$venv_path'."
  python -m venv $options "$venv_path" || return 1

  INFO "Activating Python venv '$venv_path'."
  . "$venv_bin/activate"

  is_venv "$venv_path" \
    && OK "Python venv is active." \
    && return 0

  ERR "Unable to ensure the Python venv in '$venv_path'!"
  return 1
}


ensure_pytest() {

  [[ "$(pytest --version 2>/dev/null)" =~ "pytest" ]] || {
    INFO "Installing pytest."
    pip install pytest pytest-xdist pytest-mock execnet
  }

  [[ "$(pytest --version 2>/dev/null)" =~ "pytest" ]] || {
    ERR "Unable to ensure pytest!"
    return 1
  }

  OK "pytest ready."
  return 0
}
