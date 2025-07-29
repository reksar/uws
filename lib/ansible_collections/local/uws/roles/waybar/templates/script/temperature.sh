#!/bin/bash
CRITICAL={{ settings.monitoring.temperature.critical }}
t=$(temperature)
[[ $t -gt $CRITICAL ]] && class=critical || class=
printf "$t\n\n$class"
