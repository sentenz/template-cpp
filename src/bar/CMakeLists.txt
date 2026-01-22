# ── Library Target ───────────────────────────────────────────────────────────────────────────────

add_library(${PROJECT_NAME}-bar STATIC)

target_sources(
    ${PROJECT_NAME}-bar
    PRIVATE
        bar.cpp
    PUBLIC FILE_SET public_headers
    TYPE HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
    FILES
        bar.hpp
)

target_link_libraries(${PROJECT_NAME}-bar PUBLIC ${PROJECT_NAME}::interface)

# Export a namespaced alias for subprojects and downstream consumers to link
add_library(${PROJECT_NAME}::bar ALIAS ${PROJECT_NAME}-bar)

# ── Unit Tests ───────────────────────────────────────────────────────────────────────────────────

meta_gtest(
    ENABLE ${META_BUILD_TESTING}
    TARGET ${PROJECT_NAME}-test
    SOURCES
        bar_test.cpp
    LINK
        ${PROJECT_NAME}::bar
)
