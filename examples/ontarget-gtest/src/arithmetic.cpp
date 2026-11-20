#include "demo/arithmetic.hpp"
#include <cstdint>
#include <limits>

namespace demo {
std::int32_t saturating_add(std::int32_t a, std::int32_t b) noexcept {
  constexpr auto hi = std::numeric_limits<std::int32_t>::max();
  constexpr auto lo = std::numeric_limits<std::int32_t>::min();
  if (b > 0 && a > hi - b) return hi;
  if (b < 0 && a < lo - b) return lo;
  return a + b;
}

std::uint32_t crc32(const std::uint8_t* bytes, std::uint32_t length) noexcept {
  std::uint32_t crc = 0xFFFFFFFFu;
  for (std::uint32_t i = 0; i < length; ++i) {
    crc ^= bytes[i];
    for (unsigned bit = 0; bit < 8; ++bit) {
      crc = (crc >> 1) ^ ((crc & 1u) ? 0xEDB88320u : 0u);
    }
  }
  return ~crc;
}
}  // namespace demo
