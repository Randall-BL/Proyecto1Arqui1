````markdown
# Proyecto TEA Encryption - RISC-V Assembly

Este proyecto implementa el algoritmo de encriptación **TEA (Tiny Encryption Algorithm)** sobre arquitectura **RISC-V**, utilizando una separación entre **driver en C** y **funciones críticas en ensamblador**.  
El desarrollo se probó mediante **QEMU** para emulación y **GDB** para depuración.

## 1. Arquitectura del Software

## Estructura del Proyecto
Proyecto1Arqui1/
├── Dockerfile              # Configuracion del contenedor
├── build.sh               # Script de compilacion
├── main.c                 # Driver principal en C
├── asm
│   ├── tea_encrypt_asm.s  # Funcion de encriptacion en assembly
│   ├── tea_decrypt_asm.s  # Funcion de desencriptacion en assembly
└── README.md              # Este archivo

### Separación por capas
- **C (Driver principal - `main.c`)**
  - Maneja la lógica de entrada/salida.
  - Define las estructuras de datos para bloques y claves.
  - Llama a las funciones en ensamblador mediante interfaces bien definidas.
- **Assembly RISC-V (`asm/tea_encrypt_asm.s`, `asm/tea_decrypt_asm.s`)**
  - Contiene la implementación del algoritmo TEA optimizada a bajo nivel.
  - Garantiza eficiencia en operaciones de 32 bits (sumas, XOR y shifts).

### Interfaces utilizadas
- Se definieron funciones en ensamblador con la convención de llamada estándar de RISC-V:
  - `void tea_encrypt(uint32_t* v, uint32_t* k);`
  - `void tea_decrypt(uint32_t* v, uint32_t* k);`
- Desde C se pasan punteros a bloques de datos y claves.  
- Esto permite una **interoperabilidad transparente** entre C y ensamblador.

### Justificación de diseño
- **Separación de responsabilidades**: C se encarga del control y ensamblador del rendimiento.
- **Facilidad de debugging**: GDB permite depurar tanto a nivel de C como a nivel de ensamblador.
- **Escalabilidad**: El driver en C permite reutilizar el módulo de TEA con diferentes datos sin modificar la parte en bajo nivel.

## 2. Funcionalidades Implementadas

- **Encriptación (encrypt)**  
  Convierte un bloque de 64 bits en un bloque cifrado usando una clave de 128 bits.

- **Desencriptación (decrypt)**  
  Invierte el proceso de encriptación devolviendo el texto plano original.

- **Soporte de múltiples bloques**  
  El driver en C permite procesar vectores de datos, aplicando TEA bloque por bloque.

- **Depuración paso a paso**  
  Uso de breakpoints para inspeccionar ejecución en C y ensamblador.



## 3. Evidencias de Ejecución (GDB y QEMU)

### Ejemplo de ejecución en QEMU
```bash
qemu-system-riscv64 -machine virt -nographic -bios none \
  -kernel test.elf -S -gdb tcp::1234
````

### Conexión desde GDB

gdb
(gdb) target remote localhost:1234
(gdb) break main
(gdb) continue


### Inspección en GDB

* Ejecución paso a paso:

gdb
step
info registers
layout asm


* Verificación de datos en memoria:

```gdb
x/32bx plaintext     # Texto original
x/32bx ciphertext    # Texto encriptado
```

### Evidencia de flujo observado

* El programa entra a `main` en C.
* En `step` se transfiere el control a `tea_encrypt_asm.s`.
* Se observa cómo las operaciones de suma y XOR modifican los registros.
* Al terminar, el mensaje encriptado vuelve a C.
* Se ejecuta `tea_decrypt_asm.s`, verificando que el mensaje original se recupera.



## 4. Discusión de Resultados

* **Correctitud**: El proceso de cifrado y descifrado funciona, devolviendo el mismo mensaje original.
* **Rendimiento**: La implementación en ensamblador optimiza operaciones aritméticas, siendo más rápida que una implementación pura en C.
* **Depuración**: GDB permitió validar cada paso del algoritmo en registros y memoria, lo que confirma la correcta interacción entre capas.
* **Limitaciones**: El proyecto está enfocado en validación académica; no se implementó padding ni modos de operación (CBC, CTR, etc.), por lo que está limitado a bloques exactos de 64 bits.



## 5. Instrucciones de Compilación, Ejecución y Uso

### 1. Construir el contenedor

```bash
docker build -t riscv-project1 .
```

### 2. Ejecutar el contenedor

```bash
docker run --rm -it -v "$(pwd)":/workspace -w /workspace riscv-project1 /bin/bash
```

### 3. Compilar

```bash
./build.sh
```

Esto genera el archivo `test.elf`.

### 4. Ejecutar con QEMU

```bash
qemu-system-riscv64 -machine virt -nographic -bios none \
  -kernel test.elf -S -gdb tcp::1234
```

### 5. Depurar con GDB

En otra terminal:

```bash
docker exec -it riscv-project1-container /bin/bash
cd /workspace
gdb-multiarch test.elf
```

Conectar:

```gdb
target remote localhost:1234
layout regs 
break main
break main.c:126
break main.c:140
break main.c:86
continue
```

### 6. Ejemplo de uso

Dentro de la ejecución se observará:

```
Texto original:    HolaMundo
Texto encriptado:  [bytes cifrados]
Texto desencriptado: HolaMundo
```

---

## Autor

**Randall Bryan Bolaños López**
Proyecto desarrollado para el curso de Arquitectura de Computadores I.
