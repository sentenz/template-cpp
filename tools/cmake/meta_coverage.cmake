include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/meta_utils.cmake")

# Description:
#   Enable code coverage instrumentation for projects built with the GNU Compiler Collection (GCC)
#   or with Clang.
#
# Arguments:
#   One-Value
#     ENABLE     - Boolean flag to enable coverage (ON/OFF).
#
# Outputs:
#   NONE
#
# Usage:
#   meta_coverage(ENABLE <enable>)
#
# Example:
#   meta_coverage(ENABLE ON)
function(meta_coverage)
  meta_parse_arguments(ONE_VALUE_ARGS ENABLE)

  if(NOT ARG_ENABLE)
    return()
  endif()

  find_program(meta_gcovr_executable gcovr)
  if(NOT meta_gcovr_executable)
    message(WARNING "${CMAKE_CURRENT_FUNCTION}(): 'gcovr' not found. Code coverage will be disabled.")
    return()
  endif()

  if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    message(WARNING "${CMAKE_CURRENT_FUNCTION}(): Code Coverage only supported with GNU or Clang compilers.")
    return()
  endif()

  # Compilation flags are guarded by generator expressions so that each flag is emitted as a
  # separate argument for supported compilers
  set(meta_compile_flags
    "--coverage"
    "-O0"
    "-g"
  )
  add_compile_options(
    "$<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang>:${meta_compile_flags}>"
    "$<$<COMPILE_LANG_AND_ID:C,GNU,Clang>:${meta_compile_flags}>"
  )

  # Linker flags are guarded by generator expressions to ensure libgcov is linked only for
  # supported compilers so that other toolchains are not affected
  set(meta_link_flags
    "--coverage"
  )
  add_link_options("$<$<CXX_COMPILER_ID:GNU,Clang>:${meta_link_flags}>")
endfunction()
