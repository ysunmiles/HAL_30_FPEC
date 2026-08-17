# Custom user source file list for all hand-written c-files.
# Keep your additions here so CubeMX-generated files stay separate.

set(USER_APPLICATION_SOURCES
    ${CMAKE_SOURCE_DIR}/Core/Src/OLED.c
)

target_sources(${CMAKE_PROJECT_NAME} PRIVATE ${USER_APPLICATION_SOURCES})

# OLED.h 和其他头文件位于 Core/Inc，保证这个目录包含在项目中。
target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    ${CMAKE_SOURCE_DIR}/Core/Inc
)
