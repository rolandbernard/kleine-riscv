
#define EXIT_ADDRESS 0x11000000U

#define ASSERT(NUM, COND) { if (!(COND)) { leave(NUM); } }

void main();
void leave(int code);

__asm__ (".section .text.init");
void _start() {
    __asm__ ("li sp, 0x80100000");
    main();
    leave(1);
}

__asm__ (".section .text");
void leave(int code) {
    for (;;) {
        (*(volatile int*)EXIT_ADDRESS) = code;
    }
}

#include "c_support.h"

