list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/tools/cmake")
include(policy)

add_subdirectory(app)
add_subdirectory(foo)
add_subdirectory(bar)
