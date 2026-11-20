# CMake Modules

Reusable CMake helper modules for build configuration, testing, and toolchain integration.

- [1. Modules](#1-modules)
  - [1.1. Meta Policy](#11-meta-policy)
  - [1.2. Meta Conan](#12-meta-conan)
  - [1.3. Meta Compiler Cache](#13-meta-compiler-cache)
  - [1.4. Meta Coverage](#14-meta-coverage)
  - [1.5. Meta Sanitizers](#15-meta-sanitizers)
  - [1.6. Meta GTest](#16-meta-gtest)
  - [1.7. Meta Unity](#17-meta-unity)
  - [1.8. Meta JRun](#18-meta-jrun)
- [2. References](#2-references)

## 1. Modules

### 1.1. Meta Policy

1. Details

    - [meta_policy.cmake](meta_policy.cmake)
      > Set global project properties for C++ language standard and compiler warnings.

2. Prerequisites

    - None

3. Usage

    ```cmake
    include(meta_policy)

    meta_policy()
    ```

4. Example

    ```cmake
    meta_policy()
    ```

### 1.2. Meta Conan

1. Details

    - [meta_conan.cmake](meta_conan.cmake)
      > Conan v2 integration helper for CMake. Ensures Conan is available, runs `conan install`, and configures the CMake toolchain.

2. Prerequisites

    - [Conan](https://conan.io/) v2
      > C and C++ package manager.

      ```bash
      pip install "conan>=2"
      ```

3. Usage

    ```cmake
    include(meta_conan)

    meta_conan([CREATE_INSTALL_TARGET]
               [AUTO_INSTALL <ON|OFF>]
               [USER_PRESETS_PATH <path>]
               [INSTALL_FOLDER <path>]
               [SOURCE_DIR <path>]
               [GENS <gen>...])
    ```

4. Example

    ```cmake
    meta_conan(AUTO_INSTALL ON CREATE_INSTALL_TARGET)
    ```

### 1.3. Meta Compiler Cache

1. Details

    - [meta_compiler_cache.cmake](meta_compiler_cache.cmake)
      > Enable compiler cache using `ccache` or `sccache` to speed up recompilation by caching previous compilations and detecting when the same compilation is being done again.

2. Prerequisites

    - [ccache](https://ccache.dev/)
      > Compiler cache to speed up recompilation.

      ```bash
      sudo apt install ccache
      ```

    - [sccache](https://github.com/mozilla/sccache)
      > Shared compilation cache, supports local and remote caching.

      ```bash
      sudo apt install sccache
      ```

3. Usage

    ```cmake
    include(meta_compiler_cache)

    meta_compiler_cache([ENABLE <bool>] [TYPE <auto|ccache|sccache>])
    ```

4. Example

    ```cmake
    meta_compiler_cache(ENABLE ON)
    meta_compiler_cache(ENABLE ON TYPE ccache)
    meta_compiler_cache(ENABLE ON TYPE sccache)
    ```

### 1.4. Meta Coverage

1. Details

    - [meta_coverage.cmake](meta_coverage.cmake)
      > Enable code coverage instrumentation for projects built with GCC or Clang.

2. Prerequisites

    - [gcovr](https://gcovr.com/)
      > Python-based tool for generating code coverage reports.

      ```bash
      pip install gcovr
      ```

3. Usage

    ```cmake
    include(meta_coverage)

    meta_coverage([ENABLE <bool>])
    ```

4. Example

    ```cmake
    meta_coverage(ENABLE ON)
    ```

### 1.5. Meta Sanitizers

1. Details

    - [meta_sanitizers.cmake](meta_sanitizers.cmake)
      > Enable LeakSanitizer (LSan), AddressSanitizer (ASan), and Undefined Behavior Sanitizer (UBSan) for GCC or Clang builds.

2. Prerequisites

    - None

3. Usage

    ```cmake
    include(meta_sanitizers)

    meta_sanitizers([ENABLE <bool>])
    ```

4. Example

    ```cmake
    meta_sanitizers(ENABLE ON)
    ```

### 1.6. Meta GTest

1. Details

    - [meta_gtest.cmake](meta_gtest.cmake)
      > Creates or extends a Google Test (GTest)-based executable for unit and mock tests, with optional CTest discovery and data-driven test support.

    - [GTest](https://github.com/google/googletest)
      > Google's C++ testing and mocking framework.

2. Prerequisites

    - [GTest](https://conan.io/center/recipes/gtest) Conan Registry
      > Google Test framework available as a Conan package.

      ```txt
      # conanfile.txt
      [requires]
      gtest/1.17.0
      ```

3. Usage

    ```cmake
    include(meta_gtest)

    meta_gtest([WITH_GMOCK] [WITH_MAIN] [WITH_CTEST] [WITH_DDT]
               TARGET <name>
               [ENABLE <bool>]
               [SOURCES <src>...]
               [LINK <lib>...])
    ```

4. Example

    ```cmake
    meta_gtest(WITH_CTEST TARGET my_tests SOURCES test_foo.cpp test_bar.cpp LINK my_lib)
    ```

### 1.7. Meta Unity

1. Details

    - [meta_unity.cmake](meta_unity.cmake)
      > Creates or extends a Unity-based embedded test executable. Creates an add_executable target and links any required libraries. The caller's CMake toolchain file controls the cross-compiler. Use meta_jrun() to register the resulting binary as CTest test(s).

    - [Unity](https://github.com/ThrowTheSwitch/Unity)
      > C unit testing framework for embedded systems.

2. Prerequisites

    - [Unity](https://conan.io/center/recipes/unity) Conan Registry
      > Unity C testing framework available as a Conan package.

      ```txt
      # conanfile.txt
      [requires]
      unity/2.6.0
      ```

3. Usage

    ```cmake
    include(meta_unity)

    meta_unity(TARGET <name>
               [ENABLE <bool>]
               [SOURCES <src>...]
               [LINK <lib>...])
    ```

4. Example

    ```cmake
    include(meta_unity)
    include(meta_jrun)

    meta_unity(
      TARGET   my_firmware-test
      SOURCES  test_leds.c test_sensors.c
      LINK     my_firmware::leds)

    meta_jrun(
      TARGET    my_firmware-test
      DEVICE    LPC55S16
      INTERFACE SWD
      SPEED     4000
      TIMEOUT   60
      SUITES    test_leds test_sensors)
    ```

### 1.8. Meta JRun

1. Details

    - [meta_jrun.cmake](meta_jrun.cmake)
      > Registers a pre-built firmware executable as CTest test(s) via SEGGER J-Run. J-Run flashes the ELF to the connected embedded target and captures output over RTT or semihosting. When SUITES are provided, each suite is registered as a separate namespaced CTest test with the suite name forwarded via J-Run --args. When no SUITES are specified, a single CTest test is registered for the entire binary.

    - [SEGGER J-Run](https://kb.segger.com/J-Run) Documentation
      > Reference for J-Run command-line options and usage.

2. Prerequisites

    - [SEGGER J-Run](https://kb.segger.com/J-Run)
      > J-Run CLI v8.10 or later for automated on-target testing via J-Link.

      ```bash
      # Download and install from https://www.segger.com/downloads/jlink/
      ```

3. Usage

    ```cmake
    include(meta_jrun)

    meta_jrun([WITH_RTT] [WITH_SEMIHOSTING]
              TARGET <name>
              [ENABLE <bool>]
              DEVICE <device>
              [INTERFACE <SWD|JTAG>]
              [SPEED <kHz>]
              [TIMEOUT <seconds>]
              [SUITES <suite>...])
    ```

4. Example

    ```cmake
    meta_jrun(
      TARGET    my_firmware-test
      DEVICE    LPC55S16
      INTERFACE SWD
      SPEED     4000
      TIMEOUT   60
      SUITES    test_leds test_sensors)
    ```

## 2. References

- CMake [Documentation](https://cmake.org/documentation/) page.
- CMake [Modules](https://cmake.org/cmake/help/latest/manual/cmake-modules.7.html) page.
