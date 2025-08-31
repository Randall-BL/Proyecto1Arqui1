# TEA Decryption function in RISC-V64 assembly
# void tea_decrypt_asm(uint32_t *data, uint32_t *key)
.globl tea_decrypt_asm
.type tea_decrypt_asm, @function

tea_decrypt_asm:
    # Save callee-saved registers
    addi sp, sp, -32
    sd s0, 0(sp)
    sd s1, 8(sp)
    sd s2, 16(sp)
    sd s3, 24(sp)
    
    # Load data[0] and data[1]
    lw s0, 0(a0)    # s0 = data[0] (left)
    lw s1, 4(a0)    # s1 = data[1] (right)
    
    # Load key values
    lw t0, 0(a1)    # t0 = key[0]
    lw t1, 4(a1)    # t1 = key[1]
    lw t2, 8(a1)    # t2 = key[2]
    lw t3, 12(a1)   # t3 = key[3]
    
    # Load delta constant
    lui s3, 0x9E378
    addi s3, s3, -0x647  # s3 = delta = 0x9E3779B9
    
    # Initialize sum = delta * 32 (32-bit arithmetic)
    li t4, 32           # Load 32
    mulw s2, s3, t4     # s2 = delta * 32 (32-bit multiplication)
    
    # Counter for 32 rounds
    li t4, 32
    
decrypt_loop:
    # v1 -= ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])
    # temp = (v0 << 4) + key[2]
    slliw t5, s0, 4     # t5 = v0 << 4 (32-bit)
    addw t5, t5, t2     # t5 = (v0 << 4) + key[2]
    
    # temp2 = v0 + sum
    addw t6, s0, s2     # t6 = v0 + sum
    
    # temp3 = (v0 >> 5) + key[3]
    srliw a2, s0, 5     # a2 = v0 >> 5 (32-bit)
    addw a2, a2, t3     # a2 = (v0 >> 5) + key[3]
    
    # v1 -= (temp ^ temp2) ^ temp3
    xor a3, t5, t6      # a3 = temp ^ temp2
    xor a3, a3, a2      # a3 = (temp ^ temp2) ^ temp3
    subw s1, s1, a3     # v1 -= result (32-bit subtraction)
    
    # v0 -= ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])
    # temp = (v1 << 4) + key[0]
    slliw t5, s1, 4     # t5 = v1 << 4 (32-bit)
    addw t5, t5, t0     # t5 = (v1 << 4) + key[0]
    
    # temp2 = v1 + sum
    addw t6, s1, s2     # t6 = v1 + sum
    
    # temp3 = (v1 >> 5) + key[1]
    srliw a2, s1, 5     # a2 = v1 >> 5 (32-bit)
    addw a2, a2, t1     # a2 = (v1 >> 5) + key[1]
    
    # v0 -= (temp ^ temp2) ^ temp3
    xor a3, t5, t6      # a3 = temp ^ temp2
    xor a3, a3, a2      # a3 = (temp ^ temp2) ^ temp3
    subw s0, s0, a3     # v0 -= result (32-bit subtraction)
    
    # sum -= delta (32-bit arithmetic)
    subw s2, s2, s3
    
    # Decrement counter and loop
    addi t4, t4, -1
    bnez t4, decrypt_loop
    
    # Store results back to data array
    sw s0, 0(a0)    # data[0] = left
    sw s1, 4(a0)    # data[1] = right
    
    # Restore callee-saved registers
    ld s0, 0(sp)
    ld s1, 8(sp)
    ld s2, 16(sp)
    ld s3, 24(sp)
    addi sp, sp, 32
    
    ret