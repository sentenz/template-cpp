meta_gtest(
    TARGET ${PROJECT_NAME}-test-ontarget
    SOURCES
        foo_test.cpp
    LINK
        ${PROJECT_NAME}::foo
)
