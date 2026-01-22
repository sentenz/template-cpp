include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/meta_utils.cmake")

# Description:
#   Set global project properties for languages (C++ Standard) and compiler warnings.
#
# Arguments:
#   NONE
#
# Outputs:
#   NONE
#
# Usage:
#   meta_policy()
#
# Example:
#   meta_policy()
function(meta_policy)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "" "" "")

    # Global Language Properties
    set(CMAKE_CXX_STANDARD 23 CACHE STRING "C++ standard to be used")
    set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "Require C++ standard")
    set(CMAKE_CXX_EXTENSIONS OFF CACHE BOOL "Disable C++ extensions")

    # Global Compiler Warnings
    if(MSVC)
        add_compile_options(/W4 /permissive-)
    else()
        set(meta_warning_flags -Wall -Wextra -Wpedantic)
        foreach(warning_flag IN LISTS meta_warning_flags)
            add_compile_options(
                $<$<COMPILE_LANG_AND_ID:CXX,GNU>:${warning_flag}>
                $<$<COMPILE_LANG_AND_ID:CXX,Clang>:${warning_flag}>
                $<$<COMPILE_LANG_AND_ID:CXX,AppleClang>:${warning_flag}>
            )
        endforeach()
    endif()
endfunction()
