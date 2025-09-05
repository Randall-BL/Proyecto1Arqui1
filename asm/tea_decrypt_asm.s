# TEA Decrypt Function for RISC-V64
# void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4])

.text
.align 2
.globl tea_decrypt_asm
.type tea_decrypt_asm, @function

tea_decrypt_asm:
    # Save callee-saved registers
    addi sp, sp, -32
    sd s0, 24(sp)
    sd s1, 16(sp)
    sd s2, 8(sp)
    sd s3, 0(sp)
    
    # Load data v[0] and v[1] as unsigned 32-bit
    lwu s0, 0(a0)       # s0 = v[0]
    lwu s1, 4(a0)       # s1 = v[1]
    
    # Load key[0-3] as unsigned 32-bit
    lwu t0, 0(a1)       # t0 = key[0]
    lwu t1, 4(a1)       # t1 = key[1]
    lwu t2, 8(a1)       # t2 = key[2]
    lwu t3, 12(a1)      # t3 = key[3]
    
    # Initialize TEA variables for decryption
    li s3, 0x9E3779B9   # s3 = DELTA
    li t4, 32           # temp value for multiplication
    mulw s2, s3, t4     # s2 = sum = DELTA * 32
    li t4, 32           # t4 = round counter
    
decrypt_loop:
    # v1 -= ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])
    slliw t5, s0, 4     # t5 = v0 << 4
    addw t5, t5, t2     # t5 = (v0 << 4) + key[2]
    
    addw t6, s0, s2     # t6 = v0 + sum
    
    srliw a2, s0, 5     # a2 = v0 >> 5
    addw a2, a2, t3     # a2 = (v0 >> 5) + key[3]
    
    xor a3, t5, t6      # a3 = temp1 ^ temp2
    xor a3, a3, a2      # a3 = final result
    subw s1, s1, a3     # v1 -= result
    
    # v0 -= ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])
    slliw t5, s1, 4     # t5 = v1 << 4
    addw t5, t5, t0     # t5 = (v1 << 4) + key[0]
    
    addw t6, s1, s2     # t6 = v1 + sum
    
    srliw a2, s1, 5     # a2 = v1 >> 5
    addw a2, a2, t1     # a2 = (v1 >> 5) + key[1]
    
    xor a3, t5, t6      # a3 = temp1 ^ temp2
    xor a3, a3, a2      # a3 = final result
    subw s0, s0, a3     # v0 -= result
    
    # sum -= DELTA
    subw s2, s2, s3
    
    # Decrement counter and loop
    addi t4, t4, -1
    bnez t4, decrypt_loop
    
    # Store results back
    sw s0, 0(a0)        # v[0] = s0
    sw s1, 4(a0)        # v[1] = s1
    
    # Restore callee-saved registers
    ld s0, 24(sp)
    ld s1, 16(sp)
    ld s2, 8(sp)
    ld s3, 0(sp)
    addi sp, sp, 32
    
    ret