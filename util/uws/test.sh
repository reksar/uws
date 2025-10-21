#!/bin/bash

uws="$(cd "$(dirname $(readlink -f "$BASH_SOURCE[0]"))/../.." && pwd)"
option="${1:-}"

. "$uws/lib/uws/ansible.sh"


run_ansible_tests() {
  ensure_ansible || return 1
  ensure_pytest || return 1
  cd "$uws/lib/ansible_collections/local/uws" \
    && ansible-test units --target-python default \
    && ansible-test integration \
    && return 0
  return 1
}


case $option in

  sh)
    $uws/tests/sh/run.sh && exit 0
    ;;

  py)
    $uws/tests/py/run.sh && exit 0
    ;;

  ansible)
    run_ansible_tests && exit 0
    ;;

  *)
    $uws/tests/sh/run.sh && $uws/tests/py/run.sh && run_ansible_tests && exit 0
    ;;
esac

exit 1
