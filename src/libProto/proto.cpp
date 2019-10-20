// Copyright 2017 Larry Gritz (et al)
// MIT open source license, see the LICENSE file of this distribution
// or https://opensource.org/licenses/MIT

#include <iostream>

#include <Proto/Proto.h>



void
Proto::hello()
{
    std::cout << "Hello, world\n";
    std::cout.flush();
}



float
Proto::add(float a, float b)
{
    return a + b;
}
