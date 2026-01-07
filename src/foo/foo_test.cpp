#include <gtest/gtest.h>
#include <nlohmann/json.hpp>

#include <climits>
#include <filesystem>
#include <fstream>
#include <string>
#include <utility>
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
      {"overflow: int max * 2", /* in */ {INT_MAX, 2}, /* want */ {INT_MIN}}, // This tests overflow
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

TEST(FooTest, Divide)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      int numerator;
      int denominator;
    } in;

    struct Want
    {
      double result;
      bool throws_exception;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"positive division", /* in */ {10, 2}, /* want */ {5.0, false}},
      {"negative division", /* in */ {-10, 2}, /* want */ {-5.0, false}},
      {"mixed sign division", /* in */ {10, -2}, /* want */ {-5.0, false}},
      {"zero numerator", /* in */ {0, 5}, /* want */ {0.0, false}},
      {"division by one", /* in */ {10, 1}, /* want */ {10.0, false}},
      {"division with remainder", /* in */ {7, 2}, /* want */ {3.0, false}},
      {"division by zero", /* in */ {10, 0}, /* want */ {0.0, true}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act & Assert
    if (tc.want.throws_exception)
    {
      EXPECT_THROW(foo.divide(tc.in.numerator, tc.in.denominator), std::invalid_argument);
    }
    else
    {
      auto got = foo.divide(tc.in.numerator, tc.in.denominator);
      EXPECT_DOUBLE_EQ(got, tc.want.result);
    }
  }
}

class FooFixture : public ::testing::Test
{
protected:
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

  // Data-Driven Testing
  std::vector<Tests> tests;

  void SetUp() override
  {
    // Load JSON
    std::string filename = "foo_test.json";
    std::filesystem::path filepath = std::filesystem::path(__FILE__).parent_path() / filename;
    std::ifstream file(filepath);
    ASSERT_TRUE(file.good()) << "Failed to open JSON: " << filepath.string();

    // Parse JSON
    nlohmann::json data = nlohmann::json::parse(file);
    for (const auto &row : data["foo::greet"])
    {
      Tests tmp;
      tmp.label = row.at("label").get<std::string>();
      tmp.in.text = row.at("in").at("text").get<std::string>();
      tmp.want.result = row.at("want").at("result").get<std::string>();

      tests.push_back(std::move(tmp));
    }

    ASSERT_FALSE(tests.empty()) << "Failed to parse JSON: " << filepath.string();
  }

  void TearDown() override
  {
    // Cleanup
    tests.clear();
  }
};

TEST_F(FooFixture, Greet)
{
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

TEST(FooTest, Reverse)
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
      {"normal string", /* in */ {"hello"}, /* want */ {"olleh"}},
      {"empty string", /* in */ {""}, /* want */ {""}},
      {"single character", /* in */ {"a"}, /* want */ {"a"}},
      {"palindrome", /* in */ {"racecar"}, /* want */ {"racecar"}},
      {"spaces", /* in */ {"hello test"}, /* want */ {"tset olleh"}},
      {"special characters", /* in */ {"!@#$%"}, /* want */ {"%$#@!"}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act
    auto got = foo.reverse(tc.in.text);

    // Assert
    EXPECT_EQ(got, tc.want.result);
  }
}

TEST(FooTest, Factorial)
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
      unsigned long long result;
      bool throws_exception;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"factorial of zero", /* in */ {0}, /* want */ {1, false}},
      {"factorial of one", /* in */ {1}, /* want */ {1, false}},
      {"factorial of two", /* in */ {2}, /* want */ {2, false}},
      {"factorial of five", /* in */ {5}, /* want */ {120, false}},
      {"factorial of ten", /* in */ {10}, /* want */ {3628800, false}},
      {"negative input", /* in */ {-1}, /* want */ {0, true}},
      {"boundary: large number", /* in */ {20}, /* want */ {2432902008176640000ULL, false}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act & Assert
    if (tc.want.throws_exception)
    {
      EXPECT_THROW(foo.factorial(tc.in.n), std::invalid_argument);
    }
    else
    {
      auto got = foo.factorial(tc.in.n);
      EXPECT_EQ(got, tc.want.result);
    }
  }
}

TEST(FooTest, Spline)
{
  // In-Got-Want
  struct Tests
  {
    std::string label;

    struct In
    {
      double x0;
      double y0;
      double x1;
      double y1;
      double x;
    } in;

    struct Want
    {
      double result;
      bool throws_exception;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"x at x0", /* in */ {0, 0, 10, 20, 0}, /* want */ {0.0, false}},
      {"x at x1", /* in */ {0, 0, 10, 20, 10}, /* want */ {20.0, false}},
      {"negative coordinates", /* in */ {-5, -10, 5, 10, 0}, /* want */ {0.0, false}},
      {"x between points", /* in */ {1, 2, 3, 6, 2}, /* want */ {4.0, false}},
      {"same x0 and x1", /* in */ {5, 10, 5, 15, 5}, /* want */ {0.0, true}},
      {"x beyond range", /* in */ {0, 0, 10, 20, 15}, /* want */ {30.0, false}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act & Assert
    if (tc.want.throws_exception)
    {
      EXPECT_THROW(foo.spline(tc.in.x0, tc.in.y0, tc.in.x1, tc.in.y1, tc.in.x), std::invalid_argument);
    }
    else
    {
      auto got = foo.spline(tc.in.x0, tc.in.y0, tc.in.x1, tc.in.y1, tc.in.x);
      EXPECT_DOUBLE_EQ(got, tc.want.result);
    }
  }
}

TEST(FooTest, Fibonacci)
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
      unsigned long long result;
      bool throws_exception;
    } want;
  };

  // Table-Driven Testing
  const std::vector<Tests> tests = {
      {"fibonacci of zero", /* in */ {0}, /* want */ {0, false}},
      {"fibonacci of one", /* in */ {1}, /* want */ {1, false}},
      {"fibonacci of two", /* in */ {2}, /* want */ {1, false}},
      {"fibonacci of three", /* in */ {3}, /* want */ {2, false}},
      {"fibonacci of four", /* in */ {4}, /* want */ {3, false}},
      {"fibonacci of five", /* in */ {5}, /* want */ {5, false}},
      {"fibonacci of ten", /* in */ {10}, /* want */ {55, false}},
      {"fibonacci of fifteen", /* in */ {15}, /* want */ {610, false}},
      {"negative input", /* in */ {-1}, /* want */ {0, true}},
      {"boundary: large number", /* in */ {50}, /* want */ {12586269025ULL, false}},
  };

  for (const auto &tc : tests)
  {
    SCOPED_TRACE(tc.label);

    // Arrange
    Foo foo;

    // Act & Assert
    if (tc.want.throws_exception)
    {
      EXPECT_THROW(foo.fibonacci(tc.in.n), std::invalid_argument);
    }
    else
    {
      auto got = foo.fibonacci(tc.in.n);
      EXPECT_EQ(got, tc.want.result);
    }
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
      {"large non-prime 100", /* in */ {100}, /* want */ {false}},
      {"large prime 997", /* in */ {997}, /* want */ {true}},
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
