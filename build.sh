#!/bin/bash

# Build script for Proyecto1Arqui (C + Assembly, RV64)
echo "🔨 Building Proyecto1Arqui (RV64)..."

# Flags comunes
CFLAGS="-march=rv64im -mabi=lp64 -mcmodel=medany -nostdlib -ffreestanding -fno-pic -fno-pie -g3 -gdwarf-4"

# Compile C source
riscv64-unknown-elf-gcc $CFLAGS -c main.c -o main.o
if [ $? -ne 0 ]; then
    echo "❌ C compilation failed"
    exit 1
fi

# Compile startup
riscv64-unknown-elf-gcc $CFLAGS -c startup.s -o startup.o
if [ $? -ne 0 ]; then
    echo "❌ Startup compilation failed"
    exit 1
fi

# Compile TEA encrypt
riscv64-unknown-elf-gcc $CFLAGS -c asm/tea_encrypt_asm.s -o tea_encrypt_asm.o
if [ $? -ne 0 ]; then
    echo "❌ tea_encrypt_asm compilation failed"
    exit 1
fi

# Compile TEA decrypt
riscv64-unknown-elf-gcc $CFLAGS -c asm/tea_decrypt_asm.s -o tea_decrypt_asm.o
if [ $? -ne 0 ]; then
    echo "❌ tea_decrypt_asm compilation failed"
    exit 1
fi

# Link everything
riscv64-unknown-elf-gcc $CFLAGS startup.o main.o tea_encrypt_asm.o tea_decrypt_asm.o -T linker.ld -o test.elf


if [ $? -eq 0 ]; then
    echo "✅ Build successful: test.elf created (RV64)"
else
    echo "❌ Linking failed"
    exit 1
fi
