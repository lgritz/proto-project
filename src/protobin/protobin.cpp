// Copyright Larry Gritz (et al)
// SPDX-License-Identifier: BSD-3-Clause


#include <iostream>

#include <OpenImageIO/argparse.h>

#include <Proto/Proto.h>


int
main(int argc, const char* argv[])
{
    std::cout << Proto_INTRO_STRING << "\n";
    std::cout << Proto_COPYRIGHT_STRING << "\n";
    Proto::hello();
    return 0;
}
