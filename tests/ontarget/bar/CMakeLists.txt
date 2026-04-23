meta_gtest(
    ENABLE ${META_BUILD_TESTING_ONTARGET}
    TARGET ${PROJECT_NAME}-test
    SOURCES
        bar_test.cpp
    LINK
        ${PROJECT_NAME}::bar
)
