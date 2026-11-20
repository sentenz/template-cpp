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
    - [1.8.1. Execution Modes](#181-execution-modes)
    - [1.8.2. Prerequisites](#182-prerequisites)
    - [1.8.3. CMake Interface](#183-cmake-interface)
    - [1.8.4. Examples](#184-examples)
    - [1.8.5. Google Test Result Contract](#185-google-test-result-contract)
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
      gtest/1.18.0
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
    meta_gtest(WITH_CTEST WITH_MAIN TARGET my_tests SOURCES test_foo.cpp test_bar.cpp LINK my_lib)
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

The [`meta_jrun.cmake`](meta_jrun.cmake) module registers an existing CMake executable target with CTest and delegates execution to [SEGGER J-Run](https://kb.segger.com/J-Run). J-Run loads the ELF onto hardware through J-Link, starts the application, captures its output and exits when the target signals completion.

#### 1.8.1. Execution Modes

The module supports two registration models distinguished by their test selection and result-processing behavior.

- **Existing Firmware or Unity Mode**
  > When `SUITES` is specified, `meta_jrun()` registers one CTest case per suite and forwards the suite name using `--args`. Without `SUITES`, the module registers one CTest case for the complete executable. Existing Unity configuration remains unchanged.

- **Google Test RTT Mode**
  > When `WITH_GTEST` is set, `meta_jrun()` registers one CTest case per `GTEST_FILTERS` entry (default `*`) and invokes the [Python J-Run result validator](../jrun_gtest_runner.py). The firmware must implement SEGGER RTT argument retrieval, emit a machine-readable Google Test summary and return an application exit code.

The embedded mode does not call `gtest_discover_tests()`. That CMake function queries an executable for test names and normally requires executable host access or a configured cross-compiling emulator. Explicit filter registration avoids executing an Arm ELF as part of host-side discovery.

#### 1.8.2. Prerequisites

- **SEGGER J-Run**
  > Install the J-Link software distribution containing J-Run and ensure that it can access the target debug probe. Refer to the official [J-Run documentation](https://kb.segger.com/J-Run) for supported command-line options and the installed version.

- **Cross-Compiled Executable**
  > Provide an ELF executable with board-appropriate startup code, memory layout and target runtime. The CMake toolchain and linker configuration are the caller's responsibility.

- **Python Interpreter**
  > Python 3 is required when `WITH_GTEST` is enabled. The runner handles subprocess execution, output validation, timeout classification and log retention.

- **CTest**
  > Include `CTest` in the top-level build and enable testing before registration. Each target invocation requires an accessible J-Link device and appropriate device configuration.

#### 1.8.3. CMake Interface

Example:

~~~cmake
include(meta_jrun)

meta_jrun([WITH_RTT] [WITH_SEMIHOSTING] [WITH_GTEST]
          TARGET <name>
          [ENABLE <bool>]
          DEVICE <device>
          [INTERFACE <SWD|JTAG>]
          [SPEED <kilohertz>]
          [TIMEOUT <seconds>]
          [SUITES <suite>...]
          [GTEST_FILTERS <filter>...])
~~~

| Argument | Role | Constraint |
| --- | --- | --- |
| `TARGET` | Existing CMake executable to load | Required |
| `DEVICE` | J-Link device name | Required |
| `ENABLE` | Enable or skip registration | Defaults to enabled |
| `WITH_RTT` | Request RTT transport | Exclusive with `WITH_SEMIHOSTING` |
| `WITH_SEMIHOSTING` | Request semihosting transport | Not permitted with `WITH_GTEST` |
| `WITH_GTEST` | Register Google Test filters using the Python runner | Requires RTT protocol in target firmware |
| `INTERFACE` | JTAG or SWD interface | Default `SWD` |
| `SPEED` | Debug clock in kHz | Default `4000` |
| `TIMEOUT` | J-Run timeout in seconds | Default `60` |
| `SUITES` | Suite names for the original registration model | Not permitted with `WITH_GTEST` |
| `GTEST_FILTERS` | Google Test filter expressions | Only permitted with `WITH_GTEST` |

The module resolves `JRUN_EXECUTABLE` when supplied or searches for `JRun`/`jrun` using the executable search path and `SEGGER_PATH`. In Google Test mode, the Python runner stores logs in the build tree and the CTest entries use a shared `jlink_probe` resource lock.

#### 1.8.4. Examples

1. Unity-style firmware registration

    Example:

    ~~~cmake
    include(meta_unity)
    include(meta_jrun)

    meta_unity(
      TARGET device_unity_tests
      SOURCES test_leds.c test_sensors.c
      LINK firmware::drivers)

    meta_jrun(
      TARGET device_unity_tests
      DEVICE LPC55S16
      INTERFACE SWD
      SPEED 4000
      TIMEOUT 60
      SUITES test_leds test_sensors)
    ~~~

    This registration expects firmware-side suite dispatch when `--args` is provided.

2. Google Test firmware registration

    Example:

    ~~~cmake
    include(meta_gtest)
    include(meta_jrun)

    # The target must provide a board-specific RTT-aware main().
    meta_gtest(
      TARGET on_target_gtest
      SOURCES main.cpp test_arithmetic.cpp
      LINK target_runtime)

    meta_jrun(
      WITH_RTT WITH_GTEST
      TARGET on_target_gtest
      DEVICE STM32F407VG
      INTERFACE SWD
      TIMEOUT 60
      GTEST_FILTERS "Arithmetic.*")
    ~~~

    The example is schematic: `target_runtime` represents the required board startup, linker, and RTT support. The complete buildable layout is documented in the [STM32F407VG Google Test example](../../examples/ontarget-gtest/README.md).

#### 1.8.5. Google Test Result Contract

The Google Test execution path uses SEGGER RTT channel 0 and two [J-Run application-side wildcards](https://kb.segger.com/J-Run):

1. The target emits `*ARGS*` to request the filter supplied by the J-Run `--args` option.
2. The firmware executes the selected Google Test cases and emits `GTEST_SUMMARY selected=N failed=N skipped=N`.
3. The firmware sends `*STOP*0` for success or `*STOP*<positive-code>` for failure.
4. J-Run terminates and propagates the application result to the Python wrapper.
5. The wrapper accepts success only when J-Run exits with zero, a summary is present, `selected>0`, and `failed=0`.

A nonzero process exit, missing summary, empty selection, assertion failure or timeout causes CTest to fail. For a detailed classification and hardware acceptance checklist, see the [validation record](../../examples/ontarget-gtest/docs/VALIDATION.md).

## 2. References

- CMake [Documentation](https://cmake.org/documentation/) page.
- CMake [Modules](https://cmake.org/cmake/help/latest/manual/cmake-modules.7.html) documentation.
- CMake [GoogleTest](https://cmake.org/cmake/help/latest/module/GoogleTest.html) module documentation.
- CMake [RESOURCE_LOCK](https://cmake.org/cmake/help/latest/prop_test/RESOURCE_LOCK.html) property documentation.
- SEGGER [J-Run](https://kb.segger.com/J-Run) documentation.
- SEGGER [Passing Command-Line Arguments in C for Embedded Targets](https://kb.segger.com/Passing_Command-line_arguments_in_C_for_Embedded_Targets) documentation.
