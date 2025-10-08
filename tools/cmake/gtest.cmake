include_guard(GLOBAL)

# gtest_add
#
# Brief:
#   Convenience wrapper to add a Google Test-based executable target and register
#   it with CTest. This function creates the test executable, links the
#   requested libraries (including the gtest/gmock libraries), and calls
#   add_test so the test will run when executing ctest.
#
#   gtest_add([WITH_GMOCK] [WITH_MAIN] [WITH_CTEST]
#             TARGET <name>
#             SOURCES <src>...
#             [LINK <lib>...])
#
# Arguments:
#   TARGET <name>   - (required) target name for add_executable.
#   SOURCES <src>...- (required) source files for the test executable.
#   LINK <lib>...   - optional semicolon-separated list of extra libraries to link.
#
# Options (boolean flags):
#   WITH_GMOCK  - Link GMock and define WITH_GMOCK for the target (default: OFF).
#   WITH_MAIN   - Link GTest/GMock main (default: OFF). If OFF, caller should supply a main in the SOURCES.
#   WITH_CTEST  - Register discovered tests with CTest via `gtest_discover_tests()` (default: OFF).
#
# Example:
#   gtest_add(WITH_CTEST TARGET my_tests SOURCES test_foo.cpp test_bar.cpp LINK my_lib)
function(gtest_add)
  set(options WITH_GMOCK WITH_MAIN WITH_CTEST)
  set(oneValueArgs TARGET)
  set(multiValueArgs SOURCES LINK)

  # Parse the argument list and normalize results under the GTEST prefix
  cmake_parse_arguments(PARSE_ARGV 0 GTEST "${options}" "${oneValueArgs}" "${multiValueArgs}")

  # Ensure GTest imported targets are available in the caller's scope. We do
  # this lazily here instead of at top-level so package discovery uses the
  # caller's configuration (conan, CMAKE_PREFIX_PATH, etc.). Calling
  # find_package multiple times is safe, it's idempotent when the package is
  # found.
  if(NOT TARGET GTest::gtest)
    find_package(GTest CONFIG REQUIRED)
  endif()

  # NOTE If the test configure preset requested testing, enable it at the top-level
  # so CTest generates the Testing/ directory and discovered tests are
  # available to `ctest` when run from the build root.
  if(GTEST_WITH_CTEST)
    include(CTest)
    if(NOT DEFINED BUILD_TESTING)
      enable_testing()
    endif()
  endif()

  if(NOT GTEST_TARGET)
    message(FATAL_ERROR "gtest_add: TARGET is required")
  endif()
  if(NOT GTEST_SOURCES)
    message(FATAL_ERROR "gtest_add: SOURCES is required")
  endif()

  add_executable(${GTEST_TARGET} ${GTEST_SOURCES})

  # Link base gtest
  target_link_libraries(${GTEST_TARGET} PRIVATE GTest::gtest)

  # Optionally provide a test main or use user main.cpp
  if(GTEST_WITH_MAIN)
    if(TARGET GTest::gtest_main)
      target_link_libraries(${GTEST_TARGET} PRIVATE GTest::gtest_main)
    else()
      target_link_libraries(${GTEST_TARGET} PRIVATE GTest::gtest)
    endif()
  else()
    # Caller provided main in sources or via target_sources
    # nothing to do here unless user passes main via GTEST_SOURCES
  endif()

  # GMock support
  if(GTEST_WITH_GMOCK)
    if(TARGET GTest::gmock)
      target_link_libraries(${GTEST_TARGET} PRIVATE GTest::gmock)
    endif()
    # Also attempt to use gmock_main if user asked for WITH_MAIN and it's available
    if(GTEST_WITH_MAIN AND TARGET GTest::gmock_main)
      target_link_libraries(${GTEST_TARGET} PRIVATE GTest::gmock_main)
    endif()
    target_compile_definitions(${GTEST_TARGET} PRIVATE WITH_GMOCK)
  endif()

  # Project/GTest version-aware c++ standard (fallback to 14)
  if(DEFINED GTest_VERSION AND GTest_VERSION VERSION_LESS "1.13.0")
    target_compile_features(${GTEST_TARGET} PRIVATE cxx_std_11)
  else()
    target_compile_features(${GTEST_TARGET} PRIVATE cxx_std_17)
  endif()

  # Propagate any extra link libs passed via LINK
  if(GTEST_LINK)
    target_link_libraries(${GTEST_TARGET} PRIVATE ${GTEST_LINK})
  endif()

  if(GTEST_WITH_CTEST)
    include(GoogleTest)
    gtest_discover_tests(${GTEST_TARGET} DISCOVERY_TIMEOUT 30)
  endif()
endfunction()
