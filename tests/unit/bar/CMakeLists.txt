meta_gtest(
    TARGET ${PROJECT_NAME}-test
    SOURCES
        bar_test.cpp
    LINK
        ${PROJECT_NAME}::bar
)
