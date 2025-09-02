#include <stdint.h>
#include <stddef.h>

// ------------------ Prototipos de funciones en ensamblador RISC-V ------------------
void tea_encrypt_asm(uint32_t v[2], const uint32_t key[4]);
void tea_decrypt_asm(uint32_t v[2], const uint32_t key[4]);

// ------------------ Funciones de impresión bare-metal ------------------
void print_char(char c) {
    volatile char *uart = (volatile char*)0x10000000;
    *uart = c;
}

char uart_read_char() {
    volatile char *uart = (volatile char*)0x10000000;
    return *uart;   // leer un carácter desde UART
}

void print_hex_digit(uint8_t val) {
    if (val < 10) print_char('0' + val);
    else print_char('A' + (val - 10));
}

void print_uint32_hex(uint32_t val) {
    for (int i = 28; i >= 0; i -= 4) {
        print_hex_digit((val >> i) & 0xF);
    }
}

void print_string(const char* str) {
    while (*str) print_char(*str++);
}

void print_block_bytes(uint32_t block[2]) {
    uint8_t *b = (uint8_t*)block;
    for (int i = 0; i < 8; i++) {
        print_hex_digit(b[i] >> 4);
        print_hex_digit(b[i] & 0xF);
        print_char(' ');
    }
}

// ------------------ Funciones auxiliares ------------------
void my_memcpy(void *dest, const void *src, size_t n) {
    uint8_t *d = (uint8_t*)dest;
    const uint8_t *s = (const uint8_t*)src;
    for (size_t i = 0; i < n; i++) d[i] = s[i];
}

void pad_block(uint8_t *block, size_t len) {
    for (size_t i = len; i < 8; i++) block[i] = 0;
}

size_t my_strlen(const char* str) {
    size_t len = 0;
    while (str[len] != '\0') len++;
    return len;
}

// ------------------ Variables globales ------------------
volatile uint32_t cipher_blocks[10][2];
volatile uint8_t decrypted_text[64];

// ------------------ Mensajes predefinidos ------------------
const char* predefined_texts[] = {
    "ME LLAMO RANDALL",
    "ARQUITECTURA RISC V",
    "HOLA1234",
    "Mensaje de prueba para TEA"
};
const size_t num_texts = sizeof(predefined_texts) / sizeof(predefined_texts[0]);

// ------------------ Función principal ------------------
void main() {
    print_string("=== TEA Bare-metal Example ===\n");
    print_string("Seleccione un mensaje (0-3):\n");

    for (size_t i = 0; i < num_texts; i++) {
        print_char('0' + i);
        print_string(": ");
        print_string(predefined_texts[i]);
        print_string("\n");
    }

    // Leer opción desde UART
    char c = uart_read_char();
    size_t choice = c - '0';
    if (choice >= num_texts) choice = 0; // por seguridad

    // Seleccionar mensaje
    const char* selected_text = predefined_texts[choice];
    size_t text_len = my_strlen(selected_text);

    uint8_t plaintext[64];
    my_memcpy(plaintext, selected_text, text_len);

    uint32_t key[4] = {0x11111111, 0x22222222, 0x33333333, 0x44444444};// <<Keys:  uint32_t key[4] = {0x12345678, 0x9ABCDEF0, 0xFEDCBA98, 0x76543210}
    size_t num_blocks = (text_len + 7) / 8;

    print_string("\nOriginal: ");
    print_string((char*)plaintext);
    print_string("\n\n");

    for (size_t i = 0; i < num_blocks; i++) {
        uint32_t block[2] = {0,0};
        size_t rem = text_len - i*8;

        if (rem >= 8) {
            my_memcpy(block, plaintext + i*8, 8);
        } else {
            my_memcpy(block, plaintext + i*8, rem);
            pad_block((uint8_t*)block, rem);   // << padding aquí
        }

        // ------------------ Antes de cifrar ------------------
        print_string("Bloque original ");
        print_char('0' + i);
        print_string(": ");
        print_block_bytes(block);
        print_string("\n");

        // ------------------ Cifrado ------------------
        print_string("Cifrando bloque ");
        print_char('0' + i);
        print_string("...\n");
        tea_encrypt_asm(block, key);
        cipher_blocks[i][0] = block[0];
        cipher_blocks[i][1] = block[1];

        print_string("Bloque cifrado ");
        print_char('0' + i);
        print_string(": ");
        print_block_bytes(block);
        print_string("\n");

        // ------------------ Descifrado ------------------
        print_string("Descifrando bloque ");
        print_char('0' + i);
        print_string("...\n");
        tea_decrypt_asm(block, key);

        for (size_t j = 0; j < 8 && i*8 + j < text_len; j++) {
            decrypted_text[i*8 + j] = ((uint8_t*)block)[j];
        }

        print_string("Bloque descifrado ");
        print_char('0' + i);
        print_string(": ");
        print_block_bytes(block);
        print_string("\n\n");
    }

    decrypted_text[text_len] = '\0';
    print_string("Mensaje final descifrado: ");
    print_string((char*)decrypted_text);
    print_string("\n");

    // Mantener el programa corriendo
    while (1) {
        __asm__ volatile ("nop");
    }
}
