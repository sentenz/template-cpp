#include "foo/foo.hpp"

namespace cpp_concept
{

  int Foo::add(int a, int b) const
  {
    return a + b;
  }

  std::string Foo::greet(const std::string &name) const
  {
    return "Hello, " + name + "!";
  }

} // namespace cpp_concept
