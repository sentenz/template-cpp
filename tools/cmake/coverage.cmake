include_guard(GLOBAL)

# coverage_enable
#
# Description:
#   Enable code coverage instrumentation for projects built with the GNU C/C++ compiler (GCC).
#
# Usage:
#   coverage_enable()
function(coverage_enable)
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        message(FATAL_ERROR "coverage_enable(): coverage is only supported with the GNU compiler")
    endif()

        # Compile and link flags used for gcov/lcov
        set(_coverage_compile_flags --coverage -O0)
        list(TRANSFORM _coverage_compile_flags PREPEND "")
        set(_coverage_link_flags --coverage)

        if(NOT DEFINED COVERAGE_ENABLED)
            # Compile flag guarded by a generator expression so each flag is emitted as its own
            # argument for supported GNU compilations.
            foreach(_cflag IN LISTS _coverage_compile_flags)
                add_compile_options($<$<COMPILE_LANG_AND_ID:CXX,GNU>:${_cflag}>)
                add_compile_options($<$<COMPILE_LANG_AND_ID:C,GNU>:${_cflag}>)
            endforeach()

            # Linker flags to ensure libgcov is linked in. Add each link flag guarded by a
            # generator expression so other toolchains aren't impacted.
            foreach(_lflag IN LISTS _coverage_link_flags)
                add_link_options($<$<CXX_COMPILER_ID:GNU>:${_lflag}>)
            endforeach()

            set(COVERAGE_ENABLED TRUE CACHE INTERNAL "Coverage instrumentation enabled")
        endif()

  # If not a multi-config generator, prefer Debug if unspecified to avoid optimizer interference
  # with coverage reporting.
    if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type")
    endif()
endfunction()
