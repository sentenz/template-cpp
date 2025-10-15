#pragma once

#include <string>
#include <vector>

namespace cpp_concept
{

  class Bar
  {
  public:
    Bar() = default;

    // Optionally leak memory and return a message when leaking
    std::string leak_sanitizer(bool leak = false, std::size_t bytes = 0);

    // Allocate a vector of size n and write value at index, returns the vector
    std::vector<int> address_sanitizer(std::size_t n, std::size_t index, int value);
  };

} // namespace cpp_concept
