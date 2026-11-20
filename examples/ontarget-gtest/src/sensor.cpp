#include "demo/sensor.hpp"

namespace demo {
int SensorService::read_or(int fallback) {
  int value = 0;
  return bus_.read_sample(value) ? value : fallback;
}
}  // namespace demo
