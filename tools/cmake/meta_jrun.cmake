include_guard(GLOBAL)

# Description:
#   Registers a pre-built firmware executable as CTest test(s) via SEGGER J-Run.
#   J-Run flashes the ELF to the connected embedded target and captures output.
#   When SUITES are provided, each suite is registered as a separate CTest test
#   with the suite name forwarded via J-Run --args so that the firmware's test
#   dispatcher can select and run only that suite.
#   When no SUITES are specified, a single CTest test is registered for the
#   entire firmware binary.
#
# Arguments:
#   Options
#     WITH_GTEST       - Send a Google Test filter for each suite (or * for the whole binary).
#     WITH_RTT         - Use SEGGER RTT for test output communication (default if no output method specified).
#     WITH_SEMIHOSTING - Use semihosting for test output communication.
#   One-Value
#     TARGET           - Required: CMake target name (executable) to flash and test.
#     DEVICE           - Required: Target device name for J-Run (e.g., LPC55S16).
#     ENABLE           - Optional: Boolean flag to enable/disable registration (default: ON).
#     USB / IP         - Optional: select a probe by USB serial/nickname or IP address/hostname.
#     SPEED            - Optional: Interface speed in kHz (default: 4000).
#     TIMEOUT          - Optional: CTest timeout in seconds per test (default: 60).
#     INTERFACE        - Optional: Debug interface type (SWD or JTAG, default: SWD).
#   Multi-Value
#     SUITES           - Optional: Test suite names to register as individual CTest tests.
#                        Each suite name is forwarded to the firmware via J-Run --args.
#                        If omitted, a single CTest test is registered for the entire binary.
#
# Outputs:
#   NONE
#
# Usage:
#   meta_jrun([WITH_GTEST] [WITH_RTT] [WITH_SEMIHOSTING]
#             TARGET <name>
#             [ENABLE <bool>]
#             DEVICE <device>
#             [USB <serial>|IP <host>]
#             [INTERFACE <SWD|JTAG>]
#             [SPEED <kHz>]
#             [TIMEOUT <seconds>]
#             [SUITES <suite>...])
#
# Example:
#   meta_jrun(
#     TARGET    my_firmware-test
#     DEVICE    LPC55S16
#     INTERFACE SWD
#     SPEED     4000
#     TIMEOUT   60
#     SUITES    test_leds test_sensors)
function(meta_jrun)
    set(options WITH_GTEST WITH_RTT WITH_SEMIHOSTING)
    set(one_value_args TARGET ENABLE DEVICE INTERFACE SPEED TIMEOUT USB IP)
    set(multi_value_args SUITES)
    cmake_parse_arguments(PARSE_ARGV 0 ARG "${options}" "${one_value_args}" "${multi_value_args}")

    if(DEFINED ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Unknown arguments: ${ARG_UNPARSED_ARGUMENTS}.")
    endif()

    if(DEFINED ARG_ENABLE AND NOT ARG_ENABLE)
        return()
    endif()

    if(ARG_WITH_RTT AND ARG_WITH_SEMIHOSTING)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'WITH_RTT' and 'WITH_SEMIHOSTING' are mutually exclusive.")
    endif()

    if(NOT ARG_TARGET)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'TARGET' argument is required.")
    endif()
    if(NOT TARGET "${ARG_TARGET}")
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'TARGET' must be an existing CMake target, but '${ARG_TARGET}' was not found.")
    endif()
    get_target_property(_meta_jrun_target_type "${ARG_TARGET}" TYPE)
    if(NOT _meta_jrun_target_type STREQUAL "EXECUTABLE")
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'TARGET' must be an EXECUTABLE target, but '${ARG_TARGET}' is of type '${_meta_jrun_target_type}'.")
    endif()

    if(NOT ARG_DEVICE)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'DEVICE' argument is required.")
    endif()

    # Ensure CTest infrastructure is enabled for add_test()
    if(NOT CMAKE_TESTING_ENABLED)
        enable_testing()
    endif()

    # Find J-Run executable (idempotent)
    if(NOT meta_jrun_exe)
        find_program(meta_jrun_exe NAMES JRun JRunExe jrun HINTS "$ENV{SEGGER_PATH}" NO_CMAKE_FIND_ROOT_PATH)
    endif()
    if(NOT meta_jrun_exe)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'JRun' not found. Consider setting the 'SEGGER_PATH' environment variable.")
    endif()

    # Apply defaults and validate arguments
    if(NOT ARG_INTERFACE)
        set(ARG_INTERFACE "SWD")
    endif()
    string(TOUPPER "${ARG_INTERFACE}" ARG_INTERFACE)
    set(_meta_jrun_allowed_interfaces "SWD" "JTAG")
    if(NOT ARG_INTERFACE IN_LIST _meta_jrun_allowed_interfaces)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Invalid argument of 'INTERFACE' with '${ARG_INTERFACE}'. Allowed values are '${_meta_jrun_allowed_interfaces}'.")
    endif()

    if(NOT DEFINED ARG_SPEED)
        set(ARG_SPEED 4000)
    endif()
    if(NOT ARG_SPEED MATCHES "^[1-9][0-9]*$")
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'SPEED' must be a positive integer in kHz, but got '${ARG_SPEED}'.")
    endif()

    if(NOT DEFINED ARG_TIMEOUT)
        set(ARG_TIMEOUT 60)
    endif()
    if(NOT ARG_TIMEOUT MATCHES "^[1-9][0-9]*$")
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: 'TIMEOUT' must be a positive integer in seconds, but got '${ARG_TIMEOUT}'.")
    endif()

    # Build J-Run arguments
    set(_meta_jrun_args
        --nogui
        --device "${ARG_DEVICE}"
        --if "${ARG_INTERFACE}"
        --speed "${ARG_SPEED}"
    )

    if(ARG_USB AND ARG_IP)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: Select either USB or IP for the J-Link connection.")
    elseif(ARG_USB)
        list(APPEND _meta_jrun_args --usb "${ARG_USB}")
    elseif(ARG_IP)
        list(APPEND _meta_jrun_args --ip "${ARG_IP}")
    endif()

    # Add output method flag, RTT is the default if no method is specified
    if(ARG_WITH_SEMIHOSTING)
        list(APPEND _meta_jrun_args --semihost)
    else()
        list(APPEND _meta_jrun_args --rtt)
    endif()

    # Resolve ELF path from the build target via a generator expression
    set(_meta_jrun_elf "$<TARGET_FILE:${ARG_TARGET}>")

    # Use a single probe lock across firmware images, including Unity tests.
    set(_meta_jrun_suites ${ARG_SUITES})
    list(REMOVE_DUPLICATES _meta_jrun_suites)
    list(REMOVE_ITEM _meta_jrun_suites "")
    if(NOT _meta_jrun_suites)
        set(_args)
        if(ARG_WITH_GTEST)
            set(_args --args "gtest --gtest_filter=*")
        endif()
        add_test(NAME "${ARG_TARGET}" COMMAND "${meta_jrun_exe}" ${_meta_jrun_args} ${_args} "${_meta_jrun_elf}")
        set_tests_properties("${ARG_TARGET}" PROPERTIES TIMEOUT "${ARG_TIMEOUT}" RESOURCE_LOCK jlink)
        return()
    endif()

    foreach(_suite IN LISTS _meta_jrun_suites)
        set(_arg "${_suite}")
        if(ARG_WITH_GTEST)
            # newlib treats the first token from SYS_GET_CMDLINE as argv[0].
            set(_arg "gtest --gtest_filter=${_suite}.*")
        endif()
        set(_name "${ARG_TARGET}.${_suite}")
        add_test(NAME "${_name}" COMMAND "${meta_jrun_exe}" ${_meta_jrun_args} --args "${_arg}" "${_meta_jrun_elf}")
        set_tests_properties("${_name}" PROPERTIES TIMEOUT "${ARG_TIMEOUT}" RESOURCE_LOCK jlink)
    endforeach()
endfunction()
