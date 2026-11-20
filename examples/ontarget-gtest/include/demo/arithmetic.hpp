#pragma once
#include <cstdint>

namespace demo {
std::int32_t saturating_add(std::int32_t a, std::int32_t b) noexcept;
std::uint32_t crc32(const std::uint8_t* bytes, std::uint32_t length) noexcept;
}  // namespace demo
