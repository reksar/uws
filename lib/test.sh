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

  $($cmd &>/dev/null) || {
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


test_eq_stdout_lines() {

  local msg="${3:-Two sets must be equal!}"

  # Test that the $cmd1 and $cmd2 outputs the same set of lines to `stdout`,
  # ignoring the order.
  local cmd1=$1
  local cmd2=$2

  local arr1
  local arr2
  mapfile -t arr1 < <(bash -c "$cmd1")
  mapfile -t arr2 < <(bash -c "$cmd2")

  local tmp1=$(mktemp)
  local tmp2=$(mktemp)

  for i in "${arr1[@]}"
  do
    echo "$i" >> "$tmp1"
  done

  for i in "${arr2[@]}"
  do
    echo "$i" >> "$tmp2"
  done

  local diff=$(diff <(sort "$tmp1") <(sort "$tmp2"))

  rm "$tmp1" "$tmp2"

  [[ -z $diff ]] && {
    OK "$msg"
    return 0
  }
  
  ERR "$msg"
  ERR "$diff"
  return 1
}

