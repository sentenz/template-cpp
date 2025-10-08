#include <gtest/gtest.h>

#include "bar.hpp"

using namespace cpp_concept;

TEST(BarTest, LeakMemory)
{
  // This call intentionally leaks memory for testing sanitizer/LSAN behavior
  leak_memory();
  SUCCEED();
}
