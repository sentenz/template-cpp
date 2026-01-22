include_guard(GLOBAL)

# Description:
#   Enable LeakSanitizer (LSan), AddressSanitizer (ASan), and Undefined Behavior Sanitizer (UBSan).
#
# Arguments:
#   One-Value
#     ENABLE     - Optional: Boolean flag to enable/disable sanitizers (default: ON).
#
# Outputs:
#   NONE
#
# Usage:
#   meta_sanitizers(ENABLE <enable>)
#
# Example:
#   meta_sanitizers(ENABLE ON)
function(meta_sanitizers)
    set(one_value_args ENABLE)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "" "${one_value_args}" "")

    if(DEFINED ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Unknown arguments: ${ARG_UNPARSED_ARGUMENTS}.")
    endif()

    if(DEFINED ARG_ENABLE AND NOT ARG_ENABLE)
        return()
    endif()

    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        message(WARNING "${CMAKE_CURRENT_FUNCTION}: Sanitizers only supported with GNU or Clang compilers.")
        return()
    endif()

    # Compilation flags are guarded by generator expressions so that each flag is emitted as a
    # separate argument for supported compilers
    set(meta_compile_flags "-fsanitize=address,undefined" "-fno-omit-frame-pointer" "-g" "-O0")
    add_compile_options(
        "$<$<COMPILE_LANG_AND_ID:CXX,GNU,Clang>:${meta_compile_flags}>"
        "$<$<COMPILE_LANG_AND_ID:C,GNU,Clang>:${meta_compile_flags}>"
    )

    # Linker flags are guarded by generator expressions to ensure sanitizers are linked only for
    # supported compilers so that other toolchains are not affected
    set(meta_link_flags "-fsanitize=address,undefined")
    add_link_options("$<$<CXX_COMPILER_ID:GNU,Clang>:${meta_link_flags}>")
endfunction()
