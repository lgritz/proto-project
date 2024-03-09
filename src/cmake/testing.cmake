# Copyright Contributors to the Proto project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/lgritz/proto-project

include (CTest)

# Make a build/platform/testsuite directory, and copy the master runtest.py
# there. The rest is up to the tests themselves.
file (MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/testsuite")
#file (COPY "${CMAKE_CURRENT_SOURCE_DIR}/testsuite/common"
#      DESTINATION "${CMAKE_CURRENT_BINARY_DIR}/testsuite")
add_custom_command (OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/testsuite/runtest.py"
                    COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "${CMAKE_CURRENT_SOURCE_DIR}/testsuite/runtest.py"
                        "${CMAKE_CURRENT_BINARY_DIR}/testsuite/runtest.py"
                    MAIN_DEPENDENCY "${CMAKE_CURRENT_SOURCE_DIR}/testsuite/runtest.py")
add_custom_target ( CopyFiles ALL DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/testsuite/runtest.py" )




# add_testsuite_tests() - add a set of test cases.
#
# Usage:
#   add_testsuite_tests ( test1 [ test2 ... ]
#                    [ REQUIRED_DIR name_of_required_directory ]
#                    [ URL http://find.reference.cases.here.com ] )
#
# Additional optional arguments include:
#     FOUNDVAR   specifies the name of a CMAKE variable; if not defined,
#                    the test will not be added for 'make test' (helpful
#                    for excluding tests for libraries not found).
#     REQUIRED_DIR specifies a directory for test images, one level higher
#                    than where the top level source lives -- a
#                    message will be printed if not found.
#     URL        URL where the test images can be found, will be
#                    incorporated into the error message if the test
#                    image directory is not found.
#     LABEL      If set to "broken", will designate the test as one
#                    that is known to be broken, so will only be run
#                    for "make testall", but not "make test".
#
# The optional argument REQUIRED_DIR is used to check whether external test
# materials (not supplied with this distro) are present, and to disable the
# test cases if they're not.  If REQUIRED_DIR is present, URL should also be
# included to tell the user where to find such tests.
#
macro (add_testsuite_tests)
    cmake_parse_arguments (_ats "" "" "URL;REQUIRED_DIR;LABEL;FOUNDVAR;TESTNAME" ${ARGN})
       # Arguments: <prefix> <options> <one_value_keywords> <multi_value_keywords> args...
    set (_ats_testdir "${PROJECT_SOURCE_DIR}/../${_ats_REQUIRED_DIR}")
    # If there was a FOUNDVAR param specified and that variable name is
    # not defined, mark the test as broken.
    if (_ats_FOUNDVAR AND NOT ${_ats_FOUNDVAR})
        set (_ats_LABEL "broken")
    endif ()
    if (_ats_REQUIRED_DIR AND NOT EXISTS ${_ats_testdir})
        # If the directory containig reference data (images) for the test
        # isn't found, point the user at the URL.
        message (STATUS "\n\nDid not find ${_ats_testdir}")
        message (STATUS "  -> Will not run tests ${_ats_UNPARSED_ARGUMENTS}")
        message (STATUS "  -> You can find it at ${_ats_URL}\n")
    else ()
        # Add the tests if all is well.
        set (_has_generator_expr TRUE)
        foreach (_testname ${_ats_UNPARSED_ARGUMENTS})
            set (_testsrcdir "${CMAKE_SOURCE_DIR}/testsuite/${_testname}")
            set (_testdir "${CMAKE_BINARY_DIR}/testsuite/${_testname}")
            if (_ats_TESTNAME)
                set (_testname "${_ats_TESTNAME}")
            endif ()
            if (_ats_LABEL MATCHES "broken")
                set (_testname "${_testname}-broken")
            endif ()

            set (_runtest ${Python_EXECUTABLE} "${CMAKE_SOURCE_DIR}/testsuite/runtest.py" ${_testdir})
            if (MSVC_IDE)
                set (_runtest ${_runtest} --devenv-config $<CONFIGURATION>
                                          --solution-path "${CMAKE_BINARY_DIR}" )
            endif ()

            file (MAKE_DIRECTORY "${_testdir}")

            add_test ( NAME ${_testname}
                       COMMAND ${_runtest} )

            # For texture tests, add a second test using batch mode as well.
            if (_testname MATCHES "texture")
                add_test ( NAME "${_testname}.batch"
                           COMMAND env TESTTEX_BATCH=1 ${_runtest} )
            endif ()

            if (VERBOSE)
                message (STATUS "TEST ${_testname}: ${_runtest}")
            endif ()
        endforeach ()
    endif ()
endmacro ()



# The tests are organized into a macro so it can be called after all the
# directories with plugins are included.
#
macro (proto_add_all_tests)
    # Basic tests that apply even to continuous integration tests:
    # add_testsuite_tests (foo bar)

    # Add tests that require the Python bindings if we built the Python
    # bindings. This is mostly the test that are specifically about testing
    # the Python bindings themselves, but also a handful of tests that are
    # mainly about other things but happen to use Python in order to perform
    # thee test.
    # We also exclude these tests if this is a sanitizer build on Linux,
    # because the Python interpreter itself won't be linked with the right asan
    # libraries to run correctly.
    if (USE_PYTHON)
        if (NOT SANITIZE_ON_LINUX)
            add_testsuite_tests (python-proto)
        endif ()
    endif ()

endmacro()
