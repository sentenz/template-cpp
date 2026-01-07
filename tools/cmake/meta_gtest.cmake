include_guard(GLOBAL)

# Description:
#   Creates or extens a Google Test (GTest)-based executable for unit and mock tests.
#
# Arguments:
#   Options
#     WITH_GMOCK  - Link Google Mock and define WITH_GMOCK for the target.
#     WITH_MAIN   - Link GTest/GMock main library. If not set, the caller must provide a main() in SOURCES.
#     WITH_CTEST  - Register discovered tests with CTest via gtest_discover_tests().
#     WITH_DDT    - Define WITH_DDT for data-driven tests (requires nlohmann_json when enabled).
#   One-Value
#     TARGET      - Required: target name for add_executable.
#     ENABLE      - Optional: Boolean flag to enable/disable (default: ON).
#   Multi-value
#     SOURCES     - Optional: source files are intentionally optional for incremental extensions of an already-defined test target.
#     LINK        - Optional: semicolon-separated list of additional libraries to link.
#
# Outputs:
#   NONE
#
# Usage:
#   meta_gtest([WITH_GMOCK] [WITH_MAIN] [WITH_CTEST] [WITH_DDT]
#             TARGET <name>
#             [ENABLE <bool>]
#             SOURCES <src>...
#             [LINK <lib>...])
#
# Example:
#   meta_gtest(WITH_CTEST TARGET my_tests SOURCES test_foo.cpp test_bar.cpp LINK my_lib)
function(meta_gtest)
    set(options WITH_GMOCK WITH_MAIN WITH_CTEST WITH_DDT)
    set(one_value_args TARGET ENABLE)
    set(multi_value_args SOURCES LINK)
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
    if(NOT TARGET GTest::gtest)
        find_package(GTest CONFIG REQUIRED)
    endif()

    if(NOT TARGET nlohmann_json::nlohmann_json AND ARG_WITH_DDT)
        find_package(nlohmann_json CONFIG REQUIRED)
    endif()

    # Ensure testing is enabled at the top-level so CTest can run discovered tests
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

    # Base gtest dependency (idempotent)
    target_link_libraries("${ARG_TARGET}" PRIVATE GTest::gtest)

    # Optional GTest/GMock main
    if(ARG_WITH_MAIN)
        if(TARGET GTest::gtest_main)
            target_link_libraries("${ARG_TARGET}" PRIVATE GTest::gtest_main)
        elseif(TARGET GTest::gmock_main)
            target_link_libraries("${ARG_TARGET}" PRIVATE GTest::gmock_main)
        endif()
        target_compile_definitions("${ARG_TARGET}" PRIVATE META_GTEST_WITH_MAIN)
    endif()

    # Optional GMock support
    if(ARG_WITH_GMOCK)
        if(TARGET GTest::gmock)
            target_link_libraries("${ARG_TARGET}" PRIVATE GTest::gmock)
        endif()
        target_compile_definitions("${ARG_TARGET}" PRIVATE META_GTEST_WITH_GMOCK)
    endif()

    # Optional Data-Driven Test (DDT) support
    if(ARG_WITH_DDT)
        target_link_libraries("${ARG_TARGET}" PRIVATE nlohmann_json::nlohmann_json)
        target_compile_definitions("${ARG_TARGET}" PRIVATE META_GTEST_WITH_DDT)
    endif()

    # Request a reasonable C++ standard based on the found GTest package
    if(DEFINED GTest_VERSION AND GTest_VERSION VERSION_LESS "1.13.0")
        target_compile_features("${ARG_TARGET}" PRIVATE cxx_std_11)
    else()
        target_compile_features("${ARG_TARGET}" PRIVATE cxx_std_20)
    endif()

    # Propagate any extra link libs passed via LINK (idempotent)
    if(ARG_LINK)
        target_link_libraries("${ARG_TARGET}" PRIVATE ${ARG_LINK})
    endif()

    # Register tests with CTest via GoogleTest integration when requested
    # NOTE Only register once per target, even if multiple callers specify WITH_CTEST
    if(ARG_WITH_CTEST)
        include(GoogleTest)

        if(NOT DEFINED GTEST_DISCOVERY_TIMEOUT)
            set(GTEST_DISCOVERY_TIMEOUT 30 CACHE STRING "Timeout (seconds) for GoogleTest test discovery")
        endif()

        # Prevent multiple registrations of the same target
        get_target_property(meta_gtest_registered "${ARG_TARGET}" META_GTEST_WITH_CTEST)
        if(NOT meta_gtest_registered)
            set_target_properties("${ARG_TARGET}" PROPERTIES META_GTEST_WITH_CTEST TRUE)

            gtest_discover_tests("${ARG_TARGET}" DISCOVERY_TIMEOUT "${GTEST_DISCOVERY_TIMEOUT}")
        endif()
    endif()
endfunction()
