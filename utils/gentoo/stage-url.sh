#!/bin/bash

DOWNLOADS_URL="https://www.gentoo.org/downloads"
RELEASES_URL="https://distfiles.gentoo.org/releases"

[[ -z $1 ]] && {
cat << EOF
Prints the URL of the Gentoo stagefile "stage3-[arch]-<*build>.tar.xz":
  stage-url [arch]
Examples:
  stage-url i686-openrc
  stage-url amd64-systemd
  stage-url amd64-desktop-systemd
  stage-url armv7a_hardfp-systemd
EOF
exit 1
}

arch=$1
stagefile_pattern="$RELEASES_URL/[[:alnum:]/]*/stage3-$arch-[[:alnum:]-]*\.tar\.xz"

curl --silent --location $DOWNLOADS_URL \
  | grep --only-matching --max-count 1 "$stagefile_pattern"

