find_python ()
checked_find_package (pybind11 2.4.2 REQUIRED)

set (target_name PyProto)

setup_python_module (TARGET    PyProto
                     MODULE    Proto
                     SOURCES   pyproto.cpp
                     LIBS      Proto ${Boost_LIBRARIES} ${CMAKE_DL_LIBS}
                     )
