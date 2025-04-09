#!/usr/bin/env python

import doctest
import sys
from pathlib import Path

uws = Path(__file__).parent.parent.parent
util = f"{uws}/util"

sys.path.insert(0, util)
qemu = __import__("qemu")
del sys.path[0]

failures, _ = doctest.testmod(qemu, verbose=True)
sys.exit(int(bool(failures)))
