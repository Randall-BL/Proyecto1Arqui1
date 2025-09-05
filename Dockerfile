# Imagen base: Ubuntu 22.04
FROM ubuntu:22.04

# Instalamos dependencias necesarias
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-riscv64-unknown-elf \
    gdb-multiarch \
    qemu-system-misc \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

# Creamos usuario normal (para no trabajar como root)
RUN useradd -ms /bin/bash riscv-dev
USER riscv-dev
WORKDIR /home/riscv-dev

# Mensaje por defecto al iniciar el contenedor
CMD ["/bin/bash"]
