#!/bin/bash

IMAGE_NAME="riscv-project1"
CONTAINER_NAME="riscv-project1-container"

# Detectamos runtime Docker o Podman
if command -v podman >/dev/null 2>&1; then
    CONTAINER_CMD="podman"
else
    CONTAINER_CMD="docker"
fi

# Construimos la imagen
echo "Building container image '$IMAGE_NAME'..."
$CONTAINER_CMD build -t $IMAGE_NAME .

# Corremos el contenedor con el proyecto montado
$CONTAINER_CMD run --rm -it \
    --name $CONTAINER_NAME \
    -v $(pwd):/workspace \
    -w /workspace \
    $IMAGE_NAME /bin/bash -c "\
        echo 'Compilando el proyecto...'; \
        riscv32-unknown-elf-gcc -O2 -march=rv32im -mabi=ilp32 main.c asm/tea_encrypt_asm.s asm/tea_decrypt_asm.s -o test.elf && \
        echo 'Ejecutando QEMU...'; \
        qemu-system-riscv32 -machine virt -nographic -bios none -kernel test.elf -S -gdb tcp::1234"
