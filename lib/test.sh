# Test assertions.


[[ `type -t OK` != function ]] \
  && . "$(cd $(dirname $BASH_SOURCE[0]) && pwd)/log.sh"


test_eq() {

  x="${1:-}"
  y="${2:-}"
  msg="${3:-}"

  [[ "$x" == "$y" ]] && {
    OK "$msg"
    return 0
  }

  ERR "[ \"$x\" == \"$y\" ] $msg"
  return 1
}
