#!/bin/bash

# Ensures that `python --version` >= `min_python_version`.
# Must be included due to pyenv ensuring.


uws="$(cd "$(dirname $(readlink -f "$BASH_SOURCE[0]"))/../.." && pwd)"

[[ `type -t ERR` != "function" ]] && . "$uws/lib/log.sh"
[[ `type -t is_exe` != "function" ]] && . "$uws/lib/check.sh"
[[ `type -t ensure_pyenv` != "function" ]] && . "$uws/base/pyenv/ensure.sh"


min_python_version() {
  grep -oP "min_python_version:\s*(\d+\.){0,}\d+" "$uws/settings.yml" \
  | grep -oP "[\d\.]+$" \
    || echo 3
}


check_python() {
  local python=${1:-python}
  is_exe $python && $python "$uws/util/version.py" `min_python_version` \
    && return 0
  return 1
}


update_alternatives() {

  INFO "Adding python3 as an alternative to python."
  sudo "$uws/util/alternative.sh" install python "`which python3`" \
    && OK "python is now an alias for python3." \
    && return 0

  ERR "Can't assign python3 as python!"
  return 1
}


rename_lib_config_dir() {
  # Renames dir `.pyenv/versions/x.y.z/lib/pythonx.y/config-x.y`
  # to `.pyenv/versions/x.y.z/lib/pythonx.y/config`.

  local version_xyz=$1
  local version_xy=$2

  local lib="$HOME/.pyenv/versions/$version_xyz/lib/python$version_xy"

  [ ! -d "$lib" ] \
    && ERR "Python lib dir not found: $lib" \
    && return 3

  [ -d "$lib/config" ] \
    && INFO "Python lib config already has a valid name." \
    && return 0

  local config_pattern=config-$version_xy*
  local config=`ls -d1 "$lib"/$config_pattern | head -1`

  [ ! -d "$config" ] \
    && ERR "Dir not found: $lib/$config_pattern" \
    && return 4

  cp -r "$config" "$lib/config" && rm -rf "$config" && return 0

  ERR "Can't rename $config"
  return 5
}


copy_libpython_for_cygwin() {

  local version_xyz=$1
  local version_xy=$2

  local lib="$HOME/.pyenv/versions/$version_xyz/lib"

  local libpython=libpython$version_xy.dll.a

  local destination_file="$lib/$libpython"

  [ -e "$destination_file" ] \
    && OK "Already exists: $destination_file" \
    && return 0

  local source_file="$lib/python$version_xy/config/$libpython"

  [ ! -e "$source_file" ] \
    && ERR "Not found: $source_file" \
    && return 1

  cp "$source_file" "$destination_file" && return 0

  ERR "Can't copy $source_file to $lib"
  return 2
}


rebase_libpython_for_cygwin() {
  # Fixes the availability of memory address space for this lib.

  local version_xyz=$1
  local version_xy=$2

  local filename="libpython$version_xy.dll"
  local libpython="$HOME/.pyenv/versions/$version_xyz/bin/$filename"

  rebase --database "$libpython" && return 0

  ERR "Can't update rebase database for libpython DLL."
  return 1
}


tweak_python_lib_for_cygwin() {
  # This is a logical continuation of the `modify_ext_suffix()` from the
  # `$scripts/install/pyenv/before_install_package`, but this part can be done
  # without modifying `pyenv`.

  local version_xyz=$1

  [[ ! $version_xyz =~ ^[0-9]+.[0-9]+.[0-9]+$ ]] \
    && ERR "Python version $version_xyz does follow the X.Y.Z format!" \
    && return 1

  local version_xy=${version_xyz%.*}

  [[ ! $version_xy =~ ^[0-9]+.[0-9]+$ ]] \
    && ERR "Can't reduce the Python version to X.Y" \
    && return 2

  rename_lib_config_dir $version_xyz $version_xy || return 3
  copy_libpython_for_cygwin $version_xyz $version_xy || return 4
  rebase_libpython_for_cygwin $version_xyz $version_xy || return 5
  return 0
}


tweak_python() {

  # Tweak the Python installed in `.pyenv/versions/$version`.
  local version=$1

  _is_cygwin && {
    tweak_python_lib_for_cygwin $version && return 0 || return 1
  }

  return 0
}


install_python_with_pyenv() {

  ensure_pyenv || return 1

  # Latest matched Python version available with `pyenv`.
  local version=`
    pyenv install -l | grep "^\s*$(min_python_version)[.0-9]*$" | tail -1
  `

  INFO "Checking that Python $version is installed with pyenv."
  pyenv versions | grep $version \
    && pyenv global $version \
    && OK "Python $version was set as pyenv global." \
    && return 0

  INFO "Installing Python $version with pyenv."
  pyenv install $version \
    && pyenv global $version \
    && tweak_python $version \
    && OK "Python $version installed as pyenv global." \
    && return 0

  ERR "Can't install the Python $version with pyenv!"
  return 2
}


install_python_with_apt_get() {

  INFO "Installing Python with apt-get."
  sudo "$uws/util/apt-permit.sh" true \
    && sudo apt-get update \
    && sudo apt-get install -y python3 \
    && sudo "$uws/util/apt-permit.sh" false \
    && OK "Python installed." \
    && return 0

  ERR "Can't install Python with apt-get!"
  return 1
}


install_python_with_apt_cyg() {
  "$uws/base/apt-cyg/install.sh" || return 1
  WARN "TODO: install_python_with_apt_cyg"
  return 1
}


install_system_python() {
  is_exe apt-get && install_python_with_apt_get && return 0
  _is_cygwin && install_python_with_apt_cyg && return 0
  return 1
}


install_python() {
  [[ `min_python_version` == 3 ]] && install_system_python && return 0
  install_python_with_pyenv && return 0
  return 1
}


ensure_python() {

  check_python && return 0
  check_python python3 && update_alternatives && check_python && return 0

  install_python || return 1

  check_python && return 0
  check_python python3 && update_alternatives && check_python && return 0

  ERR "Can't ensure Python!"
  return 2
}
