#!/bin/bash
BATTERY_PATH="{{ battery_path }}"
capacity="$(cat $BATTERY_PATH/capacity)"
[[ "$(cat $BATTERY_PATH/status)" == "Charging" ]] && charge="+" || charge=""
echo "$capacity%$charge"
