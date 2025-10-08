include_guard(GLOBAL)

# coverage_enable()
#
# Enables source-code coverage instrumentation for projects built with the GNU C/C++ compiler
# (GCC). This function configures compiler and build settings so that produced binaries so that
# produced binaries include coverage information compatible with gcov/lcov.
#
# Usage
#   coverage_enable()
function(coverage_enable)
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        message(FATAL_ERROR "Coverage is only supported with GNU compiler.")
    endif()

    # Compile flags (optimization and coverage instrumentation)
    set(_coverage_flags --coverage -O0)
    # Linker-only flags for coverage (ensure libgcov symbols are linked)
    set(_coverage_link_flags --coverage)

    if(NOT DEFINED COVERAGE_ENABLED)
        add_compile_options(${_coverage_flags})
        # Add link options so the coverage runtime (libgcov) is pulled in at link time
        add_link_options(${_coverage_link_flags})

        # Record that coverage has been enabled
        set(COVERAGE_ENABLED TRUE CACHE INTERNAL "Coverage instrumentation enabled")
    endif()

    # Ensure debug build type for coverage
    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type")
    endif()
endfunction()
