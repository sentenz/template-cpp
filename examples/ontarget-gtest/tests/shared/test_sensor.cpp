#include <gtest/gtest.h>
#include "demo/sensor.hpp"

namespace {
class FakeBus final : public demo::SensorBus {
 public:
  bool healthy = true;
  int sample = 27;
  int calls = 0;

  bool read_sample(int& value) override {
    ++calls;
    if (!healthy) return false;
    value = sample;
    return true;
  }
};
}  // namespace

TEST(Sensor, ReadsThroughFakeHal) {
  FakeBus bus;
  demo::SensorService service(bus);
  EXPECT_EQ(service.read_or(-1), 27);
  EXPECT_EQ(bus.calls, 1);
}

TEST(Sensor, ReturnsFallbackWhenPeripheralFails) {
  FakeBus bus;
  bus.healthy = false;
  demo::SensorService service(bus);
  EXPECT_EQ(service.read_or(-1), -1);
}
