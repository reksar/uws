#!/bin/bash

# gc - grep count (grep + wc).
#
# There must be exacly
count=$3  # occurencies
# of this line pattern
pattern=$2
# in this file
file=$1

[[ "$(grep "$pattern" "$file" | wc -l)" == "$count" ]] && exit 0

exit 1
