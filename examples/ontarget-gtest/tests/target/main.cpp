#include <cstddef>
#include <cstdio>
#include <gtest/gtest.h>
extern "C" {
#include "SEGGER_RTT.h"
}

namespace {
// J-Run responds to *ARGS* via RTT channel 0 when launched with --args.
// A missing reply times out on the host rather than silently running all tests.
bool read_filter(char* output, std::size_t capacity) {
  SEGGER_RTT_WriteString(0, "*ARGS*\n");
  std::size_t size = 0;
  bool overflow = false;
  for (;;) {
    char ch = 0;
    if (SEGGER_RTT_Read(0, &ch, 1) == 0) {
      __asm volatile("nop");
      continue;
    }
    if (ch == '\r') continue;
    if (ch == '\n') break;
    if (size + 1 < capacity) output[size++] = ch;
    else overflow = true;
  }
  output[size] = '\0';
  return !overflow && size != 0;
}
}  // namespace

int main() {
  SEGGER_RTT_Init();
  SEGGER_RTT_SetFlagsUpBuffer(0, SEGGER_RTT_MODE_BLOCK_IF_FIFO_FULL);
  setvbuf(stdout, nullptr, _IONBF, 0);

  char filter[96]{};
  if (!read_filter(filter, sizeof(filter))) {
    SEGGER_RTT_WriteString(0, "GTEST_PROTOCOL_ERROR: invalid J-Run --args\n*STOP*3\n");
    for (;;) { __asm volatile("nop"); }
  }

  int argc = 1;
  char program[] = "on_target_gtest";
  char* argv[] = {program, nullptr};
  ::testing::InitGoogleTest(&argc, argv);
  GTEST_FLAG_SET(filter, filter);

  std::printf("GTEST_FILTER: %s\n", filter);
  const int result = RUN_ALL_TESTS();
  const auto* const tests = ::testing::UnitTest::GetInstance();
  const int selected = tests->test_to_run_count();
  const int failed = tests->failed_test_count();
  const int skipped = tests->skipped_test_count();

  // Mandatory footer consumed by tools/jrun_gtest_runner.py.
  std::printf("GTEST_SUMMARY selected=%d failed=%d skipped=%d\n",
              selected, failed, skipped);
  if (selected == 0) {
    std::printf("GTEST_PROTOCOL_ERROR: filter selected zero tests\n");
  }
  std::fflush(stdout);

  const int code = selected == 0 ? 4 : (result == 0 && failed == 0 ? 0 : 1);
  // SEGGER J-Run returns the positive integer appended to *STOP* as exit code.
  SEGGER_RTT_printf(0, "*STOP*%d\n", code);
  for (;;) { __asm volatile("nop"); }
}
