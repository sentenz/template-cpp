include(FetchContent)

set(BUILD_GMOCK OFF CACHE BOOL "Google Mock not required for this example" FORCE)
set(INSTALL_GTEST OFF CACHE BOOL "Do not install downloaded Google Test" FORCE)
set(gtest_disable_pthreads ON CACHE BOOL "No POSIX threads on Cortex-M" FORCE)

# These definitions must reach Google Test itself as well as test sources.
if(BUILD_EMBEDDED)
  add_compile_definitions(
    GTEST_HAS_PTHREAD=0
    GTEST_HAS_EXCEPTIONS=0
    GTEST_HAS_RTTI=0
    GTEST_HAS_STREAM_REDIRECTION=0
    GTEST_HAS_FILE_SYSTEM=0
  )
endif()

# Offline option: -DFETCHCONTENT_SOURCE_DIR_GOOGLETEST=/path/to/googletest
FetchContent_Declare(googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG v1.17.0
  GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(googletest)
