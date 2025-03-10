# used in pagetables.zig
    .globl turn_on_paging # extern "C" fn turn_on_paging() void;
turn_on_paging:
    movl %cr0, %eax
    orl  $0x80000000, %eax
    movl %eax, %cr0
    ret

    .globl write_cr3 # extern "C" fn write_cr3(*pagedir) void;
write_cr3:
    movl 4(%esp), %eax
    movl %eax, %cr3
    ret

    .globl halt # extern "C" fn halt() void;
halt:
    hlt
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


# used in console.zig
    .globl out_b # extern "C" fn out_b(port: u16, data: u8) void;
out_b:
    movl 4(%esp), %edx
    movl 8(%esp), %eax
    outb %al, %dx        # Output the low 8 bits (AL) to port in DX.
    ret


    .globl in_b # extern "C" fn in_b(a: u16) u8;
in_b:
    movl 4(%esp), %edx
    inb %dx, %al         # Read a byte from the port in DX into AL.
    movzbl %al, %eax     # Zero-extend AL into EAX.
    ret


    .globl micro_delay # extern "C" fn micro_delay() void;
micro_delay:
    nop
    ret