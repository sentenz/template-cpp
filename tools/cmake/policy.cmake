include_guard(GLOBAL)

# policy_compiler_warnings(target)
#  - Purpose:
#    Configure sensible compiler warning flags for the given target.
#  - Behavior:
#    * On MSVC: adds "/W4 /permissive-" to the target's PRIVATE compile options.
#    * On non-MSVC compilers: adds "-Wall -Wextra -Wpedantic" to the target's PRIVATE compile options.
#  - Notes:
#    * Applied as target-level options (PRIVATE) so only the target's own translation units are affected.
#    * Call this after the target has been created; the function will NOT check for target existence beyond a fatal error.
function(policy_compiler_warnings target)
  if(MSVC)
    target_compile_options(${target} PRIVATE /W4 /permissive-)
  else()
    target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic)
  endif()
endfunction()

# policy_target_properties(target)
#  - Purpose:
#    Set modern, target-level C++ properties and request an appropriate compile feature baseline.
#  - Behavior:
#    * Validates that the named target exists; otherwise emits a fatal error.
#    * Sets target properties:
#      - CXX_STANDARD 17
#      - CXX_STANDARD_REQUIRED ON
#      - CXX_EXTENSIONS OFF
#      - POSITION_INDEPENDENT_CODE ON
#    * Requests the compile feature cxx_std_17 using target_compile_features(... PUBLIC).
#  - Notes:
#    * Prefers target-level properties over global variables to avoid contaminating other targets.
#    * Using both CXX_STANDARD and target_compile_features provides compatibility with different CMake versions and tooling.
function(policy_target_properties target)
  if(NOT TARGET ${target})
    message(FATAL_ERROR "policy_target_properties(): target '${target}' does not exist")
  endif()

  # Prefer target-level properties over global variables
  set_target_properties(${target} PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS OFF
    POSITION_INDEPENDENT_CODE ON
  )

  # Modern CMake prefers compile features; request a baseline feature as well
  target_compile_features(${target} PUBLIC cxx_std_17)
endfunction()

# policy_warnings_as_errors(target)
#  - Purpose:
#    Promote warnings to errors for supported compilers on the given target.
#  - Behavior:
#    * Validates that the named target exists; otherwise emits a fatal error.
#    * On MSVC: adds "/WX" to the target's PRIVATE compile options.
#    * On GNU/Clang-like toolchains: uses generator expressions to add "-Werror" only when compiling CXX with a matching compiler id:
#      - $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Werror>
#      - $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Werror>
#      - $<$<COMPILE_LANG_AND_ID:CXX,AppleClang>:-Werror>
#  - Notes:
#    * Generator expressions avoid applying flags to unsupported compilers at configure time.
#    * Applied privately so only the target's own compile will treat warnings as errors.
function(policy_warnings_as_errors target)
  if(NOT TARGET ${target})
    message(FATAL_ERROR "policy_warnings_as_errors(): target '${target}' does not exist")
  endif()

  if(MSVC)
    target_compile_options(${target} PRIVATE /WX)
  else()
    # Apply -Werror for GCC/Clang-like compilers. Use generator expressions to avoid
    # attempting to apply flags to unsupported compilers at configure time.
    target_compile_options(${target} PRIVATE
      $<$<COMPILE_LANG_AND_ID:CXX,GNU>:-Werror>
      $<$<COMPILE_LANG_AND_ID:CXX,Clang>:-Werror>
      $<$<COMPILE_LANG_AND_ID:CXX,AppleClang>:-Werror>
    )
  endif()
endfunction()

# policy_visibility(target)
#  - Purpose:
#    Hide exported symbols by default on platforms that support visibility controls.
#  - Behavior:
#    * Validates that the named target exists; otherwise emits a fatal error.
#    * On non-MSVC toolchains: adds "-fvisibility=hidden" to the target's PRIVATE compile options.
#  - Notes:
#    * Hiding symbols by default reduces exported surface area and can improve encapsulation and link-time behavior.
#    * This function only applies visibility-related flags on compilers that support them (i.e., not MSVC).
function(policy_visibility target)
  if(NOT TARGET ${target})
    message(FATAL_ERROR "policy_visibility(): target '${target}' does not exist")
  endif()

  # Hide symbols by default on platforms that support it.
  if(NOT MSVC)
    target_compile_options(${target} PRIVATE -fvisibility=hidden)
  endif()
endfunction()
