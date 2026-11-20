#include <stdint.h>

extern uint32_t __data_load__, __data_start__, __data_end__, __stack;
extern void _start(void) __attribute__((noreturn));

void Reset_Handler(void)
{
    const uint32_t *src = &__data_load__;
    for (uint32_t *dst = &__data_start__; dst < &__data_end__; ++dst)
        *dst = *src++;

    // rdimon initializes .bss, semihosting, argv and C++ constructors.
    _start();
}

// Unexpected exceptions remain observable as a CTest timeout.
static void Default_Handler(void)
{
    for (;;) {}
}

__attribute__((section(".vectors"), used))
const uintptr_t vectors[] = {
    (uintptr_t)&__stack,
    (uintptr_t)Reset_Handler,
    [2 ... 97] = (uintptr_t)Default_Handler, // Core exceptions and 82 peripheral IRQs.
};
