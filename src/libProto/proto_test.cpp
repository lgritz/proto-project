// Copyright 2017 Larry Gritz (et al)
// SPDX-License-Identifier: BSD-3-Clause


#include <OpenImageIO/unittest.h>

#include <Proto/Proto.h>


static void
test_add()
{
    OIIO_CHECK_EQUAL(Proto::add(1.0f, 2.0f), 3.0f);
}



int
main(int argc, const char* argv[])
{
    test_add();
    return unit_test_failures;
}
