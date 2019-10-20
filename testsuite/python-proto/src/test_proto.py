#!/usr/bin/env python

from __future__ import print_function
import Proto as proto




######################################################################
# main test starts here

try:
    proto.hello ()
    r = proto.add (1, 2)
    print ("Result =", r)

    print ("Done.")
except Exception as detail:
    print ("Unknown exception:", detail)

