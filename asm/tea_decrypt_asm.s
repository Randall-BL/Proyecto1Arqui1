    .section .text
    .global tea_decrypt_asm

# void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4])
tea_decrypt_asm:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)

    lw t0, 0(a0)
    lw t1, 4(a0)
    li t2, 0x9e3779b9
    li t3, 32
    mul t3, t2, t3           # sum = DELTA*32

loop_dec:
    slli t5, t0, 4
    add t5, t5, t0
    xor t5, t5, t0
    sub t1, t1, t5

    slli t5, t1, 4
    add t5, t5, t1
    xor t5, t5, t1
    sub t0, t0, t5

    addi t3, t3, -1
    bnez t3, loop_dec

    sw t0, 0(a0)
    sw t1, 4(a0)

    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret
