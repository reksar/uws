#!/bin/bash

# Adds `pyenvrc` to `~/.bashrc`.

uws="$(cd "$(dirname $(readlink -f "$BASH_SOURCE[0]"))/../.." && pwd)"

[[ `type -t ERR` != "function" ]] && . "$uws/lib/log.sh"


bashrc="$HOME/.bashrc"

grep "export PYENV_ROOT=\"\$HOME/.pyenv\"" $bashrc \
  && grep "export PATH=\"\$PYENV_ROOT/bin:" $bashrc \
  && grep "eval \"\$(pyenv init --path)\"" $bashrc \
  && exit 0

pyenvrc="$uws/base/pyenv/pyenvrc"

INFO "Plugging pyenv in $bashrc"
cat $pyenvrc >> $bashrc \
  && OK "pyenv plugged." \
  && exit 0

ERR "Can't plug pyenv in $bashrc"
exit 1
