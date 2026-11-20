#include <cstdint>
#include <gtest/gtest.h>

// Executed only on the target: Cortex-M4 SCB->CPUID register.
TEST(Hardware, CortexM4CoreIdentity) {
  auto* const cpuid = reinterpret_cast<volatile const std::uint32_t*>(0xE000ED00u);
  const std::uint32_t id = *cpuid;
  EXPECT_EQ((id >> 24) & 0xFFu, 0x41u);  // ARM implementer
  EXPECT_EQ((id >> 4) & 0xFFFu, 0xC24u); // Cortex-M4 part
}
