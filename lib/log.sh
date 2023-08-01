[[ `type -t ft` != "function" ]] \
  && . "$(cd $(dirname $BASH_SOURCE[0]) && pwd)/ft.sh"


INFO() {
  ftn norm black white "[INFO]"
  ft norm iwhite norm " $1"
}


OK() {
  ftn norm black green "[OK]"
  ft norm igreen norm " $1"
}


WARN() {
  ftn norm black yellow "[WARN]"
  ft norm yellow norm " $1"
}


ERR() {
  ftn norm black red "[ERR]" >&2
  ft norm ired norm " $1" >&2
}
