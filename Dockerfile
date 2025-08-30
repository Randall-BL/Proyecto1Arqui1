# Usamos Ubuntu como base
FROM ubuntu:22.04

# Instalamos dependencias básicas
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    tar \
    gdb-multiarch \
    qemu-system-misc \
    make \
    gcc \
    git \
    && rm -rf /var/lib/apt/lists/*

# Creamos directorio para RISC-V toolchain
RUN mkdir -p /opt/riscv

# Copiamos tu toolchain local al contenedor
COPY riscv32-unknown-elf.gcc-13.2.0.tar.gz /tmp/riscv-toolchain.tar.gz

# Extraemos en /opt/riscv
RUN tar -xvzf /tmp/riscv-toolchain.tar.gz -C /opt/riscv \
    && rm /tmp/riscv-toolchain.tar.gz

# Ajustamos PATH para usar riscv32-unknown-elf-gcc
ENV PATH="/opt/riscv/bin:${PATH}"

# Creamos usuario que ejecute el contenedor
RUN useradd -ms /bin/bash riscv-dev
USER riscv-dev
WORKDIR /home/riscv-dev
