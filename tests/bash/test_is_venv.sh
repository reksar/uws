#!/bin/bash


lib="$(cd "$(dirname "$BASH_SOURCE[0]")/../../lib" && pwd)"
. "$lib/test.sh"
. "$lib/python.sh"


test_false "is_venv" \
  "No active Python venv initially (deactivate any venv before test)."

test_false "is_venv some/path" \
  "Passing the path for unactive venv."

VIRTUAL_ENV=$PWD/stub/path/to/venv

test_true "is_venv" \
  "Python venv stub is active."

test_true "is_venv $VIRTUAL_ENV" \
  "Passing the active venv path."

test_true "is_venv stub/path/to/venv" \
  "Valid relative path."

test_false "is_venv /stub/path/to/venv" \
  "Relative path set as absolute by mistake."

test_false "is_venv /stub/path/to/venv" \
  "Incomplete relative path."
