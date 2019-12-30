set (CMAKE_AUTOMOC ON)
set (guiapp_srcs guiapp.cpp mainwin.cpp)
add_executable (guiapp ${guiapp_srcs})
if (Qt5_POSITION_INDEPENDENT_CODE)
    set (CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()
if (USE_OPENGL)
    target_include_directories (guiapp
                                SYSTEM PRIVATE ${OPENGL_INCLUDE_DIR}
                                        ${GLEW_INCLUDES})
endif ()
target_link_libraries (guiapp
                       PRIVATE Proto
                               Qt5::Core Qt5::Gui Qt5::Widgets
                               OpenImageIO::OpenImageIO
                               ${Boost_LIBRARIES} ${CMAKE_DL_LIBS})
set_target_properties (guiapp PROPERTIES FOLDER "Tools")
install_targets (guiapp)
