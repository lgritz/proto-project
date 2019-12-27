file (GLOB public_headers ${PROJECT_NAME}/*.h)

option (USE_GENERATED_EXPORT_HEADER "Use CMake-generated export header" ON)
if (USE_GENERATED_EXPORT_HEADER)
    include (GenerateExportHeader)
    # set (exportextras "\n#define ${PROJ_NAME}_EXPORT ${PROJ_NAME}_API\n")
    generate_export_header (${PROJECT_NAME}
          # [BASE_NAME baseName]
          EXPORT_FILE_NAME ${PROJECT_NAME}/export.h
          EXPORT_MACRO_NAME ${PROJ_NAME}_API
          NO_EXPORT_MACRO_NAME ${PROJ_NAME}_LOCAL
          STATIC_DEFINE ${PROJ_NAME}_STATIC_DEFINE
          DEPRECATED_MACRO_NAME ${PROJ_NAME}_DEPRECATED
          # [NO_DEPRECATED_MACRO_NAME noDeprecatedMacroName]
          # [DEFINE_NO_DEPRECATED]
          # [PREFIX_NAME prefix]
          # CUSTOM_CONTENT_FROM_VARIABLE exportextras
          )
    list (APPEND public_headers "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}/export.h")
else ()
    # Generate export.h from export.h.in
    configure_file (${PROJECT_NAME}/export.h.in "${CMAKE_BINARY_DIR}/include/${PROJECT_NAME}/export.h" @ONLY)
    list (APPEND public_headers "${CMAKE_BINARY_DIR}/include/${PROJECT_NAME}/export.h")
    if (VERBOSE)
        message(STATUS "Create export.h from export.h.in")
    endif ()
endif()


# Mangle the SOVERSION so that it's a valid C++ identifier for the versioning
# namespace defined in version.h
string (REGEX REPLACE "\\." "_" MANGLED_SOVERSION ${SOVERSION})
set (PROJECT_VERSION_NS "v${MANGLED_SOVERSION}")


# Generate version.h
set (versionfile version.h)
if (VERBOSE)
    message(STATUS "Create ${versionfile} from ${versionfile}.in")
endif ()
configure_file (${PROJECT_NAME}/${versionfile}.in "${CMAKE_BINARY_DIR}/include/${PROJECT_NAME}/${versionfile}" @ONLY)
list (APPEND public_headers "${CMAKE_BINARY_DIR}/include/${PROJECT_NAME}/${versionfile}")


install (FILES ${public_headers}
         DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
         COMPONENT developer)
