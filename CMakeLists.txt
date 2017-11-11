# Define the name of the project and the release version
cmake_minimum_required (VERSION 3.2.2)
cmake_policy (SET CMP0048 NEW)  # Allow VERSION specifier in project()
project (Proto
         VERSION 1.0.0
         LANGUAGES CXX C)
set (PROJ_NAME ${PROJECT_NAME})    # optional short name
string (TOLOWER ${PROJ_NAME} PROJ_NAME_LOWER)  # short name lower case
set (PROJECT_VERSION_RELEASE_TYPE "dev")   # "dev", "betaX", "RCY", ""
set (${PROJECT_NAME}_VERSION_RELEASE_TYPE ${PROJECT_VERSION_RELEASE_TYPE})
set (PROJECT_COPYRIGHTYEARS "2017")
set (PROJECT_AUTHORS "Main Author et al")
set (PROJECT_URL "")

set (PROJECT_VERSION_MAJORMINOR
     "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
message (STATUS "Building ${PROJECT_NAME} ${PROJECT_VERSION}")
message (STATUS "CMake version is ${CMAKE_VERSION}")
cmake_policy (SET CMP0017 NEW)  # Prefer files from the CMake module directory when including from there.
cmake_policy (SET CMP0025 NEW)  # Detect AppleClang for new CMake
cmake_policy (SET CMP0046 OLD)  # Don't error on non-existent dependency in add_dependencies.
set (CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS TRUE)

# N.B./FIXME - after CMake 3.0 is our minimum, we should change many of the
# add_definitions to add_compile_options. In newer cmake versions, the
# former is designated for definitions (-Dblah) and the latter is for
# compile flags (-Wno-foo).

if (VERBOSE)
    message (STATUS "Project source dir = ${PROJECT_SOURCE_DIR}")
endif ()
message (STATUS "Project build dir   = ${CMAKE_BINARY_DIR}")
message (STATUS "Project install dir = ${CMAKE_INSTALL_PREFIX}")

if ("${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message (FATAL_ERROR "Not allowed to run in-source build!")
endif ()

if (NOT CMAKE_BUILD_TYPE)
    set (CMAKE_BUILD_TYPE "Release")
endif ()
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set (DEBUGMODE ON)
endif ()

option (CMAKE_USE_FOLDERS "Use the FOLDER target property to organize targets into folders." ON)
mark_as_advanced (CMAKE_USE_FOLDERS)
if (CMAKE_USE_FOLDERS)
    set_property (GLOBAL PROPERTY USE_FOLDERS ON)
endif ()

include (GNUInstallDirs)

set (CMAKE_MODULE_PATH
     "${PROJECT_SOURCE_DIR}/src/cmake/modules"
     "${PROJECT_SOURCE_DIR}/src/cmake")

include (platform)
include (compiler)


option (VERBOSE "Print lots of messages while compiling" OFF)
set (${PROJ_NAME}_NAMESPACE ${PROJ_NAME} CACHE STRING "Customized outer namespace base name (version will be added)")
option (BUILD_TOOLS "Build the command-line tools" ON)
option (BUILD_TESTS "Build the unit tests" ON)

# Set the default namespace
set (PROJ_NAMESPACE "${${PROJ_NAME}_NAMESPACE}")
set (PROJ_NAMESPACE_V "${PROJ_NAMESPACE}_v${PROJECT_VERSION_MAJOR}_${PROJECT_VERSION_MINOR}")
message(STATUS "Setting Namespace to: ${PROJ_NAMESPACE_V}")

set (SOVERSION ${PROJECT_VERSION_MAJORMINOR}
     CACHE STRING "Set the SO version in the SO name of the output library")


include (externalpackages)
include (install)          # installation options all implemented here
include (pythonutils)

include_directories (
    BEFORE
    "${CMAKE_SOURCE_DIR}/src/include"
    "${CMAKE_BINARY_DIR}/include"
  )



# We want CTest for testing
# N.B. This needs to be added before any of the subdirectories, or
# their add_test commands will not register.
include (CTest)


# Tell CMake to process the sub-directories
add_subdirectory (src/include)
add_subdirectory (src/libProto)
if (BUILD_TOOLS)
  add_subdirectory (src/protobin)
endif ()

if (USE_PYTHON)
    add_subdirectory (src/python)
endif ()

if (USE_QT AND Qt5_FOUND)
    add_subdirectory (src/guiapp)
endif ()

#add_subdirectory (src/doc)


include (testutils)

# Make a build/platform/testsuite directory, and copy the master runtest.py
# there. The rest is up to the tests themselves.
# file (MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/testsuite")
add_custom_command (OUTPUT "${CMAKE_BINARY_DIR}/testsuite/runtest.py"
                    COMMAND ${CMAKE_COMMAND} -E copy_if_different
                        "${CMAKE_SOURCE_DIR}/testsuite/runtest.py"
                        "${CMAKE_BINARY_DIR}/testsuite/runtest.py"
                    MAIN_DEPENDENCY "${CMAKE_SOURCE_DIR}/testsuite/runtest.py")
add_custom_target ( CopyFiles ALL DEPENDS "${CMAKE_BINARY_DIR}/testsuite/runtest.py" )

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





#########################################################################
# Packaging
set (CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set (CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set (CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
# "Vendor" is only used in copyright notices, so we use the same thing that
# the rest of the copyright notices say.
set (CPACK_PACKAGE_VENDOR "${PROJECT_AUTHORS}")
set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PROJECT_NAME} is an open source library for reading and writing image file formats, a nice format-agnostic image viewer, and other image-related classes and utilities.")
set (CPACK_PACKAGE_DESCRIPTION_FILE "${PROJECT_SOURCE_DIR}/src/doc/Description.txt")
set (CPACK_PACKAGE_FILE_NAME ${PROJECT_NAME}-${PROJECT_VERSION}-${platform})
#SET (CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_SOURCE_DIR}")
file (MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/cpack")
file (COPY "${PROJECT_SOURCE_DIR}/LICENSE" DESTINATION "${CMAKE_BINARY_DIR}/cpack")
file (RENAME "${CMAKE_BINARY_DIR}/cpack/LICENSE" "${CMAKE_BINARY_DIR}/cpack/License.txt")
set (CPACK_RESOURCE_FILE_LICENSE "${CMAKE_BINARY_DIR}/cpack/License.txt")
file (COPY "${PROJECT_SOURCE_DIR}/README.md" DESTINATION "${CMAKE_BINARY_DIR}/cpack")
file (RENAME "${CMAKE_BINARY_DIR}/cpack/README.md" "${CMAKE_BINARY_DIR}/cpack/Readme.md")
set (CPACK_RESOURCE_FILE_README "${CMAKE_BINARY_DIR}/cpack/Readme.md")
set (CPACK_RESOURCE_FILE_WELCOME "${PROJECT_SOURCE_DIR}/src/doc/Welcome.txt")
#SET (CPACK_STRIP_FILES Do we need this?)
if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    set (CPACK_GENERATOR "TGZ;STGZ;RPM;DEB")
    set (CPACK_SOURCE_GENERATOR "TGZ")
endif ()
if (APPLE)
    set (CPACK_GENERATOR "TGZ;STGZ;PackageMaker")
    set (CPACK_SOURCE_GENERATOR "TGZ")
endif ()
set (CPACK_SOURCE_PACKAGE_FILE_NAME ${PROJECT_NAME}-${PROJECT_VERSION}-source)
#set (CPACK_SOURCE_STRIP_FILES Do we need this?)
set (CPACK_SOURCE_IGNORE_FILES ".*~")
set (CPACK_COMPONENT_UNSPECIFIED_HIDDEN TRUE)
set (CPACK_COMPONENT_UNSPECIFIED_REQUIRED TRUE)
set (CPACK_COMPONENTS_ALL user developer documentation Unspecified)
set (CPACK_COMPONENT_USER_DISPLAY_NAME "Applications")
set (CPACK_COMPONENT_DEVELOPER_DISPLAY_NAME "Developer files")
set (CPACK_COMPONENT_DOCUMENTATION_DISPLAY_NAME "Documentation")
set (CPACK_COMPONENT_USER_DESCRIPTION
     "Applications: iv, iinfo, iconvert, idiff, igrep, maketx and libraries")
set (CPACK_COMPONENT_DEVELOPER_DESCRIPTION "Include files")
set (CPACK_COMPONENT_DOCUMENTATION_DESCRIPTION "${PROJECT_NAME} documentation")
set (CPACK_COMPONENT_DEVELOPER_DEPENDS user)
include (CPack)
