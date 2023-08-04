# Must be included in another script to provide a pyenv environment when pyenv
# was not been inited with `~/.bashrc`.
#
# Inits `pyenv` if the shell was not restarted after installing `pyenv`.
# The `~/.bashrc` usually prevents non-interactive execution, so `pyenvrc`
# is used instead.


uws=${uws:-$(cd $(dirname $BASH_SOURCE[0]) && cd .. && cd .. && pwd)}

[[ `type -t ERR` != "function" ]] && . "$uws/lib/log.sh"
[[ `type -t is_exe` != "function" ]] && . "$uws/lib/check.sh"


ensure_pyenv() {

  is_exe pyenv && return 0
  . "$uws/base/pyenv/pyenvrc"
  is_exe pyenv && return 0

  "$uws/base/pyenv/install.sh" || return 1

  is_exe pyenv && return 0

  ERR "Cannot ensure pyenv!"
  return 2
}
