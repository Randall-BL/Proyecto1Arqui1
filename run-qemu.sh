#!/bin/bash

qemu-system-riscv32 \
    -machine virt \
    -nographic \
    -bios none \
    -kernel test.elf \
    -s -S
