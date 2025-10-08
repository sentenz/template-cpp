# ── Library Target ───────────────────────────────────────────────────────────────────────────────

add_library(${PROJECT_NAME}-foo STATIC)

target_sources(${PROJECT_NAME}-foo
  PRIVATE
    foo.cpp
  PUBLIC
    FILE_SET public_headers
    TYPE HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
    FILES foo.hpp
)

policy_target_properties(${PROJECT_NAME}-foo)

target_include_directories(${PROJECT_NAME}-foo
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

policy_compiler_warnings(${PROJECT_NAME}-foo)

# Namespaced alias for downstream consumption
if(NOT TARGET ${PROJECT_NAME}::foo)
  add_library(${PROJECT_NAME}::foo ALIAS ${PROJECT_NAME}-foo)
endif()

# ── Install / Export ─────────────────────────────────────────────────────────────────────────────

include(GNUInstallDirs)

install(
  TARGETS ${PROJECT_NAME}-foo
  EXPORT ${PROJECT_NAME}-targets
  FILE_SET public_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
)

