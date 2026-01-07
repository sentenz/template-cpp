# ── Library Target ───────────────────────────────────────────────────────────────────────────────

add_library(${PROJECT_NAME}-bar STATIC)

target_sources(
    ${PROJECT_NAME}-bar
    PRIVATE bar.cpp
    PUBLIC FILE_SET public_headers TYPE HEADERS BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR} FILES bar.hpp
)
target_link_libraries(${PROJECT_NAME}-bar PUBLIC ${PROJECT_NAME}::includes)

# Provide a namespaced alias for internal use
if(NOT TARGET ${PROJECT_NAME}::bar)
    add_library(${PROJECT_NAME}::bar ALIAS ${PROJECT_NAME}-bar)
endif()

# ── Unit Tests ───────────────────────────────────────────────────────────────────────────────────

if(META_BUILD_TESTING)
    include(meta_gtest)

    meta_gtest(
        TARGET ${PROJECT_NAME}
        SOURCES
            bar_test.cpp
        LINK
            ${PROJECT_NAME}::bar
    )
endif()
