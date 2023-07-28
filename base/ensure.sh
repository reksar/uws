#!/bin/bash

uws=${uws:-$(cd $(dirname $(dirname $BASH_SOURCE[0])) && pwd)}

. "$uws/lib/log.sh"

INFO "Testing sudo ..."
sudo ls /
