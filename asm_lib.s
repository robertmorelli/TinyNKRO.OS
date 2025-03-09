# used in main.zig
    .globl read_cr0 # extern "C" fn read_cr0() u32;
read_cr0:
    movl %cr0, %eax    # Read CR0 into EAX.
    ret


    .globl write_cr0 # extern "C" fn write_cr0(u32) void;
write_cr0:
    movl 4(%esp), %eax # Load the argument (val) from the stack.
    movl %eax, %cr0    # Write the value into CR0.
    ret


    .globl write_cr3 # extern "C" fn write_cr3(u32) void;
write_cr3:
    movl 4(%esp), %eax # Load the argument (val) from the stack.
    movl %eax, %cr3    # Write the value into CR3.
    ret


    .globl halt # extern "C" fn halt() void;
halt:
    # Halt the CPU
    hlt
    ret


    .globl write_gdt # extern "C" fn write_gdt(*u32, i32) void;
write_gdt:
    # Function signature: void write_gdt(p: *segdesc, size: i32)
    # Stack layout in 32-bit System V ABI:
    #   [ebp+8]  -> p (pointer to first GDT entry)
    #   [ebp+12] -> size (in bytes)

    pushl %ebp
    movl  %esp, %ebp
    subl  $8, %esp    # Reserve 8 bytes on the stack to build the GDT pointer

    # pd[0] = size - 1
    movl  12(%ebp), %eax     # load 'size'
    decl  %eax               # size - 1
    movw  %ax, -8(%ebp)      # store low 16 bits at [ebp - 8]

    # pd[1] = p (pointer)
    movl  8(%ebp), %eax      # load 'p'
    movw  %ax, -6(%ebp)      # store low 16 bits of pointer
    shrl  $16, %eax          # shift right to get high 16 bits
    movw  %ax, -4(%ebp)      # store high 16 bits of pointer

    # Load address of our local 6-byte GDT descriptor into EAX
    leal  -8(%ebp), %eax
    lgdt  (%eax)             # Load the GDT

    leave
    ret


    .global print_hello_world # extern "C" fn print_hello_world() void;
print_hello_world:
    movw $0x0248, 0xb8000
    movw $0x0265, 0xb8002
    movw $0x026c, 0xb8004
    movw $0x026c, 0xb8006
    movw $0x026f, 0xb8008
    movw $0x022c, 0xb800a
    movw $0x0220, 0xb800c
    movw $0x0277, 0xb800e
    movw $0x026f, 0xb8010
    movw $0x0272, 0xb8012
    movw $0x026c, 0xb8014
    movw $0x0264, 0xb8016
    movw $0x0221, 0xb8018
    movw $0x0221, 0xb801a
    ret

    # .global render # extern "C" fn render(x: u16, y: u16, d: u16) void;
render:
    movl 4(%esp), %edx      # Load x into EDX.
    movl 8(%esp), %esi      # Load y into EAX.
    movw 12(%esp), %ax     # Load d into AX.

    imul $2, %edx, %edx     # Multiply x by 2.
    imul $0xA0, %esi, %esi  # Multiply y by 0xA0 (160).
    addl %esi, %edx         # Add the y offset to x offset.
    addl $0xb8000, %edx     # Add the base address of VGA memory.

    movw %ax, (%edx)       # Store data d into the VGA memory.
    ret


# used in console.zig
    .globl out_b # extern "C" fn out_b(a: u16, b: u8) void;
out_b:
    movl 4(%esp), %edx   # Move first argument (port 'a') into EDX.
    movl 8(%esp), %eax   # Move second argument (data 'b') into EAX.
    outb %al, %dx        # Output the low 8 bits (AL) to port in DX.
    ret


    .globl in_b # extern "C" fn in_b(a: u16) u8;
in_b:
    movl 4(%esp), %edx   # Load the first parameter (port) from the stack into EDX.
    inb %dx, %al         # Read a byte from the port in DX into AL.
    movzbl %al, %eax     # Zero-extend AL into EAX.
    ret                  # Return; the value is in EAX.

    .globl in_w # extern "C" fn in_b(a: u16) u16;
in_w:
    movl 4(%esp), %edx   # Load the first parameter (port) from the stack into EDX.
    inw %dx, %ax         # Read a byte from the port in DX into AL.
    movzwl %ax, %eax     # Zero-extend AL into EAX.
    ret                  # Return; the value is in EAX.


    .globl micro_delay # extern "C" fn micro_delay() void;
micro_delay:
    nop
    ret