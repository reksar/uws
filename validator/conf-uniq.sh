#!/bin/bash

# There must be exacly 1 occurency of this settings
unique_setting=$1
# in this file
conf_file=$2
cp $2 /root/test

count=$(grep "^\s*$unique_setting\s*$" "$conf_file" | wc -l)
rc=$((count - 1))
exit $rc
