include(meta_gtest)
include(meta_jrun)

meta_gtest(
    WITH_MAIN
    TARGET ${PROJECT_NAME}-ontarget-test
)

add_subdirectory(foo)

meta_jrun(
    WITH_CTEST
    TARGET ${PROJECT_NAME}-ontarget-test
    DEVICE "${META_JRUN_DEVICE}"
)
