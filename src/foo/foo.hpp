#pragma once

#include <string>
#include <vector>

/**
 * @file foo/foo.hpp
 * @brief Header file for the Foo class providing basic mathematical and string operations.
 *
 * This file defines the Foo class within the cpp_concept namespace, offering
 * a collection of utility functions for arithmetic operations, string manipulation,
 * and mathematical computations like factorial and Fibonacci.
 *
 * @author Sentenz
 * @copyright Copyright (c) 2026 Sentenz
 * @license SPDX-License-Identifier: Apache-2.0
 */

/**
 * @brief Core namespace for C++ concept demonstrations.
 *
 * Contains utility classes and functions demonstrating common programming
 * patterns, mathematical operations, and testing scenarios.
 */
namespace cpp_concept
{

  /**
   * @brief A utility class providing basic mathematical and string operations.
   *
   * The Foo class encapsulates various common operations including arithmetic,
   * string processing, and mathematical functions. All methods are const and
   * thread-safe for read-only operations.
   *
   * @note Thread safety: All public methods are const and safe for concurrent
   *       read-only access from multiple threads.
   *
   * @see Bar
   *
   * @code
   * Foo foo;
   * int sum = foo.add(2, 3);           // Returns 5
   * std::string greeting = foo.greet("World");  // Returns "Hello, World!"
   * @endcode
   *
   * @since 1.0
   */
  class Foo
  {
  public:
    /**
     * @brief Default constructor.
     *
     * Constructs a Foo instance with default state.
     */
    Foo() = default;

    /**
     * @brief Adds two integers and returns the sum.
     *
     * @param[in] a The first integer to add.
     * @param[in] b The second integer to add.
     *
     * @return The sum of a and b.
     *
     * @note Integer overflow is undefined behavior for signed integers.
     *
     * @see subtract()
     * @see multiply()
     */
    int add(int a, int b) const;

    /**
     * @brief Subtracts two integers and returns the difference.
     *
     * @param[in] a The minuend.
     * @param[in] b The subtrahend.
     *
     * @return The difference \f$(a - b)\f$.
     *
     * @note Integer overflow is undefined behavior for signed integers.
     *
     * @see add()
     */
    int subtract(int a, int b) const;

    /**
     * @brief Multiplies two integers and returns the product.
     *
     * @param[in] a The first integer to multiply.
     * @param[in] b The second integer to multiply.
     *
     * @return The product \f$(a \times b)\f$.
     *
     * @note Integer overflow is undefined behavior for signed integers.
     *
     * @see divide()
     */
    int multiply(int a, int b) const;

    /**
     * @brief Divides two integers and returns the quotient.
     *
     * Computes the quotient \f$\frac{numerator}{denominator}\f$ as a
     * floating-point value.
     *
     * @param[in] numerator The dividend.
     * @param[in] denominator The divisor.
     *
     * @return The quotient as a double.
     *
     * @throws std::invalid_argument If denominator is zero.
     *
     * @pre denominator != 0
     * @post Result is finite when inputs are valid.
     *
     * @see multiply()
     */
    double divide(int numerator, int denominator) const;

    /**
     * @brief Returns a greeting for the provided text.
     *
     * @param[in] text The text to include in the greeting.
     *
     * @return A greeting string in the format "Hello, <text>!".
     *
     * @post Returned string starts with "Hello, " and ends with "!".
     *
     * @see reverse()
     */
    std::string greet(const std::string &text) const;

    /**
     * @brief Checks if the given integer is even.
     *
     * Determines whether \f$n \mod 2 = 0\f$.
     *
     * @param[in] n The integer to check.
     *
     * @retval true  If n is divisible by 2.
     * @retval false If n is odd.
     *
     * @see is_prime()
     */
    bool is_even(int n) const;

    /**
     * @brief Reverses the given string.
     *
     * @param[in] text The string to reverse.
     *
     * @return The reversed string.
     *
     * @post Result has the same length as input.
     *
     * @see greet()
     */
    std::string reverse(const std::string &text) const;

    /**
     * @brief Computes the factorial of a non-negative integer n.
     *
     * Calculates \f$n! = n \times (n-1) \times \cdots \times 1\f$ where
     * \f$0! = 1\f$ by convention.
     *
     * @param[in] n The non-negative integer.
     *
     * @return The factorial \f$n!\f$.
     *
     * @throws std::invalid_argument If n is negative.
     *
     * @pre n >= 0
     * @post Result >= 1.
     *
     * @warning Values of n > 20 may cause overflow for 64-bit integers.
     *
     * @see fibonacci()
     */
    unsigned long long factorial(int n) const;

    /**
     * @brief Performs linear interpolation between two points.
     *
     * Computes the value at position x using linear interpolation
     * between points \f$(x_0, y_0)\f$ and \f$(x_1, y_1)\f$.
     *
     * The interpolation formula is:
     * \f[
     *   y = y_0 + \frac{(y_1 - y_0)}{(x_1 - x_0)} \times (x - x_0)
     * \f]
     *
     * @param[in] x0 The x-coordinate of the first point.
     * @param[in] y0 The y-coordinate of the first point.
     * @param[in] x1 The x-coordinate of the second point.
     * @param[in] y1 The y-coordinate of the second point.
     * @param[in] x The position to interpolate at.
     *
     * @return The interpolated value at x.
     *
     * @pre x0 != x1 (points must have distinct x-coordinates).
     *
     * @note Extrapolation occurs when x is outside the range \f$[x_0, x_1]\f$.
     */
    double spline(double x0, double y0, double x1, double y1, double x) const;

    /**
     * @brief Computes the nth Fibonacci number.
     *
     * Calculates the Fibonacci sequence defined by:
     * \f[
     *   F(n) = \begin{cases}
     *     0 & \text{if } n = 0 \\
     *     1 & \text{if } n = 1 \\
     *     F(n-1) + F(n-2) & \text{otherwise}
     *   \end{cases}
     * \f]
     *
     * @param[in] n The index of the Fibonacci number (0-indexed).
     *
     * @return The nth Fibonacci number \f$F(n)\f$.
     *
     * @throws std::invalid_argument If n is negative.
     *
     * @pre n >= 0
     * @post Result >= 0.
     *
     * @warning Values of n > 93 may cause overflow for 64-bit integers.
     *
     * @see factorial()
     */
    unsigned long long fibonacci(int n) const;

    /**
     * @brief Checks if the given integer is a prime number.
     *
     * A prime number is a natural number greater than 1 that has no
     * positive divisors other than 1 and itself.
     *
     * @param[in] n The integer to check.
     *
     * @retval true  If n is a prime number.
     * @retval false If n is not prime (including n <= 1).
     *
     * @note 0 and 1 are not considered prime numbers.
     *
     * @see is_even()
     */
    bool is_prime(int n) const;

    /**
     * @brief Finds the maximum element in a vector of integers.
     *
     * @param[in] vec The vector to search.
     *
     * @return The maximum value in the vector.
     *
     * @throws std::invalid_argument If the vector is empty.
     *
     * @pre !vec.empty()
     * @post Result is an element of vec.
     * @post Result >= all elements in vec.
     */
    int find_max(const std::vector<int> &vec) const;
  };

} // namespace cpp_concept
