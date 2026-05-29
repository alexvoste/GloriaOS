%ifndef OPCODES_INC
%define OPCODES_INC

BLACK_ON_BLACK equ 0x00
WHITE_ON_BLACK equ 0x07
RED_ON_BLACK   equ 0x04
GREEN_ON_BLACK equ 0x02
BLUE_ON_BLACK  equ 0x01
LIGHT_GRAY_ON_BLACK equ 0x07

ASCII_NULL      equ 0x00
ASCII_BACKSPACE equ 0x08
ASCII_TAB       equ 0x09
ASCII_LF        equ 0x0A
ASCII_CR        equ 0x0D
ASCII_SPACE     equ 0x20
ASCII_QUESTION  equ 0x3F

SCAN_Q      equ 0x10
SCAN_W      equ 0x11
SCAN_E      equ 0x12
SCAN_R      equ 0x13
SCAN_T      equ 0x14
SCAN_Y      equ 0x15
SCAN_U      equ 0x16
SCAN_I      equ 0x17
SCAN_O      equ 0x18
SCAN_P      equ 0x19
SCAN_A      equ 0x1E
SCAN_S      equ 0x1F
SCAN_D      equ 0x20
SCAN_F      equ 0x21
SCAN_G      equ 0x22
SCAN_H      equ 0x23
SCAN_J      equ 0x24
SCAN_K      equ 0x25
SCAN_L      equ 0x26
SCAN_Z      equ 0x2C
SCAN_X      equ 0x2D
SCAN_C      equ 0x2E
SCAN_V      equ 0x2F
SCAN_B      equ 0x30
SCAN_N      equ 0x31
SCAN_M      equ 0x32
SCAN_COMMA  equ 0x33
SCAN_DOT    equ 0x34
SCAN_SLASH  equ 0x35
SCAN_SPACE  equ 0x39
SCAN_ENTER  equ 0x1C
SCAN_BACKSPACE equ 0x0E
SCAN_LSHIFT equ 0x2A
SCAN_RSHIFT equ 0x36

PIC1_COMMAND_PORT equ 0x20
PIC1_DATA_PORT    equ 0x21
PIC2_COMMAND_PORT equ 0xA0
PIC2_DATA_PORT    equ 0xA1
PIC_EOI_COMMAND   equ 0x20

MSR_EFER equ 0xC0000080
EFER_LME_BIT equ 8

CODE_SEG_64 equ 0x08
DATA_SEG_64 equ 0x10

LOG_LEVEL_INFO equ 0
LOG_LEVEL_ERROR equ 1
LOG_LEVEL_DEBUG equ 2

%endif