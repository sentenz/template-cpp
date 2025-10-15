#include "bar/bar.hpp"

#include <string>
#include <vector>

#include <gtest/gtest.h>

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
      std::string text;
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
    EXPECT_EQ(got, tc.want.text);
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
      std::vector<int> array;
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
    EXPECT_EQ(got, tc.want.array);
  }
}
