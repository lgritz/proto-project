fancy_add_executable (LINK_LIBRARIES
                          Proto
                          ${OPENIMAGEIO_LIBRARIES}
                          ${ILMBASE_LIBRARIES}
                          ${SANITIZE_LIBRARIES}
                          ${Boost_LIBRARIES}
                          ${CMAKE_DL_LIBS})
