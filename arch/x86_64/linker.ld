OUTPUT_FORMAT("binary")
ENTRY(start_step_two)

SECTIONS
{
    . = 0x7E00;

    .text : AT(0x7E00)
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.bss)
        *(COMMON)
    }

    /DISCARD/ : {
        *(.comment)
        *(.eh_frame)
        *(.note.gnu.property)
    }
}
