set (local_lib Proto)
set (lib_src proto.cpp)

add_library (${local_lib} ${lib_src})
target_link_libraries (${local_lib}
                       INTERFACE
                           OpenImageIO::OpenImageIO
                       PRIVATE
                           ${ILMBASE_LIBRARIES}
                           ${SANITIZE_LIBRARIES}
                           ${Boost_LIBRARIES}
                           ${CMAKE_DL_LIBS})

set_target_properties (${local_lib}
                       PROPERTIES
                           VERSION ${PROJECT_VERSION}
                           SOVERSION ${SOVERSION}
                           POSITION_INDEPENDENT_CODE ON
                      )

if (VISIBILITY_COMMAND)
    set_property (TARGET ${local_lib}
                  APPEND PROPERTY LINK_FLAGS ${VISIBILITY_MAP_COMMAND})
endif ()

install_targets (${local_lib})


# Turn every blah_test.cpp into test unit_blah.
if (BUILD_TESTS)
    file (GLOB test_srcs *_test.cpp)
    foreach (testsrc ${test_srcs})
        get_filename_component (testname ${testsrc} NAME_WE)
        add_executable (${testname} ${testsrc})
        set_target_properties (${testname} PROPERTIES FOLDER "Unit Tests")
        target_link_libraries (${testname}
                               PRIVATE ${local_lib})
        add_test (unit_${testname} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${testname})
    endforeach ()
endif ()
