#pragma once

#include <string>
#include <vector>

/**
 * @file bar/bar.hpp
 * @brief Helpers used by sanitizer-focused unit tests.
 *
 * This header provides the `Bar` class which contains small, focused
 * helper functions used by the test-suite to exercise sanitizers such as
 * LeakSanitizer, AddressSanitizer, MemorySanitizer, UndefinedBehaviorSanitizer,
 * and ThreadSanitizer.
 *
 * @author Sentenz
 * @copyright Copyright (c) 2026 Sentenz
 * @license SPDX-License-Identifier: Apache-2.0
 */

namespace cpp_concept
{

  /**
   * @brief Utility class demonstrating sanitizer-related helpers.
   *
   * The `Bar` class contains small example methods used by tests
   * to exercise various sanitizer detectors (LSan/ASan/MSan/UBSan/TSan).
   *
   * @since 1.0
   */
  class Bar
  {
  public:
    /**
     * @brief Default constructor.
     */
    Bar() = default;

    /**
     * @brief Demonstrate LeakSanitizer (LSan) memory leak detection.
     *
     * Allocates memory and optionally leaks it so that LSan can report
     * the leak at program exit.
     *
     * @param[in] leak If `true`, the allocated memory is intentionally leaked.
     * @param[in] bytes Number of bytes to allocate (0 uses a default size).
     * @return A status string describing the action taken.
     * @warning When `leak` is `true`, the allocated memory is never freed.
     */
    std::string leak_sanitizer(bool leak = false, std::size_t bytes = 0);

    /**
     * @brief Demonstrate AddressSanitizer (ASan) out-of-bounds detection.
     *
     * Creates a vector of size `n` and writes `value` at `index`. If `index`
     * is out of bounds, ASan will report the error.
     *
     * @param[in] n Size of the vector to allocate.
     * @param[in] index Position at which to write `value`.
     * @param[in] value Value to store.
     * @return The vector after the write operation.
     * @warning Passing `index >= n` causes undefined behavior detectable by ASan.
     */
    std::vector<int> address_sanitizer(std::size_t n, std::size_t index, int value);

    /**
     * @brief Demonstrate MemorySanitizer (MSan) uninitialized read detection.
     *
     * Returns a pointer to an integer that may be uninitialized depending on
     * the `initialized` parameter.
     *
     * @param[in] initialized If `true`, the returned integer is initialized to `x`.
     * @param[in] x Value used to initialize the integer when `initialized` is `true`.
     * @return Pointer to a heap-allocated integer.
     * @warning When `initialized` is `false`, reading the returned value triggers MSan.
     * @note Caller is responsible for freeing the returned pointer.
     */
    int *memory_sanitizer(bool initialized = true, int x = 0);

    /**
     * @brief Demonstrate UndefinedBehaviorSanitizer (UBSan) detection.
     *
     * Performs an operation that may invoke undefined behavior (e.g., signed
     * integer overflow or division by zero) depending on input values.
     *
     * @param[in] a First operand.
     * @param[in] b Second operand.
     * @return Result of the operation.
     * @pre `b` should not be zero if the caller expects defined behavior for division.
     * @warning Certain combinations of `a` and `b` cause undefined behavior.
     */
    int undefined_behavior_sanitizer(int a, int b);

    /**
     * @brief Demonstrate ThreadSanitizer (TSan) data race detection.
     *
     * Spawns threads that race on a shared variable without synchronization,
     * triggering TSan warnings.
     *
     * @warning This function intentionally causes a data race.
     */
    void thread_sanitizer();
  };

} // namespace cpp_concept
