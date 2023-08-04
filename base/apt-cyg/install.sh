#!/bin/bash

uws=${uws:-$(cd $(dirname $BASH_SOURCE[0]) && cd .. && cd .. && pwd)}

[[ `type -t ERR` != "function" ]] && . "$uws/lib/log.sh"
[[ `type -t is_exe` != "function" ]] && . "$uws/lib/check.sh"


has_wget() {
  # Do not use the `is_exe` checker here!
  wget --help > /dev/null 2>&1 && return 0 || return 1
}


ensure_wget() {

  has_wget && return 0

  is_exe curl || {
    # TODO: try getting wget or curl using some Windows downloaders.
    ERR "Can't proceed without wget or curl!"
    return 1
  }

  local url=https://eternallybored.org/misc/wget/1.21.3/64/wget.exe

  # Some Windows ported third-party utils like *curl* or *wget* does not works
  # correctly with the abs UNIX-like paths, so instead of using abs `/path` we
  # need to `cd /` and use the relative path.
  cd /
  local outfile=usr/local/bin/wget.exe

  INFO "Downloading wget with curl."
  curl --silent --output "$outfile" $url || {
    ERR "Can't download wget with curl!"
    return 1
  }

  has_wget && OK "wget ready." && return 0

  ERR "Can't ensure wget!"
  return 1
}


download_apt_cyg() {

  INFO "Downloading apt-cyg."

  ensure_wget || return 1

  # Some ported third-party utils like *curl* or *wget* does not works
  # correctly with the abs UNIX-like paths, so instead of using abs `/path` we
  # need to `cd /` and use the relative path.
  cd /
  local destination=usr/local/bin

  local url=https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg
  wget -P $destination $url \
    && OK "apt-cyg downloaded." \
    && return 0

  ERR "Can't download apt-cyg!"
  return 1
}


is_exe apt-cyg && exit 0
download_apt_cyg || exit 1
is_exe apt-cyg && exit 0

ERR "Can't install apt-cyg!"
exit 2
