# Centralized include target for subdirectories to link a single source/install specification
add_library(${PROJECT_NAME}-includes INTERFACE)
target_include_directories(
    ${PROJECT_NAME}-includes
    INTERFACE
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}>
)

# Export a namespaced alias for subprojects and downstream consumers to link
if(NOT TARGET ${PROJECT_NAME}::includes)
    add_library(${PROJECT_NAME}::includes ALIAS ${PROJECT_NAME}-includes)
endif()

# ── Unit Test Target Setup ───────────────────────────────────────────────────────────────────────

if(META_BUILD_TESTING)
    include(meta_gtest)

    meta_gtest(
        WITH_CTEST
        WITH_MAIN
        TARGET ${PROJECT_NAME}
    )
endif()

# ── Subdirectories ───────────────────────────────────────────────────────────────────────────────

if(NOT META_BUILD_TESTING)
    add_subdirectory(app)
endif()
add_subdirectory(foo)
add_subdirectory(bar)
