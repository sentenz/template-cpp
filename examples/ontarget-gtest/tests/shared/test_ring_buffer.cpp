#include <cstdint>
#include <gtest/gtest.h>
#include "demo/ring_buffer.hpp"

class RingBuffer : public ::testing::Test {
 protected:
  demo::RingBuffer<3> queue;
};

TEST_F(RingBuffer, StartsEmpty) {
  EXPECT_TRUE(queue.empty());
  EXPECT_EQ(queue.size(), 0u);
  EXPECT_EQ(queue.capacity(), 3u);
}

TEST_F(RingBuffer, PreservesOrderAndWrapsAround) {
  ASSERT_TRUE(queue.push(10));
  ASSERT_TRUE(queue.push(20));
  ASSERT_TRUE(queue.push(30));
  EXPECT_FALSE(queue.push(40));
  std::uint8_t value = 0;
  ASSERT_TRUE(queue.pop(value));
  EXPECT_EQ(value, 10);
  ASSERT_TRUE(queue.push(40));
  for (auto expected : {20, 30, 40}) {
    ASSERT_TRUE(queue.pop(value));
    EXPECT_EQ(value, expected);
  }
  EXPECT_TRUE(queue.empty());
}

TEST_F(RingBuffer, ClearRestoresCapacity) {
  ASSERT_TRUE(queue.push(8));
  queue.clear();
  EXPECT_TRUE(queue.empty());
  std::uint8_t value = 0;
  EXPECT_FALSE(queue.pop(value));
  EXPECT_TRUE(queue.push(99));
}
