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
echo "🛠 Building container image '$IMAGE_NAME'..."
$CONTAINER_CMD build -t $IMAGE_NAME .

# Corremos el contenedor con el proyecto montado
$CONTAINER_CMD run --rm -it \
    --name $CONTAINER_NAME \
    -v "$(pwd)":/workspace \
    -w /workspace \
    $IMAGE_NAME /bin/bash -c "\
        echo '🔨 Compilando el proyecto RV64...'; \
        riscv64-unknown-elf-gcc -O2 -march=rv64im -mabi=lp64 -mcmodel=medany -nostdlib -ffreestanding -g3 -gdwarf-4 \
            main.c startup.s asm/tea_encrypt_asm.s asm/tea_decrypt_asm.s -T linker.ld -o test.elf && \
        if [ \$? -eq 0 ]; then \
            echo '✅ Build successful: test.elf creado'; \
            echo '🖥 Ejecutando QEMU RV64...'; \
            qemu-system-riscv64 -machine virt -nographic -bios none -kernel test.elf -S -gdb tcp::1234; \
        else \
            echo '❌ Build failed'; \
            exit 1; \
        fi"
