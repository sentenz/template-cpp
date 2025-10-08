include_guard(GLOBAL)

# Enable code coverage analysis using gcov.
# This function adds the necessary compiler flags and ensures a Debug build type.
# It requires the GNU compiler.
function(coverage_enable)
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        message(FATAL_ERROR "Coverage is only supported with GNU compiler.")
    endif()

    message(STATUS "Enabling coverage analysis")

    # Add coverage flags to C and CXX
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --coverage -O0" CACHE STRING "C compiler flags" FORCE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --coverage -O0" CACHE STRING "C++ compiler flags" FORCE)

    # Ensure debug build type for coverage
    if(NOT CMAKE_BUILD_TYPE MATCHES "Debug")
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
    endif()
endfunction()
