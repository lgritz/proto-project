cmake_minimum_required (VERSION 3.18)

set (Proto_VERSION "0.1.0.0")
set (Proto_VERSION_OVERRIDE "" CACHE STRING
     "Version override (use with caution)!")
mark_as_advanced (Proto_VERSION_OVERRIDE)
if (Proto_VERSION_OVERRIDE)
    set (Proto_VERSION ${Proto_VERSION_OVERRIDE})
endif ()

project (Proto VERSION ${Proto_VERSION}
         HOMEPAGE_URL "https://example.com"
         LANGUAGES CXX C)

set (PROJ_NAME ${PROJECT_NAME})    # optional short name
string (TOLOWER ${PROJ_NAME} PROJ_NAME_LOWER)  # short name lower case
string (TOUPPER ${PROJ_NAME} PROJ_NAME_UPPER)  # short name upper case
set (PROJECT_VERSION_RELEASE_TYPE "dev" CACHE STRING
    "Build type, for example: dev, beta2, RC1 (empty string for normal release)")
set (${PROJECT_NAME}_VERSION_RELEASE_TYPE ${PROJECT_VERSION_RELEASE_TYPE})
set (PROJECT_AUTHORS "Main Author et al")
option (${PROJECT_NAME}_SUPPORTED_RELEASE
        "Set ON for supported release branch, OFF for master" OFF)
if (${PROJECT_NAME}_SUPPORTED_RELEASE)
    set (${PROJECT_NAME}_DEV_RELEASE OFF)
else ()
    set (${PROJECT_NAME}_DEV_RELEASE ON)
endif ()

# Set PROJECT_IS_TOP_LEVEL to ON if if this is the top level project (not
# if this is included as a subproject of something else). Note that this is
# handled automatically for CMake >= 3.21.
if (CMAKE_VERSION VERSION_LESS 3.21)
    if ("${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}")
        set (PROJECT_IS_TOP_LEVEL ON)
    endif ()
endif ()

# If the user wants to use Conan to build dependencies, they will have done
# this prior to the cmake config:
#   cd <build area>
#   conan install <source area>
# and that will leave a conanbuildinfo.cmake in the build area for us.
if (EXISTS ${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
    include (${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
    message (STATUS "Using Conan for dependencies")
    conan_basic_setup()
endif()

if (NOT CMAKE_BUILD_TYPE)
    set (CMAKE_BUILD_TYPE "Release")
endif ()

# If the user hasn't configured cmake with an explicit
# -DCMAKE_INSTALL_PREFIX=..., then set it to safely install into ./dist, to
# help prevent the user from accidentally writing over /usr/local or whatever.
if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT
      AND PROJECT_IS_TOP_LEVEL)
    set (CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/dist" CACHE PATH
         "Installation location" FORCE)
endif()

message (STATUS "Configuring ${PROJECT_NAME} ${PROJECT_VERSION}")
message (STATUS "CMake ${CMAKE_VERSION}")
message (STATUS "CMake system           = ${CMAKE_SYSTEM}")
message (STATUS "CMake system name      = ${CMAKE_SYSTEM_NAME}")
message (STATUS "Project source dir     = ${PROJECT_SOURCE_DIR}")
message (STATUS "Project build dir      = ${CMAKE_BINARY_DIR}")
message (STATUS "Project install prefix = ${CMAKE_INSTALL_PREFIX}")
message (STATUS "Configuration types    = ${CMAKE_CONFIGURATION_TYPES}")
message (STATUS "Build type             = ${CMAKE_BUILD_TYPE}")
message (STATUS "Supported release      = ${${PROJECT_NAME}_SUPPORTED_RELEASE}")

# Make the build area layout look a bit more like the final dist layout
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if ("${PROJECT_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message (FATAL_ERROR "Not allowed to run in-source build!")
endif ()

option (CMAKE_USE_FOLDERS "Use the FOLDER target property to organize targets into folders." ON)
mark_as_advanced (CMAKE_USE_FOLDERS)
if (CMAKE_USE_FOLDERS)
    set_property (GLOBAL PROPERTY USE_FOLDERS ON)
endif ()


option (VERBOSE "Print lots of messages while compiling" OFF)
if (VERBOSE)
    set (CMAKE_MESSAGE_LOG_LEVEL "VERBOSE" CACHE STRING "CMake log level to display")
else ()
    set (CMAKE_MESSAGE_LOG_LEVEL "STATUS" CACHE STRING "CMake log level to display")
endif ()
option (${PROJ_NAME}_BUILD_TOOLS "Build the command-line tools" ON)
option (${PROJ_NAME}_BUILD_TESTS "Build the unit tests" ON)
set (SOVERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
     CACHE STRING "Set the SO version in the SO name of the output library")


# Set the default namespace
set (${PROJ_NAME}_NAMESPACE ${PROJECT_NAME} CACHE STRING
     "Customized outer namespace base name (version will be added)")
option (${PROJ_NAME}_NAMESPACE_INCLUDE_PATCH
     "Should the inner namespace include the patch number" ${${PROJECT_NAME}_DEV_RELEASE})
set (PROJ_NAMESPACE "${${PROJ_NAME}_NAMESPACE}")
set (PROJ_NAMESPACE_V "${PROJ_NAMESPACE}_v${PROJECT_VERSION_MAJOR}_${PROJECT_VERSION_MINOR}")
if (OIIO_NAMESPACE_INCLUDE_PATCH)
    set (PROJ_NAMESPACE_V "${PROJ_NAMESPACE_V}_${PROJECT_VERSION_PATCH}")
endif ()
message(STATUS "Setting Namespace to: ${PROJ_NAMESPACE_V}")


list (APPEND CMAKE_MODULE_PATH
      "${PROJECT_SOURCE_DIR}/src/cmake/modules"
      "${PROJECT_SOURCE_DIR}/src/cmake")

include (GNUInstallDirs)

# Helpful functions and macros for our project
include (colors)
include (check_is_enabled)
include (checked_find_package)
include (fancy_add_executable)

# All the C++ and compiler related options and adjustments live here
include (compiler)

# Utilities related to finding python and making python bindings
include (pythonutils)

# All the dependency finding and options are here
include (externalpackages)

# Include all our testing apparatus and utils, but not if it's a subproject
if (PROJECT_IS_TOP_LEVEL)
    include (testing)
else ()
    macro (add_testsuite_tests)
    endmacro ()
    macro (proto_add_all_tests)
    endmacro ()
endif ()


include_directories (
    BEFORE
    "${CMAKE_SOURCE_DIR}/src/include"
    "${CMAKE_BINARY_DIR}/src/include"
    "${CMAKE_BINARY_DIR}/include"
  )

# Tell CMake to process the sub-directories
add_subdirectory (src/libProto)
add_subdirectory (src/include)

if (${PROJ_NAME}_BUILD_TOOLS)
    add_subdirectory (src/protobin)
endif ()

if (USE_PYTHON)
    add_subdirectory (src/python)
endif ()

if (USE_QT AND (Qt5_FOUND OR Qt6_FOUND))
    add_subdirectory (src/guiapp)
endif ()

#add_subdirectory (src/doc)

# Last minute site-specific instructions, if they exist
if (OIIO_SITE AND EXISTS "${PROJECT_SOURCE_DIR}/site/${SITE}/cmake/sitecustom.cmake")
    include ("${PROJECT_SOURCE_DIR}/site/${SITE}/cmake/sitecustom.cmake")
endif ()



# Export the configuration files. There are also library-specific config
# exports in the CMakeLists.txt of library subdirectories.
# Turn this ON for projects that have "downstream" CMake consumers who need
# exported cmake configuration files as part of the build.
# For projects that arent making downstream-consumable artifacts (headers,
# libraries, etc.) this whole section can be omitted.
option (${PROJECT_NAME}_EXPORT_CMAKE_CONFIG
        "Export CMake config for the project?" OFF)
if (${PROJECT_NAME}_EXPORT_CMAKE_CONFIG)
    include (CMakePackageConfigHelpers)

    # the file containing the exported targets
    set (TARGETS_EXPORT_NAME "${PROJECT_NAME}Targets.cmake")
    # the version file
    set (VERSION_CONFIG "${CMAKE_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake")
    # the config file that is actually looked for by find_package
    set (PROJECT_CONFIG "${CMAKE_BINARY_DIR}/${PROJECT_NAME}Config.cmake")
    # where all these files will be installed
    set (CONFIG_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")

    # first generate the version file in the binary dir
    write_basic_package_version_file (
            ${VERSION_CONFIG}
            VERSION ${PROJECT_VERSION}
            COMPATIBILITY SameMajorVersion)

    # generate the Targets file in the binary dir using the targets collected in
    # PROTO_EXPORTED_TARGETS each target is added to PROTO_EXPORTED_TARGETS
    # through the macro install_target().
    export (EXPORT ${PROJ_NAME}_EXPORTED_TARGETS FILE "${CMAKE_BINARY_DIR}/${TARGETS_EXPORT_NAME}")

    # generate the config file from the template in the binary dir
    configure_package_config_file ("${PROJECT_SOURCE_DIR}/src/cmake/Config.cmake.in"
            "${PROJECT_CONFIG}"
            INSTALL_DESTINATION "${CONFIG_INSTALL_DIR}")

    # generate the config file from the template in the binary dir
    install (FILES "${PROJECT_CONFIG}" "${VERSION_CONFIG}"
            DESTINATION "${CONFIG_INSTALL_DIR}")

    # install targets files
    install (EXPORT Proto_EXPORTED_TARGETS
            DESTINATION ${CONFIG_INSTALL_DIR}
            FILE ${TARGETS_EXPORT_NAME}
            NAMESPACE ${PROJECT_NAME}::)
endif ()



if (PROJECT_IS_TOP_LEVEL AND BUILD_TESTING AND ${PROJ_NAME}_BUILD_TESTS)
    proto_add_all_tests()
endif ()

if (PROJECT_IS_TOP_LEVEL)
    include (packaging)
endif ()
