# ── Library Target ───────────────────────────────────────────────────────────────────────────────

add_library(${PROJECT_NAME}-foo STATIC)

target_sources(
    ${PROJECT_NAME}-foo
    PRIVATE foo.cpp
    PUBLIC FILE_SET public_headers TYPE HEADERS BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR} FILES foo.hpp
)
target_link_libraries(${PROJECT_NAME}-foo PUBLIC ${PROJECT_NAME}::includes)

# Provide a namespaced alias for internal use
if(NOT TARGET ${PROJECT_NAME}::foo)
    add_library(${PROJECT_NAME}::foo ALIAS ${PROJECT_NAME}-foo)
endif()
