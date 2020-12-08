// Copyright Larry Gritz (et al)
// SPDX-License-Identifier: BSD-3-Clause


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
