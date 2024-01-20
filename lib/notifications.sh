[[ `type -t ft` != function ]] \
  && . "$(cd "$(dirname $BASH_SOURCE[0])" && pwd)/ft.sh"


__notifications__INFO_PREFIX="[INFO]"
__notifications__OK_PREFIX="[OK]"
__notifications__WARN_PREFIX="[WARN]"
__notifications__ERR_PREFIX="[ERR]"


INFO() {
  [[ "${1:-}" == ... ]] && shift \
    || ftn norm black white "$__notifications__INFO_PREFIX"
  msg="${1:-}" && shift
  [[ "${1:-}" == ... ]] && show=ftn || show=ft
  $show norm iwhite norm " $msg"
}


OK() {
  [[ "${1:-}" == ... ]] && shift \
    || ftn norm black green "$__notifications__OK_PREFIX"
  msg="${1:-}" && shift
  [[ "${1:-}" == ... ]] && show=ftn || show=ft
  $show norm igreen norm " $msg"
}


WARN() {
  [[ "${1:-}" == ... ]] && shift \
    || ftn norm black yellow "$__notifications__WARN_PREFIX"
  msg="${1:-}" && shift
  [[ "${1:-}" == ... ]] && show=ftn || show=ft
  $show norm yellow norm " $msg"
}


ERR() {
  [[ "${1:-}" == ... ]] && shift \
    || ftn norm black red "$__notifications__ERR_PREFIX" >&2
  msg="${1:-}" && shift
  [[ "${1:-}" == ... ]] && show=ftn || show=ft
  $show norm ired norm " $msg" >&2
}
