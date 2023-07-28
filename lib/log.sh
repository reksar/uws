. $(cd $(dirname $BASH_SOURCE[0]) && pwd)/ft.sh


log_info_prefix=[INFO]
log_info_prefix_format="norm black iwhite"
log_info_text_format="norm iwhite norm"

log_ok_prefix=[OK]
log_ok_prefix_format="norm black green"
log_ok_text_format="norm green norm"

log_warn_prefix=[WARN]
log_warn_prefix_format="norm black yellow"
log_warn_text_format="norm yellow norm"

log_err_prefix=[ERR]
log_err_prefix_format="norm black red"
log_err_text_format="norm red norm"


INFO() {
  ftn $log_info_prefix_format $log_info_prefix
  ft $log_info_text_format " $1"
}


OK() {
  ftn $log_ok_prefix_format $log_ok_prefix
  ft $log_ok_text_format " $1"
}


WARN() {
  ftn $log_warn_prefix_format $log_warn_prefix
  ft $log_warn_text_format " $1"
}


ERR() {
  ftn $log_err_prefix_format $log_err_prefix >&2
  ft $log_err_text_format " $1" >&2
}
