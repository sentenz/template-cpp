#include <gtest/gtest.h>

#include <string>
#include <vector>

#include "bar/bar.hpp"

TEST(BarTest, LeakSanitizer)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      bool leak;
      std::size_t bytes;
    } in;

    struct Want
    {
      std::string result;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"no leak (default)", /* in */ {false, 0}, /* want */ {""}},
      // NOTE The following test case may trigger LSan if enabled, it is commented out to avoid test failures
      {"leak 256 bytes", /* in */ {true, 256}, /* want */ {"Leaked 256 bytes"}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    cpp_concept::Bar bar;

    // Act
    auto got = bar.leak_sanitizer(tc.in.leak, tc.in.bytes);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}

TEST(BarTest, AddressSanitizer)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      std::size_t n;
      std::size_t index;
      int value;
    } in;

    struct Want
    {
      std::vector<int> result;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"valid write within bounds", /* in */ {5, 2, 99}, /* want */ {{0, 1, 99, 3, 4}}},
      {"write at start (index 0)", /* in */ {3, 0, -1}, /* want */ {{-1, 1, 2}}},
      {"write at end (index n-1)", /* in */ {4, 3, -2}, /* want */ {{0, 1, 2, -2}}},
      {"zero length (n=0)", /* in */ {0, 0, 0}, /* want */ {{}}},
      // NOTE The following test case may trigger ASan if enabled, it is commented out to avoid test failures
      {"out-of-bounds (OOB) write (index n)", /* in */ {3, 3, 42}, /* want */ {{0, 1, 2}}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    cpp_concept::Bar bar;

    // Act
    auto got = bar.address_sanitizer(tc.in.n, tc.in.index, tc.in.value);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}

TEST(BarTest, MemorySanitizer)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      bool initialized;
      int x;
    } in;

    struct Want
    {
      int result;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"initialized with positive value", /* in */ {true, 42}, /* want */ {42}},
      {"initialized with negative value", /* in */ {true, -10}, /* want */ {-10}},
      {"initialized with zero", /* in */ {true, 0}, /* want */ {0}},
      {"initialized with max int", /* in */ {true, INT_MAX}, /* want */ {INT_MAX}},
      {"initialized with min int", /* in */ {true, INT_MIN}, /* want */ {INT_MIN}},
      // NOTE The following test case may trigger MSan if enabled, it is commented out to avoid test failures
      {"uninitialized", /* in */ {false, 0}, /* want */ {0}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    cpp_concept::Bar bar;

    // Act
    auto got = bar.memory_sanitizer(tc.in.initialized, tc.in.x);

    // Assert
    EXPECT_EQ(*got, tc.want.result);

    // Cleanup
    delete got;
  }
}

TEST(BarTest, UndefinedBehaviorSanitizer)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      int a;
      int b;
    } in;

    struct Want
    {
      int result;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"positive division", /* in */ {10, 2}, /* want */ {5}},
      {"negative dividend", /* in */ {-10, 2}, /* want */ {-5}},
      {"negative divisor", /* in */ {10, -2}, /* want */ {-5}},
      {"both negative", /* in */ {-10, -2}, /* want */ {5}},
      {"divide by one", /* in */ {42, 1}, /* want */ {42}},
      {"zero dividend", /* in */ {0, 5}, /* want */ {0}},
      {"large numbers", /* in */ {INT_MAX, 2}, /* want */ {INT_MAX / 2}},
      // NOTE The following test case may trigger UBSan if enabled, it is commented out to avoid test failures
      {"division by zero", /* in */ {10, 0}, /* want */ {0}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    cpp_concept::Bar bar;

    // Act
    auto got = bar.undefined_behavior_sanitizer(tc.in.a, tc.in.b);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}

TEST(BarTest, ThreadSanitizer)
{
  // Arrange
  cpp_concept::Bar bar;

  // Act & Assert
  EXPECT_NO_THROW(bar.thread_sanitizer());
}
