#!/bin/bash

uws="$(cd "$(dirname "$(readlink -f -- "$BASH_SOURCE")")/../.." && pwd)"
. "$uws/lib/notifications.sh"
notification_title="[Arch syncrepo]"


remote_repo="rsync://mirror.23m.com/archlinux"
filter="$uws/utils/arch/syncrepo.filter"
rsync_opts=(
  --recursive --hard-links --safe-links --copy-links --times --delete-after
  --delete-excluded --info=progress2 --stats --human-readable
)


usage() {
cat << EOF
Usage:
  syncrepo {options} [local repo]
Options:
  -h --help
    This help.
  -f --filter [file]
    Path to a file will be used as the rsync filter. If not provided, then the
    default file will be used:
    $filter
  -i --info
    Do not sync files, just print stats.
EOF
}


argv=()

[[ $# -le 0 ]] && set -- -h

while [[ $# -gt 0 ]]
do
  case $1 in
    -h|--help)
      usage
      exit 1
      ;;
    -f|--filter)
      filter="${2:-}"
      shift
      shift
      ;;
    -i|--info)
      rsync_opts+=(--dry-run)
      shift
      ;;
    -d|--deps)
      WARN "TODO: sync package dependencies"
      shift
      ;;
    -w|--whole)
      WARN "TODO: do not use filter"
      shift
      ;;
    -*)
      ERR "Unknown option '$1'"
      exit 2
      ;;
    *)
      argv+=("$1")
      shift
      ;;
  esac
done

set -- "${argv[@]}"

local_repo="${1:-}"

if [[ -z "$local_repo" ]]
then
  ERR "Local repo dir is not provided"
  exit 2
fi

if [[ ! -d "$local_repo" ]]
then
  ERR "Local repo dir is not found: '$local_repo'"
  exit 2
fi

if [[ ! -f "$filter" ]]
then
  ERR "No filter file '$filter'"
  exit 2
fi

rsync_opts+=(--filter="merge $filter")


rsync "${rsync_opts[@]}" "$remote_repo" "$local_repo"
