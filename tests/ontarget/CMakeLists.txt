include(meta_gtest)

meta_gtest(
    WITH_MAIN
    TARGET ${PROJECT_NAME}-test-ontarget
)

add_subdirectory(foo)
add_subdirectory(bar)
