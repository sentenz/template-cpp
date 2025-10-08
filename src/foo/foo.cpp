#include "foo.hpp"

namespace cpp_concept
{

  int add(int a, int b)
  {
    return a + b;
  }

  std::string greet(const std::string &name)
  {
    return "Hello, " + name + "!";
  }

} // namespace cpp_concept
