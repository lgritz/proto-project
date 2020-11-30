# Copyright Contributors to the Proto project.
# SPDX-License-Identifier: BSD-3-Clause
# https://github.com/lgritz/proto-project

###########################################################################
# Find external dependencies
###########################################################################

if (NOT VERBOSE)
    set (Boost_FIND_QUIETLY true)
    set (PkgConfig_FIND_QUIETLY true)
    set (Threads_FIND_QUIETLY true)
endif ()

message (STATUS "${ColorBoldWhite}")
message (STATUS "* Checking for dependencies...")
message (STATUS "*   - Missing a dependency 'Package'?")
message (STATUS "*     Try cmake -DPackage_ROOT=path or set environment var Package_ROOT=path")
message (STATUS "*     For many dependencies, we supply src/build-scripts/build_Package.bash")
message (STATUS "*   - To exclude an optional dependency (even if found),")
message (STATUS "*     -DUSE_Package=OFF or set environment var USE_Package=OFF ")
message (STATUS "${ColorReset}")

set (LOCAL_DEPS_PATH "${CMAKE_SOURCE_DIR}/ext/dist" CACHE STRING
     "Local area for dependencies added to CMAKE_PREFIX_PATH")
list (APPEND CMAKE_PREFIX_PATH ${CMAKE_SOURCE_DIR}/ext/dist)


include (ExternalProject)

option (BUILD_MISSING_DEPS "Try to download and build any missing dependencies" OFF)


###########################################################################
# Boost setup
if (MSVC)
    # Disable automatic linking using pragma comment(lib,...) of boost libraries upon including of a header
    add_definitions (-DBOOST_ALL_NO_LIB=1)
endif ()
if (LINKSTATIC)
    set (Boost_USE_STATIC_LIBS ON)
else ()
    if (MSVC)
        add_definitions (-DBOOST_ALL_DYN_LINK=1)
    endif ()
endif ()
if (BOOST_CUSTOM)
    set (Boost_FOUND true)
    # N.B. For a custom version, the caller had better set up the variables
    # Boost_VERSION, Boost_INCLUDE_DIRS, Boost_LIBRARY_DIRS, Boost_LIBRARIES.
else ()
    set (Boost_COMPONENTS filesystem system thread)
    if (NOT USE_STD_REGEX)
        list (APPEND Boost_COMPONENTS regex)
    endif ()
    # The FindBoost.cmake interface is broken if it uses boost's installed
    # cmake output (e.g. boost 1.70.0, cmake <= 3.14). Specifically it fails
    # to set the expected variables printed below. So until that's fixed
    # force FindBoost.cmake to use the original brute force path.
    set (Boost_NO_BOOST_CMAKE ON)
    checked_find_package (Boost REQUIRED
                          VERSION_MIN 1.70
                          COMPONENTS ${Boost_COMPONENTS}
                          PRINT Boost_INCLUDE_DIRS Boost_LIBRARIES )
endif ()

# On Linux, Boost 1.55 and higher seems to need to link against -lrt
if (CMAKE_SYSTEM_NAME MATCHES "Linux"
      AND ${Boost_VERSION} VERSION_GREATER_EQUAL 105500)
    list (APPEND Boost_LIBRARIES "rt")
endif ()

include_directories (SYSTEM "${Boost_INCLUDE_DIRS}")
link_directories ("${Boost_LIBRARY_DIRS}")

# end Boost setup
###########################################################################


checked_find_package (OpenImageIO REQUIRED
                      VERSION_MIN 2.1)
# checked_find_package (TIFF REQUIRED
#                       VERSION_MIN 4.0)
# checked_find_package (ZLIB REQUIRED)

# IlmBase & OpenEXR
checked_find_package (OpenEXR REQUIRED
                      VERSION_MIN 2.4
                      PRINT IMATH_INCLUDES)

checked_find_package (OpenGL)

# From pythonutils.cmake
find_python()


###########################################################################
# Qt setup
set (qt5_modules Core Gui Widgets)
if (OPENGL_FOUND)
    list (APPEND qt5_modules OpenGL)
endif ()
option (USE_QT "Use Qt if found" ON)
checked_find_package (Qt5 COMPONENTS ${qt5_modules})
if (USE_QT AND NOT Qt5_FOUND AND APPLE)
    message (STATUS "  If you think you installed qt5 with Homebrew and it still doesn't work,")
    message (STATUS "  try:   export PATH=/usr/local/opt/qt5/bin:$PATH")
endif ()

