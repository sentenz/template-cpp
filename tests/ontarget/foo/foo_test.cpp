#include <gtest/gtest.h>

#include <climits>
#include <string>
#include <vector>

#include "foo/foo.hpp"

using namespace cpp_concept;

TEST(FooTest, Add)
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
      {"overflow: int max + 1", /* in */ {INT_MAX, 1}, /* want */ {INT_MIN}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act
    auto got = foo.add(tc.in.a, tc.in.b);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}

TEST(FooTest, Subtract)
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
      {"small positive numbers", /* in */ {5, 3}, /* want */ {2}},
      {"small negative numbers", /* in */ {-5, -3}, /* want */ {-2}},
      {"zero inputs", /* in */ {0, 0}, /* want */ {0}},
      {"mixed sign", /* in */ {5, -3}, /* want */ {8}},
      {"boundary: int max - 0", /* in */ {INT_MAX, 0}, /* want */ {INT_MAX}},
      {"boundary: int min - 0", /* in */ {INT_MIN, 0}, /* want */ {INT_MIN}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act
    auto got = foo.subtract(tc.in.a, tc.in.b);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}

TEST(FooTest, Multiply)
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
      {"small positive numbers", /* in */ {2, 3}, /* want */ {6}},
      {"small negative numbers", /* in */ {-2, -3}, /* want */ {6}},
      {"mixed sign", /* in */ {5, -3}, /* want */ {-15}},
      {"zero inputs", /* in */ {0, 0}, /* want */ {0}},
      {"multiply by zero", /* in */ {5, 0}, /* want */ {0}},
      {"boundary: int max * 1", /* in */ {INT_MAX, 1}, /* want */ {INT_MAX}},
      {"boundary: int min * 1", /* in */ {INT_MIN, 1}, /* want */ {INT_MIN}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act
    auto got = foo.multiply(tc.in.a, tc.in.b);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}

TEST(FooTest, IsEven)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      int n;
    } in;

    struct Want
    {
      bool result;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"positive even", /* in */ {4}, /* want */ {true}},
      {"positive odd", /* in */ {3}, /* want */ {false}},
      {"negative even", /* in */ {-4}, /* want */ {true}},
      {"negative odd", /* in */ {-3}, /* want */ {false}},
      {"zero", /* in */ {0}, /* want */ {true}},
      {"boundary: int max", /* in */ {INT_MAX}, /* want */ {false}},
      {"boundary: int min", /* in */ {INT_MIN}, /* want */ {true}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act
    auto got = foo.is_even(tc.in.n);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}

TEST(FooTest, IsPrime)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      int n;
    } in;

    struct Want
    {
      bool result;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"prime number 2", /* in */ {2}, /* want */ {true}},
      {"prime number 3", /* in */ {3}, /* want */ {true}},
      {"prime number 11", /* in */ {11}, /* want */ {true}},
      {"prime number 17", /* in */ {17}, /* want */ {true}},
      {"non-prime 1", /* in */ {1}, /* want */ {false}},
      {"non-prime 4", /* in */ {4}, /* want */ {false}},
      {"non-prime 6", /* in */ {6}, /* want */ {false}},
      {"non-prime 9", /* in */ {9}, /* want */ {false}},
      {"negative number", /* in */ {-5}, /* want */ {false}},
      {"large prime 97", /* in */ {97}, /* want */ {true}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act
    auto got = foo.is_prime(tc.in.n);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}

TEST(FooTest, Greet)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      std::string text;
    } in;

    struct Want
    {
      std::string result;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"empty string", /* in */ {""}, /* want */ {"Hello, !"}},
      {"single word", /* in */ {"World"}, /* want */ {"Hello, World!"}},
      {"multiple words", /* in */ {"C++ Developer"}, /* want */ {"Hello, C++ Developer!"}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act
    auto got = foo.greet(tc.in.text);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}
