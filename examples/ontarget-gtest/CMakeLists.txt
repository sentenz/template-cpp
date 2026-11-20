cmake_minimum_required(VERSION 3.28.3)
project(ontarget_gtest_reference LANGUAGES C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_EMBEDDED "Build a bare-metal STM32F407VG firmware ELF" OFF)
option(ENABLE_JRUN_TESTS "Register physical J-Link tests with CTest" ON)

if(BUILD_EMBEDDED AND NOT CMAKE_CROSSCOMPILING)
  message(FATAL_ERROR "BUILD_EMBEDDED requires the ARM cross toolchain preset")
elseif(NOT BUILD_EMBEDDED AND CMAKE_CROSSCOMPILING)
  message(FATAL_ERROR "Host tests cannot be built using a cross toolchain")
endif()

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/../../tools/cmake"
                              "${PROJECT_SOURCE_DIR}/cmake")
include(CTest)
include(dependencies)
include(meta_gtest)

add_library(demo_core STATIC src/arithmetic.cpp src/sensor.cpp)
target_include_directories(demo_core PUBLIC "${PROJECT_SOURCE_DIR}/include")
target_compile_features(demo_core PUBLIC cxx_std_17)

set(SHARED_SOURCES
  tests/shared/test_arithmetic.cpp
  tests/shared/test_ring_buffer.cpp
  tests/shared/test_sensor.cpp
)

if(BUILD_EMBEDDED)
  include(segger_rtt)
  meta_gtest(
    TARGET on_target_gtest
    SOURCES
      tests/target/main.cpp
      tests/target/test_cortex_m4.cpp
      ${SHARED_SOURCES}
      board/stm32f407/startup_stm32f407.S
      board/stm32f407/runtime.c
      board/stm32f407/syscalls.c
    LINK demo_core segger_rtt
  )
  target_link_options(on_target_gtest PRIVATE
    "-T${PROJECT_SOURCE_DIR}/board/stm32f407/stm32f407vg.ld"
    "-Wl,-Map,${CMAKE_CURRENT_BINARY_DIR}/on_target_gtest.map"
    "-Wl,--print-memory-usage"
  )
  set_target_properties(on_target_gtest PROPERTIES SUFFIX ".elf")
  add_custom_command(TARGET on_target_gtest POST_BUILD
    COMMAND "${CMAKE_SIZE}" "$<TARGET_FILE:on_target_gtest>"
    VERBATIM
  )
  if(BUILD_TESTING AND ENABLE_JRUN_TESTS)
    include(meta_jrun)
    meta_jrun(
      WITH_RTT WITH_GTEST
      TARGET on_target_gtest
      DEVICE "${JRUN_DEVICE}"
      INTERFACE "${JRUN_INTERFACE}"
      SPEED "${JRUN_SPEED_KHZ}"
      TIMEOUT "${JRUN_TIMEOUT_SECONDS}"
      GTEST_FILTERS "Arithmetic.*" "HostAndTarget/AddCases.*" "RingBuffer.*" "Sensor.*" "Hardware.*"
    )
  endif()
else()
  meta_gtest(WITH_CTEST WITH_MAIN
    TARGET host_gtest
    SOURCES ${SHARED_SOURCES}
    LINK demo_core
  )
endif()
