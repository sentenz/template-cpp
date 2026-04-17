meta_gtest(
    TARGET ${PROJECT_NAME}-test-ontarget
    SOURCES
        bar_test.cpp
    LINK
        ${PROJECT_NAME}::bar
)
