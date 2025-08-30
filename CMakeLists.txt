cmake_minimum_required(VERSION 3.28)
project(Proyecto1Arqui C ASM)

# ------------------ Configuración de toolchain ------------------
# Cambia la ruta si tu toolchain está en otro lugar
set(TOOLCHAIN_PATH "/workspace/riscv/bin")
set(CMAKE_C_COMPILER "${TOOLCHAIN_PATH}/riscv32-unknown-elf-gcc")
set(CMAKE_ASM_COMPILER "${TOOLCHAIN_PATH}/riscv32-unknown-elf-gcc")

# ------------------ Estándar C y flags ------------------
set(CMAKE_C_STANDARD 11)
# Flags para compilación y debug
set(CMAKE_C_FLAGS "-O2 -g -march=rv32im -mabi=ilp32")
set(CMAKE_ASM_FLAGS "-O2 -g -march=rv32im -mabi=ilp32")

# ------------------ Habilitar lenguaje ASM ------------------
enable_language(ASM)

# ------------------ Archivos fuente ------------------
set(SOURCES
        main.c
        asm/tea_encrypt_asm.s
        asm/tea_decrypt_asm.s
)

# ------------------ Crear ejecutable ------------------
add_executable(test.elf ${SOURCES})

# ------------------ Opcional: imprimir mensaje de compilación ------------------
message(STATUS "Toolchain: ${CMAKE_C_COMPILER}")
message(STATUS "Compilando para RV32IM, ABI ILP32")
