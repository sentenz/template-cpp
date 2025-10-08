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
target_include_directories(${PROJECT_NAME}-bar
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src>
    $<INSTALL_INTERFACE:include>
)

policy_target_properties(${PROJECT_NAME}-bar)
policy_compiler_warnings(${PROJECT_NAME}-bar)

# Namespaced alias for downstream consumption
if(NOT TARGET ${PROJECT_NAME}::bar)
  add_library(${PROJECT_NAME}::bar ALIAS ${PROJECT_NAME}-bar)
endif()

# ── Install / Export ─────────────────────────────────────────────────────────────────────────────

install(
  TARGETS ${PROJECT_NAME}-bar
  EXPORT ${PROJECT_NAME}-targets
  FILE_SET public_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
)

