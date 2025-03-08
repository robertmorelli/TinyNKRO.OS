# Compiler and flags for Zig (using native build-obj)
ZIG            = zig build-obj
TARGET_FLAGS   = -target x86-freestanding -mcpu=i386
COMMON_FLAGS   = -fPIC
INCLUDE_FLAGS  = -I.
ZIG_EXTRA_FLAGS= -fno-stack-check -Drelease-fast

# Assembler (NASM) and flags for .asm files
NASM           = nasm
NASM_FLAGS     = -f elf32

# Linker and flags
LD       = x86_64-elf-ld
LD_FLAGS = -m elf_i386 -T linker.ld -o kernel.bin

# GRUB rescue tool
GRUB_MKRESCUE = i686-elf-grub-mkrescue

ziggy:
	make clean
	# Compile assembly library (GAS assembly) using Zig's build-obj
	$(ZIG) $(TARGET_FLAGS) asm_lib.s $(COMMON_FLAGS)

	# Compile Zig sources using Zig's native build-obj
	$(ZIG) $(TARGET_FLAGS) $(INCLUDE_FLAGS) main.zig $(ZIG_EXTRA_FLAGS) $(COMMON_FLAGS)
	$(ZIG) $(TARGET_FLAGS) $(INCLUDE_FLAGS) console.zig $(ZIG_EXTRA_FLAGS) $(COMMON_FLAGS)
	$(ZIG) $(TARGET_FLAGS) $(INCLUDE_FLAGS) string.zig $(ZIG_EXTRA_FLAGS) $(COMMON_FLAGS)

	# Assemble NASM sources (.asm)
	$(NASM) $(NASM_FLAGS) multiboot_header.asm -o multiboot_header.o
	$(NASM) $(NASM_FLAGS) boot.asm -o boot.o

	# Link the kernel binary
	$(LD) $(LD_FLAGS) multiboot_header.o boot.o main.o console.o string.o asm_lib.o

	# Prepare ISO structure and copy files
	mkdir -p build/isofiles/boot/grub/
	cp boot/grub.cfg build/isofiles/boot/grub/grub.cfg
	cp kernel.bin build/isofiles/boot/

	# Create bootable ISO image
	$(GRUB_MKRESCUE) -o ziggy.iso build/isofiles

	# Run in QEMU (optional)
	# qemu-system-x86_64 -cdrom ziggy.iso -vga std -no-reboot -nographic
clean:
	rm -rf build
	rm -f *.o
	rm -f *.bin
	rm -f *.iso