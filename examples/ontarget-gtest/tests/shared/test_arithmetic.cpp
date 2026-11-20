#include <cstdint>
#include <limits>
#include <tuple>
#include <gtest/gtest.h>
#include "demo/arithmetic.hpp"

class AddCases : public ::testing::TestWithParam<std::tuple<int, int, int>> {};

TEST_P(AddCases, SaturatesCorrectly) {
  const auto [a, b, expected] = GetParam();
  EXPECT_EQ(demo::saturating_add(a, b), expected);
}

INSTANTIATE_TEST_SUITE_P(HostAndTarget, AddCases,
  ::testing::Values(
    std::make_tuple(20, 22, 42),
    std::make_tuple(-20, 22, 2),
    std::make_tuple(0, 0, 0)
  )
);

TEST(Arithmetic, SaturatesAtIntegerBoundaries) {
  constexpr auto hi = std::numeric_limits<std::int32_t>::max();
  constexpr auto lo = std::numeric_limits<std::int32_t>::min();
  EXPECT_EQ(demo::saturating_add(hi, 1), hi);
  EXPECT_EQ(demo::saturating_add(lo, -1), lo);
  EXPECT_EQ(demo::saturating_add(hi, lo), -1);
}

TEST(Arithmetic, StandardCrc32) {
  constexpr std::uint8_t message[] = {'1','2','3','4','5','6','7','8','9'};
  EXPECT_EQ(demo::crc32(message, sizeof(message)), 0xCBF43926u);
  EXPECT_EQ(demo::crc32(nullptr, 0), 0u);
}
