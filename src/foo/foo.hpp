#pragma once

#include <string>

// A simple example API
namespace cpp_concept
{

class Foo
{
public:
  Foo() = default;

  // Adds two integers and returns the sum
  int add(int a, int b) const;

  // Returns a greeting for the provided name
  std::string greet(const std::string &name) const;
};

} // namespace cpp_concept
