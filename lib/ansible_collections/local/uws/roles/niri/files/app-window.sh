#!/usr/bin/env bash

# Focus on the Niri window of the specified $app ID. If the related window is
# not exists (or there is no relation between the window and $app), runs the
# new $app instance, assigns the window ID to the $app and focus it.

readonly app="$1"

readonly ASSOCIATED_APP_WINDOWS=/run/user/$UID/niri/app_windows


# Try to focus on the associated window.
#
# WARN: `focus-window` returns the status 0 even if the $associated_window_id
# is not exists! So we check first if the window exists.
readonly associated_window_id=$(cat "$ASSOCIATED_APP_WINDOWS/$app")
niri msg windows | grep "Window ID $associated_window_id:" \
&& niri msg action focus-window --id $associated_window_id \
&& exit 0


# If we got here, there is no a Niri window associated with the $app.


# May be locked when the $app instance is already running.
[[ $associated_window_id == "lock" ]] && exit 1


# We need to run a new $app instance via the $app_cmd.
readonly APP_WINDOW_SETTINGS="$HOME/.config/niri/app_windows"
readonly app_cmd=$(grep -Po "^$app:\K.*" "$APP_WINDOW_SETTINGS")
[[ -z $app_cmd ]] && exit 2


echo lock > "$ASSOCIATED_APP_WINDOWS/$app"


# ID list of the current $app windows. There are may be some $app windows, but
# no one is associated with the $app.
readonly app_window_ids=$(
  niri msg --json windows \
  | jq --arg app_id $app '[.[] | select(.app_id == $app_id) | .id]'
)

get_new_window_id() {
  # Find a new $app window ID, excluding the $app_window_ids.
  # WARN: Can return a string instead of integer!
  niri msg --json windows \
  | jq --raw-output --arg app_id $app --argjson exclude_ids "$app_window_ids" '
    [
      .[] 
      | select(
        .app_id == $app_id and (.id as $id | ($exclude_ids | index($id) | not))
      ) 
      | .id
    ] 
    | last
  '
}

# Run the new $app instance.
$app_cmd &

# Try to get a new Niri window ID.

# Attempts to get an ID when the $app instance starts.
ATTEMPTS=20
readonly RETRY_TIMEOUT_SEC=0.05

sleep $RETRY_TIMEOUT_SEC
new_window_id=$(get_new_window_id)

while [[ $((--ATTEMPTS)) -gt 0 && ! $new_window_id -gt 0 ]]
do
  sleep $RETRY_TIMEOUT_SEC
  new_window_id=$(get_new_window_id)
done


[[ ! $new_window_id -gt 0 ]] && {
  # Unlock.
  echo > "$ASSOCIATED_APP_WINDOWS/$app"
  exit 3
}


niri msg action focus-window --id $new_window_id
[[ -d $ASSOCIATED_APP_WINDOWS ]] || mkdir --parents $ASSOCIATED_APP_WINDOWS
echo $new_window_id > "$ASSOCIATED_APP_WINDOWS/$app"
