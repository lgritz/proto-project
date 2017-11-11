###########################################################################
# Find libraries

# When not in VERBOSE mode, try to make things as quiet as possible
if (NOT VERBOSE)
    set (Boost_FIND_QUIETLY true)
    set (GLEW_FIND_QUIETLY true)
    set (IlmBase_FIND_QUIETLY true)
    set (OpenColorIO_FIND_QUIETLY true)
    set (OpenCV_FIND_QUIETLY true)
    set (OpenEXR_FIND_QUIETLY true)
    set (OpenGL_FIND_QUIETLY true)
    set (OpenImageIO_FIND_QUIETLY true)
    set (PkgConfig_FIND_QUIETLY true)
    set (PugiXML_FIND_QUIETLY TRUE)
    set (PythonInterp_FIND_QUIETLY true)
    set (PythonLibs_FIND_QUIETLY true)
    set (Qt5_FIND_QUIETLY true)
    set (Threads_FIND_QUIETLY true)
    set (TIFF_FIND_QUIETLY true)
    set (ZLIB_FIND_QUIETLY true)
endif ()


find_package (OpenImageIO 1.7)
if (OPENIMAGEIO_FOUND)
    include_directories ("${OPENIMAGEIO_INCLUDE_DIR}")
    link_directories ("${OPENIMAGEIO_LIBRARY_DIRS}")
    message (STATUS "Using OpenImageIO ${OPENIMAGEIO_VERSION}")
endif ()


option (USE_TIFF "Include TIFF support" OFF)
if (USE_TIFF)
    find_package (TIFF REQUIRED)
    include_directories (${TIFF_INCLUDE_DIR})
endif ()


option (USE_ZLIB "Include zlib support" OFF)
if (USE_ZLIB)
    find_package (ZLIB REQUIRED)
    include_directories (${ZLIB_INCLUDE_DIR})
endif ()


option (USE_OPENEXR "Include OpenEXR/IlmBase support" ON)
if (USE_OPENEXR)
    find_package (OpenEXR REQUIRED)
    #OpenEXR 2.2 still has problems with importing ImathInt64.h unqualified
    #thus need for ilmbase/OpenEXR
    include_directories ("${OPENEXR_INCLUDE_DIR}"
                         "${ILMBASE_INCLUDE_DIR}"
                         "${ILMBASE_INCLUDE_DIR}/OpenEXR")
    if (${OPENEXR_VERSION} VERSION_LESS 2.0.0)
        # OpenEXR 1.x had weird #include dirctives, this is also necessary:
        include_directories ("${OPENEXR_INCLUDE_DIR}/OpenEXR")
    else ()
        add_definitions (-DUSE_OPENEXR_VERSION2=1)
    endif ()
endif ()



###########################################################################
# Boost setup
if (NOT Boost_FIND_QUIETLY)
    message (STATUS "BOOST_ROOT ${BOOST_ROOT}")
endif ()
if (NOT DEFINED Boost_ADDITIONAL_VERSIONS)
    set (Boost_ADDITIONAL_VERSIONS "1.63" "1.62" "1.61" "1.60"
                                   "1.59" "1.58" "1.57" "1.56" "1.55")
endif ()
if (LINKSTATIC)
    set (Boost_USE_STATIC_LIBS ON)
endif ()
set (Boost_USE_MULTITHREADED ON)
if (BOOST_CUSTOM)
    set (Boost_FOUND true)
    # N.B. For a custom version, the caller had better set up the variables
    # Boost_VERSION, Boost_INCLUDE_DIRS, Boost_LIBRARY_DIRS, Boost_LIBRARIES.
else ()
    set (Boost_COMPONENTS filesystem system thread)
    if (NOT USE_STD_REGEX)
        list (APPEND Boost_COMPONENTS regex)
    endif ()
    find_package (Boost 1.53 REQUIRED
                  COMPONENTS ${Boost_COMPONENTS})

    # Try to figure out if this boost distro has Boost::python.  If we
    # include python in the component list above, cmake will abort if
    # it's not found.  So we resort to checking for the boost_python
    # library's existance to get a soft failure.
    find_library (my_boost_python_lib boost_python
                  PATHS ${Boost_LIBRARY_DIRS} NO_DEFAULT_PATH)
    mark_as_advanced (my_boost_python_lib)
    if (NOT my_boost_python_lib AND Boost_SYSTEM_LIBRARY_RELEASE)
        get_filename_component (my_boost_PYTHON_rel
                                ${Boost_SYSTEM_LIBRARY_RELEASE} NAME
                               )
        string (REGEX REPLACE "^(lib)?(.+)_system(.+)$" "\\2_python\\3"
                my_boost_PYTHON_rel ${my_boost_PYTHON_rel} )
        find_library (my_boost_PYTHON_LIBRARY_RELEASE
                      NAMES ${my_boost_PYTHON_rel} lib${my_boost_PYTHON_rel}
                      HINTS ${Boost_LIBRARY_DIRS}
                      NO_DEFAULT_PATH
                     )
        mark_as_advanced (my_boost_PYTHON_LIBRARY_RELEASE)
    endif ()
    if (NOT my_boost_python_lib AND Boost_SYSTEM_LIBRARY_DEBUG)
        get_filename_component (my_boost_PYTHON_dbg
                                ${Boost_SYSTEM_LIBRARY_DEBUG} NAME )
        string (REGEX REPLACE "^(lib)?(.+)_system(.+)$" "\\2_python\\3"
                my_boost_PYTHON_dbg ${my_boost_PYTHON_dbg} )
        find_library (my_boost_PYTHON_LIBRARY_DEBUG
                      NAMES ${my_boost_PYTHON_dbg} lib${my_boost_PYTHON_dbg}
                      HINTS ${Boost_LIBRARY_DIRS}
                      NO_DEFAULT_PATH )
        mark_as_advanced (my_boost_PYTHON_LIBRARY_DEBUG)
    endif ()
    if (my_boost_python_lib OR
        my_boost_PYTHON_LIBRARY_RELEASE OR my_boost_PYTHON_LIBRARY_DEBUG)
        set (boost_PYTHON_FOUND ON)
    else ()
        set (boost_PYTHON_FOUND OFF)
    endif ()
endif ()
if (CMAKE_SYSTEM_NAME MATCHES "Linux" AND ${Boost_VERSION} GREATER 105499)
    # On Linux, Boost 1.55 and higher seems to need to link against -lrt
    list (APPEND Boost_LIBRARIES "rt")
endif ()
if (NOT Boost_FIND_QUIETLY)
    message (STATUS "BOOST_ROOT ${BOOST_ROOT}")
    message (STATUS "Boost found ${Boost_FOUND} ")
    message (STATUS "Boost version      ${Boost_VERSION}")
    message (STATUS "Boost include dirs ${Boost_INCLUDE_DIRS}")
    message (STATUS "Boost library dirs ${Boost_LIBRARY_DIRS}")
    message (STATUS "Boost libraries    ${Boost_LIBRARIES}")
    message (STATUS "Boost python found ${boost_PYTHON_FOUND}")
endif ()
if (NOT boost_PYTHON_FOUND)
    # If Boost python components were not found, turn off all python support.
    message (STATUS "Boost python support not found -- will not build python components!")
    if (APPLE AND USE_PYTHON)
        message (STATUS "   If your Boost is from Macports, you need the +python26 variant to get Python support.")
    endif ()
    set (USE_PYTHON OFF)
    set (PYTHONLIBS_FOUND OFF)
endif ()
include_directories (SYSTEM "${Boost_INCLUDE_DIRS}")
link_directories ("${Boost_LIBRARY_DIRS}")


option (USE_OPENGL "Include OpenGL support" OFF)
if (USE_OPENGL)
    find_package (OpenGL)
    if (NOT OpenGL_FIND_QUIETLY)
        message (STATUS "OPENGL_FOUND=${OPENGL_FOUND} USE_OPENGL=${USE_OPENGL}")
    endif ()
    find_package (GLEW)
endif ()


option (USE_OCIO "Include OpenColorIO support" OFF)
if (USE_OCIO)
    # If 'OCIO_PATH' not set, use the env variable of that name if available
    if (NOT OCIO_PATH)
        if (NOT $ENV{OCIO_PATH} STREQUAL "")
            set (OCIO_PATH $ENV{OCIO_PATH})
        endif ()
    endif()

    find_package (OpenColorIO)

    if (OCIO_FOUND)
        include_directories (${OCIO_INCLUDES})
        add_definitions ("-DUSE_OCIO=1")
    else ()
        message (STATUS "Skipping OpenColorIO support")
    endif ()

    if (LINKSTATIC)
        find_library (TINYXML_LIBRARY NAMES tinyxml)
        if (TINYXML_LIBRARY)
            set (OCIO_LIBRARIES ${OCIO_LIBRARIES} ${TINYXML_LIBRARY})
        endif ()
        find_library (YAML_LIBRARY NAMES yaml-cpp)
        if (YAML_LIBRARY)
            set (OCIO_LIBRARIES ${OCIO_LIBRARIES} ${YAML_LIBRARY})
        endif ()
        find_library (LCMS2_LIBRARY NAMES lcms2)
        if (LCMS2_LIBRARY)
            set (OCIO_LIBRARIES ${OCIO_LIBRARIES} ${LCMS2_LIBRARY})
        endif ()
    endif ()
endif ()


option (USE_PUGIXML "Use PugiXML" OFF)
if (USE_PUGIXML)
    find_package (PugiXML REQUIRED)
    include_directories (BEFORE "${PUGIXML_INCLUDE_DIR}")
endif()


###########################################################################
# Qt setup
option (USE_QT "Include Qt support" ON)
option (USE_OPENGL "Include OpenGL support" OFF)
if (USE_QT)
    set (qt5_modules Core Gui Widgets)
    if (USE_OPENGL)
        list (APPEND qt5_modules OpenGL)
    endif ()
    find_package (Qt5 COMPONENTS ${qt5_modules})
endif ()
if (USE_QT AND Qt5_FOUND)
    if (NOT Qt5_FIND_QUIETLY)
        message (STATUS "Qt5_FOUND=${Qt5_FOUND}")
    endif ()
else ()
    message (STATUS "No Qt5 -- skipping components that need Qt5.")
    if (USE_QT AND NOT Qt5_FOUND AND APPLE)
        message (STATUS "If you think you installed qt5 with Homebrew and it still doesn't work,")
        message (STATUS "try:   export PATH=/usr/local/opt/qt5/bin:$PATH")
    endif ()
endif ()

