# ── Library Target ───────────────────────────────────────────────────────────────────────────────

add_library(${PROJECT_NAME}-core STATIC)

target_sources(${PROJECT_NAME}-core
  PRIVATE
    foo.cpp
  PUBLIC
    FILE_SET public_headers
    TYPE HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
    FILES foo.hpp
)

policy_target_properties(${PROJECT_NAME}-core)

target_include_directories(${PROJECT_NAME}-core
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

policy_compiler_warnings(${PROJECT_NAME}-core)

# Namespaced alias for downstream consumption
add_library(${PROJECT_NAME}::core ALIAS ${PROJECT_NAME}-core)

# ── Executable Target ────────────────────────────────────────────────────────────────────────────

add_executable(${PROJECT_NAME})
target_sources(${PROJECT_NAME} PRIVATE main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}-core)
policy_compiler_warnings(${PROJECT_NAME})

# ── Install / Export ─────────────────────────────────────────────────────────────────────────────

include(GNUInstallDirs)

install(
  TARGETS ${PROJECT_NAME}-core
  EXPORT ${PROJECT_NAME}-targets
  FILE_SET public_headers
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}
)

install(
  TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
