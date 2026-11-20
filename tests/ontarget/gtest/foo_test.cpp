#include <gtest/gtest.h>

#include <climits>

#include "foo/foo.hpp"

TEST(FooArithmetic, Add)
{
  const cpp_concept::Foo foo;
  EXPECT_EQ(foo.add(-2, 3), 1);
  EXPECT_EQ(foo.add(INT_MAX, 0), INT_MAX);
}

TEST(FooText, Reverse)
{
  const cpp_concept::Foo foo;
  EXPECT_EQ(foo.reverse("target"), "tegrat");
  EXPECT_TRUE(foo.reverse("").empty());
}
