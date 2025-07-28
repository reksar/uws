#!/bin/bash
CRITICAL=70
t=$(temperature)
[[ $t -gt $CRITICAL ]] && class=critical || class=
printf "$t\n\n$class"
