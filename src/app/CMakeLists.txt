# ── Executable Target ────────────────────────────────────────────────────────────────────────────

add_executable(${PROJECT_NAME})

target_sources(${PROJECT_NAME} PRIVATE main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}::foo ${PROJECT_NAME}::bar ${PROJECT_NAME}::includes)

# ── Install Target ───────────────────────────────────────────────────────────────────────────────

install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
