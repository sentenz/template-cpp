# Verification record and hardware acceptance criteria

Prepared on 2026-11-20. The authoring environment does **not** contain an
attached STM32F407VG board, J-Link probe, J-Run installation, or GNU Arm
Embedded toolchain. Firmware linking, flashing and on-board execution are
**not verified**.

The original standalone J-Run runner contract, on which this repository
integration is based, passed six Python unit tests in the authoring
environment. New branch changes must be checked by the GitHub Actions
workflow and then qualified on physical hardware.

## Acceptance checks

1. From repository root, run:
   python3 -m unittest discover -s tests/tooling -p 'test_*.py' -v
2. From examples/ontarget-gtest/, configure/build/run the host preset and
   confirm all Google Test cases pass through CTest.
3. Configure/build the stm32f407-build-only preset and examine the generated
   ELF/map file with arm-none-eabi-size.
4. Connect the STM32F407VG and J-Link. Configure/build the stm32f407 preset,
   run CTest, and inspect the captured RTT summaries for each filter.
5. Deliberately fail an assertion: J-Run must return nonzero and CTest fail.
6. Run an unmatched filter: selected=0 must cause failure, not success.
7. Disconnect the probe and stall the firmware: host transport errors and
   timeouts must cause nonzero CTest results.
8. Confirm static C++ constructors execute and RTT buffers live in
   debugger-visible SRAM. Measure RAM, heap and stack margins before
   production adoption.

## Failure classification

| Observed condition | Diagnosis |
| --- | --- |
| Nonzero process exit | Test assertion, firmware exit or probe error |
| Missing GTEST_SUMMARY | Incomplete execution or lost RTT output |
| selected=0 | GTest filter did not select a test |
| selected>0 and failed>0 | Google Test assertion failure |
| Timeout | Firmware hang or J-Run/RTT handshake stalled |
| TARGET_HARDFAULT | Cortex-M fault handler reached |

The [SEGGER J-Run reference](https://kb.segger.com/J-Run) documents RTT
argument passing using *ARGS* and target return codes using *STOP*.
