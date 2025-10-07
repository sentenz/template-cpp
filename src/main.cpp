#include "foo.hpp"

#include <iostream>

int main()
{
  std::cout << "Result of add(2, 3): " << cpp_concept::add(2, 3) << std::endl;
  std::cout << cpp_concept::greet("World") << std::endl;

  return 0;
}
