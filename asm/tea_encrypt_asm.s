# TEA Encryption/Decryption in RISC-V64 Assembly
# void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4])
# void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4])

.text
.align 2
.globl tea_encrypt_asm
.globl tea_decrypt_asm

# TEA Encrypt Function
tea_encrypt_asm:
    # Save registers following RISC-V ABI
    addi sp, sp, -32
    sd s0, 24(sp)
    sd s1, 16(sp)
    sd s2, 8(sp)
    sd s3, 0(sp)
    
    # Load v[0] and v[1] as unsigned 32-bit values
    lwu s0, 0(a0)       # s0 = v[0] (v0)
    lwu s1, 4(a0)       # s1 = v[1] (v1)
    
    # Load key[0-3] as unsigned 32-bit values
    lwu t0, 0(a1)       # t0 = key[0]
    lwu t1, 4(a1)       # t1 = key[1]
    lwu t2, 8(a1)       # t2 = key[2]
    lwu t3, 12(a1)      # t3 = key[3]
    
    # Initialize TEA variables
    li s2, 0            # s2 = sum = 0
    li s3, 0x9E3779B9   # s3 = DELTA
    li t4, 32           # t4 = round counter
    
encrypt_loop:
    # sum += DELTA (32-bit arithmetic)
    addw s2, s2, s3
    
    # v0 += ((v1 << 4) + key[0]) ^ (v1 + sum) ^ ((v1 >> 5) + key[1])
    slliw t5, s1, 4     # t5 = v1 << 4
    addw t5, t5, t0     # t5 = (v1 << 4) + key[0]
    
    addw t6, s1, s2     # t6 = v1 + sum
    
    srliw a2, s1, 5     # a2 = v1 >> 5
    addw a2, a2, t1     # a2 = (v1 >> 5) + key[1]
    
    xor a3, t5, t6      # a3 = ((v1 << 4) + key[0]) ^ (v1 + sum)
    xor a3, a3, a2      # a3 = result
    addw s0, s0, a3     # v0 += result
    
    # v1 += ((v0 << 4) + key[2]) ^ (v0 + sum) ^ ((v0 >> 5) + key[3])
    slliw t5, s0, 4     # t5 = v0 << 4
    addw t5, t5, t2     # t5 = (v0 << 4) + key[2]
    
    addw t6, s0, s2     # t6 = v0 + sum
    
    srliw a2, s0, 5     # a2 = v0 >> 5
    addw a2, a2, t3     # a2 = (v0 >> 5) + key[3]
    
    xor a3, t5, t6      # a3 = ((v0 << 4) + key[2]) ^ (v0 + sum)
    xor a3, a3, a2      # a3 = result
    addw s1, s1, a3     # v1 += result
    
    # Loop control
    addi t4, t4, -1
    bnez t4, encrypt_loop
    
    # Store results back
    sw s0, 0(a0)        # v[0] = v0
    sw s1, 4(a0)        # v[1] = v1
    
    # Restore registers
    ld s0, 24(sp)
    ld s1, 16(sp)
    ld s2, 8(sp)
    ld s3, 0(sp)
    addi sp, sp, 32
    
    ret

