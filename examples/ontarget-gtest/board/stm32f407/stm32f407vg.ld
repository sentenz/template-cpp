/* STM32F407VG: 1 MiB flash and 128 KiB debugger-visible SRAM.
 * 64 KiB CCM RAM deliberately not used for RTT memory.
 */
ENTRY(Reset_Handler)
MEMORY {
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 1024K
  RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
  CCM   (rwx) : ORIGIN = 0x10000000, LENGTH = 64K
}

_estack = ORIGIN(RAM) + LENGTH(RAM);
__StackSize = 16K;
__HeapLimit = _estack - __StackSize;

SECTIONS {
  .isr_vector : {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } > FLASH
  .text : {
    . = ALIGN(4);
    *(.text .text.*)
    *(.rodata .rodata.*)
    KEEP(*(.init))
    KEEP(*(.fini))
    . = ALIGN(4);
  } > FLASH
  .ARM.extab : { *(.ARM.extab* .gnu.linkonce.armextab.*) } > FLASH
  .ARM.exidx : {
    __exidx_start = .;
    *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    __exidx_end = .;
  } > FLASH
  .preinit_array : {
    . = ALIGN(4);
    __preinit_array_start = .;
    KEEP(*(.preinit_array*))
    __preinit_array_end = .;
  } > FLASH
  .init_array : {
    . = ALIGN(4);
    __init_array_start = .;
    KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
    KEEP(*(.init_array))
    __init_array_end = .;
  } > FLASH
  .fini_array : {
    . = ALIGN(4);
    __fini_array_start = .;
    KEEP(*(SORT_BY_INIT_PRIORITY(.fini_array.*)))
    KEEP(*(.fini_array))
    __fini_array_end = .;
  } > FLASH
  .data : {
    . = ALIGN(8);
    _sdata = .;
    *(.data .data.*)
    . = ALIGN(8);
    _edata = .;
  } > RAM AT > FLASH
  _sidata = LOADADDR(.data);
  .bss (NOLOAD) : {
    . = ALIGN(8);
    _sbss = .;
    *(.bss .bss.*)
    *(COMMON)
    . = ALIGN(8);
    _ebss = .;
  } > RAM
  .noinit (NOLOAD) : {
    . = ALIGN(8);
    *(.noinit .noinit.*)
    . = ALIGN(8);
  } > RAM
  . = ALIGN(8);
  __HeapBase = .;
  /DISCARD/ : {
    *(.note.GNU-stack)
    *(.comment)
  }
}
ASSERT(__HeapBase < __HeapLimit,
       "Static RAM allocation leaves no room for heap and reserved stack")
ASSERT(SIZEOF(.isr_vector) <= 0x400, "Unexpected vector table size")
