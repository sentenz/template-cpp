# On-Target Google Test with CMake and SEGGER J-Run

On-target testing is the execution of cross-compiled test firmware on the microcontroller for which it was built. This reference integrates [Google Test](https://github.com/google/googletest), [CMake and CTest](https://cmake.org/cmake/help/latest/manual/ctest.1.html), and [SEGGER J-Run](https://kb.segger.com/J-Run) to build tests on a development host, program a physical device through J-Link, capture Real Time Transfer (RTT) output, and report the outcome to CTest.

The example targets an **STM32F407VG (Arm Cortex-M4F)** and reuses platform-independent C++ tests in native and embedded configurations. It is an opt-in subproject of the existing repository and does not replace the Unity-based on-target tests. Cross-linking and hardware execution require separate validation; see the [validation record](docs/VALIDATION.md).

- [1. Architecture](#1-architecture)
  - [1.1. Execution Environments](#11-execution-environments)
  - [1.2. Project Layout](#12-project-layout)
- [2. Prerequisites](#2-prerequisites)
  - [2.1. Host Development](#21-host-development)
  - [2.2. Embedded Hardware](#22-embedded-hardware)
- [3. Build and Test Workflow](#3-build-and-test-workflow)
  - [3.1. Native Tests](#31-native-tests)
  - [3.2. Cross-Compilation Without Hardware](#32-cross-compilation-without-hardware)
  - [3.3. Hardware-in-the-Loop Tests](#33-hardware-in-the-loop-tests)
- [4. Test Protocol and Result Handling](#4-test-protocol-and-result-handling)
  - [4.1. RTT Argument and Exit Protocol](#41-rtt-argument-and-exit-protocol)
  - [4.2. CTest Registration and Artifacts](#42-ctest-registration-and-artifacts)
- [5. Extension and Portability](#5-extension-and-portability)
  - [5.1. Test Suite Extension](#51-test-suite-extension)
  - [5.2. Microcontroller Porting](#52-microcontroller-porting)
- [6. Continuous Integration and Validation](#6-continuous-integration-and-validation)
- [7. References](#7-references)

## 1. Architecture

The project separates test source code, platform-specific runtime support, and the mechanisms used to execute compiled tests. CMake constructs the test executable; CTest invokes either the native executable or J-Run.

### 1.1. Execution Environments

| Property | Native host | Embedded target |
| --- | --- | --- |
| Compiler | GCC or Clang | GNU Arm Embedded GCC |
| Executable | `host_gtest` | `on_target_gtest.elf` |
| Entry point | `GTest::gtest_main` | RTT-aware `main()` |
| Test registration | `gtest_discover_tests()` | `meta_jrun(WITH_GTEST)` |
| Test selection | Google Test discovery | Explicit Google Test filters |
| Execution | Local process | J-Link / J-Run / STM32F407VG |
| Result transport | Process status and output | RTT summary and `*STOP*<code>` |

Example:

~~~plaintext
                          Shared C++ Google Test suites
                          /                          \
                  Native compiler             ARM cross-compiler
                         |                            |
                    host_gtest                on_target_gtest.elf
                         |                            |
                Google Test discovery             SEGGER J-Run
                         |                            |
                       CTest                     J-Link / SWD
                                                      |
                                               STM32F407VG
                                                      |
                                           RTT output and exit code
                                                      |
                                           Python result validator
                                                      |
                                                     CTest
~~~

The native executable can enumerate individual Google Test cases on the host. The cross-compiled executable cannot be executed directly by the host, so the embedded configuration registers filters explicitly instead of calling `gtest_discover_tests()` on an Arm ELF. This distinction is consistent with the [CMake GoogleTest module](https://cmake.org/cmake/help/latest/module/GoogleTest.html).

### 1.2. Project Layout

| Location | Responsibility |
| --- | --- |
| [`CMakeLists.txt`](CMakeLists.txt) | Targets, shared sources, build selection and CTest registration |
| [`CMakePresets.json`](CMakePresets.json) | Host, firmware-only and hardware execution presets |
| [`cmake/dependencies.cmake`](cmake/dependencies.cmake) | Google Test source configuration |
| [`cmake/arm-none-eabi.cmake`](cmake/arm-none-eabi.cmake) | Cortex-M4F compiler and linker options |
| [`cmake/segger_rtt.cmake`](cmake/segger_rtt.cmake) | SEGGER RTT source dependency |
| [`include/demo/`](include/demo/) and [`src/`](src/) | Platform-independent example library |
| [`tests/shared/`](tests/shared/) | Shared fixtures, parameterized cases and fake-bus tests |
| [`tests/target/`](tests/target/) | Hardware-specific tests and embedded Google Test entry point |
| [`board/stm32f407/`](board/stm32f407/) | Vector table, startup, linker layout and C runtime adaptation |
| [`tools/jrun_gtest_runner.py`](../../tools/jrun_gtest_runner.py) | Host-side J-Run launcher and result validation |
| [`tests/tooling/`](../../tests/tooling/) | Hardware-independent Python runner tests |

## 2. Prerequisites

The host and firmware builds use distinct compiler configurations. A functioning host build does not establish that the embedded toolchain or target firmware is valid.

### 2.1. Host Development

- CMake 3.28.3 or later, Ninja and Git.
- GCC or Clang with the C++20 support requested by the repository's `meta_gtest()` helper.
- Python 3.9 or later for the J-Run wrapper and its unit tests.
- Network access to fetch Google Test v1.17.0 or a local source checkout.

Google Test is declared through CMake `FetchContent`. For a local checkout, provide `-DFETCHCONTENT_SOURCE_DIR_GOOGLETEST=/path/to/googletest` at configuration time.

### 2.2. Embedded Hardware

- GNU Arm Embedded GCC and the corresponding newlib-nano runtime.
- An STM32F407VG board with a compatible powered SWD connection.
- A SEGGER J-Link probe and a J-Link software installation containing J-Run for physical test execution.
- SEGGER RTT sources, resolved through the pinned upstream revision or `-DSEGGER_RTT_ROOT=/path/to/RTT-repository`.

The board linker file assumes **1 MiB Flash and 128 KiB ordinary SRAM**. It excludes the 64 KiB core-coupled memory (CCM) bank from the runtime allocations in this reference; RTT control structures therefore remain in memory accessible to the debugger. CPU, FPU, memory map and board settings must be rechecked when changing device variants.

> [!NOTE]
> The existing `meta_gtest()` module requests `cxx_std_20` for Google Test v1.17.0. The example's initial `CMAKE_CXX_STANDARD` value does not override this target-level requirement.

## 3. Build and Test Workflow

Commands in this section are issued from the example directory unless explicitly stated otherwise.

### 3.1. Native Tests

Example:

~~~bash
cd examples/ontarget-gtest
cmake --preset host
cmake --build --preset host --parallel
ctest --preset host --output-on-failure

# Execute the host-side J-Run contract tests without a probe.
python3 -m unittest discover -s ../../tests/tooling -p 'test_*.py' -v
~~~

The native executable links the shared tests against `demo_core` and `GTest::gtest_main`. Test discovery creates individual CTest cases, including the instantiated parameterized tests. The Python tests exercise result-handling behavior without starting a real J-Run process.

### 3.2. Cross-Compilation Without Hardware

The firmware-only preset enables Arm cross-compilation while omitting J-Run test registration.

Example:

~~~bash
cmake --preset stm32f407-build-only
cmake --build --preset stm32f407-build-only --parallel
~~~

Expected build artifacts include `build/stm32f407-build-only/on_target_gtest.elf` and `build/stm32f407-build-only/on_target_gtest.map`. The build invokes `arm-none-eabi-size` to report section sizes. Successful compilation and linking do not verify RTT behavior or target execution.

### 3.3. Hardware-in-the-Loop Tests

The hardware preset registers separate CTest invocations for each configured Google Test filter. J-Run loads the ELF, starts the application and forwards target output through RTT.

Example:

~~~bash
cmake --preset stm32f407 -DJRUN_EXECUTABLE=/opt/SEGGER/JLink/JRun
cmake --build --preset stm32f407 --parallel
ctest --preset stm32f407 --verbose

# A second CTest invocation that emits a JUnit report.
ctest --test-dir build/stm32f407 \
  --output-on-failure \
  --output-junit build/stm32f407/junit.xml
~~~

The explicit executable path is illustrative; the actual location depends on the J-Link installation. When `JRUN_EXECUTABLE` is omitted, `meta_jrun()` searches the executable path and `SEGGER_PATH`.

| Cache variable | Example value | Purpose |
| --- | --- | --- |
| `JRUN_EXECUTABLE` | `/opt/SEGGER/JLink/JRun` | J-Run executable path |
| `JRUN_DEVICE` | `STM32F407VG` | J-Link device identifier |
| `JRUN_INTERFACE` | `SWD` | Target debug interface |
| `JRUN_SPEED_KHZ` | `4000` | Debug interface clock in kHz |
| `JRUN_TIMEOUT_SECONDS` | `60` | Host subprocess timeout in seconds |

## 4. Test Protocol and Result Handling

The runner requires independent evidence of firmware completion and test success. Loading an ELF file successfully does not satisfy the acceptance condition.

### 4.1. RTT Argument and Exit Protocol

The target application and J-Run use the [SEGGER RTT argument protocol](https://kb.segger.com/Passing_Command-line_arguments_in_C_for_Embedded_Targets).

1. The target initializes RTT and transmits `*ARGS*` on channel 0.
2. J-Run, launched with `--args <filter>`, supplies the filter string to the target.
3. The embedded entry point initializes Google Test, sets `GTEST_FLAG_SET(filter, ...)` and calls `RUN_ALL_TESTS()`.
4. Firmware writes `GTEST_SUMMARY selected=N failed=N skipped=N` and flushes standard output.
5. Firmware emits `*STOP*0` after a successful nonempty run, or `*STOP*<positive-code>` on failure.
6. J-Run terminates and passes its exit status to the Python validator, which checks the footer and the subprocess result.

Example:

~~~plaintext
GTEST_FILTER: Arithmetic.*
[==========] Running 2 tests from 1 test suite.
...
GTEST_SUMMARY selected=2 failed=0 skipped=0
*STOP*0
~~~

The log shown above illustrates the required application-level footer and exit marker; it is **not** a captured hardware execution result. The runner rejects missing summaries, zero selected tests, reported assertion failures, nonzero process exit status and timeouts.

### 4.2. CTest Registration and Artifacts

The [`meta_jrun()` helper](../../tools/cmake/meta_jrun.cmake) registers one CTest test for each value of `GTEST_FILTERS`. The example currently selects `Arithmetic.*`, `HostAndTarget/AddCases.*`, `RingBuffer.*`, `Sensor.*` and `Hardware.*`. Each invocation flashes the same executable and executes only its corresponding filter.

The CTest `RESOURCE_LOCK` property uses `jlink_probe` to prevent concurrent tests from contending for the same physical debugger within a single CTest run. See the [CMake resource lock documentation](https://cmake.org/cmake/help/latest/prop_test/RESOURCE_LOCK.html). Multiple independent CI jobs require separate coordination.

RTT logs are saved under `build/stm32f407/jrun-logs/`. CTest also records its standard test output and can generate a JUnit file with `--output-junit`; this is a separate CTest-level report, not a Google Test XML file generated on the microcontroller.

## 5. Extension and Portability

The example isolates reusable tests from board startup and transport code, allowing the test framework to be extended without coupling the production library to the target debugger.

### 5.1. Test Suite Extension

1. Add hardware-independent `TEST`, `TEST_F` or `TEST_P` cases under [`tests/shared/`](tests/shared/).
2. Append each new source to `SHARED_SOURCES` in [`CMakeLists.txt`](CMakeLists.txt).
3. Add tests that require registers or peripherals under [`tests/target/`](tests/target/).
4. Register corresponding `GTEST_FILTERS` in the target `meta_jrun()` call.
5. Verify that every filter selects at least one test. Unmatched filters are treated as errors.

The sample `SensorService` uses a fake `SensorBus` implementation so that logic can be exercised without physical peripherals. CPU identity tests in `tests/target/` run only on the microcontroller.

### 5.2. Microcontroller Porting

A board port must review the startup vector table, interrupt handlers, linker regions, initialization of static C++ objects, standard-library syscalls, CPU/FPU compiler options and J-Link device identifier. Hardware-specific assertions must also be adapted.

The firmware disables exceptions, run-time type information (RTTI), POSIX thread support and stream redirection where configured. The available C++ library facilities, heap size and stack budget depend on the cross-toolchain and memory map. The reference is not a production board-support package.

## 6. Continuous Integration and Validation

The [GitHub Actions example](../../.github/workflows/gtest-jrun-example.yml) runs native tests and the Python runner-contract tests on supported pull-request and push events. Hardware execution is opt-in through `workflow_dispatch` and requires a self-hosted Linux runner labeled `arm-embedded` and `jlink-stm32f407` with the required tools and device connection.

The [validation record](docs/VALIDATION.md) separates documentation and static inspection from native execution, firmware linking and hardware acceptance. It also defines failure-injection checks for assertions, unmatched filters, probe disconnection and firmware hangs.

> [!IMPORTANT]
> No assertion of a successful on-device run is made until the cross-link and physical hardware acceptance checks have been completed.

## 7. References

- SEGGER [J-Run](https://kb.segger.com/J-Run) documentation.
- SEGGER [Passing Command-Line Arguments in C for Embedded Targets](https://kb.segger.com/Passing_Command-line_arguments_in_C_for_Embedded_Targets) documentation.
- Google [Google Test](https://github.com/google/googletest) repository.
- CMake [GoogleTest](https://cmake.org/cmake/help/latest/module/GoogleTest.html) module documentation.
- CMake [RESOURCE_LOCK](https://cmake.org/cmake/help/latest/prop_test/RESOURCE_LOCK.html) property documentation.
- Sentenz [CMake Modules](../../tools/cmake/README.md) documentation.
- Sentenz [On-Target Test Validation and Acceptance Criteria](docs/VALIDATION.md) documentation.
