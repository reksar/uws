#!/bin/bash

uws="${uws:-$(cd "$(dirname $BASH_SOURCE[0])/../.." && pwd)}"
option="${1:-}"

. "$uws/lib/uws/ansible.sh"

case $option in

  bash)
    $uws/tests/bash/run.sh
    ;;

  ansible)
    ensure_ansible || exit 1
    ensure_pytest || exit 1
    lib=$(
      ansible-config dump \
      | grep ANSIBLE_COLLECTIONS_PATH \
      | grep --perl-regexp --only-matching "'$uws.*?'" \
      | tr --delete "'"
    )
    cd "$lib/ansible_collections/local/uws" \
      && ansible-test units --target-python default \
      && ansible-test integration
    ;;

  *)
    # TODO: Run all tests when no option passed.
    WARN "Specify test option: bash or ansible."
    ;;
esac
