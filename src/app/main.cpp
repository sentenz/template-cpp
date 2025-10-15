#include "foo/foo.hpp"
#include "bar/bar.hpp"

#include <iostream>

int main()
{
  cpp_concept::Foo foo;
  std::cout << "Result of add(2, 3): " << foo.add(2, 3) << std::endl;
  std::cout << foo.greet("World") << std::endl;

  cpp_concept::Bar bar;
  std::cout << bar.leak_sanitizer(true, 256) << std::endl;

  return 0;
}
