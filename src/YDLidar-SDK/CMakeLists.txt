cmake_minimum_required(VERSION 3.5)
project(ydlidar_sdk LANGUAGES C CXX)

#########################################################
# version
set(YDLIDAR_SDK_VERSION_MAJOR 1)
set(YDLIDAR_SDK_VERSION_MINOR 2)
set(YDLIDAR_SDK_VERSION_PATCH 19)
set(YDLIDAR_SDK_VERSION
  ${YDLIDAR_SDK_VERSION_MAJOR}.${YDLIDAR_SDK_VERSION_MINOR}.${YDLIDAR_SDK_VERSION_PATCH}
)

#########################################################
# C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#########################################################
# platform
if(CMAKE_SYSTEM_NAME MATCHES "Linux")
  add_compile_options(-fPIC)
endif()

#########################################################
# module path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#########################################################
# include internal cmake
include(common/ydlidar_base)
include(common/ydlidar_parse)

#########################################################
# options
option(BUILD_SHARED_LIBS "Build shared libraries." OFF)
option(BUILD_EXAMPLES "Build Example." OFF)
option(BUILD_CSHARP "Build CSharp." OFF)
option(BUILD_TEST "Build Test." OFF)

#########################################################
# generate config header
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/ydlidar_config.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/ydlidar_config.h
)

#########################################################
# subdirectories
add_subdirectory(core)
add_subdirectory(src)

#########################################################
# build library
add_library(${PROJECT_NAME}
  ${SDK_SOURCES}
  ${SDK_HEADERS}
  ${CMAKE_CURRENT_BINARY_DIR}/ydlidar_config.h
)

target_link_libraries(${PROJECT_NAME}
  ${SDK_LIBS}
)

# ⭐ 핵심: SDK include 전체 공개
target_include_directories(${PROJECT_NAME}
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<INSTALL_INTERFACE:include>
)

#########################################################
# install headers
install(DIRECTORY
  src/
  include/
  DESTINATION include
)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/ydlidar_config.h
  DESTINATION include
)

#########################################################
# install library
install(TARGETS ${PROJECT_NAME}
  EXPORT ydlidar_sdkTargets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)

#########################################################
# export cmake package
include(CMakePackageConfigHelpers)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/ydlidar_sdkConfigVersion.cmake
  VERSION ${YDLIDAR_SDK_VERSION}
  COMPATIBILITY SameMajorVersion
)

configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/ydlidar_sdkConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/ydlidar_sdkConfig.cmake
  INSTALL_DESTINATION lib/cmake/ydlidar_sdk
)

install(EXPORT ydlidar_sdkTargets
  FILE ydlidar_sdkTargets.cmake
  NAMESPACE ydlidar::
  DESTINATION lib/cmake/ydlidar_sdk
)

install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/ydlidar_sdkConfig.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/ydlidar_sdkConfigVersion.cmake
  DESTINATION lib/cmake/ydlidar_sdk
)

#########################################################
# summary
message(STATUS "YDLidar SDK configured successfully")
