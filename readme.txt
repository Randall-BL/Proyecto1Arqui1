# Proyecto TEA Encryption - RISC-V Assembly

Este proyecto implementa el algoritmo de encriptación **TEA (Tiny Encryption Algorithm)** utilizando una combinación de código C como driver principal y funciones de encriptación/desencriptación implementadas en ensamblador RISC-V.

## Descripción

El proyecto consiste en:
- **Driver en C**: Maneja las funciones principales y la interfaz del programa
- **Funciones en Assembly RISC-V**: Implementan los algoritmos de encriptación y desencriptación TEA
- **Entorno de desarrollo**: Utiliza Docker, QEMU y GDB para compilación, emulación y debugging

## Estructura del Proyecto

```
Proyecto1Arqui1/
├── Dockerfile              # Configuracion del contenedor
├── build.sh               # Script de compilacion
├── main.c                 # Driver principal en C
├── asm
│   ├── tea_encrypt_asm.s  # Funcion de encriptacion en assembly
│   ├── tea_decrypt_asm.s  # Funcion de desencriptacion en assembly
└── README.md              # Este archivo
```

## Prerrequisitos

- Docker instalado en el sistema
- WSL2 (si usas Windows) o sistema Linux/macOS
- Tener instalado las herramientas necesarias para ejecutar codigo en C.

## Configuración del Entorno

### 1. Construcción del Contenedor Docker

```bash

Navegar hacia la carpeta donde se tiene clonado el repositorio, por ejemplo: 
cd /mnt/c/Users/YITAN/OneDrive/Escritorio/Proyecto1Arqui1

Luego ejecutar: 
docker build -t riscv-project1 .
```

### 2. Ejecución del Contenedor

```bash
docker run --rm -it \
    --name riscv-project1-container \
    -v "$(pwd)":/workspace \
    -w /workspace \
    riscv-project1 /bin/bash
```

### 3. Compilación del Proyecto

Dentro del contenedor:

```bash
./build.sh
```

## Ejecución y Debugging

### Terminal 1: Iniciar QEMU

En el contenedor Docker:

```bash
qemu-system-riscv64 -machine virt -nographic -bios none -kernel test.elf -S -gdb tcp::1234
```

**Opciones utilizadas:**
- `-machine virt`: Utiliza la máquina virtual genérica de RISC-V
- `-nographic`: Modo sin interfaz gráfica
- `-bios none`: Sin BIOS
- `-kernel test.elf`: Carga nuestro ejecutable compilado
- `-S`: Pausa la ejecución al inicio (para debugging)
- `-gdb tcp::1234`: Habilita servidor GDB en puerto 1234

### Terminal 2: Debugging con GDB

Abre una nueva terminal y conecta al contenedor:

```bash
docker exec -it riscv-project1-container /bin/bash
cd /workspace
```

Inicia GDB:

```bash
gdb-multiarch test.elf
```

### Comandos de Debugging

#### Configuración Inicial de GDB

```gdb
target remote localhost:1234
layout regs 
break main
break main.c:126
break main.c:140
break main.c:86
continue
```
### Comportamiento esperado

Una vez ejecuta el continue, se puede aapreciar el codigo de C siendo ejecutado, de la misma forma, se puede ir ejecutando "step" para verlo,
la recomendacion es que cuando llegue a cada break point, se ejecute STEP, para ingresar al codigo de ensamblador y verificar como funciona, luego se 
puede seguir ejecutando step hasta que termine el proceso de encriptacion, o se puede ejecutar FINISH, para terminarlo antes, una vez en el codigo de C, se ejecuta Continue, 
para que llame a la funcion de desencriptar, se ingresa con STEP, y se ejecuta FINISH, esto se repite cada vez, hasta que en la terminal con QEMU, se muestre el mensaje decodificado.

#### Comandos de Inspección Durante la Ejecución

```gdb
# Ejecución paso a paso
step                    # Ejecutar siguiente instrucción

# Inspección de registros y memoria
info registers          # Ver valores de registros
x/32bx plaintext       # Ver memoria del texto plano
x/32bx ciphertext      # Ver memoria cifrada
x/2x cipher_blocks[0]  # Ver primer bloque cifrado

# Cambio de vista en GDB
layout asm             # Vista ensamblador
layout regs            # Vista registros

# Control de ejecución
continue               # Continuar hasta siguiente breakpoint

# Salir
monitor quit           # Salir de QEMU
```

## Algoritmo TEA

**TEA (Tiny Encryption Algorithm)** es un algoritmo de cifrado por bloques que:
- Opera sobre bloques de 64 bits
- Utiliza una clave de 128 bits
- Ejecuta 32 rondas de encriptación
- Es especialmente eficiente en arquitecturas de 32 bits

### Características de la Implementación

- **Encriptación**: Función implementada en `encrypt.s`
- **Desencriptación**: Función implementada en `decrypt.s` 
- **Interfaz**: Controlada desde el driver en C (`main.c`)

## Breakpoints Importantes

Los breakpoints configurados permiten inspeccionar:

- **main.c:86**: Inicio del proceso de encriptación
- **main.c:126**: Punto medio del procesamiento
- **main.c:140**: Finalización del proceso

## Comandos de Memoria Útiles

```gdb
# Ver contenido en formato hexadecimal
x/NTx address    # N=cantidad, T=tamaño (b=byte, w=word, g=giant)

# Ejemplos específicos
x/32bx plaintext       # 32 bytes del texto plano
x/32bx ciphertext      # 32 bytes del texto cifrado
x/4wx cipher_blocks    # 4 words del bloque cifrado
```

## Flujo de Ejecución

1. **Compilación**: `build.sh` genera `test.elf`
2. **Emulación**: QEMU carga el ejecutable en arquitectura RISC-V
3. **Debugging**: GDB permite inspeccionar paso a paso la ejecución
4. **Procesamiento**: 
   - El driver C prepara los datos
   - Las funciones assembly realizan encriptación/desencriptación
   - Se verifica la correctitud del resultado

## Troubleshooting

### Error de Conexión GDB
Si GDB no puede conectar:
```bash
# Verificar que QEMU esté corriendo con -S -gdb tcp::1234
# Asegurarse de que el puerto 1234 esté disponible
```

### Error de Compilación
```bash
# Verificar que el contenedor tenga las herramientas necesarias
# Revisar permisos de build.sh
chmod +x build.sh
```

### QEMU No Responde
```bash
# Usar Ctrl+A, X para salir de QEMU
# O desde GDB: monitor quit
```

## Notas Adicionales

- El proyecto utiliza la arquitectura RISC-V de 64 bits
- Los breakpoints pueden ajustarse según las necesidades de debugging
- El layout de GDB puede cambiarse entre `regs`, `asm`, `src` según preferencia
- Para debugging avanzado, considera usar `watch` para variables específicas

## Autor
Randall Bryan Bolaños López
Proyecto desarrollado para el curso de Arquitectura de Computadores I.