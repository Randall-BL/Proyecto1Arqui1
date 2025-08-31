# TEA Encryption function in RISC-V64 assembly
# void tea_encrypt_asm(uint32_t *data, uint32_t *key)
# 
# Parameters:
# a0: pointer to data (64-bit block: data[0], data[1])
# a1: pointer to key (128-bit key: key[0], key[1], key[2], key[3])
#
# TEA constants:
# delta = 0x9E3779B9
# rounds = 32

.text
.globl tea_encrypt_asm
.type tea_encrypt_asm, @function

tea_encrypt_asm:
    # Save callee-saved registers
    addi sp, sp, -32
    sd s0, 0(sp)
    sd s1, 8(sp)
    sd s2, 16(sp)
    sd s3, 24(sp)
    
    # Load data[0] and data[1] (32-bit values)
    lw s0, 0(a0)    # s0 = data[0] (left)
    lw s1, 4(a0)    # s1 = data[1] (right)
    
    # Load key values (32-bit each)
    lw t0, 0(a1)    # t0 = key[0]
    lw t1, 4(a1)    # t1 = key[1]
    lw t2, 8(a1)    # t2 = key[2]
    lw t3, 12(a1)   # t3 = key[3]
    
    # Initialize sum = 0
    li s2, 0        # s2 = sum
    
    # Load delta constant
    lui s3, 0x9E377  # Load upper 20 bits of 0x9E3779B9
    addi s3, s3, 0x7B9  # Add lower 12 bits (sign-extended)
    # Note: We need to handle this carefully due to sign extension
    lui s3, 0x9E378
    addi s3, s3, -0x647  # 0x9E3779B9 = 0x9E378000 - 0x647
    
    # Counter for 32 rounds
    li t4, 32       # t4 = round counter
    
encrypt_loop:
    # sum += delta
    add s2, s2, s3
    
    # temp = (right << 4) + key[0]
    slli t5, s1, 4      # t5 = right << 4
    add t5, t5, t0      # t5 = (right << 4) + key[0]
    
    # temp2 = right + sum
    add t6, s1, s2      # t6 = right + sum
    
    # temp3 = (right >> 5) + key[1]
    srli a2, s1, 5      # a2 = right >> 5
    add a2, a2, t1      # a2 = (right >> 5) + key[1]
    
    # left += (temp ^ temp2) ^ temp3
    xor a3, t5, t6      # a3 = temp ^ temp2
    xor a3, a3, a2      # a3 = (temp ^ temp2) ^ temp3
    add s0, s0, a3      # left += result
    
    # temp = (left << 4) + key[2]
    slli t5, s0, 4      # t5 = left << 4
    add t5, t5, t2      # t5 = (left << 4) + key[2]
    
    # temp2 = left + sum
    add t6, s0, s2      # t6 = left + sum
    
    # temp3 = (left >> 5) + key[3]
    srli a2, s0, 5      # a2 = left >> 5
    add a2, a2, t3      # a2 = (left >> 5) + key[3]
    
    # right += (temp ^ temp2) ^ temp3
    xor a3, t5, t6      # a3 = temp ^ temp2
    xor a3, a3, a2      # a3 = (temp ^ temp2) ^ temp3
    add s1, s1, a3      # right += result
    
    # Decrement counter and loop
    addi t4, t4, -1
    bnez t4, encrypt_loop
    
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
