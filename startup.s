.section .text
.globl _start

_start:
    la sp, _stack_top   # stack pointer
    call main
1:  j 1b
