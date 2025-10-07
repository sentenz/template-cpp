cmake_minimum_required(VERSION 3.23.0)

project(${META_PROJECT_NAME})

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/tools/cmake")
include(policy)

include(GNUInstallDirs)

if(META_BUILD_TESTING)
  include(CTest)
  if(NOT DEFINED BUILD_TESTING)
    enable_testing()
  endif()
endif()

# Subdirectories
add_subdirectory(src)
add_subdirectory(tests)
