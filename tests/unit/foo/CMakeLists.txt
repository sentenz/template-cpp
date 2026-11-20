meta_gtest(
    ENABLE ${META_BUILD_TESTING_SEPARATE}
    WITH_DDT
    TARGET ${PROJECT_NAME}-test
    SOURCES
        foo_test.cpp
    LINK
        ${PROJECT_NAME}::foo
)
