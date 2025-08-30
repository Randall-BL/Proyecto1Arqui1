#include <stdio.h>
#include <stdint.h>
#include <string.h>

// ------------------ Prototipos de funciones en ensamblador RISC-V ------------------
void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4]);
void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4]);

// ------------------ Helpers en C ------------------
void pad_block(uint8_t *block, size_t len) {
    for (size_t i = len; i < 8; i++)
        block[i] = 0;
}
int main() {
    uint8_t plaintext[] = "Mensaje de prueba para TEA";
    size_t text_len = strlen((char*)plaintext);
    uint32_t key[4] = {0x12345678, 0x9ABCDEF0, 0xFEDCBA98, 0x76543210};

    printf("=== Prueba TEA con ensamblador RISC-V ===\n");
    printf("Texto original: %s\n\n", plaintext);

    size_t num_blocks = (text_len + 7) / 8;
    uint32_t ciphertext[num_blocks][2];

    // ------------------ Cifrado ------------------
    printf("--- Cifrado ---\n");
    for (size_t i = 0; i < num_blocks; i++) {
        uint32_t block[2] = {0, 0};
        size_t rem = text_len - i*8;
        if (rem >= 8) memcpy(block, plaintext + i*8, 8);
        else { memcpy(block, plaintext + i*8, rem); pad_block((uint8_t*)block, rem); }

        tea_encrypt_asm(block, key);      // Llamada a la función en ensamblador
        ciphertext[i][0] = block[0];
        ciphertext[i][1] = block[1];
        printf("Bloque cifrado %zu: %08X %08X\n", i+1, block[0], block[1]);
    }

    // ------------------ Descifrado ------------------
    printf("\n--- Descifrado ---\n");
    uint8_t decrypted[text_len + 1];
    size_t pos = 0;

    for (size_t i = 0; i < num_blocks; i++) {
        uint32_t block[2];
        block[0] = ciphertext[i][0];
        block[1] = ciphertext[i][1];

        tea_decrypt_asm(block, key);      // Llamada a la función en ensamblador

        // Convertir uint32_t a bytes y copiar al array final
        memcpy(decrypted + pos, &block[0], 4);
        pos += 4;
        if (pos < text_len) {
            memcpy(decrypted + pos, &block[1], 4);
            pos += 4;
        }
    }

    decrypted[text_len] = '\0';
    printf("Mensaje descifrado: %s\n", decrypted);

    return 0;
}
