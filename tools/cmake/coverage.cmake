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

  # Compile flag guarded by a generator expression so each flag is emitted as its own
  # argument for supported GNU compilations.
  set(_coverage_compile_flags --coverage -O0)
  list(TRANSFORM _coverage_compile_flags PREPEND "")
  foreach(_cflag IN LISTS _coverage_compile_flags)
    add_compile_options($<$<COMPILE_LANG_AND_ID:CXX,GNU>:${_cflag}>)
    add_compile_options($<$<COMPILE_LANG_AND_ID:C,GNU>:${_cflag}>)
  endforeach()

  # Linker flags to ensure libgcov is linked in. Add each link flag guarded by a
  # generator expression so other toolchains aren't impacted.
  set(_coverage_link_flags --coverage)
  foreach(_lflag IN LISTS _coverage_link_flags)
    add_link_options($<$<CXX_COMPILER_ID:GNU>:${_lflag}>)
  endforeach()

  # If not a multi-config generator, prefer Debug if unspecified to avoid optimizer interference
  # with coverage reporting.
  if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type")
  endif()
endfunction()
