include_guard(GLOBAL)

# Description:
#   Internal wrapper for cmake_parse_arguments that provides consistent argument parsing with
#   automatic validation for unparsed arguments. Uses PARSE_ARGV mode and the standard ARG prefix.
#
# Arguments:
#   Options
#     options          - Option names (boolean flags with no value).
#   One-Value
#     one_value_args   - Argument names that accept a single value.
#   Multi-Value
#     multi_value_args - Argument names that accept multiple values.
#
# Outputs:
#   Sets ARG_<name> variables in the caller's scope for each parsed argument.
#
# Usage:
#   meta_parse_arguments(
#     OPTIONS <opt>...
#     ONE_VALUE_ARGS <arg>...
#     MULTI_VALUE_ARGS <arg>...
#   )
#
# Example:
#   meta_parse_arguments(
#     OPTIONS WITH_GMOCK WITH_MAIN
#     ONE_VALUE_ARGS TARGET
#     MULTI_VALUE_ARGS SOURCES LINK
#   )
macro(meta_parse_arguments)
    set(_mpa_options "")
    set(_mpa_one_value_args "")
    set(_mpa_multi_value_args "")

    cmake_parse_arguments(_MPA "" "" "OPTIONS;ONE_VALUE_ARGS;MULTI_VALUE_ARGS" ${ARGN})

    if(DEFINED _MPA_OPTIONS)
        set(_mpa_options ${_MPA_OPTIONS})
    endif()
    if(DEFINED _MPA_ONE_VALUE_ARGS)
        set(_mpa_one_value_args ${_MPA_ONE_VALUE_ARGS})
    endif()
    if(DEFINED _MPA_MULTI_VALUE_ARGS)
        set(_mpa_multi_value_args ${_MPA_MULTI_VALUE_ARGS})
    endif()

    cmake_parse_arguments(PARSE_ARGV 0 ARG "${_mpa_options}" "${_mpa_one_value_args}" "${_mpa_multi_value_args}")

    if(DEFINED ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: unknown arguments: ${ARG_UNPARSED_ARGUMENTS}.")
    endif()

    # Cleanup internal variables
    unset(_mpa_options)
    unset(_mpa_one_value_args)
    unset(_mpa_multi_value_args)
    unset(_MPA_OPTIONS)
    unset(_MPA_ONE_VALUE_ARGS)
    unset(_MPA_MULTI_VALUE_ARGS)
    unset(_MPA_UNPARSED_ARGUMENTS)
    unset(_MPA_KEYWORDS_MISSING_VALUES)
endmacro()
