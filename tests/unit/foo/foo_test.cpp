#include <gtest/gtest.h>

#include "foo/foo.hpp"

using namespace cpp_concept;

TEST(FooTest, AddPositive)
{
  EXPECT_EQ(add(2, 3), 5);
}

TEST(FooTest, AddNegative)
{
  EXPECT_EQ(add(-1, -2), -3);
}

TEST(FooTest, Greet)
{
  EXPECT_EQ(greet("World"), "Hello, World!");
}
