include(meta_gtest)
include(meta_jrun)

# Create the on-target test executable with a main entry point. Sources are appended
# incrementally by each subdirectory using the same TARGET name (meta_gtest is idempotent).
meta_gtest(
    WITH_MAIN
    TARGET ${PROJECT_NAME}-ontarget-test
)

add_subdirectory(foo)

# Register the fully-linked test executable as a CTest test that is flashed and run
# on the target hardware via SEGGER J-Run. Set META_JRUN_DEVICE at configure time,
# e.g., -DMETA_JRUN_DEVICE=Cortex-M4.
meta_jrun(
    WITH_CTEST
    TARGET ${PROJECT_NAME}-ontarget-test
)
