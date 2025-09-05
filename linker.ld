ENTRY(_start)

MEMORY {
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 128K
}

SECTIONS {
  . = ORIGIN(RAM);

  .text : {
    *(.text*)
    *(.rodata*)   /* Literales */
  }

  .data : {
    *(.data*)
  }

  .bss : {
    *(.bss*)
    *(COMMON)
  }

  . = ALIGN(16);
  _stack_top = . + 0x4000;  /* 16 KB de stack */
}
