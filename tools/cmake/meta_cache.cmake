include_guard(GLOBAL)

# Description:
#   Enable compiler caching using ccache or sccache to speed up recompilation by caching
#   previous compilations and detecting when the same compilation is being done again.
#
# Arguments:
#   One-Value
#     ENABLE     - Boolean flag to enable compiler cache (ON/OFF).
#     BACKEND    - Compiler cache backend to use: "ccache", "sccache", or "auto" (default: "auto").
#
# Outputs:
#   Sets CMAKE_C_COMPILER_LAUNCHER and CMAKE_CXX_COMPILER_LAUNCHER if a cache is found.
#
# Usage:
#   meta_cache(ENABLE <enable> [BACKEND <backend>])
#
# Example:
#   meta_cache(ENABLE ON)
#   meta_cache(ENABLE ON BACKEND ccache)
#   meta_cache(ENABLE ON BACKEND sccache)
function(meta_cache)
    set(one_value_args ENABLE BACKEND)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "" "${one_value_args}" "")

    if(DEFINED ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Unknown arguments: ${ARG_UNPARSED_ARGUMENTS}.")
    endif()

    if(NOT ARG_ENABLE)
        return()
    endif()

    # Set default backend to "auto" if not specified
    if(NOT DEFINED ARG_BACKEND OR ARG_BACKEND STREQUAL "")
        set(ARG_BACKEND "auto")
    endif()

    # Validate backend argument
    if(NOT ARG_BACKEND MATCHES "^(auto|ccache|sccache)$")
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Invalid BACKEND '${ARG_BACKEND}'. Must be 'auto', 'ccache', or 'sccache'.")
    endif()

    # Try to find the requested cache backend
    if(ARG_BACKEND STREQUAL "ccache")
        find_program(meta_cache_exe NAMES ccache)
        if(NOT meta_cache_exe)
            message(WARNING "${CMAKE_CURRENT_FUNCTION}: 'ccache' not found. Compiler caching will be disabled.")
            return()
        endif()
    elseif(ARG_BACKEND STREQUAL "sccache")
        find_program(meta_cache_exe NAMES sccache)
        if(NOT meta_cache_exe)
            message(WARNING "${CMAKE_CURRENT_FUNCTION}: 'sccache' not found. Compiler caching will be disabled.")
            return()
        endif()
    elseif(ARG_BACKEND STREQUAL "auto")
        # Auto-detect: prefer ccache, fallback to sccache
        find_program(meta_cache_exe NAMES ccache)
        if(NOT meta_cache_exe)
            find_program(meta_cache_exe NAMES sccache)
        endif()
        if(NOT meta_cache_exe)
            message(WARNING "${CMAKE_CURRENT_FUNCTION}: Neither 'ccache' nor 'sccache' found. Compiler caching will be disabled.")
            return()
        endif()
    endif()

    # Set compiler launcher for C and C++
    set(CMAKE_C_COMPILER_LAUNCHER "${meta_cache_exe}" CACHE STRING "C compiler launcher" FORCE)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${meta_cache_exe}" CACHE STRING "C++ compiler launcher" FORCE)

    # Get the basename of the cache executable for the message
    get_filename_component(cache_name "${meta_cache_exe}" NAME)
    message(STATUS "Compiler cache enabled: ${cache_name} at ${meta_cache_exe}")
endfunction()
