#!/bin/bash


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/.." && pwd)"
. "$uws/lib/notifications.sh"


glob="${1:-}"
src="${2:-}"
dest="${3:-}"


[[ $# -ne 3 ]] && {
cat << EOF
List of missing files [dest]/[glob], but existing in [src]/[glob]:

  glob_diff.sh [glob] [src] [dest]

EOF
exit 1
}

[[ -d "$src" ]] || {
  ERR "[src] must be a directory!"
  exit 1
}

[[ -d "$dest" ]] || {
  ERR "[dest] must be a directory!"
  exit 1
}


# Exit the script on error.
#
# NOTE: This is not enough to exit on error during the $src_files evaluation
# with using `ls`.
set -e
# NOTE: Declaring var before evaluation allows to break the script on error.
declare src_files


src_files="$(ls "$src/"$glob)"

for i in $src_files
do

  file="$(basename "$i")"

  if [[ ! -f "$dest/$file" ]]
  then
    echo "$file"
  fi

done
