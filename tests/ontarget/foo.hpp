#pragma once

#include <string>
#include <vector>

/**
 * @file foo.hpp
 * @brief Lightweight utility class examples used in unit tests and demos.
 *
 * This header declares the `Foo` helper class which provides a collection
 * of small, self-contained utility operations (arithmetic, string, and
 * container helpers) used by the examples and tests.
 *
 * @author Generated
 * @copyright Copyright (c) 2026 cpp-concept
 * @license SPDX-License-Identifier: LicenseRef-Proprietary
 */

/**
 * @brief Core namespace for cpp-concept library components.
 *
 * Contains utility classes, algorithms, and helper functions used
 * throughout the cpp-concept project for examples and demonstrations.
 */
namespace cpp_concept
{

  /**
   * @brief Collection of small utility operations for examples and tests.
   *
   * The `Foo` class groups several independent utility functions that are
   * intentionally simple to demonstrate unit tests and basic algorithm
   * behavior. All methods are const and have no hidden state.
   *
   * @note Methods do not throw on typical usage; callers should validate
   *       preconditions where noted (for example, non-zero denominators).
   */
  class Foo
  {
  public:
    Foo() = default;

    /**
     * @brief Add two integers.
     *
     * Computes \f$a + b\f$.
     *
     * @param[in] a First addend.
     * @param[in] b Second addend.
     * @return Sum of `a` and `b`.
     *
     * @see subtract(), multiply(), divide()
     */
    int add(int a, int b) const;
  };

} // namespace cpp_concept
