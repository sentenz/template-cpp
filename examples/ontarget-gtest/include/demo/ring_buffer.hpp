#pragma once
#include <array>
#include <cstddef>
#include <cstdint>

namespace demo {
// Single-threaded fixed-size FIFO; not safe for simultaneous IRQ access.
template <std::size_t Capacity>
class RingBuffer {
  static_assert(Capacity > 0, "Capacity must be nonzero");

 public:
  bool push(std::uint8_t value) noexcept {
    if (count_ == Capacity) return false;
    data_[tail_] = value;
    tail_ = (tail_ + 1) % Capacity;
    ++count_;
    return true;
  }
  bool pop(std::uint8_t& result) noexcept {
    if (!count_) return false;
    result = data_[head_];
    head_ = (head_ + 1) % Capacity;
    --count_;
    return true;
  }
  void clear() noexcept { head_ = tail_ = count_ = 0; }
  std::size_t size() const noexcept { return count_; }
  constexpr std::size_t capacity() const noexcept { return Capacity; }
  bool empty() const noexcept { return count_ == 0; }
  bool full() const noexcept { return count_ == Capacity; }

 private:
  std::array<std::uint8_t, Capacity> data_{};
  std::size_t head_ = 0;
  std::size_t tail_ = 0;
  std::size_t count_ = 0;
};
}  // namespace demo
