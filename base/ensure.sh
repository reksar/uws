#!/bin/bash

uws="$(cd "$(dirname $(readlink -f "$BASH_SOURCE[0]"))/.." && pwd)"

[[ `type -t ERR` != "function" ]] && . "$uws/lib/log.sh"
. "$uws/base/python/ensure.sh"

ensure_python || exit 1

INFO "Testing Python ..."
python --version
