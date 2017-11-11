###########################################################################
# Fonts are not available yet.
option (INSTALL_DOCS "Install documentation" ON)
option (INSTALL_FONTS "Install default fonts" OFF)

###########################################################################
# Rpath handling at the install step
set (MACOSX_RPATH ON)
if (CMAKE_SKIP_RPATH)
    # We need to disallow the user from truly setting CMAKE_SKIP_RPATH, since
    # we want to run the generated executables from the build tree in order to
    # generate the manual page documentation.  However, we make sure the
    # install rpath is unset so that the install tree is still free of rpaths
    # for linux packaging purposes.
    set (CMAKE_SKIP_RPATH FALSE)
    unset (CMAKE_INSTALL_RPATH)
else ()
    # the RPATH to be used when installing
    set (CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_FULL_LIBDIR}")

    # add the automatically determined parts of the RPATH that
    # point to directories outside the build tree to the install RPATH
    set (CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    if (VERBOSE)
        message (STATUS "CMAKE_INSTALL_RPATH = ${CMAKE_INSTALL_RPATH}")
    endif ()
endif ()



# Macro to install targets to the appropriate locations.  Use this instead of
# the install(TARGETS ...) signature.
#
# Usage:
#
#    install_targets (target1 [target2 ...])
#
macro (install_targets)
    install (TARGETS ${ARGN}
             RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT user
             LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT user
             ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT developer)
endmacro()
