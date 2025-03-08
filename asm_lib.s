    .globl read_cr0
read_cr0:
    movl %cr0, %eax    # Read CR0 into EAX.
    ret

    .globl write_cr0
write_cr0:
    movl 4(%esp), %eax # Load the argument (val) from the stack.
    movl %eax, %cr0    # Write the value into CR0.
    ret

    .globl write_cr3
write_cr3:
    movl 4(%esp), %eax # Load the argument (val) from the stack.
    movl %eax, %cr3    # Write the value into CR3.
    ret

    .globl out_b
out_b:
    movl 4(%esp), %edx   # Move first argument (port 'a') into EDX.
    movl 8(%esp), %eax   # Move second argument (data 'b') into EAX.
    outb %al, %dx        # Output the low 8 bits (AL) to port in DX.
    ret

    .globl in_b
in_b:
    movl 4(%esp), %edx   # Load the first parameter (port) from the stack into EDX.
    inb %dx, %al         # Read a byte from the port in DX into AL.
    movzbl %al, %eax     # Zero-extend AL into EAX.
    ret                  # Return; the value is in EAX.
    .globl halt
halt:
    # Halt the CPU
    hlt
    ret


    .globl write_gdt
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