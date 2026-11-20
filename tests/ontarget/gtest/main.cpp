#include <gtest/gtest.h>

#include <cstdio>

int main(int argc, char **argv)
{
  // A lost command line or a stale suite name must fail the hardware run.
  GTEST_FLAG_SET(filter, "");
  testing::InitGoogleTest(&argc, argv);
  int status = RUN_ALL_TESTS();
  if (testing::UnitTest::GetInstance()->test_to_run_count() == 0)
  {
    std::puts("No tests matched the J-Run filter.");
    status = 1;
  }

  // Report the status even on 32-bit runtimes that drop main's exit code.
  std::printf("*STOP*%d\n", status);
  std::fflush(stdout);
  return status;
}
