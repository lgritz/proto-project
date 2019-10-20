// Copyright 2017 Larry Gritz (et al)
// MIT open source license, see the LICENSE file of this distribution
// or https://opensource.org/licenses/MIT

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
