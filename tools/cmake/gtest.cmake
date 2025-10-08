include_guard(GLOBAL)

# gtest_add
#
# Convenience wrapper to add a Google Test executable and optionally register it with CTest.
#
#   gtest_add([WITH_GMOCK] [WITH_MAIN] [WITH_CTEST]
#             TARGET <name>
#             SOURCES <src>...
#             [LINK <lib>...])
#
# Parameters:
#   TARGET <name>   - (required) target name for add_executable.
#   SOURCES <src>...- (required) source files for the test executable.
#   LINK <lib>...   - optional semicolon-separated list of extra libraries to link.
#
# Options:
#   WITH_GMOCK  - Link GMock and define WITH_GMOCK for the target (default: OFF).
#   WITH_MAIN   - Link GTest/GMock main (default: OFF). If OFF, caller should supply a main in the SOURCES.
#   WITH_CTEST  - Register discovered tests with CTest via `gtest_discover_tests()` (default: OFF).
#
# Usage:
#   gtest_add(WITH_CTEST TARGET my_tests SOURCES test_foo.cpp test_bar.cpp LINK my_lib)
function(gtest_add)
  set(options WITH_GMOCK WITH_MAIN WITH_CTEST)
  set(oneValueArgs TARGET)
  set(multiValueArgs SOURCES LINK)
  cmake_parse_arguments(PARSE_ARGV 0 GTEST "${options}" "${oneValueArgs}" "${multiValueArgs}")

  if(NOT GTEST_TARGET)
    message(FATAL_ERROR "gtest_add: TARGET is required")
  endif()
  if(NOT GTEST_SOURCES)
    message(FATAL_ERROR "gtest_add: SOURCES is required")
  endif()

  # Lazy find_package so caller configuration (conan, CMAKE_PREFIX_PATH) is honored
  if(NOT TARGET GTest::gtest)
    find_package(GTest CONFIG REQUIRED)
  endif()

  # Ensure testing is enabled at the top-level so ctest can run discovered tests
  if(GTEST_WITH_CTEST)
    include(CTest)
    enable_testing()
  endif()

  add_executable(${GTEST_TARGET} ${GTEST_SOURCES})

  # Link base gtest target
  target_link_libraries(${GTEST_TARGET} PRIVATE GTest::gtest)

  # Optionally use the provided main
  if(GTEST_WITH_MAIN)
    if(TARGET GTest::gtest_main)
      target_link_libraries(${GTEST_TARGET} PRIVATE GTest::gtest_main)
    elseif(TARGET GTest::gmock_main)
      target_link_libraries(${GTEST_TARGET} PRIVATE GTest::gmock_main)
    endif()
  endif()

  # GMock support
  if(GTEST_WITH_GMOCK)
    if(TARGET GTest::gmock)
      target_link_libraries(${GTEST_TARGET} PRIVATE GTest::gmock)
    endif()
    target_compile_definitions(${GTEST_TARGET} PRIVATE WITH_GMOCK)
  endif()

  # Request a reasonable C++ standard based on the found GTest package
  if(DEFINED GTest_VERSION AND GTest_VERSION VERSION_LESS "1.13.0")
    target_compile_features(${GTEST_TARGET} PRIVATE cxx_std_11)
  else()
    target_compile_features(${GTEST_TARGET} PRIVATE cxx_std_17)
  endif()

  # Propagate any extra link libs passed via LINK
  if(GTEST_LINK)
    target_link_libraries(${GTEST_TARGET} PRIVATE ${GTEST_LINK})
  endif()

  # Register tests with CTest via GoogleTest integration when requested
  if(GTEST_WITH_CTEST)
    include(GoogleTest)
    gtest_discover_tests(${GTEST_TARGET} DISCOVERY_TIMEOUT 30)
  endif()
endfunction()
