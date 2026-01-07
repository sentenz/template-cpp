# ── Library Target ───────────────────────────────────────────────────────────────────────────────

add_library(${PROJECT_NAME}-bar STATIC)

target_sources(
    ${PROJECT_NAME}-bar
    PRIVATE bar.cpp
    PUBLIC FILE_SET public_headers TYPE HEADERS BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR} FILES bar.hpp
)
target_link_libraries(${PROJECT_NAME}-bar PUBLIC ${PROJECT_NAME}::includes)

# Export a namespaced alias for subprojects and downstream consumers to link
if(NOT TARGET ${PROJECT_NAME}::bar)
    add_library(${PROJECT_NAME}::bar ALIAS ${PROJECT_NAME}-bar)
endif()

# ── Unit Tests ───────────────────────────────────────────────────────────────────────────────────

meta_gtest(
    ENABLE ${META_BUILD_TESTING}
    TARGET ${PROJECT_NAME}-test
    SOURCES
        bar_test.cpp
    LINK
        ${PROJECT_NAME}::bar
)
