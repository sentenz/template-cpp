include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/meta_utils.cmake")

# Description:
#   Enable compiler cache using ccache or sccache to speed up recompilation by caching previous
#   compilations and detecting when the same compilation is being done again.
#
# Arguments:
#   One-Value
#     ENABLE     - Boolean flag to enable compiler cache (ON/OFF).
#     TYPE       - Type of cache to use: "ccache", "sccache", or "auto" (default: "auto").
#                  "auto" will try to find ccache first, then sccache.
#
# Outputs:
#   NONE
#
# Usage:
#   meta_cache(ENABLE <enable> [TYPE <type>])
#
# Example:
#   meta_cache(ENABLE ON)
#   meta_cache(ENABLE ON TYPE ccache)
#   meta_cache(ENABLE ON TYPE sccache)
#   meta_cache(ENABLE ON TYPE auto)
function(meta_cache)
  meta_parse_arguments(ONE_VALUE_ARGS ENABLE TYPE)

  if(NOT ARG_ENABLE)
    return()
  endif()

  # Default to auto-detection if TYPE is not specified
  if(NOT DEFINED ARG_TYPE OR ARG_TYPE STREQUAL "")
    set(ARG_TYPE "auto")
  endif()

  # Validate TYPE argument
  if(NOT ARG_TYPE MATCHES "^(ccache|sccache|auto)$")
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}(): Invalid TYPE '${ARG_TYPE}'. Must be 'ccache', 'sccache', or 'auto'.")
  endif()

  set(meta_cache_found FALSE)
  set(meta_cache_executable "")
  set(meta_cache_name "")

  # Try to find the specified cache tool or auto-detect
  if(ARG_TYPE STREQUAL "ccache")
    find_program(META_CCACHE_EXECUTABLE ccache)
    if(META_CCACHE_EXECUTABLE)
      set(meta_cache_found TRUE)
      set(meta_cache_executable "${META_CCACHE_EXECUTABLE}")
      set(meta_cache_name "ccache")
    endif()
  elseif(ARG_TYPE STREQUAL "sccache")
    find_program(META_SCCACHE_EXECUTABLE sccache)
    if(META_SCCACHE_EXECUTABLE)
      set(meta_cache_found TRUE)
      set(meta_cache_executable "${META_SCCACHE_EXECUTABLE}")
      set(meta_cache_name "sccache")
    endif()
  elseif(ARG_TYPE STREQUAL "auto")
    # Try ccache first
    find_program(META_CCACHE_EXECUTABLE ccache)
    if(META_CCACHE_EXECUTABLE)
      set(meta_cache_found TRUE)
      set(meta_cache_executable "${META_CCACHE_EXECUTABLE}")
      set(meta_cache_name "ccache")
    else()
      # Try sccache if ccache is not found
      find_program(META_SCCACHE_EXECUTABLE sccache)
      if(META_SCCACHE_EXECUTABLE)
        set(meta_cache_found TRUE)
        set(meta_cache_executable "${META_SCCACHE_EXECUTABLE}")
        set(meta_cache_name "sccache")
      endif()
    endif()
  endif()

  # Check if a cache tool was found
  if(NOT meta_cache_found)
    if(ARG_TYPE STREQUAL "auto")
      message(WARNING "${CMAKE_CURRENT_FUNCTION}(): Neither 'ccache' nor 'sccache' found. Compiler cache will be disabled.")
    else()
      message(WARNING "${CMAKE_CURRENT_FUNCTION}(): '${ARG_TYPE}' not found. Compiler cache will be disabled.")
    endif()
    return()
  endif()

  # Set CMake variables to use the compiler cache
  set(CMAKE_C_COMPILER_LAUNCHER "${meta_cache_executable}" CACHE STRING "C compiler launcher")
  set(CMAKE_CXX_COMPILER_LAUNCHER "${meta_cache_executable}" CACHE STRING "C++ compiler launcher")

  message(STATUS "${CMAKE_CURRENT_FUNCTION}(): Enabled compiler cache using '${meta_cache_name}' (${meta_cache_executable})")
endfunction()
