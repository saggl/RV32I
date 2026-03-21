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
        _data_start = .;
        *(.data)
        *(.data.*)
        . = ALIGN(4);
        _data_end = .;
    } > RAM AT > FLASH
    _data_lma = LOADADDR(.data);

    .bss : {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > RAM

    _stack = ORIGIN(RAM) + LENGTH(RAM);
}
