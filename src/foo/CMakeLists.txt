# ── Library Target ───────────────────────────────────────────────────────────────────────────────

add_library(${PROJECT_NAME}-foo STATIC)

target_sources(
    ${PROJECT_NAME}-foo
    PRIVATE
        foo.cpp
    PUBLIC FILE_SET public_headers
    TYPE HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
    FILES
        foo.hpp
)

target_link_libraries(${PROJECT_NAME}-foo PUBLIC ${PROJECT_NAME}::interface)

# Export a namespaced alias for subprojects and downstream consumers to link
add_library(${PROJECT_NAME}::foo ALIAS ${PROJECT_NAME}-foo)

# ── Unit Tests ───────────────────────────────────────────────────────────────────────────────────

meta_gtest(
    ENABLE ${META_BUILD_TESTING}
    WITH_DDT
    TARGET ${PROJECT_NAME}-test
    SOURCES
        foo_test.cpp
    LINK
        ${PROJECT_NAME}::foo
)
