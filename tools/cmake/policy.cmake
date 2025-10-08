include_guard(GLOBAL)

# policy_compiler_warnings
#
# Description:
#   Configure a target with a set of strict compiler warning flags appropriate for the detected
#   compiler.
#
# Parameters:
#   <target>  - The name of an existing CMake target (library or executable).
#
# Usage:
#   add_library(my_lib ...)
#   policy_compiler_warnings(my_lib)
function(policy_compiler_warnings target)
  if(NOT TARGET "${target}")
    message(FATAL_ERROR "policy_compiler_warnings(): target '${target}' does not exist")
  endif()

  if(MSVC)
    target_compile_options("${target}" PRIVATE /W4 /permissive-)
  else()
    # Use generator expressions to apply flags only for supported compilers and languages at build time
    target_compile_options("${target}" PRIVATE
      $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Wall>
      $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Wextra>
      $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Wpedantic>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wall>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wextra>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Wpedantic>
      $<$<COMPILE_LANG_AND_ID:CXX,AppleClang>:-Wall>
      $<$<COMPILE_LANG_AND_ID:CXX,AppleClang>:-Wextra>
      $<$<COMPILE_LANG_AND_ID:CXX,AppleClang>:-Wpedantic>
    )
  endif()
endfunction()

# policy_target_properties
#
# Description:
#   Establish a consistent and modern C++17 build environment for a target.
#
# Parameters:
#   <target>  - The name of an existing CMake target (library or executable).
#
# Usage:
#   add_library(my_lib ...)
#   policy_target_properties(my_lib)
function(policy_target_properties target)
  if(NOT TARGET "${target}")
    message(FATAL_ERROR "policy_target_properties(): target '${target}' does not exist")
  endif()

  # Prefer target-level properties over global variables
  set_target_properties("${target}" PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    POSITION_INDEPENDENT_CODE ON
  )

  # Modern CMake prefers compile features, request a baseline feature as well
  target_compile_features("${target}" PUBLIC cxx_std_17)
endfunction()

# policy_warnings_as_errors(target)
#
# Description:
#   Enforces warnings as errors for the given target.
#
#   NOTE Generator expressions are used so flags are not applied to unsupported compilers
#   at configure time.
#
# Parameters:
#   <target>  - The name of an existing CMake target (library or executable).
#
# Usage:
#     add_library(my_lib ...)
#     policy_warnings_as_errors(my_lib)
function(policy_warnings_as_errors target)
  if(NOT TARGET "${target}")
    message(FATAL_ERROR "policy_warnings_as_errors(): target '${target}' does not exist")
  endif()

  if(MSVC)
    target_compile_options("${target}" PRIVATE /WX)
  else()
    # Apply -Werror for GCC/Clang-like compilers using generator expressions
    target_compile_options("${target}" PRIVATE
      $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Werror>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Werror>
      $<$<COMPILE_LANG_AND_ID:CXX,AppleClang>:-Werror>
    )
  endif()
endfunction()
