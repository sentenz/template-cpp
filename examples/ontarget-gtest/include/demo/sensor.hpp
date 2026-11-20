#pragma once

namespace demo {
// Replace SensorBus with a real MCU ADC/I2C driver in production.
class SensorBus {
 public:
  virtual ~SensorBus() = default;
  virtual bool read_sample(int& value) = 0;
};

class SensorService {
 public:
  explicit SensorService(SensorBus& bus) : bus_(bus) {}
  int read_or(int fallback);

 private:
  SensorBus& bus_;
};
}  // namespace demo
