cmake_minimum_required(VERSION 2.8)
project(ydlidar_sdk C CXX)

#########################################################
# version
set(YDLIDAR_SDK_VERSION_MAJOR 1)
set(YDLIDAR_SDK_VERSION_MINOR 2)
set(YDLIDAR_SDK_VERSION_PATCH 19)
set(YDLIDAR_SDK_VERSION
  ${YDLIDAR_SDK_VERSION_MAJOR}.${YDLIDAR_SDK_VERSION_MINOR}.${YDLIDAR_SDK_VERSION_PATCH})

##########################################################
# Detect wordsize
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(CMAKE_MRPT_WORD_SIZE 64)
else()
  set(CMAKE_MRPT_WORD_SIZE 32)
endif()

##################################################
# C++11
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

##########################################################
if(CMAKE_SYSTEM_NAME MATCHES "Linux")
  message(STATUS "Current platform: Linux")
  add_compile_options(-fPIC)
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
  message(STATUS "Current platform: Windows")
  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    add_compile_options("/utf-8")
    add_definitions(-DWIN32_LEAN_AND_MEAN -DNOMINMAX)
  endif()
endif()

#####################################################
# cmake module path
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(SDK_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#############################################################################
# include cmake files
include(common/ydlidar_base)
include(install_package)

#############################################################################
# policies
if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
  cmake_policy(SET CMP0005 NEW)
  if(POLICY CMP0053)
    cmake_policy(SET CMP0053 OLD)
  endif()
  if(POLICY CMP0037)
    cmake_policy(SET CMP0037 OLD)
  endif()
  if(POLICY CMP0043)
    cmake_policy(SET CMP0043 OLD)
  endif()
endif()

#############################################################################
# options
option(BUILD_SHARED_LIBS "Build shared libraries." OFF)
option(BUILD_EXAMPLES "Build Example." ON)
option(BUILD_CSHARP "Build CSharp." OFF)
option(BUILD_TEST "Build Test." OFF)

############################################################################
# find packages
find_package(SWIG)
find_package(PythonInterp)
find_package(PythonLibs)
find_package(GTest)

############################################################################
# include headers (소스 단계)
include_directories(. core src)

#############################################################################
# subdirectories
add_subdirectory(core)
add_subdirectory(src)

if(BUILD_EXAMPLES)
  add_subdirectory(examples)
endif()

#############################################################################
# parse libraries
include(common/ydlidar_parse)
include_directories(${SDK_INCS} ${CMAKE_CURRENT_BINARY_DIR})

########################################################
# generate config header  ★★★ 핵심 ★★★
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/ydlidar_config.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/ydlidar_config.h"
)
set(GENERATED_HEADERS ${CMAKE_CURRENT_BINARY_DIR}/ydlidar_config.h)

#############################################################################
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})

#############################################################################
# build library
if(BUILD_SHARED_LIBS)
  ydlidar_add_library(${PROJECT_NAME} SHARED
    ${SDK_SOURCES} ${SDK_HEADERS} ${GENERATED_HEADERS})
else()
  ydlidar_add_library(${PROJECT_NAME} STATIC
    ${SDK_SOURCES} ${SDK_HEADERS} ${GENERATED_HEADERS})
endif()

target_link_libraries(${PROJECT_NAME} ${SDK_LIBS})

# ★★★ 핵심 수정: binary dir를 PUBLIC include로 노출 ★★★
target_include_directories(${PROJECT_NAME} PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${CMAKE_CURRENT_BINARY_DIR}
)

############################################################################
# enable test
enable_testing()

############################################################################
# python binding
if(SWIG_FOUND AND PYTHONLIBS_FOUND)
  message(STATUS "build python API....")
  include_directories(python)
  add_subdirectory(python)
endif()

############################################################################
# csharp binding
if(WIN32 AND BUILD_CSHARP)
  message(STATUS "build csharp API....")
  include_directories(csharp)
  add_subdirectory(csharp)
endif()

############################################################################
# test
if(GTEST_FOUND AND BUILD_TEST)
  message(STATUS "build test is ON.....")
  include_directories(test)
  add_subdirectory(test)
endif()

###############################################################################
# install package
string(TOUPPER ${PROJECT_NAME} PROJECT_PKG_NAME)

install_package(
  PKG_NAME ${PROJECT_PKG_NAME}
  LIB_NAME ${PROJECT_NAME}
  VERSION ${YDLIDAR_SDK_VERSION}
  INSTALL_HEADERS ${SDK_HEADERS}
  INSTALL_GENERATED_HEADERS ${GENERATED_HEADERS}
  DESTINATION ${CMAKE_INSTALL_PREFIX}/include
  INCLUDE_DIRS ${SDK_INCS}
  LINK_LIBS ${SDK_LIBS}
)

install(DIRECTORY cmake/
  DESTINATION ${CMAKE_INSTALL_PREFIX}/share/${PROJECT_PKG_NAME})

install(FILES LICENSE.txt README.md
  DESTINATION ${CMAKE_INSTALL_PREFIX}/share/${PROJECT_PKG_NAME})

install(DIRECTORY doc
  DESTINATION $
