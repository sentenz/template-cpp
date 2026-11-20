# On-Target Test Validation and Acceptance Criteria

Validation of on-target tests establishes that a cross-compiled test executable can start on its intended microcontroller, execute the selected test cases, and deliver a reliable result to the host. This record defines the verification stages for the STM32F407VG Google Test and SEGGER J-Run example, including expected evidence and deliberate failure scenarios.

**Status as of 2026-11-20:** The PR documentation and execution contract have been reviewed, but the updated repository implementation has **not** been qualified through a completed native build, GNU Arm firmware link, or physical J-Link execution in the authoring environment. The absence of these results must not be interpreted as a passing test run.

- [1. Verification Scope](#1-verification-scope)
- [2. Verification Matrix](#2-verification-matrix)
- [3. Acceptance Procedure](#3-acceptance-procedure)
  - [3.1. Python Result-Contract Tests](#31-python-result-contract-tests)
  - [3.2. Native Google Test Execution](#32-native-google-test-execution)
  - [3.3. Cross-Compilation and ELF Inspection](#33-cross-compilation-and-elf-inspection)
  - [3.4. Physical Target Execution](#34-physical-target-execution)
  - [3.5. Negative and Fault-Injection Tests](#35-negative-and-fault-injection-tests)
- [4. Failure Classification](#4-failure-classification)
- [5. Constraints and Evidence Retention](#5-constraints-and-evidence-retention)
- [6. References](#6-references)

## 1. Verification Scope

The example combines native Google Test execution with an embedded executable that communicates over SEGGER Real Time Transfer (RTT). The host runner requires both a successful J-Run process status and a nonempty Google Test summary.

Verification covers four distinct mechanisms:

- **Host-Side Result Validation**
  > Python unit tests simulate J-Run output, subprocess failures and timeouts without requiring an MCU or debug probe.

- **Native Test Execution**
  > CMake builds and CTest executes platform-independent Google Test suites on the development host.

- **Firmware Compilation and Linking**
  > GNU Arm Embedded GCC cross-compiles the test firmware and resolves startup, linker, runtime and dependency symbols for STM32F407VG.

- **Hardware-in-the-Loop Execution**
  > J-Run loads the firmware through J-Link, transfers test filters over RTT, observes the test summary and returns the target exit status.

These stages require separate evidence. A successful compilation is not evidence of test execution, and a successful flash operation is not evidence of passing assertions.

## 2. Verification Matrix

The following matrix identifies tests and acceptance conditions. An unverified status denotes an outstanding check rather than a failed or successful test.

| Stage | Verification method | Acceptance criterion | Status |
| --- | --- | --- | --- |
| Runner contract | `python3 -m unittest` | Contract tests pass, including negative cases | Not executed for this revision |
| Native CMake configure | `cmake --preset host` | Configuration completes without errors | Not executed for this revision |
| Native tests | `ctest --preset host` | All registered Google Test cases pass | Not executed for this revision |
| Firmware build | `cmake --build --preset stm32f407-build-only` | ARM ELF links and size/map output is produced | Not executed for this revision |
| Target execution | `ctest --preset stm32f407` | Selected tests complete with valid RTT summaries | Not executed for this revision |
| Failure injection | Assertion, no-match filter, stalled target, missing probe | Each injected failure propagates as nonzero CTest status | Not executed for this revision |

## 3. Acceptance Procedure

The working directory and required hardware are specified for each stage. All commands are intended for the checked-out PR branch.

### 3.1. Python Result-Contract Tests

Execute the host-side unit tests from the repository root.

Example:

~~~bash
python3 -m unittest discover \
  -s tests/tooling \
  -p 'test_*.py' \
  -v
~~~

The tests exercise successful summaries, assertion failures, zero selected tests, absent summaries, nonzero J-Run exits, timeouts and subprocess start failures. Success requires the unit-test command to exit with status zero.

### 3.2. Native Google Test Execution

Configure and execute the native Google Test suites using the example's CMake presets.

Example:

~~~bash
cd examples/ontarget-gtest
cmake --preset host
cmake --build --preset host --parallel
ctest --preset host --output-on-failure
~~~

Success requires a completed build and no failed tests in the CTest summary. The host configuration uses `gtest_discover_tests()` for individual test registration; it does not invoke J-Run.

### 3.3. Cross-Compilation and ELF Inspection

The firmware-only preset compiles the startup and Google Test runtime for Cortex-M4F without registering hardware execution tests.

Example:

~~~bash
cd examples/ontarget-gtest
cmake --preset stm32f407-build-only
cmake --build --preset stm32f407-build-only --parallel
arm-none-eabi-size build/stm32f407-build-only/on_target_gtest.elf
~~~

Inspect `build/stm32f407-build-only/on_target_gtest.map` and the cross-linker memory usage report. Verify that the vector table and reset handler are present, static constructors are retained and sections fit within the linker-defined Flash and SRAM regions. This step alone cannot verify runtime startup, heap/stack high-water marks or RTT accessibility.

### 3.4. Physical Target Execution

A physical run requires the STM32F407VG, a connected J-Link probe, installed J-Run and the Arm compiler toolchain.

Example:

~~~bash
cd examples/ontarget-gtest
cmake --preset stm32f407 -DJRUN_EXECUTABLE=/opt/SEGGER/JLink/JRun
cmake --build --preset stm32f407 --parallel
ctest --preset stm32f407 --verbose

# Optional: rerun through CTest and generate JUnit output.
ctest --test-dir build/stm32f407 \
  --output-on-failure \
  --output-junit build/stm32f407/junit.xml
~~~

Accept a test only when the runner reports a zero J-Run exit status, detects a `GTEST_SUMMARY selected=N failed=0 skipped=M` footer and confirms `N > 0`. Inspect the RTT logs under `build/stm32f407/jrun-logs/` to confirm that the expected filters ran. Confirm that C++ static constructors completed and that RTT output resides in debugger-accessible RAM.

### 3.5. Negative and Fault-Injection Tests

Failure-injection tests establish that the reporting path cannot silently accept an incomplete or failed target run. Perform these checks on a dedicated development board, and restore any intentionally modified test sources afterward.

1. **Assertion Failure**

    Introduce a deliberately failing `EXPECT_EQ` in a selected target test, rebuild the firmware and rerun the hardware CTest case. The RTT summary must report a failure; the runner and CTest must return failure.

2. **Unmatched Google Test Filter**

    Invoke the host runner manually with a filter that matches no linked test. The application must produce `selected=0`; the runner must return failure even if the transport itself exits normally.

    Example:

    ~~~bash
    python3 ../../tools/jrun_gtest_runner.py \
      --jrun /opt/SEGGER/JLink/JRun \
      --device STM32F407VG \
      --interface SWD \
      --speed 4000 \
      --timeout 60 \
      --log-dir build/stm32f407/jrun-logs \
      --filter 'NonexistentSuite.*' \
      --elf build/stm32f407/on_target_gtest.elf
    ~~~

3. **Unavailable Debug Probe**

    Run a target test with the probe disconnected or inaccessible. J-Run must fail, and the host runner must not report a passing CTest case.

4. **Firmware Stall**

    Deliberately stall firmware before the summary or exit marker. The configured host timeout must terminate the process and report failure.

5. **Fault Handler**

    For a controlled fault-injection build, enter a target fault handler and verify that the diagnostic marker and nonzero `*STOP*<code>` terminate the run as a failure.

## 4. Failure Classification

The runner combines process status with the target-generated summary. Errors must be interpreted from the complete log rather than from exit status alone.

| Observation | Meaning | Required outcome |
| --- | --- | --- |
| Zero exit and `selected>0, failed=0` | Completed test run without reported assertion failures | Pass |
| Nonzero J-Run process exit | Firmware result or host-side J-Run error | Fail |
| `GTEST_SUMMARY` absent | Target did not complete reporting or RTT output was incomplete | Fail |
| `selected=0` | Filter did not select a linked test | Fail |
| `failed>0` | Google Test recorded a failed assertion | Fail |
| Runner exit `124` | J-Run subprocess timeout | Fail |
| Runner exit `125` | J-Run executable could not be started | Fail |
| `TARGET_HARDFAULT` marker | Firmware reached the target's HardFault handler | Fail |

These conditions follow the behavior of [`jrun_gtest_runner.py`](../../../tools/jrun_gtest_runner.py) and the [firmware test entry point](../tests/target/main.cpp).

## 5. Constraints and Evidence Retention

Hardware qualification must record the microcontroller board revision, GNU Arm compiler version, J-Link hardware identity, J-Run version, RTT source revision and applicable CMake presets. Results should include build output, ELF/map size information, RTT logs, CTest logs and any generated JUnit reports.

The sample uses a simplified startup and C library adaptation. A production board-support package requires additional review of clock initialization, watchdog behavior, interrupt vectors, fault capture and memory usage. The example has no measured stack or heap headroom and no verified hardware timing baseline.

A self-hosted GitHub Actions runner can execute the hardware job only after it is provisioned with a connected board, probe and toolchain; the [workflow](../../../.github/workflows/gtest-jrun-example.yml) does not provision hardware.

## 6. References

- SEGGER [J-Run](https://kb.segger.com/J-Run) documentation.
- SEGGER [Passing Command-Line Arguments in C for Embedded Targets](https://kb.segger.com/Passing_Command-line_arguments_in_C_for_Embedded_Targets) documentation.
- CMake [GoogleTest](https://cmake.org/cmake/help/latest/module/GoogleTest.html) module documentation.
- Sentenz [On-Target Google Test with CMake and SEGGER J-Run](../README.md) documentation.
- Sentenz [J-Run Result Validator](../../../tools/jrun_gtest_runner.py) source file.
