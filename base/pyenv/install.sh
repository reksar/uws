#!/bin/bash

# Installs required system packages to build Python, then installs `pyenv` and
# plugs it in `~/.bashrc`.


uws=${uws:-$(cd $(dirname $BASH_SOURCE[0]) && cd .. && cd .. && pwd)}

[[ `type -t ERR` != "function" ]] && . "$uws/lib/log.sh"
[[ `type -t is_exe` != "function" ]] && . "$uws/lib/check.sh"


install_packages_with_apt_get() {

  local packages="
    curl
    wget
    git
    make
    build-essential
    tk-dev
    xz-utils
    zlib1g-dev
    libbz2-dev
    libffi-dev
    liblzma-dev
    libncursesw5-dev
    libreadline-dev
    libsqlite3-dev
    libssl-dev
    libxml2-dev
    libxmlsec1-dev
  "

  INFO "Installing required system packages for pyenv with apt-get."
  sudo "$uws/utils/apt-permit.sh" true \
    && sudo apt-get update \
    && sudo apt-get install -y $packages \
    && sudo "$uws/utils/apt-permit.sh" false \
    && OK "pyenv dependencies are installed." \
    && return 0

  ERR "Can't install required system packages for pyenv!"
  return 1
}


install_packages_with_apt_cyg() {

  local packages="
    alternatives
    curl
    git
    make
    automake
    binutils
    cygwin-devel
    gcc-core
    gcc-g++
    libbz2-devel
    libcurl4
    libcom_err2
    libidn12
    libidn2_0
    libisl23
    libcrypt2
    libcrypt-devel
    libgc1
    libgcrypt20
    libffi8
    libffi-devel
    libgdbm-devel
    libguile3.0_1
    libgpg-error0
    libgssapi_krb5_2
    libk5crypto3
    libkrb5_3
    libkrb5support0
    liblzma-devel
    libmpc3
    libncurses-devel
    libnghttp2_14
    libntlm0
    libopenldap2
    libpkgconf4
    libpsl5
    libreadline7
    libreadline-devel
    libsasl2_3
    libsqlite3_0
    libsqlite3-devel
    libssh2_1
    libssl-devel
    libuuid-devel
    libunistring2
    libunistring5
    libbrotlicommon1
    libbrotlidec1
    libgsasl18
    libzstd1
    pkg-config
    pkgconf
    w32api-runtime
    zlib
    zlib-devel
  "

  INFO "Installing required system packages for pyenv with apt-cyg."
  "$uws/base/apt-cyg/install.sh" \
    && apt-cyg install $packages \
    && OK "pyenv dependencies are installed." \
    && tweak_cygwin_packages \
    && return 0

  ERR "Can't install required system packages for pyenv!"
  return 1
}


tweak_cygwin_packages() {

  INFO "Tweaking Cygwin packages."

  # The linker does not understand `dll.a` extension when building
  # the `_ctypes` Python module.
  #
  # NOTE: copying is important, because creating a link does not work.
  cp /lib/libffi.dll.a /lib/libffi.a

  # Remove unnecessary dir left after installing packages.
  rm -rf /usr/x86_64-pc-cygwin

  OK "Cygwin packages are configured."
}


install_system_packages() {
  # SEE: https://github.com/pyenv/pyenv/wiki#suggested-build-environment
  # NOTE: The llvm package is optional.
  is_exe apt-get && install_packages_with_apt_get && return 0
  is_cygwin && install_packages_with_apt_cyg && return 0
  return 1
}


deploy_pyenv() {

  local pyenv="$HOME/.pyenv"

  [[ -x "$pyenv/bin/pyenv" ]] && [[ `ls "$pyenv/libexec" | wc -l` -gt 20 ]] \
    && return 0

  INFO "Deploying pyenv."
  curl https://pyenv.run | bash \
    && OK "pyenv installed." \
    && return 0

  ERR "Can't deploy pyenv!"
  return 1
}


add_cygwin_hook() {
  # Adds a hook to change the `EXT_SUFFIX` in Python `configure` script when
  # building Python with `pyenv`.
  #
  # The `.pyenv/plugins/python-build/bin/python-build` script has a stub for
  # the `before_install_package()` hook, that is called in the `make_package()`
  # function.
  #
  # Replaces the hook `$stub` in the `$pyenv_script` with the real `$hook`
  # function from `$hook_script` file.
  #
  # NOTE: this hook is fragile, because Cygwin + GCC is not supported by the
  # CPython core team, see https://peps.python.org/pep-0011

  INFO "Adding Cygwin hook for pyenv."

  local pyenv_script=$HOME/.pyenv/plugins/python-build/bin/python-build

  # This `$stub` from the `$pyenv_script` will be replaced with `$hook`.
  local stub="before_install_package() {\n\s*local stub=1\n}"

  # NOTE: edit this file carefully! Mind the conversion of the `$hook_script`
  # contents to the `$hook` substitution string.
  local hook_script="$uws/base/pyenv/before_install_package"

  # Join `$hook_script` lines using "\n" delimiter.
  local hook_line=`sed -z "s/\n/\\\\\n/g" "$hook_script"`

  # Escape chars listed in square brackets using "\". Escaped round brackets
  # are used to translate listed chars with "\1".
  local hook=`echo $hook_line | sed "s/\([&$./\"]\)/\\\\\\\\\1/g"`

  sed -z -i "s/$stub/$hook/" "$pyenv_script"

  OK "pyenv hook added."
}


tweak_pyenv() {

  is_cygwin && {
    add_cygwin_hook || return 1
  }

  return 0
}


install_system_packages \
  && deploy_pyenv \
  && tweak_pyenv \
  && "$uws/base/pyenv/addrc.sh" \
  && exit 0

ERR "Can't install pyenv!"
exit 1
