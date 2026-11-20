# ── Setup and Configuration ──────────────────────────────────────────────────────────────────────

include(CTest)
if(NOT DEFINED BUILD_TESTING)
    enable_testing()
endif()

include(meta_conan)
meta_conan()

# ── Library Target ───────────────────────────────────────────────────────────────────────────────

add_library(${META_PROJECT_NAME}-foo STATIC)

target_sources(
    ${META_PROJECT_NAME}-foo
    PRIVATE
        foo.cpp
    PUBLIC FILE_SET public_headers
    TYPE HEADERS
    BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}
    FILES
        foo.hpp
)

target_include_directories(${META_PROJECT_NAME}-foo PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

add_library(${META_PROJECT_NAME}::foo ALIAS ${META_PROJECT_NAME}-foo)

# ── Unit Tests ───────────────────────────────────────────────────────────────────────────────────

include(meta_unity)
meta_unity(
    ENABLE ${META_BUILD_TESTING_ONTARGET}
    TARGET ${META_PROJECT_NAME}-test
    SOURCES
        foo_test.cpp
    LINK
        ${META_PROJECT_NAME}::foo
)


# ── Flash Tests ──────────────────────────────────────────────────────────────────────────────────

include(meta_jrun)
meta_jrun(
    ENABLE ${META_BUILD_TESTING_ONTARGET}
    WITH_RTT
    TARGET ${META_PROJECT_NAME}-test
    DEVICE ${META_DEVICE_NAME}
)
