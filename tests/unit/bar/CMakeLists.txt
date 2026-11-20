meta_gtest(
    ENABLE ${META_BUILD_TESTING_SEPARATE}
    TARGET ${PROJECT_NAME}-test
    SOURCES
        bar_test.cpp
    LINK
        ${PROJECT_NAME}::bar
)
