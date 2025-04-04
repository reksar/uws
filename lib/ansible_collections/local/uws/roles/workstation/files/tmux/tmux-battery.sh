#!/bin/bash

info="$(acpi | grep -Po 'Battery\s*\d+:\s*(?!Unknown)\K\w.*' | head -1)"

# When battery is charging, then '+' suffix will be added after '%'.
[[ "$info" =~ "Discharging" ]] && suffix="" || suffix="+"

charge="$(echo $info | grep -o '[[:digit:]]\+%')"

echo "$charge$suffix"
