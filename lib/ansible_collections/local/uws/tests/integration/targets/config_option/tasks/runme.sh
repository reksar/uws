#!/usr/bin/env bash

set -eux

ansible-playbook main.yml -v "$@"
