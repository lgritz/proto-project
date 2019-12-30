fancy_add_executable (LINK_LIBRARIES
                          Proto
                          OpenImageIO::OpenImageIO
                          ${ILMBASE_LIBRARIES}
                          ${SANITIZE_LIBRARIES}
                          ${Boost_LIBRARIES}
                          ${CMAKE_DL_LIBS})
