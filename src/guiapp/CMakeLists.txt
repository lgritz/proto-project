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
                               $<TARGET_NAME_IF_EXISTS:Qt5::Core>
                               $<TARGET_NAME_IF_EXISTS:Qt5::Gui>
                               $<TARGET_NAME_IF_EXISTS:Qt5::Widgets>
                               $<TARGET_NAME_IF_EXISTS:Qt5::OpenGL>
                               $<TARGET_NAME_IF_EXISTS:Qt6::Core>
                               $<TARGET_NAME_IF_EXISTS:Qt6::Gui>
                               $<TARGET_NAME_IF_EXISTS:Qt6::Widgets>
                               $<TARGET_NAME_IF_EXISTS:Qt6::OpenGLWidgets>
                               ${OPENGL_LIBRARIES}
                               OpenImageIO::OpenImageIO
                               ${Boost_LIBRARIES} ${CMAKE_DL_LIBS})
set_target_properties (guiapp PROPERTIES FOLDER "Tools")
install_targets (guiapp)
