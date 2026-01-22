include_guard(GLOBAL)

# Description:
#   Enable compiler cache using ccache or sccache to speed up recompilation by caching
#   previous compilations and detecting when the same compilation is being done again.
#
#   NOTE Sets CMAKE_C_COMPILER_LAUNCHER and CMAKE_CXX_COMPILER_LAUNCHER if a cache is found.
#
# Arguments:
#   One-Value
#     ENABLE     - Optional: Boolean flag to enable/disable compiler cache (default: ON).
#     TYPE       - Optional: Compiler cache type to use in the order "auto", "ccache" or "sccache" (default: "auto").
#
# Outputs:
#   NONE
#
# Usage:
#   meta_compiler_cache(ENABLE <enable> [TYPE <type>])
#
# Example:
#   meta_compiler_cache(ENABLE ON)
#   meta_compiler_cache(ENABLE ON TYPE ccache)
#   meta_compiler_cache(ENABLE ON TYPE sccache)
#   meta_compiler_cache(ENABLE ON TYPE auto)
function(meta_compiler_cache)
    set(one_value_args ENABLE TYPE)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "" "${one_value_args}" "")

    if(DEFINED ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Unknown arguments: ${ARG_UNPARSED_ARGUMENTS}.")
    endif()

    if(DEFINED ARG_ENABLE AND NOT ARG_ENABLE)
        return()
    endif()

    # Set default TYPE to "auto" if not specified
    if(NOT DEFINED ARG_TYPE OR ARG_TYPE STREQUAL "")
        set(ARG_TYPE "auto")
    endif()

    # Validate TYPE argument
    if(NOT ARG_TYPE MATCHES "^(auto|ccache|sccache)$")
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Invalid TYPE '${ARG_TYPE}'. Must be 'auto', 'ccache', or 'sccache'.")
    endif()

    # Try to find the requested cache TYPE
    if(ARG_TYPE STREQUAL "ccache")
        find_program(meta_cache_exe NAMES ccache)
        if(NOT meta_cache_exe)
            message(WARNING "${CMAKE_CURRENT_FUNCTION}: 'ccache' not found. Compiler cache will be disabled.")
            return()
        endif()
    elseif(ARG_TYPE STREQUAL "sccache")
        find_program(meta_cache_exe NAMES sccache)
        if(NOT meta_cache_exe)
            message(WARNING "${CMAKE_CURRENT_FUNCTION}: 'sccache' not found. Compiler cache will be disabled.")
            return()
        endif()
    elseif(ARG_TYPE STREQUAL "auto")
        # Auto-detect: prefer ccache, fallback to sccache
        find_program(meta_cache_exe NAMES ccache)
        if(NOT meta_cache_exe)
            find_program(meta_cache_exe NAMES sccache)
        endif()

        # Check if a cache tool was found
        if(NOT meta_cache_exe)
            message(WARNING "${CMAKE_CURRENT_FUNCTION}: Neither 'ccache' nor 'sccache' found. Compiler cache will be disabled.")
            return()
        endif()
    endif()

    # Set compiler launcher to use the cache tool for C and C++
    set(CMAKE_C_COMPILER_LAUNCHER "${meta_cache_exe}" CACHE STRING "C compiler launcher" FORCE)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${meta_cache_exe}" CACHE STRING "C++ compiler launcher" FORCE)

    # Get the basename of the cache executable for the message
    get_filename_component(cache_name "${meta_cache_exe}" NAME)
    message(STATUS "${CMAKE_CURRENT_FUNCTION}: Compiler cache enabled: ${cache_name} at ${meta_cache_exe}")
endfunction()
