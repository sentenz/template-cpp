#pragma once

#include <string>
#include <vector>

namespace cpp_concept
{

  class Foo
  {
  public:
    Foo() = default;

    // Adds two integers and returns the sum
    int add(int a, int b) const;

    // Subtracts two integers and returns the difference
    int subtract(int a, int b) const;

    // Multiplies two integers and returns the product
    int multiply(int a, int b) const;

    // Divides two integers and returns the quotient
    double divide(int numerator, int denominator) const;

    // Returns a greeting for the provided text
    std::string greet(const std::string &text) const;

    // Checks if the given integer is even
    bool is_even(int n) const;

    // Reverses the given string
    std::string reverse(const std::string &text) const;

    // Computes the factorial of a non-negative integer n
    unsigned long long factorial(int n) const;

    // Spline interpolation between two points (x0, y0) and (x1, y1) at position x
    double spline(double x0, double y0, double x1, double y1, double x) const;

    // fibonacci computes the nth Fibonacci number
    unsigned long long fibonacci(int n) const;

    // Checks if the given integer is a prime number
    bool is_prime(int n) const;

    // Finds the maximum element in a vector of integers
    int find_max(const std::vector<int> &vec) const;
  };

} // namespace cpp_concept
