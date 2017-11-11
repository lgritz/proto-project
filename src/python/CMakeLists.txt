find_python ()
find_or_download_pybind11 ()

set (target_name PyProto)

setup_python_module (TARGET    PyProto
                     MODULE    Proto
                     SOURCES   pyproto.cpp
                     LIBS      Proto ${Boost_LIBRARIES} ${CMAKE_DL_LIBS}
                     )
