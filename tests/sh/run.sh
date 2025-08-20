#!/bin/bash

# Collect all $TEST_FILES in all nested dirs, modify them by adding the echoing
# the line number of each test function call, then run them.


TEST_FILES="test*.sh"

tests_root="$(cd $(dirname $BASH_SOURCE[0]) && pwd)"
all_test_files="$(find "$tests_root" -name "$TEST_FILES")"


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


rc=0

for file in $test_files
do
  file_relative=${file#$tests_root/}
  file_escaped=${file_relative//\//\\/}
  file_line_prefix="echo -n \"$file_escaped:\$LINENO \"\&\&"

  # Echo a $file_line_prefix for each test function call in a 'test_*' script
  # file and run the modified script in a separate bash env. Then save the
  # result to $out.
  out=$(
    sed "s/\(\(^\|\s\|\W\)test_\)/$file_line_prefix\1/" $file \
    | (cd $(dirname $file) && exec -a $file_relative bash) \
    2>&1
  )

  printf "%s\n" "$out"

  [[ $rc -eq 0 && "$out" == *"ERR"* ]] && rc=1
done

exit $rc
