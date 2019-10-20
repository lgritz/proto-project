// Copyright 2017 Larry Gritz (et al)
// MIT open source license, see the LICENSE file of this distribution
// or https://opensource.org/licenses/MIT

#include <Proto/Proto.h>

#include <pybind11/pybind11.h>
namespace py = pybind11;


#if PY_MAJOR_VERSION == 2
// Preferred Python string caster for Python2 is py::bytes, so it's a byte
// string (not unicode).
#    define PY_STR py::bytes
#else
// Python3 is always unicode, so return a true str
#    define PY_STR py::str
#endif



namespace PyProto {



// This DECLARE_PYMODULE mojo is necessary if we want to pass in the
// MODULE name as a #define. Google for Argument-Prescan for additional
// info on why this is necessary

#define DECLARE_PYMODULE(x) PYBIND11_MODULE(x, m)

DECLARE_PYMODULE(PYMODULE_NAME)
{
    using namespace pybind11::literals;

    m.def("hello", &Proto::hello);
    m.def("add", &Proto::add, "a"_a, "b"_a);
}

}  // namespace PyProto
