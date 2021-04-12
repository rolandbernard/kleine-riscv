
MEMORY {
    mem : ORIGIN = 0x00000000, LENGTH = 0x00018000
}

SECTIONS {
    .memory : {
        . = 0x000000;
        *(.text.init);
        *(.text*);
        *(.data*);
        *(.bss*);
    } > mem
}

