    .section .text
    .globl _start
_start:
    # Inicializar puntero de pila (definido en linker.ld)
    la sp, _stack_top     

    # Llamar a main
    call main             

    # Si main termina, bucle infinito
1:  j 1b
