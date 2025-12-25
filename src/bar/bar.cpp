#include "bar/bar.hpp"

#include <iostream>
#include <string>
#include <thread>
#include <atomic>

namespace cpp_concept
{

  std::string Bar::leak_sanitizer(bool leak, std::size_t bytes)
  {
    static std::string msg = "";

    if (leak && bytes > 0)
    {
      // NOTE Intentionally leak memory for testing sanitizer/reporting
      volatile char *p = new char[bytes];
      for (std::size_t i = 0; i < bytes; ++i)
        p[i] = static_cast<char>(i & 0xFF);
      (void)p; // keep p referenced to avoid optimization
      msg = "Leaked " + std::to_string(bytes) + " bytes";
    }

    return msg;
  }

  std::vector<int> Bar::address_sanitizer(std::size_t n, std::size_t index, int value)
  {
    if (n == 0)
    {
      return {};
    }

    std::vector<int> vec;
    vec.reserve(n);
    for (std::size_t i = 0; i < n; ++i)
    {
      vec.push_back(static_cast<int>(i));
    }

    // NOTE Perform the write (may be out of bounds intentionally)
    // Use operator[] to preserve the original potential OOB behavior when tests
    // intentionally check address-sanitizer behavior. If vec[index] is OOB
    // this may still exhibit undefined behavior or be caught by ASan.
    vec[index] = value; // potentially OOB

    return vec;
  }

  int *Bar::memory_sanitizer(bool initialized, int x)
  {
    int *data = new int;

    if (initialized)
    {
      *data = x;
    }

    // Caller owns the allocation
    return data; // trigger MSan if uninitialized
  }

  int Bar::undefined_behavior_sanitizer(int a, int b)
  {
    return a / b; // trigger UBSan if b == 0
  }

  void Bar::thread_sanitizer()
  {
    static std::atomic<int> counter{0};

    auto increment = []()
    {
      for (int i = 0; i < 10; ++i)
      {
        ++counter; // potential data race
      }
    };

    std::thread t1(increment);
    std::thread t2(increment);
    t1.join();
    t2.join();
  }

} // namespace cpp_concept
