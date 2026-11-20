# Build the framework with the same CPU, C++ ABI and newlib as the firmware.
include(FetchContent)
set(BUILD_GMOCK OFF)
set(INSTALL_GTEST OFF)
set(gtest_disable_pthreads ON)
FetchContent_Declare(googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG 063de7e9578f82b369302001269680b4b1553359 # v1.18.0
    EXCLUDE_FROM_ALL
)
FetchContent_MakeAvailable(googletest)
target_compile_definitions(gtest PUBLIC _DEFAULT_SOURCE GTEST_HAS_FILE_SYSTEM=0 GTEST_HAS_POSIX_RE=0)

include(meta_gtest)
set(firmware ${PROJECT_NAME}-ontarget-test)
meta_gtest(
    TARGET ${firmware}
    SOURCES main.cpp foo_test.cpp ${PROJECT_SOURCE_DIR}/src/foo/foo.cpp ${META_ONTARGET_STARTUP}
)
target_include_directories(${firmware} PRIVATE "${PROJECT_SOURCE_DIR}/src")
set_target_properties(${firmware} PROPERTIES SUFFIX ".elf")
if(META_ONTARGET_LINKER_SCRIPT)
    set_property(TARGET ${firmware} APPEND PROPERTY LINK_DEPENDS "${META_ONTARGET_LINKER_SCRIPT}")
endif()

set(META_JRUN_USB "" CACHE STRING "J-Link USB serial number or nickname")
set(META_JRUN_IP "" CACHE STRING "Remote J-Link address or hostname")
set(META_JRUN_SUITES "FooArithmetic;FooText" CACHE STRING "Google Test suite names (empty runs the entire image)")
set(META_JRUN_INTERFACE SWD CACHE STRING "J-Link debug interface")
set(META_JRUN_SPEED 4000 CACHE STRING "J-Link speed in kHz")
set(META_JRUN_TIMEOUT 60 CACHE STRING "Time limit per flash and test run in seconds")

set(probe_args)
foreach(transport IN ITEMS USB IP)
    if(META_JRUN_${transport})
        list(APPEND probe_args ${transport} "${META_JRUN_${transport}}")
    endif()
endforeach()

include(meta_jrun)
meta_jrun(
    WITH_GTEST WITH_SEMIHOSTING
    TARGET ${firmware}
    DEVICE ${META_DEVICE_NAME}
    ${probe_args}
    INTERFACE ${META_JRUN_INTERFACE}
    SPEED ${META_JRUN_SPEED}
    TIMEOUT ${META_JRUN_TIMEOUT}
    SUITES ${META_JRUN_SUITES}
)
