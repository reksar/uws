#!/usr/bin/env bash

set -euo pipefail

cmd=${1:-next}
[[ $cmd != next || $cmd != prev ]] && cmd=next

active_workspace=$(
  niri msg -j workspaces | jq -r '.[] | select(.is_focused == true) | .id'
)
[[ -z $active_workspace ]] && exit 0

mapfile -t window_ids < <(
  niri msg -j windows \
  | jq -r --argjson ws "$active_workspace" \
    '.[] | select(.workspace_id == ($ws)) | .id'
)

[[ "${#window_ids[@]}" -eq 0 ]] && exit 0

active_window=$(
  niri msg -j windows \
  | jq -r '.[] | select(.is_focused == true) | .id // empty'
)

active_id=-1
for i in "${!window_ids[@]}"; do
  [[ "${window_ids[$i]}" = "$active_window" ]] && active_id=$i && break
done

if [[ "$active_id" -eq -1 ]]; then
  if [[ "$cmd" = "prev" ]]; then
    target=${window_ids[$(( ${#window_ids[@]} - 1 ))]}
  else
    target=${window_ids[0]}
  fi
else
  if [[ "$cmd" = "prev" ]]; then
    next=$(( (active_id - 1 + ${#window_ids[@]}) % ${#window_ids[@]} ))
  else
    next=$(( (active_id + 1) % ${#window_ids[@]} ))
  fi
  target=${window_ids[$next]}
fi

niri msg action focus-window --id "$target"
