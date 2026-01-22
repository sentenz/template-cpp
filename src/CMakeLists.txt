# ── Include Target ─────────────────────────────────────────────────────────────────────────────

# Provide an interface target for including headers
add_library(${PROJECT_NAME}-interface INTERFACE)
target_include_directories(${PROJECT_NAME}-interface INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}>
)

# Export a namespaced alias for subprojects and downstream consumers to link
add_library(${PROJECT_NAME}::interface ALIAS ${PROJECT_NAME}-interface)

# ── Unit Tests ───────────────────────────────────────────────────────────────────────────────────

include(meta_gtest)
meta_gtest(
    ENABLE ${META_BUILD_TESTING}
    WITH_CTEST
    WITH_MAIN
    TARGET ${PROJECT_NAME}-test
)

# ── Subdirectories ───────────────────────────────────────────────────────────────────────────────

add_subdirectory(app)
add_subdirectory(foo)
add_subdirectory(bar)
