
MEMORY {
    mem : ORIGIN = 0x80000000, LENGTH = 0x00100000
}

SECTIONS {
    .memory : {
        . = 0x80000000;
        *(.text.init);
        *(.*text*);
        *(.*data*);
        *(.*bss*);
    } > mem
}

