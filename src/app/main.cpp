#include "foo/foo.hpp"
#include "bar/bar.hpp"

#include <iostream>

int main()
{
  std::cout << "Result of add(2, 3): " << cpp_concept::add(2, 3) << std::endl;
  std::cout << cpp_concept::greet("World") << std::endl;
  std::cout << cpp_concept::leak_memory() << std::endl; // Call to function in bar to demonstrate linkage

  return 0;
}
