# Test assertions.


[[ `type -t OK` != function ]] \
  && . "$(cd "$(dirname $BASH_SOURCE[0])" && pwd)/notifications.sh"


test_true() {

  local cmd="$1"
  local msg="${2:-}"

  $($cmd) && {
    OK "$msg"
    return 0
  }

  ERR "[ \"$cmd\" returns not 0 ] $msg"
  return 1
}


test_false() {

  local cmd="$1"
  local msg="${2:-}"

  $($cmd) || {
    OK "$msg"
    return 0
  }

  ERR "[ \"$cmd\" returns 0 ] $msg"
  return 1
}


test_eq() {

  local x="${1:-}"
  local y="${2:-}"
  local msg="${3:-}"

  [[ "$x" == "$y" ]] && {
    OK "$msg"
    return 0
  }

  ERR "[ \"$x\" == \"$y\" ] $msg"
  return 1
}


test_re() {

  local re="${1:-}"
  local value="${2:-}"
  local msg="${3:-}"

  [[ -z $re ]] && {
    ERR "Empty regexp test!"
    return 2
  }

  echo "$value" | grep -P "$re" &> /dev/null && {
    OK "$msg"
    return 0
  }

  ERR "[ \"$value\" =~ \"$re\" ] $msg"
  return 1
}

