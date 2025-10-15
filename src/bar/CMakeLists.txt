# ── Library Target ───────────────────────────────────────────────────────────────────────────────

add_library(${PROJECT_NAME}-bar STATIC)

target_sources(${PROJECT_NAME}-bar
  PRIVATE
    bar.cpp
  PUBLIC
    FILE_SET public_headers
    TYPE HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
    FILES bar.hpp
)
target_link_libraries(${PROJECT_NAME}-bar PUBLIC ${PROJECT_NAME}::includes)

policy_target_properties(${PROJECT_NAME}-bar)
policy_compiler_warnings(${PROJECT_NAME}-bar)

# Provide a namespaced alias for internal use
if(NOT TARGET ${PROJECT_NAME}::bar)
  add_library(${PROJECT_NAME}::bar ALIAS ${PROJECT_NAME}-bar)
endif()

