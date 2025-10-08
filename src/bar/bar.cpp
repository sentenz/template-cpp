#include "bar/bar.hpp"

namespace cpp_concept
{

  std::string_view leak_memory()
  {
    // allocate and intentionally do not free to create a leak
    volatile char *p = new char[256];
    // touch the memory to avoid optimizing it away
    for(int i = 0; i < 256; ++i) p[i] = static_cast<char>(i);
    (void)p;
    return "Leaked 256 bytes";
  }

} // namespace cpp_concept
