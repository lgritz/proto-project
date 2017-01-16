// Copyright 2017 Larry Gritz (et al)
// MIT open source license, see the LICENSE file of this distribution
// or https://opensource.org/licenses/MIT

#include <iostream>

#include <Proto/Proto.h>


Proto_NAMESPACE_BEGIN

void
hello ()
{
    std::cout << "Hello, world\n";
}



float
add (float a, float b)
{
    return a + b;
}


Proto_NAMESPACE_END
