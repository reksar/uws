#!/bin/bash

tests_root=$(cd $(dirname $BASH_SOURCE[0]) && pwd)
all_test_files=$(find "$tests_root" -name "test*.sh")


unset test_files

for specified_file in $@
do
  for test_file in $all_test_files
  do
    matched_file=$(echo $test_file | grep "$specified_file")
    test_files="$test_files $matched_file"
  done
done

[[ $test_files =~ [[:alpha:]] ]] || test_files=$all_test_files


for file in $test_files
do
  file_relative=${file#$tests_root/}
  file_escaped=${file_relative//\//\\/}
  file_line_prefix="echo -n \"$file_escaped:\$LINENO \"\&\&"

  # Add echo'ing a $file_line_prefix to each `test_*` and run the modified
  # script in a separate bash env.
  sed "s/\(\(^\|\s\|\W\)test_\)/$file_line_prefix\1/" $file \
    | (cd $(dirname $file) && exec -a $file_relative bash)
done
