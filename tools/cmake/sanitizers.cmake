include_guard(GLOBAL)

# sanitizers_enable
#
# Description:
#   Enable LeakSanitizer, AddressSanitizer and UndefinedBehaviorSanitizer for the current CMake project.
#
# Usage:
#   sanitizers_enable()
function(sanitizers_enable)
  if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    message(FATAL_ERROR "sanitizers_enable(): sanitizers are only supported with the GNU compiler")
  endif()

  set(_sanitize_compile_flags -fsanitize=address,undefined -fno-omit-frame-pointer -g -O0)

  foreach(_cflag IN LISTS _sanitize_compile_flags)
    add_compile_options(
      $<$<COMPILE_LANG_AND_ID:CXX,GNU>:${_cflag}>
      $<$<COMPILE_LANG_AND_ID:C,GNU>:${_cflag}>
    )
  endforeach()

  set(_sanitize_link_flags -fsanitize=address,undefined)

  foreach(_lflag IN LISTS _sanitize_link_flags)
    add_link_options($<$<CXX_COMPILER_ID:GNU>:${_lflag}>)
  endforeach()

  # If not a multi-config generator, prefer Debug if unspecified to avoid optimizer interference
  # with sanitizer diagnostics
  if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type")
  endif()
endfunction()
