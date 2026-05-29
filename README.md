# GloriaOS

GloriaOS is a minimalist x86\_64 hobby operating system written in pure Assembly (NASM) with an isolated compiler toolchain integration. The kernel boots via Multiboot, transitions from 32-bit protected mode into 64-bit long mode with paging enabled using 2MB huge pages, initializes the Interrupt Descriptor Table (IDT), remaps the PIC, and processes keyboard interrupts (IRQ1) natively.

---

## Features

**Bootloader**
Multiboot 1 compliant. Initializes the stack and performs CPU capability verification via CPUID, including Long Mode compatibility checks.

**Memory Management**
Custom 4-level paging scheme (PML4 → PDPT → PD) identity-mapping the first 1 GB of physical memory using 2MB huge pages.

**Interrupt Handling**
Custom 64-bit Interrupt Descriptor Table (IDT). Hardware interrupts are resolved by remapping the dual 8259 PICs.

**Device Drivers**
Low-level PS/2 keyboard driver handling IRQ1 interrupts with a custom scan-code translation table (US QWERTY layout) mapped directly to VGA text-mode video memory at `0xB8000`.

---

## Project Structure

```
arch/
└── x86_64/
    ├── boot.asm      # Bootloader, page tables, GDT, IDT, ISR definitions
    └── linker.ld     # Linker script targeting elf_i386
src/
└── main.glo          # Isolated compiler entry point (stub)
build/                # Intermediate object files
Makefile              # Build automation
kernel.bin            # Output kernel image
```

---

## Prerequisites

| Tool | Purpose |
|---|---|
| `nasm` | Assembler |
| `ld`, `objcopy` | Linker and binary utilities (i386/x86\_64 targets) |
| `go` | Required to satisfy the legacy Gloria compilation step |
| `qemu-system-x86_64` | Emulator for running the kernel |

### Debian / Ubuntu

```bash
sudo apt update
sudo apt install build-essential nasm qemu-system-x86_64 golang-go
```

### Arch Linux

```bash
sudo pacman -S base-devel nasm qemu go
```

---

## Build and Run

The build process compiles the legacy high-level stub, assembles the 32/64-bit bootloader, wraps the compiler payload into an ELF object, and links everything into a final flat bootable binary.

**Compile the kernel:**

```bash
make
```

**Launch in QEMU:**

```bash
make run
```

**Clean build artifacts:**

```bash
make clean
```

---

## Technical Reference

**Video Memory**
Text mode base address: `0xB8000`. Character cell format: `[ Attribute Byte (8-bit) | ASCII Character (8-bit) ]`.

**Keyboard I/O**
Scan codes are read from PS/2 controller data port `0x60` on IRQ1, which maps to interrupt vector `0x21`.

**Segment Selectors**
Code Segment (CS) selector is defined as `0x08` within the 64-bit Global Descriptor Table.

Author: AlexVoste
