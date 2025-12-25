#pragma once

#include <string>
#include <vector>

namespace cpp_concept
{

  class Bar
  {
  public:
    Bar() = default;

    // LeakSanitizer (LSan) to detects memory leaks
    std::string leak_sanitizer(bool leak = false, std::size_t bytes = 0);

    // AddressSanitizer (ASan) to detect memory corruption bugs, memory access errors such as out-of-bounds (OOB) memory accesses and use-after-free bugs
    std::vector<int> address_sanitizer(std::size_t n, std::size_t index, int value);

    // MemorySanitizer (MSan) to detect uninitialized memory reads
    int *memory_sanitizer(bool initialized = true, int x = 0);

    // UndefinedBehaviorSanitizer (UBSan) to detect undefined behavior, such as signed integer overflow and division by zero
    int undefined_behavior_sanitizer(int a, int b);

    // ThreadSanitizer (TSan) to detect data races in multithreaded code
    void thread_sanitizer();
  };

} // namespace cpp_concept
