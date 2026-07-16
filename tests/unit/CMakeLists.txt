include(meta_gtest)
meta_gtest(
    ENABLE ${META_BUILD_TESTING_SEPARATE}
    WITH_CTEST
    WITH_MAIN
    TARGET ${PROJECT_NAME}-test
)

add_subdirectory(foo)
add_subdirectory(bar)
