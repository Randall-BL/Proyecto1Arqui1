cd /mnt/c/Users/YITAN/OneDrive/Escritorio/Proyecto1Arqui1

docker build -t riscv-project1 .

docker run --rm -it \
    --name riscv-project1-container \
    -v "$(pwd)":/workspace \
    -w /workspace \
    riscv-project1 /bin/bash


./build.sh


qemu-system-riscv64 -machine virt -nographic -bios none -kernel test.elf -S -gdb tcp::1234




Terminal 2:

docker exec -it riscv-project1-container /bin/bash

cd /workspace

gdb-multiarch test.elf


target remote localhost:1234
layout regs 
break main
break main.c:126
break main.c:140
break main.c:86


break decrypt_break
continue

print block

print decrypted_text



step                  # Ejecutar instrucción
info registers         # Ver valores de registros
x/32bx plaintext       # Ver memoria del texto plano
x/32bx ciphertext      # Ver memoria cifrada
layout asm             # Vista ensamblador
layout regs            # Vista registros
continue               # Continuar hasta siguiente breakpoint
x/2x cipher_blocks[0]  # ver primer bloque cifrado
monitor quit           # Salir de QEMU
