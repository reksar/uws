#!/bin/bash


lib="$(cd "$(dirname "$BASH_SOURCE[0]")/../../lib" && pwd)"
. "$lib/test.sh"
. "$lib/notifications.sh"


# See $__ft__ON and $__ft__OFF in lib/ft.sh
FT_ON_RE="\\033\["
FT_OFF_RE="${FT_ON_RE}0m"


# Empty messages contains prefix only.
test_re "OK" "`OK`"
test_re "INFO" "`INFO`"
test_re "ERR" "`ERR 2>&1`"


# Notifications are formatted: starts with $FT_ON_RE and ends with $FT_OFF_RE.
test_re "^$FT_ON_RE.*$FT_OFF_RE" "`OK`"
test_re "^$FT_ON_RE.*$FT_OFF_RE" "`ERR message 2>&1`"
test_re "^$FT_ON_RE.*$FT_OFF_RE" "`WARN message`"


# Messages.
test_re ".*OK.*ready" "`OK ready`"
test_re ".*ERR.*error" "`ERR error 2>&1`"
test_re ".*WARN.*warning" "`WARN warning`"
test_re ".*INFO.*information" "`INFO information`"

# Messages with spaces.

test_re ".*OK.*two words" "`OK two words`"
test_re "So. More complicated message, contains some punctuation!" \
  "`INFO So. More complicated message, contains some punctuation!`"

test_re "1 2 3" "`OK 1 2 3`" \
  "Regular spaces."

test_re "1 2 3" "`OK "1\x202\x203"`" \
  "Space separated, but using charcode."

test_re "1 2 3" "`OK 1  2   3`" \
  "Extra spaces are omitted."

test_re "1\s\s2\s\s\s3" "`OK "1\x20\x202\x20\x20\x203"`" \
  "Extra spaces are available with the charcode."


# EOL

result="$(OK && echo tail)"
line_count=$(echo "$result" | wc -l)
test_eq $line_count 2 "EOL after prefix when message is empty."

result="$(OK message && echo tail)"
line_count=$(echo "$result" | wc -l)
test_eq $line_count 2 "EOL after message."

result="$(OK ... && echo tail)"
line_count=$(echo "$result" | wc -l)
test_eq $line_count 1 "No EOL after prefix when ends with ellipsis."

result="$(OK some message ... && echo tail)"
line_count=$(echo "$result" | wc -l)
test_eq $line_count 1 "No EOL after message when ends with ellipsis."


# Title

notification_title="Some notification title!"

test_re "$notification_title" "`OK`" \
  "Notification title can be set with the \$notification_title variable."

test_re "Some notification title!.* Message" "`OK Message`" \
  "Notification title follows the prefix and prepends the message."

notification_title=

test_re "OK]$FT_OFF_RE$" "`OK`" \
  "Unset the \$notification_title to unset the notification title."
