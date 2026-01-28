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

namespace cpp_concept
{

  /**
   * @brief A utility class providing basic mathematical and string operations.
   *
   * The Foo class encapsulates various common operations including arithmetic,
   * string processing, and mathematical functions. All methods are const and
   * thread-safe for read-only operations.
   *
   * @code
   * Foo foo;
   * int sum = foo.add(2, 3);
   * std::string greeting = foo.greet("World");
   * @endcode
   *
   * @since 1.0
   */
  class Foo
  {
  public:
    Foo() = default;

    /**
     * @brief Adds two integers and returns the sum.
     *
     * @param[in] a The first integer to add.
     * @param[in] b The second integer to add.
     * @return The sum of a and b.
     */
    int add(int a, int b) const;

    /**
     * @brief Subtracts two integers and returns the difference.
     *
     * @param[in] a The minuend.
     * @param[in] b The subtrahend.
     * @return The difference (a - b).
     */
    int subtract(int a, int b) const;

    /**
     * @brief Multiplies two integers and returns the product.
     *
     * @param[in] a The first integer to multiply.
     * @param[in] b The second integer to multiply.
     * @return The product of a and b.
     */
    int multiply(int a, int b) const;

    /**
     * @brief Divides two integers and returns the quotient.
     *
     * @param[in] numerator The dividend.
     * @param[in] denominator The divisor.
     * @return The quotient as a double.
     * @throws std::invalid_argument If denominator is zero.
     *
     * @pre denominator != 0
     */
    double divide(int numerator, int denominator) const;

    /**
     * @brief Returns a greeting for the provided text.
     *
     * @param[in] text The text to include in the greeting.
     * @return A greeting string in the format "Hello, <text>!".
     */
    std::string greet(const std::string &text) const;

    /**
     * @brief Checks if the given integer is even.
     *
     * @param[in] n The integer to check.
     * @return True if n is even, false otherwise.
     */
    bool is_even(int n) const;

    /**
     * @brief Reverses the given string.
     *
     * @param[in] text The string to reverse.
     * @return The reversed string.
     */
    std::string reverse(const std::string &text) const;

    /**
     * @brief Computes the factorial of a non-negative integer n.
     *
     * @param[in] n The non-negative integer.
     * @return The factorial of n.
     * @throws std::invalid_argument If n is negative.
     *
     * @pre n >= 0
     */
    unsigned long long factorial(int n) const;

    /**
     * @brief Performs linear interpolation between two points.
     *
     * Computes the value at position x using linear interpolation
     * between points (x0, y0) and (x1, y1).
     *
     * @param[in] x0 The x-coordinate of the first point.
     * @param[in] y0 The y-coordinate of the first point.
     * @param[in] x1 The x-coordinate of the second point.
     * @param[in] y1 The y-coordinate of the second point.
     * @param[in] x The position to interpolate at.
     * @return The interpolated value at x.
     */
    double spline(double x0, double y0, double x1, double y1, double x) const;

    /**
     * @brief Computes the nth Fibonacci number.
     *
     * @param[in] n The index of the Fibonacci number.
     * @return The nth Fibonacci number.
     * @throws std::invalid_argument If n is negative.
     *
     * @pre n >= 0
     */
    unsigned long long fibonacci(int n) const;

    /**
     * @brief Checks if the given integer is a prime number.
     *
     * @param[in] n The integer to check.
     * @return True if n is prime, false otherwise.
     * @note 0 and 1 are not considered prime numbers.
     */
    bool is_prime(int n) const;

    /**
     * @brief Finds the maximum element in a vector of integers.
     *
     * @param[in] vec The vector to search.
     * @return The maximum value in the vector.
     * @throws std::invalid_argument If the vector is empty.
     *
     * @pre !vec.empty()
     */
    int find_max(const std::vector<int> &vec) const;
  };

} // namespace cpp_concept
