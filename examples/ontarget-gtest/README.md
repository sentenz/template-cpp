# Google Test + CMake + SEGGER J-Run on target

This standalone example extends the existing template-cpp
[CMake helpers](../../tools/cmake/README.md) with an embedded Google Test
workflow. It **does not alter the default top-level build or the existing
Unity tests**. The reference board is STM32F407VG (Cortex-M4F) with a J-Link
debug probe and SWD connection.

## Architecture

~~~text
     Test sources: arithmetic + ring buffer + fake sensor HAL
                     /                  \
       Native GCC/Clang             GNU Arm toolchain
           host_gtest               on_target_gtest.elf
               |                         |
      gtest_discover_tests()        JRun --args filter
               |                         |
              CTest              J-Link SWD, STM32F407
                                         |
                                   RTT *ARGS* request
                                   RUN_ALL_TESTS()
                                   GTEST_SUMMARY footer
                                   RTT *STOP*exit-code
                                         |
                               jrun_gtest_runner.py
                                         |
                                        CTest
~~~

Platform-independent test sources live in **tests/shared/**. The target
executable also includes **tests/target/**, startup assembly, memory layout,
newlib syscalls and RTT. The host executable links GTest's standard main
function; target firmware supplies its own RTT-aware main function.

## Prerequisites

Host tests require CMake 3.28.3+, Ninja, GCC/Clang with C++20, Git, Python
3.9+, and a working Google Test source checkout or network access.

Target builds additionally require GNU Arm Embedded GCC with newlib-nano.
Hardware execution requires an STM32F407VG board, SEGGER J-Link, compatible
J-Run and a powered SWD-connected device. The device has 1 MiB internal
Flash, 128 KiB ordinary SRAM and 64 KiB CCM. This linker script deliberately
excludes CCM because it is unsuitable for SEGGER RTT debug access.

The FetchContent dependency for Google Test is fixed at **v1.17.0**.
The official SEGGER RTT source dependency is pinned to a specific commit.
Either dependency may be sourced from an existing local checkout.

## Native host tests

Run from repository root:

~~~bash
cd examples/ontarget-gtest
cmake --preset host
cmake --build --preset host --parallel
ctest --preset host --output-on-failure

# Runner-contract unit tests: no probe required
python3 -m unittest discover -s ../../tests/tooling -p 'test_*.py' -v
~~~

Google Test cases registered with **gtest_discover_tests()** run directly
on the host. Host tests share the same C++ source files as target tests and
exercise fixtures, parameterized cases, boundary values and a fake sensor bus.

## Cross-compile without a probe

~~~bash
cmake --preset stm32f407-build-only
cmake --build --preset stm32f407-build-only --parallel
~~~

This preset requires the Arm GCC cross compiler but does not require J-Run.
It generates the firmware ELF and a map file for flash/RAM inspection.

## Run on actual hardware

~~~bash
cmake --preset stm32f407 -DJRUN_EXECUTABLE=/opt/SEGGER/JLink/JRun
cmake --build --preset stm32f407 --parallel
ctest --preset stm32f407 --verbose

# Optional JUnit output
ctest --test-dir build/stm32f407 --output-junit build/stm32f407/junit.xml
~~~

Device name, interface and timing can be customized with CMake cache settings:
**JRUN_DEVICE**, **JRUN_INTERFACE**, **JRUN_SPEED_KHZ** and
**JRUN_TIMEOUT_SECONDS**. J-Run may also be discovered from PATH or SEGGER_PATH.

Each filter registered through **meta_jrun(WITH_GTEST)** launches an
independent flash-and-run CTest invocation. The resource lock named
**jlink_probe** serializes tests that share the hardware debugger.

### Target/host result protocol

1. The MCU sends **\*ARGS\*** over RTT; J-Run responds with the configured
   Google Test filter.
2. Firmware initializes Google Test, applies that filter and executes
   **RUN_ALL_TESTS()**.
3. Firmware emits **GTEST_SUMMARY selected=N failed=N skipped=N** and flushes
   output through RTT.
4. Firmware sends **\*STOP\*0** on success, or a positive integer on failure.
5. J-Run maps the target code to a process exit status. The Python host runner
   independently checks the summary and fails for zero tests, assertions,
   crashed runs, lost communication, nonzero exit codes and timeouts.
6. Individual RTT logs are kept under **build/stm32f407/jrun-logs/**.

A successful firmware flash **does not** imply that tests passed.

### Porting to another MCU

Adapt the files in **board/stm32f407/**, toolchain flags, startup vector
table, CPU-specific tests, J-Link device name and memory regions. RTT
buffers must be placed in debugger-accessible SRAM. C++ static constructors
must execute before Google Test starts.

The target build disables C++ exceptions, RTTI, pthreads, file-system
support and stream redirection. Memory sizing and newlib compatibility
must be qualified for the selected toolchain.

Add new platform-independent tests to **tests/shared/** and register them
in **SHARED_SOURCES**. Add hardware-only test files under
**tests/target/**. Register appropriate GTest filters in the call to
**meta_jrun()**. Do not use host-side test discovery for cross-compiled ELF
files.

## Files and references

- [Main project CMake](CMakeLists.txt) and [presets](CMakePresets.json)
- [Arm toolchain](cmake/arm-none-eabi.cmake)
- [Google Test dependency](cmake/dependencies.cmake)
- [SEGGER RTT dependency](cmake/segger_rtt.cmake)
- [Board startup and linker configuration](board/stm32f407/)
- [J-Run result runner](../../tools/jrun_gtest_runner.py)
- [Runner unit tests](../../tests/tooling/)
- [Validation and acceptance checklist](docs/VALIDATION.md)
- [CI workflow](../../.github/workflows/gtest-jrun-example.yml)
- [SEGGER J-Run reference](https://kb.segger.com/J-Run)
- [Google Test](https://github.com/google/googletest)
