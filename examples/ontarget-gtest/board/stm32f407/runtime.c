#include <stdint.h>
#include "SEGGER_RTT.h"

extern uint32_t _sidata, _sdata, _edata, _sbss, _ebss;
extern void (*__preinit_array_start[])(void);
extern void (*__preinit_array_end[])(void);
extern void (*__init_array_start[])(void);
extern void (*__init_array_end[])(void);

extern int main(void);
extern void _exit(int status);

__attribute__((noreturn)) void Reset_Handler(void) {
  // STM32F407 resets to internal HSI and starts with FPU disabled.
  volatile uint32_t* const cpacr = (volatile uint32_t*)0xE000ED88u;
  *cpacr |= 0xFu << 20;
  __asm volatile("dsb\n\tisb" ::: "memory");

  uint32_t* src = &_sidata;
  for (uint32_t* dst = &_sdata; dst < &_edata;) *dst++ = *src++;
  for (uint32_t* dst = &_sbss; dst < &_ebss;) *dst++ = 0;

  // Google Test registers TEST/TEST_F instances via C++ static constructors.
  for (void (**p)(void) = __preinit_array_start; p < __preinit_array_end; ++p) (*p)();
  for (void (**p)(void) = __init_array_start; p < __init_array_end; ++p) (*p)();

  _exit(main());
  __builtin_unreachable();
}

__attribute__((noreturn)) void HardFault_Handler(void) {
  SEGGER_RTT_WriteString(0, "\nTARGET_HARDFAULT\n*STOP*11\n");
  for (;;) { __asm volatile("nop"); }
}

__attribute__((noreturn)) void Default_Handler(void) {
  SEGGER_RTT_WriteString(0, "\nTARGET_UNHANDLED_IRQ\n*STOP*12\n");
  for (;;) { __asm volatile("nop"); }
}
