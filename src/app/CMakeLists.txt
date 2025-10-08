# ── Executable Target ────────────────────────────────────────────────────────────────────────────

add_executable(${PROJECT_NAME})
target_sources(${PROJECT_NAME} PRIVATE main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}::foo ${PROJECT_NAME}::bar)
policy_compiler_warnings(${PROJECT_NAME})

# Ensure the executable can find headers under src/ (e.g. foo/foo.hpp)
target_include_directories(${PROJECT_NAME}
  PRIVATE
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src>
)

# ── Install Target ───────────────────────────────────────────────────────────────────────────────

install(
  TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
