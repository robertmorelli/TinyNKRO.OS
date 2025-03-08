# Compiler and flags for Zig (using native build-obj)
ZIG            = zig build-obj
TARGET_FLAGS   = -target x86-freestanding -mcpu=i386
COMMON_FLAGS   = -fPIC
INCLUDE_FLAGS  = -I.
ZIG_EXTRA_FLAGS= -fno-stack-check -Drelease-fast

# Linker and flags
LD       = x86_64-elf-ld
LD_FLAGS = -m elf_i386 -T linker.ld -o kernel.bin

# GRUB rescue tool
GRUB_MKRESCUE = i686-elf-grub-mkrescue

# sources
ASM_SRCS := asm_lib.s multiboot_header.s boot.s
ZIG_SRCS := main.zig pagetables.zig console.zig string.zig

%.o: %.s
	$(ZIG) $(TARGET_FLAGS) $< $(COMMON_FLAGS)
%.o: %.zig
	$(ZIG) $(TARGET_FLAGS) $(INCLUDE_FLAGS) $< $(ZIG_EXTRA_FLAGS) $(COMMON_FLAGS)

ziggy: $(ASM_SRCS:.s=.o) $(ZIG_SRCS:.zig=.o)
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