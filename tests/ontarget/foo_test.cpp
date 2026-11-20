#include "unity/unity.h"

#include <climits>
#include <vector>

#include "foo.hpp"

using namespace cpp_concept;

void setUp(void) {}

void tearDown(void) {}

void test_FooTest_Add(void)
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
      {"positive numbers", /* in */ {2, 3}, /* want */ {5}},
      {"negative numbers", /* in */ {-2, -3}, /* want */ {-5}},
      {"zero inputs", /* in */ {0, 0}, /* want */ {0}},
      {"mixed sign", /* in */ {5, -3}, /* want */ {2}},
      {"boundary: int max + 0", /* in */ {INT_MAX, 0}, /* want */ {INT_MAX}},
      {"boundary: int min + 0", /* in */ {INT_MIN, 0}, /* want */ {INT_MIN}},
      // NOTE The following test case triggers UBSan in sanitizer builds, so it is commented out.
      // {"overflow: int max + 1", /* in */ {INT_MAX, 1}, /* want */ {INT_MIN}},
  };

  for (const auto &tc : tests)
  {
    // Arrange
    Foo foo;

    // Act
    const auto got = foo.add(tc.in.a, tc.in.b);

    // Assert
    TEST_ASSERT_EQUAL_INT_MESSAGE(tc.want.result, got, tc.label.c_str());
  }
}

int main(void)
{
  UNITY_BEGIN();

  RUN_TEST(test_FooTest_Add);

  int result = UNITY_END();

  return result;
}
