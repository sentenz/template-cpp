# ── Executable Target ────────────────────────────────────────────────────────────────────────────

add_executable(${PROJECT_NAME})

target_sources(${PROJECT_NAME} PRIVATE main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}::foo ${PROJECT_NAME}::bar)
target_include_directories(${PROJECT_NAME} PRIVATE $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src>)

policy_target_properties(${PROJECT_NAME})
policy_compiler_warnings(${PROJECT_NAME})

# ── Install Target ───────────────────────────────────────────────────────────────────────────────

install(
  TARGETS ${PROJECT_NAME}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
