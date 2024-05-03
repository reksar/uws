[[ `type -t ft` != function ]] \
  && . "$(cd "$(dirname $BASH_SOURCE[0])" && pwd)/ft.sh"


declare -A __notifications__=()

__notifications__["INFO"]="local PREFIX='[INFO]'"
__notifications__["INFO"]+=";local PREFIX_COLOR='norm black white'"
__notifications__["INFO"]+=";local MSG_COLOR='norm iwhite norm'"

__notifications__["OK"]="local PREFIX='[OK]'"
__notifications__["OK"]+=";local PREFIX_COLOR='norm black green'"
__notifications__["OK"]+=";local MSG_COLOR='norm igreen norm'"

__notifications__["WARN"]="local PREFIX='[WARN]'"
__notifications__["WARN"]+=";local PREFIX_COLOR='norm black yellow'"
__notifications__["WARN"]+=";local MSG_COLOR='norm yellow norm'"

__notifications__["ERR"]="local PREFIX='[ERR]'"
__notifications__["ERR"]+=";local PREFIX_COLOR='norm black red'"
__notifications__["ERR"]+=";local MSG_COLOR='norm ired norm'"


__notifications__notify() {

  # First arg is required and must be the msg type: INFO, OK, WARN, ERR.
  local msg_type=$1
  # All remaining arg starting from the $MSG_START are parts of the $msg.
  # When only 1 arg is passed, the $msg will be empty and only the notification
  # prefix will be shown.
  local MSG_START=2
  # The $last arg can be "...". In this case, it will not be appended to $msg
  # and no EOL will be added after the notification.
  local last="${@:$#:1}"

  # Must contain local vars: PREFIX, PREFIX_COLOR, MSG_COLOR.
  local settings=${__notifications__[$msg_type]}
  eval $settings

  # Show notification prefix. Can include a title. No EOL!
  ftn $PREFIX_COLOR "$PREFIX${notification_title:-}"

  [[ $# -lt $MSG_START ]] && echo && return

  # Message args overcount after the $MSG_START. Must be >= 0!
  local overcount=$(($# - $MSG_START))

  # Join the message args.
  local msg=""
  for arg in ${@:$MSG_START:$overcount}
  do
    local msg+=" $arg"
  done

  # When the last arg is "...", do not append it and EOL to the $msg.
  [[ "$last" == "..." ]] && {
    local ft=ftn
  } || {
    local ft=ft
    local msg+=" $last"
  }

  # Show notification message.
  $ft $MSG_COLOR "$msg"
}


INFO() {
  __notifications__notify INFO $@
}


OK() {
  __notifications__notify OK $@
}


WARN() {
  __notifications__notify WARN $@
}


ERR() {
  __notifications__notify ERR $@ >&2
}
