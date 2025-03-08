
kernel := build/kernel.bin
iso := build/hello.iso

linker_script := linker.ld
grub_cfg := boot/grub.cfg
assembly_source_files := $(wildcard *.asm)
assembly_object_files := $(patsubst %.asm, build/%.o, $(assembly_source_files))
c_source_files := $(wildcard *.c)
c_object_files := $(patsubst %.c, build/%.o, $(c_source_files))

CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -fno-stack-protector -O1 -Wall -MD -ggdb -m32 -fno-omit-frame-pointer -Werror 

target ?= hello

.PHONY: all clean run iso kernel doc disk

all: $(kernel)

clean:
	rm -r build

qemu: $(iso)
	qemu-system-i386 -cdrom $(iso) -curses -vga std -serial file:serial.log

qemu-nox: $(iso)
	qemu-system-x86_64 -m 128 -cdrom $(iso) -vga std -no-reboot -nographic 

qemu-gdb: $(iso)
	qemu-system-x86_64 -S -m 128 -cdrom $(iso) -curses -vga std -s -serial file:serial.log -no-reboot -no-shutdown -d int,cpu_reset 

.PHONY: qemu-gdb-nox
qemu-gdb-nox: $(iso)
	qemu-system-x86_64 -S -m 128 -cdrom $(iso) -vga std -s -serial file:serial.log -no-reboot -no-shutdown -d int,cpu_reset -nographic

iso: $(iso)
	@echo "Done"

$(iso): $(kernel) $(grub_cfg)
	@mkdir -p build/isofiles/boot/grub
	cp $(kernel) build/isofiles/boot/kernel.bin
	cp $(grub_cfg) build/isofiles/boot/grub
	grub2-mkrescue -d /home/cs5460/grub/lib/grub/i386-pc -o $(iso) build/isofiles #2> /dev/null
	@rm -r build/isofiles

$(kernel): $(c_object_files) $(assembly_object_files) $(linker_script)
	ld -m elf_i386  -T $(linker_script) -o $(kernel) $(assembly_object_files) $(c_object_files)

# compile C files
build/%.o: %.c
	@mkdir -p $(shell dirname $@)
	gcc $(CFLAGS) -c $< -o $@

# compile assembly files
build/%.o: %.asm
	@mkdir -p $(shell dirname $@)
	nasm -felf32 $< -o $@


CFLAGS = -fno-pic -static -fno-builtin -fno-strict-aliasing -O1 -Wall -MD -ggdb -m32 -fno-omit-frame-pointer -Werror -nostdlib -fno-stack-protector

do-boot:
	gcc -c main.c -o main.o $(CFLAGS)
	gcc -c console.c -o console.o $(CFLAGS)
	nasm -f elf32 multiboot_header.asm
	nasm -f elf32 boot.asm
	ld -m elf_i386 -T linker.ld -o kernel.bin multiboot_header.o boot.o main.o console.o
	mkdir -p build/isofiles/boot/grub/
	cp boot/grub.cfg build/isofiles/boot/grub/grub.cfg
	cp kernel.bin build/isofiles/boot/
	grub2-mkrescue -d /home/cs5460/grub/lib/grub/i386-pc -o hello.iso build/isofiles
	qemu-system-x86_64 -cdrom hello.iso -vga std -no-reboot -nographic 

ziggy:
	zig cc -target x86-freestanding -mcpu=i386 -c asm_lib.s -o asm_lib.o -fPIC
	zig cc -target x86-freestanding -mcpu=i386 -I. -c main.zig -o main.o -fno-sanitize=all -ffreestanding -fno-stack-check -Drelease-fast -fPIC
	zig cc -target x86-freestanding -mcpu=i386 -I. -c console.zig -o console.o -fno-sanitize=all -ffreestanding -fno-stack-check -Drelease-fast -fPIC
	zig cc -target x86-freestanding -mcpu=i386 -I. -c string.zig -o string.o -fno-sanitize=all -fPIC
	nasm -f elf32 multiboot_header.asm -o multiboot_header.o
	nasm -f elf32 boot.asm -o boot.o
	x86_64-elf-ld -m elf_i386 -T linker.ld -o kernel.bin multiboot_header.o boot.o main.o console.o asm_lib.o string.o
	mkdir -p build/isofiles/boot/grub/
	cp boot/grub.cfg build/isofiles/boot/grub/grub.cfg
	cp kernel.bin build/isofiles/boot/
	i686-elf-grub-mkrescue -o helloZig.iso build/isofiles