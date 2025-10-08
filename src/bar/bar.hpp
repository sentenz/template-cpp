#pragma once

#include <string>

// A simple example API
namespace cpp_concept
{

  // Intentionally leaks memory for testing sanitizer/reporting
  std::string_view leak_memory();

} // namespace cpp_concept
