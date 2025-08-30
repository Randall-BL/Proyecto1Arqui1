    .section .text
    .global tea_encrypt_asm

# void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4])
tea_encrypt_asm:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)

    lw t0, 0(a0)             # v0 = v[0]
    lw t1, 4(a0)             # v1 = v[1]
    li t2, 0x9e3779b9        # DELTA
    li t3, 0                 # sum = 0
    li t4, 32                # rondas

loop_enc:
    add t3, t3, t2           # sum += DELTA

    slli t5, t1, 4           # (v1 << 4)
    add t5, t5, t1           # simulando key[0]
    xor t5, t5, t1
    add t0, t0, t5

    slli t5, t0, 4
    add t5, t5, t0
    xor t5, t5, t0
    add t1, t1, t5

    addi t4, t4, -1
    bnez t4, loop_enc

    sw t0, 0(a0)
    sw t1, 4(a0)

    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret
