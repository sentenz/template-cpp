include(meta_gtest)
meta_gtest(
    ENABLE ${META_BUILD_TESTING_ONTARGET}
    WITH_MAIN
    TARGET ${PROJECT_NAME}-test
)

add_subdirectory(foo)
add_subdirectory(bar)
