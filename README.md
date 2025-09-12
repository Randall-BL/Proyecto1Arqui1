````markdown
# Proyecto TEA Encryption - RISC-V Assembly

Este proyecto implementa el algoritmo de encriptación **TEA (Tiny Encryption Algorithm)** sobre arquitectura **RISC-V**, utilizando una separación entre **driver en C** y **funciones críticas en ensamblador**.  
El desarrollo se probó mediante **QEMU** para emulación y **GDB** para depuración.

---

## 1. Arquitectura del Software

### Estructura del Proyecto
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

---

## 2. Funcionalidades Implementadas

- **Encriptación (encrypt)**  
  Convierte un bloque de 64 bits en un bloque cifrado usando una clave de 128 bits.

- **Desencriptación (decrypt)**  
  Invierte el proceso de encriptación devolviendo el texto plano original.

- **Soporte de múltiples bloques**  
  El driver en C permite procesar vectores de datos, aplicando TEA bloque por bloque.

- **Depuración paso a paso**  
  Uso de breakpoints para inspeccionar ejecución en C y ensamblador.

---

## 3. Evidencias de Ejecución (GDB y QEMU)

### Ejemplo de ejecución en QEMU
```bash
qemu-system-riscv64 -machine virt -nographic -bios none \
  -kernel test.elf -S -gdb tcp::1234
````

### Conexión desde GDB

```gdb
(gdb) target remote localhost:1234
(gdb) break main
(gdb) break main.c:86: Se elige las palabras a encriptar
(gdb) break main.c:126: Se llama a encriptar en asm
(gdb) break main.c:140: Se llama a desencriptar
(gdb) continue
```

### Inspección en GDB

* Ejecución paso a paso:

```gdb
step
info registers
layout asm
```

### Evidencia de flujo observado

* El programa entra a `main` en C.
* En `step` se transfiere el control a `tea_encrypt_asm.s`.
* Se observa cómo las operaciones de suma y XOR modifican los registros.
* Al terminar, el mensaje encriptado vuelve a C.
* Se ejecuta `tea_decrypt_asm.s`, verificando que el mensaje original se recupera.

---

## 4. Discusión de Resultados

* **Correctitud**: El proceso de cifrado y descifrado funciona, devolviendo el mismo mensaje original.
* **Rendimiento**: La implementación en ensamblador optimiza operaciones aritméticas, siendo más rápida que una implementación pura en C. El padding funciona correctamente.
* **Depuración**: GDB permitió validar cada paso del algoritmo en registros y memoria, lo que confirma la correcta interacción entre capas.
* **Mejoras**: Se implementó un menú para elegir la palabra a decodificar, que funciona correctamente.
---

## 5. Técnica y Detalles de Implementación

### Descripción de la solución

El proyecto combina **C** como lenguaje de alto nivel para la gestión del flujo del programa, y **RISC-V Assembly** para las operaciones de bajo nivel del algoritmo TEA.
La técnica usada fue:

* Implementar en **assembly** las operaciones críticas (sumas, XOR, corrimientos de bits).
* Usar **C** para el control de bloques, la preparación de datos y la interacción con el entorno de pruebas.

### Diagrama de arquitectura del sistema

```
+---------------------------+
|         Driver C          |
|  - Entrada/Salida         |
|  - Control de flujo       |
|  - Llamadas a ASM         |
+-------------+-------------+
              |
              v
+---------------------------+
|     RISC-V Assembly       |
|  - tea_encrypt_asm.s      |
|  - tea_decrypt_asm.s      |
|  Operaciones TEA          |
+-------------+-------------+
              |
              v
+---------------------------+
|        Hardware sim       |
|    QEMU + GDB Debugging   |
+---------------------------+
```

### Decisiones de diseño

* **Mantener C como capa superior** para simplificar pruebas y extensibilidad.
* **Pasar punteros a bloques de memoria** en lugar de valores por copia, para optimizar el manejo de datos.
* **Utilizar registros de 32 bits** en ensamblador, alineados al diseño original de TEA.
* **Depurar con QEMU+GDB** para observar el flujo desde alto nivel hasta ensamblador.

### Resultados generales

* El sistema logró encriptar y desencriptar correctamente bloques de 64 bits.
* Se verificó que la salida de desencriptación coincide con el texto original.
* Se validó el correcto paso de datos entre C y ensamblador.

### Análisis de rendimiento

* El uso de ensamblador redujo la cantidad de instrucciones necesarias frente a una implementación en C puro.
* La ejecución en QEMU mostró tiempos estables incluso con múltiples bloques.
* La eficiencia se debe al uso de operaciones simples (suma, XOR, shift), que son muy rápidas en arquitecturas RISC.

---

## 6. Instrucciones de Compilación, Ejecución y Uso

### 1. Construir el contenedor
Una vez accesado a la dirección del repositorio clonado, se debe construir el docker.

```bash
docker build -t riscv-project1 .
```

### 2. Ejecutar el contenedor

```bash
docker run --rm -it \
    --name riscv-project1-container \
    -v "$(pwd)":/workspace \
    -w /workspace \
    riscv-project1 /bin/bash
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
break main.c:86    #Se elige las palabras a encriptar
break main.c:126   #Se llama a encriptar en asm
break main.c:140   #Se llama a desencriptar
continue
```

### 6. Ejemplo de uso
De ser necesario, se pueden cambiar las Keys, en la linea 97 del codigo en C. Simplemente con reemplazar las claves a las necesarias.
A la hora de hacer todos los breaks, en el momento del break main.c86, se puede elegir la palabra a desencriptar,esto se hace marcando en la terminal de qemu, la opcion con los 
numeros del teclado, según las opciones, una vez presionadas, se puede regresar a la terminal del gdb, escribiendo de nuevo continue para seguir con el proceso de encriptar y desencriptar, de igual manera, se puede usar STEP para ingresar a la parte del codigo de asm, y revisar las rondas de ecriptacion y desencriptacion. 

Resultados esperados en caso de usar la palabra HOLA1234:

```
=== TEA Bare-metal Example ===
Seleccione un mensaje (0-3):
0: ME LLAMO RANDALL
1: ARQUITECTURA RISC V
2: HOLA1234
3: Mensaje de prueba para TEA

Original: HOLA1234

Bloque original 0: 48 4F 4C 41 31 32 33 34
Cifrando bloque 0...
Bloque cifrado 0: 14 57 B0 AB 3E D0 A3 61
Descifrando bloque 0...
Bloque descifrado 0: 48 4F 4C 41 31 32 33 34

Mensaje final descifrado: HOLA1234

```

En caso de usar Mensaje de prueba para TEA

```
=== TEA Bare-metal Example ===
Seleccione un mensaje (0-3):
0: ME LLAMO RANDALL
1: ARQUITECTURA RISC V
2: HOLA1234
3: Mensaje de prueba para TEA

Original: Mensaje de prueba para TEA

Bloque original 0: 4D 65 6E 73 61 6A 65 20
Cifrando bloque 0...
Bloque cifrado 0: B9 20 31 81 48 62 38 B0
Descifrando bloque 0...
Bloque descifrado 0: 4D 65 6E 73 61 6A 65 20

Bloque original 1: 64 65 20 70 72 75 65 62
Cifrando bloque 1...
Bloque cifrado 1: 40 A9 EC F1 A8 BE 9D BD
Descifrando bloque 1...
Bloque descifrado 1: 64 65 20 70 72 75 65 62

Bloque original 2: 61 20 70 61 72 61 20 54
Cifrando bloque 2...
Bloque cifrado 2: 70 2A 6A E6 CE A3 B8 09
Descifrando bloque 2...
Bloque descifrado 2: 61 20 70 61 72 61 20 54

Bloque original 3: 45 41 00 00 00 00 00 00
Cifrando bloque 3...
Bloque cifrado 3: 8F 1E 38 28 4B 26 F2 B6
Descifrando bloque 3...
Bloque descifrado 3: 45 41 00 00 00 00 00 00

Mensaje final descifrado: Mensaje de prueba para TEA

```



---

## Autor

**Randall Bryan Bolaños López**
Proyecto desarrollado para el curso de Arquitectura de Computadores I.

