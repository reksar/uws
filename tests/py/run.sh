#!/bin/bash
tests_root="$(cd $(dirname $BASH_SOURCE[0]) && pwd)"
$tests_root/test_qemu.py || exit 1
exit 0
