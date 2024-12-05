# Set env vars for 'uws'.

. "$(cd "$(dirname $BASH_SOURCE[0])/.." && pwd)/notifications.sh"

[[ -z "${XDG_CONFIG_HOME:-}" ]] && {
  WARN "\$XDG_CONFIG_HOME is not set, using the '$HOME/.config'."
  XDG_CONFIG_HOME="$HOME/.config"
}

# TODO: Make persistent when no XDG utils.
XDG_APP_DIR="$(xdg-user-dir APP)"
