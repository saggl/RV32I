MEMORY {
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 0x00010000 /* 64KB */
    RAM   (rwx) : ORIGIN = 0x00010000, LENGTH = 0x00010000 /* 64KB */
}

SECTIONS {
    .text : {
        . = ALIGN(4);
        *(.text)
        *(.text.*)
        . = ALIGN(4);
    } > FLASH

    .rodata : {
        . = ALIGN(4);
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
    } > FLASH

    .data : {
        . = ALIGN(4);
        *(.data)
        *(.data.*)
        . = ALIGN(4);
    } > RAM AT > FLASH

    .bss : {
        . = ALIGN(4);
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
    } > RAM

    _stack = ORIGIN(RAM) + LENGTH(RAM);
}
