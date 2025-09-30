#!/usr/bin/env bash

# Focus the next tile in the column or the first tile in in the next column.
# Cycles last to first tile in the workspace when reaches the end. If the
# 'back' arg is provided, then move focus in the backward direction.

set -eu -o pipefail


[[ ${1:-} == back ]] && readonly back=1 || readonly back=


readonly focused_workspace=$(
  niri msg --json workspaces \
  | jq --raw-output '.[] | select(.is_focused == true) | .id'
)


# Format: '[<column>,<tile>]:<window ID>'.
readonly WINDOW_ENTRY='"\(.layout.pos_in_scrolling_layout):\(.id)"'

# Select windows in the $focused_workspace as the array of sorted strings of
# $WINDOW_ENTRY format.
mapfile -t windows < <(
  niri msg --json windows \
  | jq --raw-output --argjson workspace "$focused_workspace" "
    .[] | select(.workspace_id == \$workspace) | $WINDOW_ENTRY
  " | sort
)
readonly window_count=${#windows[@]}
[[ $window_count -le 1 ]] && exit 1

# A string of $WINDOW_ENTRY format.
readonly focused_window=$(
  niri msg --json windows \
  | jq --raw-output --argjson workspace "$focused_workspace" "
    .[]
    | select(.is_focused == true and .workspace_id == \$workspace)
    | $WINDOW_ENTRY
  "
)


# Index in the $windows array of the $focused_window.
icurrent=-1
for i in "${!windows[@]}"; do
  if [[ "${windows[i]}" == "$focused_window" ]]; then
    icurrent=$i
    break
  fi
done


# Index in the $windows array of the next window to be focused.
[[ -n $back ]] \
  && readonly inext=$(( (icurrent - 1 + $window_count) % $window_count )) \
  || readonly inext=$(( (icurrent + 1) % $window_count ))


readonly next_window="${windows[$inext]}"
readonly next_window_id="${next_window#*:}"
niri msg action focus-window --id $next_window_id
