#!/bin/bash

# ----------------------------
# Build script for Proyecto1Arqui
# ----------------------------

# Añadir toolchain local al PATH
export PATH="$(pwd)/riscv/bin:$PATH"

# Verificar que el compilador existe
if ! command -v riscv32-unknown-elf-gcc &> /dev/null
then
    echo "❌ Error: riscv32-unknown-elf-gcc no se encuentra en ./riscv/bin"
    exit 1
fi

echo "🔨 Building Proyecto1Arqui (C + Assembly)..."
riscv32-unknown-elf-gcc --version

# Flags comunes
CFLAGS="-march=rv32im -mabi=ilp32 -nostdlib -ffreestanding -g3 -gdwarf-4"

# Compilar C principal
riscv32-unknown-elf-gcc $CFLAGS -c main.c -o main.o
if [ $? -ne 0 ]; then
    echo "❌ C compilation failed"
    exit 1
fi

# Compilar startup
riscv32-unknown-elf-gcc $CFLAGS -c startup.s -o startup.o
if [ $? -ne 0 ]; then
    echo "❌ Startup assembly compilation failed"
    exit 1
fi

# Compilar TEA encrypt
riscv32-unknown-elf-gcc $CFLAGS -c asm/tea_encrypt_asm.s -o tea_encrypt_asm.o
if [ $? -ne 0 ]; then
    echo "❌ tea_encrypt_asm compilation failed"
    exit 1
fi

# Compilar TEA decrypt
riscv32-unknown-elf-gcc $CFLAGS -c asm/tea_decrypt_asm.s -o tea_decrypt_asm.o
if [ $? -ne 0 ]; then
    echo "❌ tea_decrypt_asm compilation failed"
    exit 1
fi

# Linkear todo
riscv32-unknown-elf-gcc $CFLAGS \
    startup.o main.o tea_encrypt_asm.o tea_decrypt_asm.o \
    -T linker.ld \
    -o test.elf

if [ $? -eq 0 ]; then
    echo "✅ Build successful: test.elf created"
    echo "   Object files: main.o, startup.o, tea_encrypt_asm.o, tea_decrypt_asm.o"
else
    echo "❌ Linking failed"
    exit 1
fi
