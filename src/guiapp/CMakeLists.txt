set (CMAKE_AUTOMOC ON)
if (Qt5_POSITION_INDEPENDENT_CODE)
    set (CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()
if (USE_OPENGL)
    include_directories (${OPENGL_INCLUDE_DIR} ${GLEW_INCLUDES})
endif ()
set (guiapp_srcs guiapp.cpp MyMainWindow.cpp)
add_executable (guiapp ${guiapp_srcs})
set_target_properties (guiapp PROPERTIES FOLDER "Tools")
target_link_libraries (guiapp Proto
                           Qt5::Core Qt5::Gui Qt5::Widgets
                           ${OPENIMAGEIO_LIBRARIES} ${Boost_LIBRARIES} ${CMAKE_DL_LIBS})
install_targets (guiapp)
