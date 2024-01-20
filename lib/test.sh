# Test assertions.


[[ `type -t OK` != function ]] \
  && . "$(cd "$(dirname $BASH_SOURCE[0])" && pwd)/notifications.sh"


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


test_re() {

  re="${1:-}"

  [[ -z $re ]] && {
    ERR "Empty regexp test!"
    return 2
  }

  value="${2:-}"
  msg="${3:-}"

  echo $value | grep -P "$re" > /dev/null && {
    OK "$msg"
    return 0
  }

  ERR "[ \"$value\" =~ \"$re\" ] $msg"
  return 1
}
