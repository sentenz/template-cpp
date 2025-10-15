list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/tools/cmake")
include(policy)

# Centralized include target for subdirectories to link a single source/install specification
add_library(${PROJECT_NAME}-includes INTERFACE)
target_include_directories(${PROJECT_NAME}-includes INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}>
)

# Export a namespaced alias for subprojects and downstream consumers to link
if(NOT TARGET ${PROJECT_NAME}::includes)
  add_library(${PROJECT_NAME}::includes ALIAS ${PROJECT_NAME}-includes)
endif()

add_subdirectory(app)
add_subdirectory(foo)
add_subdirectory(bar)
