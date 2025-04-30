#!/bin/bash


uws="$(cd "$(dirname "$BASH_SOURCE[0]")/../../.." && pwd)"
. "$uws/lib/test.sh"


glob_diff="$uws/util/glob_diff.sh"


# Requires exactly 3 args.

test_false "$glob_diff" \
  "Error when no args provided."

test_false "$glob_diff a" \
  "Error when 1 arg provided."

test_false "$glob_diff a b" \
  "Error when 2 args provided."

test_false "$glob_diff a b c d" \
  "Error when 4 args provided."


test_false "$glob_diff a b '$uws'" \
  "Error when [src] is not a dir."

test_false "$glob_diff a '$uws' b" \
  "Error when [dest] is not a dir."


test_eq "$($glob_diff '*.md' "$uws" "$uws")" "" \
  "Empty list when [src] == [dest]."


actual="$glob_diff '*.sh' '$uws/util/disk' '.'"
expected="ls '$uws/util/disk/'"

test_eq_stdout_lines "$actual" "$expected" \
  "The \`ls [src]\` is the same when there are no [glob] files at [dest]."


diff="$glob_diff '*.sh' '$uws/util/uws' '$uws/lib/uws'"
expected_names="printf '%s\n' doc.sh test.sh"

test_eq_stdout_lines "$diff" "$expected_names" \
  "Nameset intersection when [src] is util, [dest] is lib."


diff="$glob_diff '*.sh' '$uws/lib/uws' '$uws/util/uws'"
expected_names="printf '%s\n' ansible.sh"

test_eq_stdout_lines "$diff" "$expected_names" \
  "Nameset intersection when [src] is lib, [dest] is util."
