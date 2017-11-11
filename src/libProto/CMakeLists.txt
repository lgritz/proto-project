set (local_lib Proto)
set (lib_src proto.cpp)

add_library (${local_lib} ${LIBRARY_BUILD_TYPE} ${lib_src})
target_link_libraries (${local_lib} ${SANITIZE_LIBRARIES})
target_link_libraries (${local_lib} ${OPENIMAGEIO_LIBRARIES})
target_link_libraries (${local_lib} ${ILMBASE_LIBRARIES})
target_link_libraries (${local_lib} ${Boost_LIBRARIES})

set_target_properties (${local_lib}
                       PROPERTIES
                       VERSION ${PROJECT_VERSION}
                       SOVERSION ${SOVERSION}
                      )

if (VISIBILITY_COMMAND)
    set_target_properties (${local_lib}
                           PROPERTIES
                           LINK_FLAGS "${VISIBILITY_COMMAND} ${VISIBILITY_MAP_COMMAND}")
endif ()

install_targets (${local_lib})


# Turn every blah_test.cpp into test unit_blah.
if (BUILD_TESTS)
    file (GLOB test_srcs *_test.cpp)
    foreach (testsrc ${test_srcs})
        get_filename_component (testname ${testsrc} NAME_WE)
        add_executable (${testname} ${testsrc})
        set_target_properties (${testname} PROPERTIES FOLDER "Unit Tests")
        target_link_libraries (${testname} ${local_lib}
                               ${OPENIMAGEIO_LIBRARIES} ${OPENEXR_LIBRARIES}
                               ${Boost_LIBRARIES})
        add_test (unit_${testname} ${testname})
    endforeach ()
endif ()
