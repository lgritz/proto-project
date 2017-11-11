#!/usr/bin/env python

import Proto as proto




######################################################################
# main test starts here

try:
    proto.hello ()
    r = proto.add (1, 2)
    print "Result =", r

    print "Done."
except Exception as detail:
    print "Unknown exception:", detail

