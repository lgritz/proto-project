file (GLOB public_headers ${PROJECT_NAME}/*.h)

message (STATUS "public headers are ${public_headers}")

# Mangle the SOVERSION so that it's a valid C++ identifier for the versioning
# namespace defined in version.h
string (REGEX REPLACE "\\." "_" MANGLED_SOVERSION ${SOVERSION})
set (PROJECT_VERSION_NS "v${MANGLED_SOVERSION}")

# Generate version.h from version.h.in
configure_file (${PROJECT_NAME}/version.h.in "${CMAKE_BINARY_DIR}/include/${PROJECT_NAME}/version.h" @ONLY)
list (APPEND public_headers "${CMAKE_BINARY_DIR}/include/${PROJECT_NAME}/version.h")
if (VERBOSE)
    message(STATUS "Create version.h from version.h.in")
endif ()

# Generate export.h from export.h.in
configure_file (${PROJECT_NAME}/export.h.in "${CMAKE_BINARY_DIR}/include/${PROJECT_NAME}/export.h" @ONLY)
list (APPEND public_headers "${CMAKE_BINARY_DIR}/include/${PROJECT_NAME}/export.h")
if (VERBOSE)
    message(STATUS "Create export.h from export.h.in")
endif ()

install (FILES ${public_headers} DESTINATION include/${PROJECT_NAME}
         COMPONENT developer)
