include_guard(GLOBAL)

# Description:
#   Creates or extends a Unity-based executable for C unit tests targeting embedded systems
#   (on-target testing) under CMake/CTest.
#
# Arguments:
#   Options
#     WITH_CTEST  - Register the test binary with CTest via add_test(). Use COMMAND to specify
#                   the runner for on-target execution; defaults to running the binary directly.
#   One-Value
#     TARGET      - Required: target name for add_executable.
#     ENABLE      - Optional: Boolean flag to enable/disable unity (default: ON).
#     TIMEOUT     - Optional: CTest test timeout in seconds (default: 60).
#   Multi-value
#     SOURCES     - Optional: source files are intentionally optional for incremental extensions of an already-defined test target.
#     LINK        - Optional: semicolon-separated list of additional libraries to link.
#     COMMAND     - Optional: command (and arguments) used by CTest to execute the test binary on
#                   the target (e.g. a flash-and-run script). Defaults to running the binary directly,
#                   which suits host simulation.
#
# Outputs:
#   NONE
#
# Usage:
#   meta_unity([WITH_CTEST]
#             TARGET <name>
#             [ENABLE <bool>]
#             [TIMEOUT <seconds>]
#             SOURCES <src>...
#             [LINK <lib>...]
#             [COMMAND <cmd>...])
#
# Example:
#   meta_unity(WITH_CTEST
#             TARGET my_target_tests
#             SOURCES test_foo.c test_bar.c
#             LINK my_lib)
function(meta_unity)
    set(options WITH_CTEST)
    set(one_value_args TARGET ENABLE TIMEOUT)
    set(multi_value_args SOURCES LINK COMMAND)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "${options}" "${one_value_args}" "${multi_value_args}")

    if(DEFINED ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Unknown arguments: ${ARG_UNPARSED_ARGUMENTS}.")
    endif()

    if(DEFINED ARG_ENABLE AND NOT ARG_ENABLE)
        return()
    endif()

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'TARGET' argument is required.")
    endif()

    # Find required packages (idempotent)
    if(NOT TARGET unity::unity)
        find_package(unity CONFIG REQUIRED)
    endif()

    # Ensure testing is enabled at the top-level so CTest can run tests
    if(ARG_WITH_CTEST AND NOT BUILD_TESTING)
        message(WARNING "${CMAKE_CURRENT_FUNCTION}: 'BUILD_TESTING' must be enabled e.g., include(CTest).")
    endif()

    # Create the executable once, without binding to a fixed source set
    if(NOT TARGET "${ARG_TARGET}")
        add_executable("${ARG_TARGET}")
    endif()

    # Any SOURCES passed in this or subsequent calls are appended incrementally
    if(ARG_SOURCES)
        target_sources("${ARG_TARGET}" PRIVATE ${ARG_SOURCES})
    endif()

    # Base Unity dependency (idempotent)
    target_link_libraries("${ARG_TARGET}" PRIVATE unity::unity)

    # Propagate any extra link libs passed via LINK (idempotent)
    if(ARG_LINK)
        target_link_libraries("${ARG_TARGET}" PRIVATE ${ARG_LINK})
    endif()

    # Register the test binary with CTest when requested
    # NOTE Only register once per target, even if multiple callers specify WITH_CTEST
    if(ARG_WITH_CTEST)
        # Default timeout
        if(NOT DEFINED ARG_TIMEOUT)
            set(ARG_TIMEOUT 60)
        endif()

        # Determine the runner command: caller-supplied or the test executable itself
        if(ARG_COMMAND)
            set(meta_unity_cmd ${ARG_COMMAND})
        else()
            set(meta_unity_cmd "$<TARGET_FILE:${ARG_TARGET}>")
        endif()

        # Prevent multiple registrations of the same target
        get_target_property(meta_unity_registered "${ARG_TARGET}" META_UNITY_WITH_CTEST)
        if(NOT meta_unity_registered)
            set_target_properties("${ARG_TARGET}" PROPERTIES META_UNITY_WITH_CTEST TRUE)

            add_test(NAME "${ARG_TARGET}" COMMAND ${meta_unity_cmd})
            set_tests_properties("${ARG_TARGET}" PROPERTIES TIMEOUT "${ARG_TIMEOUT}")
        endif()
    endif()
endfunction()
