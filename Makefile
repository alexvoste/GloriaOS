BOOT_ASM         = ./arch/x86_64/step-one/main-step-one.asm
ENTER_LONG_ASM   = ./arch/x86_64/step-two/enter_long_mode.asm

BOOT_BIN         = ./build/boot.bin
LONG_MODE_BIN    = ./build/enter_long_mode.bin
FINAL_IMG        = ./build/gloria.img

RENDER_SOURCES = ./arch/x86_64/render-engine/put-char.asm \
	./arch/x86_64/render-engine/print-string.asm \
	./arch/x86_64/system/debug_out.asm
	
RENDER_OBJECTS = ./build/put-char.o \
	./build/print-string.o \
	./build/debug_out.o

.PHONY: all clean run

all: $(FINAL_IMG)

$(BOOT_BIN): $(BOOT_ASM)
	@mkdir -p build
	@echo "[+] Assembling MBR (Step One)..."
	nasm -f bin -i./arch/x86_64/step-one/ -i./arch/x86_64/ $(BOOT_ASM) -o $(BOOT_BIN)


$(LONG_MODE_BIN): $(ENTER_LONG_ASM) $(RENDER_SOURCES)
	@mkdir -p build
	@echo "[+] Assembling Long Mode (Step Two)..."
	nasm -f elf64 -DARCH_PC_RELATIVE_VMODE $(ENTER_LONG_ASM) -o ./build/enter_long_mode.o
	@echo "[+] Assembling System, Interrupts, Keyboard and Shell..."
	nasm -f elf64 ./arch/x86_64/system/pic_init.asm -o ./build/pic_init.o
	nasm -f elf64 ./arch/x86_64/interrupt/interrupt.asm -o ./build/interrupt.o
	nasm -f elf64 ./arch/x86_64/user/keyboard.asm -o ./build/keyboard.o
	nasm -f elf64 ./arch/x86_64/user/shell.asm -o ./build/shell.o
	@echo "[+] Assembling Render Engine..."
	@for file in $(RENDER_SOURCES); do \
	obj="./build/$$(basename $$file .asm).o"; \
	nasm -f elf64 -DARCH_PC_RELATIVE_VMODE -i./arch/x86_64/ $$file -o $$obj; \
	done
	@echo "[+] Linking Step Two with strict linker script..."
	ld -m elf_x86_64 -T ./arch/x86_64/linker.ld \
	./build/enter_long_mode.o \
	./build/pic_init.o \
	./build/interrupt.o \
	./build/keyboard.o \
	./build/shell.o \
	$(RENDER_OBJECTS) \
	-o $(LONG_MODE_BIN)


$(FINAL_IMG): $(BOOT_BIN) $(LONG_MODE_BIN)
	@echo "[+] Creating flat disk image..."
	cp $(BOOT_BIN) $(FINAL_IMG)
	cp $(LONG_MODE_BIN) ./build/temp_step2.bin
	truncate -s 32768 ./build/temp_step2.bin
	cat ./build/temp_step2.bin >> $(FINAL_IMG)
	truncate -s 1440k $(FINAL_IMG)
	@echo "[+] Successfully built clean GloriaOS Image (No Go Compiler)!"

run: $(FINAL_IMG)
	@echo "[+] Booting clean image in QEMU..."
	qemu-system-x86_64 -drive format=raw,file=$(FINAL_IMG) -serial stdio -d int,cpu_reset -D qemu-debug.log -no-reboot

clean:
	@echo "[+] Cleaning build directory..."
	rm -rf build

