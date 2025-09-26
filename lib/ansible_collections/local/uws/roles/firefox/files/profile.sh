#!/usr/bin/env bash

# Guess the Firefox user profile. Firefox has not a native method to get the
# default or current user profile. Some empyrical methods are used here.


readonly ff_user_dir="$HOME/.mozilla/firefox"


# First of all, try to detect the user profile used by already running Firefox.

# Write all file descriptors used by all Firefox processes to $fds file.

readonly fds=$(mktemp)

# The native alternative of `lsof` util.
for pid in $(pidof firefox); do
  for fd in /proc/$pid/fd/*; do
    readlink "$fd" 2>/dev/null >> $fds
  done
done

# Try to find one of existing Firefox $profiles in the used $fds.

readonly profiles=$(grep -Po 'Path=\K.*' "$configs/profiles.ini")

for i in $profiles; do
  [[ $(<$fds) == *"$i"* ]] && profile=$i && break
done

rm $fds

[[ -n $profile ]] && echo $profile && exit 0


# A current Firefox profile is not found. Try to guess which should be used.

# Hope that there is only one Firefox installation and the $installs contains
# only one entry with the default profile.

readonly installs="$ff_user_dir/installs.ini"
readonly installs_count=$(grep -c 'Default=.*' "$installs")
profile=$(grep -Po -m1 'Default=\K.*' "$installs")

[[ $installs_count -eq 1 && -d "$ff_user_dir/$profile" ]] \
  && echo "$profile" && exit 0


# In previous step we got either more than 1 entry or not existing profile dir.
# Trying to use a default release profile if it single.

readonly default_profiles=("$ff_user_dir/*.default-release")
[[ ${#default_profiles[@]} -eq 1 ]] && echo ${default_profiles[0]} && exit 0


exit 1
