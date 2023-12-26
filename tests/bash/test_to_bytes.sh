#!/bin/bash


lib="$(cd "$(dirname "$BASH_SOURCE[0]")/../../lib" && pwd)"
. "$lib/test.sh"
. "$lib/units.sh"


test_eq "`to_bytes 0`"       0
test_eq "`to_bytes 1`"       1
test_eq "`to_bytes 1B`"      1
test_eq "`to_bytes 1b`"      1
test_eq "`to_bytes '1 B'`"   1
test_eq "`to_bytes '1 KB'`"  1000
test_eq "`to_bytes 1K`"      1000
test_eq "`to_bytes 1k`"      1000
test_eq "`to_bytes 1KB`"     1000
test_eq "`to_bytes 1Kb`"     1000
test_eq "`to_bytes 1kb`"     1000
test_eq "`to_bytes 1Ki`"     1024
test_eq "`to_bytes 1ki`"     1024
test_eq "`to_bytes 1KiB`"    1024
test_eq "`to_bytes 1kib`"    1024
test_eq "`to_bytes 1Mi`"     1048576
test_eq "`to_bytes '1 MiB'`" 1048576
test_eq "`to_bytes 10M`"     10000000
test_eq "`to_bytes 0TiB`"    0
test_eq "`to_bytes 1TI`"     1099511627776
test_eq "`to_bytes 2i`"
test_eq "`to_bytes 2I`"
test_eq "`to_bytes i`"
test_eq "`to_bytes I`"
test_eq "`to_bytes b`"
test_eq "`to_bytes B`"
test_eq "`to_bytes 1BK`"
test_eq "`to_bytes K`"
test_eq "`to_bytes `"

