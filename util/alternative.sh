#!/bin/bash

# Wrapper for `update-alternatives`.


max_priority() {

  local name=$1

  # Suppress `stderr` to get empty `info` on err.
  local info=`update-alternatives --query $name 2> /dev/null`

  if [[ $info ]]
  then
    echo $info | grep 'Priority:' | grep -Eo '[0-9]{1,}' | sort -n | tail -1
  else
    echo 0
  fi
}


next_priority() {
  local name=$1
  local priority=`max_priority $name`
  ((priority+=1))
  echo $priority
}


install() {

  local name=$1
  local path="$2"
  local link=/usr/local/bin/$name
  local priority=`next_priority $name`

  update-alternatives --force --install $link $name "$path" $priority \
    && return 0

  return 1
}


$1 $2 "${3:-}" || exit 1
