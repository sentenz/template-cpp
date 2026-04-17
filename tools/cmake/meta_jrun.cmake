include_guard(GLOBAL)

# Description:
#   Registers a cross-compiled GTest executable as a CTest test that is flashed and executed on
#   a target microcontroller via SEGGER J-Run. The executable is built on the host, then
#   automatically flashed and run on the hardware using the J-Link probe.
#
# Arguments:
#   Options
#     WITH_CTEST    - Register discovered tests with CTest via add_test().
#   One-Value
#     TARGET        - Required: name of the cross-compiled executable target.
#     ENABLE        - Optional: Boolean flag to enable/disable J-Run registration (default: ON).
#     DEVICE        - Optional: SEGGER target device string (e.g., Cortex-M4, STM32F429ZI).
#                    Defaults to the META_JRUN_DEVICE cache variable when not specified.
#     INTERFACE     - Optional: debug interface: SWD (default) or JTAG.
#     SPEED         - Optional: connection speed in kHz (default: auto).
#     TIMEOUT       - Optional: CTest timeout in seconds (default: 60).
#
# Outputs:
#   NONE
#
# Usage:
#   meta_jrun([WITH_CTEST]
#             TARGET <name>
#             [ENABLE <bool>]
#             [DEVICE <device>]
#             [INTERFACE <SWD|JTAG>]
#             [SPEED <speed>]
#             [TIMEOUT <seconds>])
#
# Example:
#   meta_jrun(WITH_CTEST TARGET my_ontarget_tests DEVICE Cortex-M4 INTERFACE SWD SPEED 4000)
function(meta_jrun)
    set(options WITH_CTEST)
    set(one_value_args TARGET ENABLE DEVICE INTERFACE SPEED TIMEOUT)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "${options}" "${one_value_args}" "")

    if(DEFINED ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Unknown arguments: ${ARG_UNPARSED_ARGUMENTS}.")
    endif()

    if(DEFINED ARG_ENABLE AND NOT ARG_ENABLE)
        return()
    endif()

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'TARGET' argument is required.")
    endif()

    if(NOT TARGET "${ARG_TARGET}")
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Target '${ARG_TARGET}' does not exist.")
    endif()

    # Apply defaults
    if(NOT ARG_DEVICE)
        set(ARG_DEVICE "${META_JRUN_DEVICE}")
    endif()

    if(NOT ARG_INTERFACE)
        set(ARG_INTERFACE "SWD")
    endif()

    if(NOT ARG_SPEED)
        set(ARG_SPEED "auto")
    endif()

    if(NOT ARG_TIMEOUT)
        set(ARG_TIMEOUT 60)
    endif()

    if(NOT ARG_DEVICE)
        message(WARNING "${CMAKE_CURRENT_FUNCTION}: No DEVICE specified and META_JRUN_DEVICE is not set. "
            "Pass DEVICE <device> or set -DMETA_JRUN_DEVICE=<device> at configure time.")
    endif()

    if(NOT ARG_WITH_CTEST)
        return()
    endif()

    # Ensure testing is enabled at the top-level so CTest can run discovered tests
    if(NOT BUILD_TESTING)
        message(WARNING "${CMAKE_CURRENT_FUNCTION}: 'BUILD_TESTING' must be enabled e.g., include(CTest).")
    endif()

    find_program(meta_jrun_exe NAMES JRun jrun)
    if(NOT meta_jrun_exe)
        message(WARNING "${CMAKE_CURRENT_FUNCTION}: 'JRun' not found. "
            "Install SEGGER J-Link tools and ensure JRun is on PATH.")
        return()
    endif()

    # Build JRun argument list
    set(meta_jrun_args "")

    if(ARG_DEVICE)
        list(APPEND meta_jrun_args "--device" "${ARG_DEVICE}")
    endif()

    list(APPEND meta_jrun_args "--if" "${ARG_INTERFACE}")
    list(APPEND meta_jrun_args "--speed" "${ARG_SPEED}")

    # Prevent duplicate CTest registration
    get_target_property(meta_jrun_registered "${ARG_TARGET}" META_JRUN_WITH_CTEST)
    if(NOT meta_jrun_registered)
        set_target_properties("${ARG_TARGET}" PROPERTIES META_JRUN_WITH_CTEST TRUE)

        add_test(
            NAME "${ARG_TARGET}"
            COMMAND "${meta_jrun_exe}" ${meta_jrun_args} "$<TARGET_FILE:${ARG_TARGET}>"
        )

        set_tests_properties("${ARG_TARGET}" PROPERTIES TIMEOUT "${ARG_TIMEOUT}")
    endif()
endfunction()
