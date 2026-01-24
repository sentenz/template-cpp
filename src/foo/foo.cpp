#include "foo/foo.hpp"

#include <stdexcept>

namespace cpp_concept
{

  int Foo::add(int a, int b) const
  {
    return a + b;
  }

  int Foo::subtract(int a, int b) const
  {
    return a - b;
  }

  int Foo::multiply(int a, int b) const
  {
    return a * b;
  }

  double Foo::divide(int numerator, int denominator) const
  {
    if (denominator == 0)
    {
      throw std::invalid_argument("Denominator cannot be zero");
    }

    return static_cast<double>(numerator / denominator);
  }

  std::string Foo::greet(const std::string &text) const
  {
    return "Hello, " + text + "!";
  }

  bool Foo::is_even(int n) const
  {
    return n % 2 == 0;
  }

  std::string Foo::reverse(const std::string &text) const
  {
    return std::string(text.rbegin(), text.rend());
  }

  unsigned long long Foo::factorial(int n) const
  {
    if (n < 0)
    {
      throw std::invalid_argument("Negative input not allowed");
    }

    unsigned long long result = 1;
    for (int i = 2; i <= n; ++i)
    {
      result *= i;
    }

    return result;
  }

  double Foo::spline(double x0, double y0, double x1, double y1, double x) const
  {
    if (x1 == x0)
    {
      throw std::invalid_argument("x0 and x1 cannot be the same");
    }

    double t = (x - x0) / (x1 - x0);
    return (1 - t) * y0 + t * y1; // Linear interpolation as a simple spline
  }

  unsigned long long Foo::fibonacci(int n) const
  {
    if (n < 0)
    {
      throw std::invalid_argument("Negative input not allowed");
    }

    if (n == 0)
    {
      return 0;
    }

    if (n == 1)
    {
      return 1;
    }

    unsigned long long a = 0, b = 1, c;
    for (int i = 2; i <= n; ++i)
    {
      c = a + b;
      a = b;
      b = c;
    }

    return b;
  }

  bool Foo::is_prime(int n) const
  {
    if (n <= 1)
    {
      return false;
    }

    for (int i = 2; i * i <= n; ++i)
    {
      if (n % i == 0)
      {
        return false;
      }
    }

    return true;
  }

  int Foo::find_max(const std::vector<int> &vec) const
  {
    if (vec.empty())
    {
      throw std::invalid_argument("Vector cannot be empty");
    }

    int max_val = vec[0];
    for (size_t i = 1; i < vec.size(); ++i)
    {
      if (vec[i] > max_val)
      {
        max_val = vec[i];
      }
    }

    return max_val;
  }

} // namespace cpp_concept
