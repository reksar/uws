#!/bin/bash

tests_root=$(cd $(dirname $BASH_SOURCE[0]) && pwd)

for file in $(ls -1d $(find "$tests_root" -name "test*.sh"))
do
  file_relative=${file#$tests_root/}
  file_escaped=${file_relative//\//\\/}
  file_line_prefix="echo -n \"$file_escaped:\$LINENO \"\&\&"

  # Add echo'ing a $file_line_prefix to each `test_*` and run the modified
  # script in a separate bash env.
  sed "s/\(\(^\|\s\|\W\)test_\)/$file_line_prefix\1/" $file \
    | (cd $(dirname $file) && exec -a $file_relative bash)
done
