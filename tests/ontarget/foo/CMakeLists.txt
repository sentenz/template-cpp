meta_gtest(
    ENABLE ${META_BUILD_TESTING_ONTARGET}
    TARGET ${PROJECT_NAME}-test
    SOURCES
        foo_test.cpp
    LINK
        ${PROJECT_NAME}::foo
)
